
Shader "Moose_Yang/NormalMap"
{
   Properties
   {
		_MainTex("Base 2D", 2D) = "white"{}
		_BumpMap("Bump Map", 2D) = "bump"{}
		_Diffuse("Diffuse Color", Color) = (1,1,1,1)
        _BumpFactor ("Bump Scale", Range(0, 10.0)) = 1.0
	}
 
	SubShader
	{
		Pass
		{
			//定义Tags
			Tags{ "RenderType" = "Opaque" }
 
			CGPROGRAM
			//引入头文件
			#include "Lighting.cginc"
            //使用vert函数和frag函数
			#pragma vertex vert
			#pragma fragment frag	

			fixed4 _Diffuse;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
            float _BumpFactor;
 
			//定义结构体：vertex shader阶段输出的内容
			struct v2f
			{
				float4 pos : SV_POSITION;
				//转化纹理坐标
				float2 uv : TEXCOORD0;
				//tangent空间的光线方向
				float3 lightDir : TEXCOORD1;
			};
 
			//定义顶点shader
			v2f vert(appdata_tan v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				//这个宏为我们定义好了模型空间到切线空间的转换矩阵rotation，注意后面有个；
				TANGENT_SPACE_ROTATION;
				//ObjectSpaceLightDir可以把光线方向转化到模型空间，然后通过rotation再转化到切线空间
                //切线空间下的光照方向 (因为法线也在切线空间，所以需要将光照也变换到一样的坐标系下)
				o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex));
				//通过TRANSFORM_TEX宏转化纹理坐标，主要处理了Offset和Tiling的改变,默认时等同于o.uv = v.texcoord.xy;
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

				return o;
			}
 
			//定义片元shader
			fixed4 frag(v2f i) : SV_Target
			{
				//unity自身的diffuse也是带了环境光，这里我们也增加一下环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * _Diffuse.xyz;
				//直接解出切线空间法线
				float3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uv));
                //构建一个float3向量，用于与法线相乘得到更改后的法线值  (增强法线效果)
				float3 normalFactor = float3(_BumpFactor, _BumpFactor, 1);
                //将factor与法线相乘并normalize
				tangentNormal = normalize(tangentNormal * normalFactor);
				//normalize一下切线空间的光照方向
				float3 tangentLight = normalize(i.lightDir);
				//根据半兰伯特模型计算像素的光照信息
				fixed3 lambert = 0.5 * dot(tangentNormal, tangentLight) + 0.5;
				//最终输出颜色为lambert光强*材质diffuse颜色*光颜色
				fixed3 diffuse = lambert * _Diffuse.xyz * _LightColor0.xyz + ambient;
				//进行纹理采样
				fixed4 color = tex2D(_MainTex, i.uv);

				return fixed4(diffuse * color.rgb, 1.0);
			}
			ENDCG
		}
	}
    FallBack "Diffuse"
}
