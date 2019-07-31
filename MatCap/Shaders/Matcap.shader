Shader "Moose_Yang/Matcap"
{
   Properties
	{
		_MatCap ("Matcap Texture", 2D) = "white" {}
	}

	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100
 
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
 
			struct v2f
			{
				float2 matcapUV : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};
 
			sampler2D _MatCap;
			
            //MatCap: 一种预计算好的特殊光照效果贴图
            //MatCap缺点: Matcap在视角方面有一些限制，仅对于固定的相机视角较好
            //解决办法：把相机的位置也加入计算，不仅仅考虑法线方向
            //在计算方向的时候，不直接使用Normal计算，
            //而是根据当前像素点的相机空间位置，相机空间法线，计算一个反射的方向，再用这个反射的方向进行matcap采样即可

			v2f vert (appdata_base v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

                //性能优化 (但是，对于非缩放值不是1的情况，采样范围不在[0, 1])
                //o.matcapuv.x = mul(UNITY_MATRIX_IT_MV[0], v.normal);
                //o.matcapuv.y = mul(UNITY_MATRIX_IT_MV[1], v.normal);

				//乘以逆转置矩阵将normal变换到视空间
                //对于非uniform变换可能导致法线与平面不垂直的问题, 所以使用逆转置矩阵
				float3 viewSpaceNormal = mul(UNITY_MATRIX_IT_MV, v.normal);
				//需要normalize一下，否则保证normal处在（-1,1）区间，否则有scale的object效果不对 (针对于非统一缩放)
                //在xy方向上的权重进行采样
				viewSpaceNormal = normalize(viewSpaceNormal);
				o.matcapUV = viewSpaceNormal.xy * 0.5 + 0.5;	// [0, 1]

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 matColor = tex2D(_MatCap, i.matcapUV);

				return matColor;
			}
			ENDCG
		}
	}
}
