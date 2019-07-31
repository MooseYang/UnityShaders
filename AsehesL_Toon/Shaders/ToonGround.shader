Shader "Custom/ToonGround"
{
	Properties
	{
		_Color ("Color", color) = (1,1,1,1)
		_MainTex ("Texture", 2D) = "white" {}
		_Ramp ("Ramp", 2D) = "" {}
		_VirtualLight ("VirtualLight", vector) = (0,0,0,0)
		_VirtualLightRange ("VirtualLightRange", float) = 0.01
		_VirtualLightRamp ("VirtualLightRamp", 2D) = "" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			Tags { "LightMode" = "ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float4 worldPos : TEXCOORD2;
				UNITY_FOG_COORDS(3)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			sampler2D _Ramp;

			fixed4 _Color;

			half4 _VirtualLight;
			half _VirtualLightRange;
			sampler2D _VirtualLightRamp;

			v2f vert(appdata_base v)
			{
				v2f o;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				//避免一次模型矩阵的运算
				o.vertex = mul(UNITY_MATRIX_VP, o.worldPos);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				UNITY_TRANSFER_FOG(o,o.vertex);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float3 vlitDir = _VirtualLight.xyz - i.worldPos.xyz;
				float virtualLightDis = saturate(length(vlitDir) / _VirtualLightRange);

				float3 litDir = normalize(UnityWorldSpaceLightDir(i.worldPos.xyz));
				float ndl = max(0, dot(normalize(i.worldNormal), litDir));
				float ndvl = max(0, dot(normalize(i.worldNormal), normalize(vlitDir)));

				//渐变纹理的采样 (根据光照方向计算uv)
				fixed4 vlightcol = tex2D(_VirtualLightRamp, half2(virtualLightDis, virtualLightDis));

				fixed4 col = tex2D(_MainTex, i.uv) * _Color;

				col.rgb *= UNITY_LIGHTMODEL_AMBIENT.rgb + tex2D(_Ramp, half2(ndl, ndl));
				col.rgb += vlightcol * ndvl;

				UNITY_APPLY_FOG(i.fogCoord, col);

				return col;
			}
			ENDCG
		}
	}
	fallback "Diffuse"
}
