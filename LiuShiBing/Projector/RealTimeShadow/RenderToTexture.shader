Shader "Moose_Yang/Projector/RenderToTexture"
{
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
            };

            struct v2f
            {
                float2 depth : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.depth = o.vertex.zw;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float depth = i.depth.x / i.depth.y;  // [0, 1]

                //将物体的深度值转换为颜色值，并存储到贴图里
                //记录深度信息
                fixed4 col = EncodeFloatRGBA(depth);

                return col;
            }
            ENDCG
        }
    }
}
