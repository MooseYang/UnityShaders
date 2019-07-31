Shader "Moose_Yang/MySea"
{
    Properties
    {
        _Color("Color Sea", Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "white" {}
        _DetailTex("Detail Texture", 2D) = "white"{}
    }

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent-100" }

		Cull Off 
        ZWrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _DetailTex;
            float4 _DetailTex_ST;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
                o.uv2 = TRANSFORM_TEX(v.texcoord.xy, _DetailTex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 col2 = tex2D(_DetailTex, i.uv2);

                return col;
            }
            ENDCG
        }
    }
}
