
Shader "ToonWater/Sky"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
        _SpeedX ("Speed X", float) = 1
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
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
			};

            sampler2D _MainTex;
            fixed _SpeedX;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
                float scrollX = _Time * _SpeedX;
				o.uv = v.uv + float2(scrollX, 0);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				return col * col;
			}
			ENDCG
		}
	}
}
