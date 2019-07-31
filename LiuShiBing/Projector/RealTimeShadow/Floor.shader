// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Moose_Yang/Projector/Floor"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 uv_proj : TEXCOORD1;
                float2 depth : TEXCOORD2;    //当前正在渲染的物体的深度值 (场景相机)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _DepthTexture;  //使用投影纹理进行采样 (因为深度值是透视除法变换后的值)  RenderToTexture.shader里面计算完成
            float4x4 Custom_ProjectorMatrix;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.depth = o.vertex.zw;

                Custom_ProjectorMatrix = mul(Custom_ProjectorMatrix, unity_ObjectToWorld);
                o.uv_proj = mul(Custom_ProjectorMatrix, v.vertex);  //对模型自身的顶点进行矩阵变换

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //得到当前正在渲染的物体的深度值 [0, 1]
                float curDepth = i.depth.x / i.depth.y;

                fixed4 depthCol = tex2Dproj(_DepthTexture, i.uv_proj);
                float depth = DecodeFloatRGBA(depthCol);

                float shadowScale = 1;
                if(curDepth > depth)
                {
                    shadowScale = 0.5;
                }

                fixed4 col = tex2D(_MainTex, i.uv) * shadowScale;

                return col;
            }
            ENDCG
        }
    }
}
