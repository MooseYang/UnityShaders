Shader "Hidden/Interact"
{
	Properties
	{
	}

	SubShader
	{
		Tags { "RenderType"="Opaque" }
		Zwrite Off

		Pass
		{
			Cull Front

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _DepthTexture;

			struct v2f
			{
				float4 proj : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata_base v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.proj = ComputeScreenPos(o.vertex);
				o.proj.z = COMPUTE_DEPTH_01;

				return o;
			}
			
			half4 frag (v2f i) : SV_Target
			{
				half deltaDepth = tex2Dproj(_DepthTexture, i.proj).r - i.proj.z;

				clip(-deltaDepth);

				return 0.5;
			}
			ENDCG
		}

		Pass
		{
			Cull Back

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _DepthTexture;

			struct v2f
			{
				float4 proj : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert(appdata_base v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				//计算顶点在屏幕空间的位置（没有进行透视除法） 
				o.proj = ComputeScreenPos(o.vertex);
				o.proj.z = COMPUTE_DEPTH_01;

				//计算顶点距离相机的距离  
                //COMPUTE_EYEDEPTH(o.proj.z);  

				return o;
			}

			half4 frag(v2f i) : SV_Target
			{
				//计算二者的深度差，该值越小，说明越近穿插 (交互)
				half deltaDepth = tex2Dproj(_DepthTexture, i.proj).r - i.proj.z;
				
				clip(-deltaDepth);

				return 0;
			}
			ENDCG
		}
	}
}
