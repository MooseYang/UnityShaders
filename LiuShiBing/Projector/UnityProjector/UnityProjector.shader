// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Moose_Yang/Projector/UnityProjector"
{
    Properties
    {
        //需要投影到地面的贴图 (模拟阴影)
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Blend dstColor zero

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
                float4 uv_proj : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            //通过自定义的投影矩阵，替代unity_Projetor矩阵  (CustomProjector.cs传递进来)
            float4x4 custom_Projector;
            //float4x4 unity_Projector;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                //使用摄像机的投影矩阵，变换模型自身的顶点
                //o.uv_proj = mul(unity_Projector, v.vertex);

                custom_Projector = mul(custom_Projector, unity_ObjectToWorld);
                o.uv_proj = mul(custom_Projector, v.vertex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2Dproj(_MainTex, i.uv_proj);

                col.rgb = 1 - col.a;

                return col;
            }
            ENDCG
        }
    }
}
