
Shader "ToonWater/Sea"
{
	Properties
	{
        _Color ("Color", Color) = (0.5, 0.5, 0.5, 1)
		_MainTex ("Texture", 2D) = "white" {}
        _DetailTex ("Detail", 2D) = "white" {}
        _WiggleTex ("Wiggle", 2D) = "white" {}  //流体模拟
        _MainTexAlpha ("Main Alpha", float) = 1
        _DetailTexAlpha ("Detail Alpha", float) = 1
        _SpeedX ("Speed X", float) = 1
        _SpeedY ("Speed Y", float) = 1
        _WaveSpeed ("Wave Speed", float) = 1  //海浪速度
        _WaveHeight ("Wave Height", float) = 1 //海浪浪高
        _MainWiggleStrength ("Main Wiggle Strength", float) = 0.2
        _DetailWiggleStrength ("Detail Wiggle Strength", float) = 0.1
	}
	SubShader
	{
        Tags { "RenderType"="Transparent" "Queue"="Transparent-100" }

		Cull Off 
        ZWrite Off

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
                float2 uvWiggle : TEXCOORD2;
				float4 vertex : SV_POSITION;
			};

            fixed4 _Color;

            sampler2D _MainTex;
            sampler2D _DetailTex;
            sampler2D _WiggleTex;
            fixed4 _MainTex_ST;
            fixed4 _DetailTex_ST;
            fixed4 _WiggleTex_ST;

            fixed _MainTexAlpha;
            fixed _DetailTexAlpha;

            fixed _SpeedX;
            fixed _SpeedY;

            fixed _WaveSpeed;

            fixed _WaveHeight;

            fixed _MainWiggleStrength;
            fixed _DetailWiggleStrength;


			v2f vert (appdata_full v)
			{
				v2f o;

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                //利用网格顶点x和z方向的分量分别进行正弦函数运算后再叠加，求出y分量
                v.vertex.y = (sin(_Time * worldPos.x * _WaveSpeed) - sin(_Time * worldPos.z * _WaveSpeed)) * _WaveHeight;

				o.vertex = UnityObjectToClipPos(v.vertex);

				o.uv = TRANSFORM_TEX(v.texcoord.xy, _MainTex) + frac(float2(_SpeedX, _SpeedY) * _Time);
                o.uv2 = TRANSFORM_TEX(v.texcoord.xy, _DetailTex) + frac(float2(_SpeedX, _SpeedY) * _Time);

                o.uvWiggle = TRANSFORM_TEX(v.texcoord.xy, _WiggleTex);
                
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
                //先进行流体贴图的uv形变
                i.uvWiggle.x -= _SinTime;  //float4类型 (sin(t/8),sin(t/4),sin(t/2),sin(t))
                i.uvWiggle.y += _CosTime;  //float4类型(cos(t/8),cos(t/4),cos(t/2),cos(t))

                //_WiggleTex流体贴图：
                //利用一张rgb贴图保存水流体信息
                //r值用来控制海水纹理的uv的x方向上的形变
                //b值用来控制海水纹理的uv的y方向上的形变
                fixed4 colWiggle = tex2D(_WiggleTex, i.uvWiggle);
                i.uv.x -= colWiggle.r * _MainWiggleStrength;
                i.uv.y += colWiggle.b * _MainWiggleStrength;

				fixed4 col = tex2D(_MainTex, i.uv) * _MainTexAlpha;     

                i.uv2.x -= colWiggle.r * _DetailWiggleStrength;
                i.uv2.y += colWiggle.b * _DetailWiggleStrength;

                fixed4 col2 = tex2D(_DetailTex, i.uv2) * _DetailTexAlpha;

				return (col + col2 + _Color) * _LightColor0;
			}
			ENDCG
		}
	}
}
