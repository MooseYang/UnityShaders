﻿Shader "Hidden/Foam"
{
	Properties
	{
		_Pre("Pre", 2D) = "black" {}
		_Interact("Interact", 2D) = "black" {}
		_Speed("Speed", vector) = (0,0,0,0)
	}
	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct v2f
			{
				float4 proj : TEXCOORD0;
				float2 uv : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			sampler2D _Pre;
			sampler2D _Interact;
			half4 _Speed;
			
			v2f vert (appdata_base v)
			{
				v2f o;
				float4 pos = UnityObjectToClipPos(v.vertex);
				//限制顶点坐标范围: [0, 1]
				o.vertex = float4(v.texcoord.x * 2 - 1, (1 - v.texcoord.y) * 2 - 1, 0, 1);
				o.proj = ComputeScreenPos(pos);
				o.uv = v.texcoord;

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2Dproj(_Interact, i.proj);
				//两次采样取平均值
				fixed4 pre = (tex2D(_Pre, i.uv + half2(_Speed.x, _Speed.y)) + tex2D(_Pre, i.uv + half2(_Speed.x, -_Speed.y))) * 0.5;

				col = col + pre * 0.95;

				//return fixed4(i.uv,0,1)*col;
				return col;
			}
			ENDCG
		}
	}
}
