// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ToonWater/CoastLineLayer1"
{
	Properties
	{
        _Color ("Color", Color) = (0.5, 0.5, 0.5, 1)
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
        Tags { "RenderType"="Transparent" "Queue"="Transparent-89" }
        Blend SrcAlpha OneMinusSrcAlpha
		// No culling or depth
		Cull Off ZWrite Off

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
				float4 vertex : SV_POSITION;
			};

            fixed4 _Color;
            sampler2D _MainTex;
            fixed4 _MainTex_ST;
			v2f vert (appdata_full v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
                float mod = _Time - 0.312 * floor(_Time / 0.312);
				o.uv = TRANSFORM_TEX(v.texcoord.xy, _MainTex) + frac(float2(0, 0.2) * sin(mod));
				return o;
			}


			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				return col * _Color * _LightColor0;
			}
			ENDCG
		}
	}
}
