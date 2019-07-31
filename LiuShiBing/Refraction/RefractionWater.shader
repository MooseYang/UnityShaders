Shader "Moose_Yang/RefractionWater"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _L("L", float) = 1
        _S("S", float) = 0.5
        _A("A", float) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent"}
        LOD 100

        GrabPass
        {
            "_CustomGrabTexture"
        }

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
                float4 uv_proj : TEXCOORD1;
                float4 vertex : SV_POSITION;
                float3 N : NORMAL;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _CustomGrabTexture;  //抓取到屏幕的一张纹理
            float _L;
            float _S;
            float _A;

            //原理：抓取摄像机渲染的数据，对屏幕空间的像素点进行采样 (经过透视除法后的点)
            //依然会使用投影纹理 (没有使用半透明渲染，是因为水底的顶点不能一一映射到水面上)

            v2f vert (appdata v)
            {
                float w = 2 * 3.14159 / _L;
                float f = _S * w;
                v.vertex.y += _A * sin(length(v.vertex.xz) * w + _Time.x * f);

                //使用偏导数计算 副切线和切线
                float dx = _A * v.vertex.x * w * cos(-length(v.vertex.xz) * w + _Time.x * f);
                float dz = _A * v.vertex.z * w * cos(-length(v.vertex.xz) * w + _Time.x * f);

                float3 B = normalize(float3(1, dx, 0));
                float3 T = normalize(float3(0, dz, 1));

                v2f o;

                //向量叉乘优化 (直接凑)
                o.N = float3(dx, -1, dz);
                //o.N = cross(B, T);

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv_proj = ComputeGrabScreenPos(o.vertex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //方法一: 使用波动方程，模拟折射效果
                //i.uv_proj.xy += 0.01 * sin(i.uv_proj.xz * 3.14 * 10 + _Time.y * 2);
                
                //添加一张法线贴图的采样，加强顶点法线的"扭曲"程度
                float3 nCol = UnpackNormal(tex2D(_MainTex, i.uv * _Time.x)) * 0.3;
                i.N += nCol;

                //方法二: 使用经过 偏导数计算出来的法线 实现波动效果
                float d = dot(i.N, float3(0, 1, 0));
                i.uv_proj.xy = d;

                fixed4 col = tex2Dproj(_CustomGrabTexture, i.uv_proj) * 0.5;

                return col;
            }
            ENDCG
        }
    }
}
