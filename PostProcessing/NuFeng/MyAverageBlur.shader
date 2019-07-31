Shader "Moose_Yang/MyAverageBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlurRadio("BlurRedio", float) = 0.5
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

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
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float2 uv2 : TEXCOORD2;
                float2 uv3 : TEXCOORD3;
                float2 uv4 : TEXCOORD4;
            };

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            float _BlurRadio;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                o.uv1 = o.uv + _BlurRadio * _MainTex_TexelSize.x * float2(-1, 1);
                o.uv2 = o.uv + _BlurRadio * _MainTex_TexelSize.x * float2(-1, 1);
                o.uv3 = o.uv + _BlurRadio * _MainTex_TexelSize.x * float2(-1, 1);
                o.uv4 = o.uv + _BlurRadio * _MainTex_TexelSize.x * float2(-1, 1);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                // float uv1 = i.uv + _BlurRadio * _MainTex_TexelSize.x * float2(-1, 1);
                // float uv2 = i.uv + _BlurRadio *  _MainTex_TexelSize.x * float2(1, 1);
                // float uv3 = i.uv + _BlurRadio * _MainTex_TexelSize.x * float2(1, -1);
                // float uv4 = i.uv + _BlurRadio *  _MainTex_TexelSize.x * float2(-1, -1);
                // col += tex2D(_MainTex, uv1);
                // col += tex2D(_MainTex, uv2);
                // col += tex2D(_MainTex, uv3);
                // col += tex2D(_MainTex, uv4);

                col += tex2D(_MainTex, i.uv1);
                col += tex2D(_MainTex, i.uv2);
                col += tex2D(_MainTex, i.uv3);
                col += tex2D(_MainTex, i.uv4);

                col *= 0.2;

                return col;
            }
            ENDCG
        }
    }
}
