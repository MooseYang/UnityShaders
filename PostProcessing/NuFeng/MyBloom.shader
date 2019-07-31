Shader "Moose_Yang/MyBloom"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }

    CGINCLUDE
        #include "UnityCG.cginc"

        struct appdata
        {
            float4 vertex : POSITION;
            float2 uv : TEXCOORD0;
        };

        struct v2f_threshold
        {
            float4 vertex : SV_POSITION;
            float2 uv : TEXCOORD0;
        };

        struct v2f_blur
        {
            float4 vertex : SV_POSITION;
            float2 uv : TEXCOORD0;
            float4 uv01 : TEXCOORD1;
            float4 uv23 : TEXCOORD2;
            float4 uv45 : TEXCOORD3;
        };

        struct v2f_bloom
        {
            float4 vertex : SV_POSITION;
            float2 uv : TEXCOORD0;
        };

        sampler2D _MainTex;
        float4 _MainTex_ST;
        float4 _MainTex_TexelSize;
        sampler2D _BlurTex;
        float4 _ColorThreshold;
        float _LuminanceThreshold;
        float4 _Offsets;
        float4 _BloomColor;
        float _BloomFactor;


        //阈值 (图像分割)
        v2f_threshold vert_threshold(appdata v)
        {
            v2f_threshold o;

            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv = TRANSFORM_TEX(v.uv, _MainTex);

            return o;
        }

        fixed4 frag_threshold(v2f_threshold i) : SV_Target
        {
            fixed4 col = tex2D(_MainTex, i.uv);

            //return saturate(col - _ColorThreshold);
            return saturate(Luminance(col) - _LuminanceThreshold);
        }

        //高斯模糊
        v2f_blur vert_blur(appdata v)
        {
            v2f_blur o;

            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv = TRANSFORM_TEX(v.uv, _MainTex);

            _Offsets *= _MainTex_TexelSize.xyxy;

            o.uv01 = o.uv.xyxy + _Offsets.xyxy * float4(1, 1, -1, -1);
            o.uv23 = o.uv.xyxy + _Offsets.xyxy * float4(1, 1, -1, -1) * 2;
            o.uv45 = o.uv.xyxy + _Offsets.xyxy * float4(1, 1, -1, -1) * 3;

            return o;
        }

        fixed4 frag_bloom(v2f_blur i) : SV_Target
        {
            fixed4 col = fixed4(0, 0, 0, 0);
            //加权平均
            col += 0.4 * tex2D(_MainTex, i.uv);
            col += 0.15 * tex2D(_MainTex, i.uv01.xy);
            col += 0.15 * tex2D(_MainTex, i.uv01.zw);

            col += 0.1 * tex2D(_MainTex, i.uv23.xy);
            col += 0.1 * tex2D(_MainTex, i.uv23.zw);

            col += 0.05 * tex2D(_MainTex, i.uv45.xy);
            col += 0.05 * tex2D(_MainTex, i.uv45.zw);

            return col;
        }

        v2f_bloom vert_bloom(appdata v)
        {
            v2f_bloom o;

            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv = TRANSFORM_TEX(v.uv, _MainTex);

            return o;
        }

        // 模糊 + 原图
        fixed4 frag_bloom(v2f_bloom i) : SV_Target
        {
            fixed4 col = tex2D(_MainTex, i.uv);
            fixed4 blurCol = tex2D(_BlurTex, i.uv);

            fixed4 finalCol = col + blurCol * _BloomColor * _BloomFactor;

            return finalCol;
        }
    ENDCG

    SubShader
    {
        Tags{"RenderType"="Opaque"}

        LOD 200

        Pass
        {
            ZTest Off
            Cull Off
            Fog{Mode Off}

            CGPROGRAM
            #pragma vertex vert_threshold
            #pragma fragment frag_threshold
            ENDCG
        }   

        Pass
        {
            ZTest Off
            Cull Off
            Fog{Mode Off}

            CGPROGRAM
            #pragma vertex vert_blur
            #pragma fragment frag_bloom
            ENDCG
        } 

        Pass
        {
            ZTest Off
            Cull Off
            Fog{Mode Off}

            CGPROGRAM
            #pragma vertex vert_bloom
            #pragma fragment frag_bloom
            ENDCG
        } 
    }
}
