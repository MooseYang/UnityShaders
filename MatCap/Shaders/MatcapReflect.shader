Shader "Moose_Yang/MatcapReflect"
{
    Properties
	{
		_MatCap ("Matcap", 2D) = "white" {}
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
			//sampler2D _GlobalMatcap;
			
            //MatCap优化版本 (基于反射效果)
			//原理:
			//由于物体的法线是一个三维的朝向，但是最终采样到二维贴图也只有两个维度。
			//需要去掉一个维度，在相机空间下的物体法线向量，可以不考虑Z轴的指向，
			//即不考虑Z轴本身对屏幕空间的XY平面的贡献，因为法线是一个单位向量，如果法线在XY方向上的投影权重很大，那么说明在Z方向的权重就很小，
			//对应到二维的Matcap上采样的位置越靠近边缘；而如果法线在XY方向的投影权重很小，那么Z方向的权重就很大，
			//对应到二维的Matcap上的采样位置就越靠近中心。
			//接下来需要考虑的是在哪一个空间计算Matcap，如果是物体空间或者是世界空间，由于相机位置朝向不确定，
			//不好确定法线的Z方向与屏幕空间的关系，不好确定舍弃哪一个维度。
			//而相机空间下的物体在屏幕上的方位都已经大致确定，相机空间下相对运算要比屏幕空间更少一些。所以最合适的实际上就是相机空间下进行计算。
			//可以通过Unity的内置矩阵将法线从物体空间转化到视空间，然后对于是空间的法线方向，由于方向是（-1,1）区间，
			//需要再将其*0.5 + 0.5变化到（0,1）区间，就可以实现使用这个xy方向采样Matcap贴图


			v2f vert (appdata_base v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				//乘以逆转置矩阵将normal变换到视空间
				float3 viewnormal = mul(UNITY_MATRIX_IT_MV, v.normal);
				viewnormal = normalize(viewnormal);
				float3 viewPos = UnityObjectToViewPos(v.vertex);
				float3 r = reflect(viewPos, viewnormal);
				float m = 2.0 * sqrt(r.x * r.x + r.y * r.y + (r.z + 1) * (r.z + 1));
				o.matcapUV = r.xy / m + 0.5;

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
