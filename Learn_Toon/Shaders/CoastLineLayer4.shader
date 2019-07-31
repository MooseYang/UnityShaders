
Shader "ToonWater/CoastLineLayer4"
{
	Properties
	{
        _Color ("Color", Color) = (1, 1, 1, 1)
		_MainTex ("Texture", 2D) = "white" {}
        _DetailTex ("Detail Texture", 2D) = "white" {}
        _SpeedX ("Speed X", float) = 5
	}
	SubShader
	{
        Tags { "RenderType"="Transparent" "Queue"="Transparent-86" }
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
                float2 uv2 : TEXCOORD1;
                float2 uv3 : TEXCOORD2;
				float4 vertex : SV_POSITION;
			};

            fixed4 _Color;
            sampler2D _MainTex;
            sampler2D _DetailTex;
            fixed _SpeedX;
            fixed4 _MainTex_ST;
            fixed4 _DetailTex_ST;

			v2f vert (appdata_full v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
                float time = _Time;
				o.uv = TRANSFORM_TEX(v.texcoord.xy, _MainTex) + frac(float2(_SpeedX, 0) * time) + frac(0.2 + 0.2 * sin(_Time - 1));
                o.uv2 = TRANSFORM_TEX(v.texcoord.xy, _MainTex) + frac(float2(-_SpeedX, 0) * time) + frac(0.2 + 0.2 * sin(_Time - 1));
                o.uv3 = TRANSFORM_TEX(v.texcoord.xy, _DetailTex) + frac(float2(_SpeedX, 0) * time) + frac(0.2 + 0.2 * sin(_Time - 1));
				return o;
			}         

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 col2 = tex2D(_MainTex, i.uv2);
                fixed4 col3 = tex2D(_DetailTex, i.uv3);
				return (col + col2 + col3 * 0.2) * _Color * fixed4(_LightColor0.r, _LightColor0.g, _LightColor0.b, 1);
			}
			ENDCG
		}
	}
}
