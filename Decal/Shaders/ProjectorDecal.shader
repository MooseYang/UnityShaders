Shader "Moose_Yang/ProjectorDecal"
{
   Properties 
	{
		_Color ("Main Color", Color) = (1,1,1,1)
		_DecalTex ("Cookie", 2D) = "" {}
		_FalloffTex ("FallOff", 2D) = "white" {}
	}
 
	Subshader 
	{
		Pass 
		{
			ZWrite Off
			Fog { Color (0, 0, 0) }
			ColorMask RGB
			Blend SrcAlpha OneMinusSrcAlpha
			Offset -1, -1
 
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			struct v2f 
			{
				float4 uvDecal : TEXCOORD0;
				float4 uvFalloff : TEXCOORD1;
				float4 pos : SV_POSITION;
			};
			
            //使用Unity Projector组件自带的矩阵
			//Projector的Decal是通过额外的Pass渲染的，整个场景都额外进行了一次渲染,
			//如果一个Projector覆盖太多的物体可能会导致批次上升
			float4x4 unity_Projector;
			float4x4 unity_ProjectorClip;
			fixed4 _Color;
			sampler2D _DecalTex;
			sampler2D _FalloffTex;
			
			v2f vert (float4 vertex : POSITION)
			{
				v2f o;
				o.pos = UnityObjectToClipPos (vertex);
				o.uvDecal = mul (unity_Projector, vertex);
				o.uvFalloff = mul (unity_ProjectorClip, vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 decal = tex2Dproj (_DecalTex, UNITY_PROJ_COORD(i.uvDecal));
				decal *= _Color;
 
				fixed falloff = tex2Dproj (_FalloffTex, UNITY_PROJ_COORD(i.uvFalloff)).r;
				decal *= falloff;

				return decal;
			}			
			ENDCG
		}
	}
}
