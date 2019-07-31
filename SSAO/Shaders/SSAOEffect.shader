Shader "Moose_Yang/SSAOEffect"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "black" {}
	}

	CGINCLUDE
	#include "UnityCG.cginc"
	
	struct appdata
	{
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
	};
	
	struct v2f
	{
		float2 uv : TEXCOORD0;
		float4 vertex : SV_POSITION;
		float3 viewRay : TEXCOORD1;
	};
	
	#define MAX_SAMPLE_KERNEL_COUNT 32

	sampler2D _MainTex;
	float4 _MainTex_TexelSize;
	sampler2D _AOTex;
	sampler2D _CameraDepthNormalsTexture;

	float4x4 _InverseProjectionMatrix;

	float _DepthBiasValue;
	float4 _SampleKernelArray[MAX_SAMPLE_KERNEL_COUNT];
	float _SampleKernelCount;
	float _AOStrength;
	float _SampleKeneralRadius;
	float4 _BlurRadius;
	float _BilaterFilterFactor;
	
	
	float3 GetNormal(float2 uv)
	{
		float4 cdn = tex2D(_CameraDepthNormalsTexture, uv);
		return DecodeViewNormalStereo(cdn);
	}
	
	half CompareNormal(float3 normal1, float3 normal2)
	{
		return smoothstep(_BilaterFilterFactor, 1.0, dot(normal1, normal2));
	}
	
	//原理: 要使用SSAO，需要有全屏幕的深度来反算视空间位置；而为了保证采样点集中在法线所在半球，需要有全屏幕的法线图

	v2f vert_ao (appdata v)
	{
		v2f o;

		o.vertex = UnityObjectToClipPos(v.vertex);
		//当前像素的纹理坐标
		o.uv = v.uv;
		// NDC position  Z:[-1, 1]
		float4 clipPos = float4(v.uv.x * 2 - 1.0, v.uv.y * 2 - 1.0, 1.0, 1.0);
		// view space
		float4 viewRay = mul(_InverseProjectionMatrix, clipPos);
		// perspective divided
		o.viewRay = viewRay.xyz / viewRay.w;  

		return o;
	}
	
	fixed4 frag_ao (v2f i) : SV_Target
	{
		fixed4 col = tex2D(_MainTex, i.uv);
		
		//这个深度值是范围在[0,1]的线性深度值
		float linear01Depth;
		//法线则是视角空间下的法线方向
		float3 viewNormal;
		
		//观察空间下的[法线]信息会被编码进纹理的R和G通道，而[深度]信息会被编进B和A通道
		//i.uv是一个float2类型的变量，对应了当前像素的纹理坐标
		//当通过纹理采样得到深度值后，这些深度值往往是非线性的，这种非线性来自于透视投影使用的裁剪矩阵
		//这个采样结果是unity对深度和法线信息编码后的结果，它的xy分量存储的是视角空间下的法线信息，而深度信息被编码进了zw
		float4 cdn = tex2D(_CameraDepthNormalsTexture, i.uv);
		DecodeDepthNormal(cdn, linear01Depth, viewNormal);
		float3 viewPos = linear01Depth * i.viewRay;
		viewNormal = normalize(viewNormal) * float3(1, 1, -1);  //观察空间是[右手]坐标系
		
		int sampleCount = _SampleKernelCount;
	
		float oc = 0.0;
		for(int i = 0; i < sampleCount; i++)
		{
			//随机向量
			float3 randomVec = _SampleKernelArray[i].xyz;
			//如果随机点的位置与法线反向，那么将随机方向取反，使之保证在法线半球
			randomVec = dot(randomVec, viewNormal) < 0 ? -randomVec : randomVec;
			
			float3 randomPos = viewPos + randomVec * _SampleKeneralRadius;
			float3 rclipPos = mul((float3x3)unity_CameraProjection, randomPos);
			//屏幕空间坐标 (0, 1)
			float2 rscreenPos = (rclipPos.xy / rclipPos.z) * 0.5 + 0.5;
			
			float randomDepth;
			float3 randomNormal;
			float4 rcdn = tex2D(_CameraDepthNormalsTexture, rscreenPos);
			//获取全屏幕的深度值和法线方向
			DecodeDepthNormal(rcdn, randomDepth, randomNormal);
			//乘以了一个距离的权重 _ProjectionParams.z(相机的远裁剪平面)，使AO有一个更好的渐变效果
			float range = abs(randomDepth - linear01Depth) * _ProjectionParams.z < _SampleKeneralRadius ? 1.0 : 0.0;
			float ao = randomDepth + _DepthBiasValue < linear01Depth  ? 1.0 : 0.0;
			oc += ao * range;
		}

		oc /= sampleCount;
		oc = max(0.0, 1 - oc * _AOStrength);
	
		col.rgb = oc;

		return col;
	}
	
	//双线性滤波 (在模糊的同时保持图像中的边缘信息)
	//除了考虑正常高斯滤波的空域信息（domain）外，还要考虑另外的一个图像本身携带的值域信息（range）
	//采样图像当前像素点，然后对于其周围的像素点，计算周围像素点与当前像素点颜色（转为灰度）后的差值作为权重进行双边滤波操作
	fixed4 frag_blur (v2f i) : SV_Target
	{
		//基于法线的双边滤波:
		//对于3D渲染的场景，我们除了可以得到当前屏幕上显示的图像之外，还可以得到对应的全屏幕的深度值，全屏幕的法线值。
		//使用深度或者法线的差异作为双边滤波的值域信息，可以让我们对3D场景结果滤波时保证边界拐角的地方不被模糊，保持边缘
		//每个采样点的权重使用当前像素点法线和周围采样点的法线差异作为权重，直接使用向量点乘表示两个向量的共线程度
		float2 delta = _MainTex_TexelSize.xy * _BlurRadius.xy;
		
		float2 uv = i.uv;
		float2 uv0a = i.uv - delta;
		float2 uv0b = i.uv + delta;	
		float2 uv1a = i.uv - 2.0 * delta;
		float2 uv1b = i.uv + 2.0 * delta;
		float2 uv2a = i.uv - 3.0 * delta;
		float2 uv2b = i.uv + 3.0 * delta;
		
		float3 normal = GetNormal(uv);
		float3 normal0a = GetNormal(uv0a);
		float3 normal0b = GetNormal(uv0b);
		float3 normal1a = GetNormal(uv1a);
		float3 normal1b = GetNormal(uv1b);
		float3 normal2a = GetNormal(uv2a);
		float3 normal2b = GetNormal(uv2b);
		
		fixed4 col = tex2D(_MainTex, uv);
		fixed4 col0a = tex2D(_MainTex, uv0a);
		fixed4 col0b = tex2D(_MainTex, uv0b);
		fixed4 col1a = tex2D(_MainTex, uv1a);
		fixed4 col1b = tex2D(_MainTex, uv1b);
		fixed4 col2a = tex2D(_MainTex, uv2a);
		fixed4 col2b = tex2D(_MainTex, uv2b);
		
		half w = 0.37004405286;
		half w0a = CompareNormal(normal, normal0a) * 0.31718061674;
		half w0b = CompareNormal(normal, normal0b) * 0.31718061674;
		half w1a = CompareNormal(normal, normal1a) * 0.19823788546;
		half w1b = CompareNormal(normal, normal1b) * 0.19823788546;
		half w2a = CompareNormal(normal, normal2a) * 0.11453744493;
		half w2b = CompareNormal(normal, normal2b) * 0.11453744493;
		
		half3 result;
		result = w * col.rgb;
		result += w0a * col0a.rgb;
		result += w0b * col0b.rgb;
		result += w1a * col1a.rgb;
		result += w1b * col1b.rgb;
		result += w2a * col2a.rgb;
		result += w2b * col2b.rgb;
		
		result /= w + w0a + w0b + w1a + w1b + w2a + w2b;

		return fixed4(result, 1.0);
	}
	
	fixed4 frag_composite(v2f i) : SV_Target
	{
		fixed4 ori = tex2D(_MainTex, i.uv);
		fixed4 ao = tex2D(_AOTex, i.uv);
		ori.rgb *= ao.r;

		return ori;
	}
	ENDCG
	
	SubShader
	{
		
		Cull Off ZWrite Off ZTest Always
 
		//Pass 0 : Generate AO 
		Pass
		{
			CGPROGRAM
			#pragma vertex vert_ao
			#pragma fragment frag_ao
			ENDCG
		}
		
		//Pass 1 : Bilateral Filter Blur
		Pass
		{
			CGPROGRAM
			#pragma vertex vert_ao
			#pragma fragment frag_blur
			ENDCG
		}
		
		//Pass 2 : Composite AO
		Pass
		{
			CGPROGRAM
			#pragma vertex vert_ao
			#pragma fragment frag_composite
			ENDCG
		}
	}
}
