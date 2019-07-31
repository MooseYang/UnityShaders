
Shader "Moose_Yang/Depth/ForceField"
{
	Properties
	{
		_MainColor("Main Color", Color) = (0,0,0,0)
		_NoiseTex("NoiseTexture", 2D) = "white" {}
		_DistortStrength("DistortStrength", Range(0,1)) = 0.2
		_DistortTimeFactor("DistortTimeFactor", Range(0,1)) = 0.2
		_RimStrength("RimStrength",Range(0, 10)) = 2
		_IntersectPower("IntersectPower", Range(0, 3)) = 2
	}

	SubShader
	{
		ZWrite Off
		Cull Off
		Blend SrcAlpha OneMinusSrcAlpha

		Tags
		{
			"RenderType" = "Transparent"
			"Queue" = "Transparent"
		}

		GrabPass
		{
			"_GrabTempTex"
		}

		Pass
		{
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float4 screenPos : TEXCOORD1;
				float4 grabPos : TEXCOORD2;
				float3 normal : NORMAL;
				float3 viewDir : TEXCOORD3;
			};

			sampler2D _CameraDepthTexture;
			sampler2D _GrabTempTex;
			float4 _GrabTempTex_ST;
			sampler2D _NoiseTex;
			float4 _NoiseTex_ST;
			float _DistortStrength;
			float _DistortTimeFactor;
			float _RimStrength;
			float _IntersectPower;
			fixed4 _MainColor;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.grabPos = ComputeGrabScreenPos(o.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _NoiseTex);

				o.normal = UnityObjectToWorldNormal(v.normal);
				o.viewDir = normalize(UnityWorldSpaceViewDir(mul(unity_ObjectToWorld, v.vertex)));

				//将返回片段着色器的屏幕位置
				//o.screenPos.z --->顶点在屏幕空间的深度值
				o.screenPos = ComputeScreenPos(o.vertex);

				//计算顶点摄像机空间的深度：距离裁剪平面的距离，线性变化
				//将顶点转换到视空间 (待比较的当前像素深度值)
				COMPUTE_EYEDEPTH(o.screenPos.z);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				//圆环
				float rim = 1 - abs(dot(i.normal, normalize(i.viewDir))) * _RimStrength;

				//获取已有的深度信息,此时的深度图里没有力场的信息
				//计算当前像素深度值 (转换到了视空间)
				float sceneZ = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos)).r);

				float diff = sceneZ - i.screenPos.z;
				//相交程度
				float intersect = (1 - diff) * _IntersectPower;

				float glow = max(intersect, rim);

				//扭曲
				float4 offset = tex2D(_NoiseTex, i.uv - _Time.xy * _DistortTimeFactor);
				i.grabPos.xy -= offset.xy * _DistortStrength;
				fixed4 color = tex2Dproj(_GrabTempTex, i.grabPos);

				fixed4 finalColor = color + _MainColor * glow;

				return finalColor;
			}
			ENDCG
		}
	}
}
