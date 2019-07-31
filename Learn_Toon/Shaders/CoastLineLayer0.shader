// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ToonWater/CoastLineLayer0"
{
	Properties
	{
        _Color ("Color", Color) = (0.5, 0.5, 0.5, 1)
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
        Tags { "RenderType"="Transparent" "Queue"="Transparent-90" }
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
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);            
				return col * _Color * fixed4(_LightColor0.r, _LightColor0.g, _LightColor0.b, 1);
			}
			ENDCG
		}
	}
}
