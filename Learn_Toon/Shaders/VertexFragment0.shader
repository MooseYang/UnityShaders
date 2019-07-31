// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/VertexFragment0"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
        _DetailTex ("Detail", 2D) = "white" {}
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite On

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

            sampler2D _MainTex;
            sampler2D _DetailTex;
            fixed4 _MainTex_ST;
            fixed4 _DetailTex_ST;

			v2f vert (appdata_full v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
                o.uv2 = TRANSFORM_TEX(v.texcoord.xy, _DetailTex);
				return o;
			}


			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 col2 = tex2D(_DetailTex, i.uv2);
				return col * col2 * _LightColor0;
			}
			ENDCG
		}
	}
}
