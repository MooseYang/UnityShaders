
Shader "Moose_Yang/ParallaxMap"
{
    Properties
	{
		_Diffuse("Diffuse Color", Color) = (1,1,1,1)
		_MainTex("Base 2D", 2D) = "white"{}
		_BumpMap("Bump Map", 2D) = "bump"{}
		_HeightMap("Height Map", 2D) = "black"{}
		_HeightFactor ("Height Scale", Range(0, 1)) = 0.05
	}
 
	SubShader
	{
		Pass
		{
			Tags{ "RenderType" = "Opaque" }
 
			CGPROGRAM

			#include "Lighting.cginc"           
			#pragma vertex vert
			#pragma fragment frag	
			fixed4 _Diffuse;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float _HeightFactor;
			sampler2D _HeightMap;
 

			struct v2f
			{
				float4 pos : SV_POSITION;
				//转化纹理坐标
				float2 uv : TEXCOORD0;
				//切空间的光线方向
				float3 lightDir : TEXCOORD1;
				//切空间下的视线方向
				float3 viewDir : TEXCOORD2;
			};
 
			//计算uv偏移值
			inline float2 CaculateParallaxUV(v2f i)
			{
				//采样heightmap (需要偏移的强度. 黑色值：不需要偏移，白色值：偏移)
				float height = tex2D(_HeightMap, i.uv).r;
				//normalize view Dir
				float3 viewDir = normalize(i.viewDir);
				//偏移值 = 切线空间的视线方向.xy（uv空间下的视线方向）* height * 控制系数
                //viewDir.xy / viewDir.z (通过切平面垂直的z分量来调整xy方向（uv方向）偏移的大小
                //也就是视角越平，uv偏移越大；视角越垂直于表面，uv偏移值越小)
				float2 offset = viewDir.xy / viewDir.z * height * _HeightFactor;

				return offset;
			}
 
			v2f vert(appdata_tan v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				//这个宏为我们定义好了模型空间到切线空间的转换矩阵rotation，注意后面有个；
				TANGENT_SPACE_ROTATION;
				//ObjectSpaceLightDir可以把光线方向转化到模型空间，然后通过rotation再转化到切线空间
				o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex));
				//通过TRANSFORM_TEX宏转化纹理坐标，主要处理了Offset和Tiling的改变,默认时等同于o.uv = v.texcoord.xy;
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				//计算观察方向 (切线空间下)
				o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex));

				return o;
			}
 
			fixed4 frag(v2f i) : SV_Target
			{
				//unity自身的diffuse也是带了环境光，这里我们也增加一下环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * _Diffuse.xyz;
				float2 uvOffset = CaculateParallaxUV(i);
				i.uv += uvOffset;
				//直接解出切线空间法线
				float3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uv));
				//normalize一下切线空间的光照方向
				float3 tangentLight = normalize(i.lightDir);
				//兰伯特光照
				fixed3 lambert = saturate(dot(tangentNormal, tangentLight));
				//最终输出颜色为lambert光强*材质diffuse颜色*光颜色
				fixed3 diffuse = lambert * _Diffuse.xyz * _LightColor0.xyz + ambient;
                //高光
                float3 halfDir = normalize(i.lightDir + i.viewDir);
				fixed3 specular = _LightColor0.rgb * pow(saturate(dot(halfDir, tangentNormal)), 10);

				//进行纹理采样
				fixed4 color = tex2D(_MainTex, i.uv);

				return fixed4(diffuse * color.rgb, 1.0);
			}
			ENDCG
		}
	}
    FallBack "Diffuse"
}
