// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ToonWater/Ripple"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
        _Speed ("Speed", float) = 1
        _Color ("Color", Color) = (1, 1, 1, 1)
	}
	SubShader
	{
        Tags { "RenderType"="Transparent" "Queue"="Transparent-99" }
		// No culling or depth
        Blend SrcAlpha OneMinusSrcAlpha
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

            fixed _Speed;
            fixed4 _Color;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv + frac(float2(_Speed, 0) * _Time);
				return o;
			}
			
			sampler2D _MainTex;

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				return fixed4((col.rgb + _Color.rgb) * _LightColor0.rgb, col.a);
			}
			ENDCG
		}
	}
}
