Shader "Moose_Yang/RefractionMagnifyingGlass"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MagnifierIndensity("MagnifierIndensity", float) = 0.02
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent+100"}
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
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 screenPos : TEXCOORD1;
                float4 vertex : SV_POSITION;
                float2 offset_uv : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _CustomGrabTexture;
            float _MagnifierIndensity;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.screenPos = ComputeGrabScreenPos(o.vertex);

                //将模型的法线，变换到视空间
                float offset_x = dot(UNITY_MATRIX_IT_MV[0].xyz, v.normal);
                float offset_y = dot(UNITY_MATRIX_IT_MV[1].xyz, v.normal);

                float angle = max(0, dot(v.normal, normalize(ObjSpaceViewDir(v.vertex))));

                //该方法效率比较低
                //o.offset_uv.x = -asin(sin(offset_x) / 1.6);
                //o.offset_uv.y = asin(sin(offset_y) / 1.6) * (_ScreenParams.x / _ScreenParams.y);

                //优化后的方法
                o.offset_uv.x = offset_x * angle;
                o.offset_uv.y = -offset_y * angle * (_ScreenParams.x / _ScreenParams.y);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //uv偏移实现模拟折射效果
                i.screenPos.xy += i.offset_uv * _MagnifierIndensity;

                //背景颜色投影到当前放大镜上的颜色
                fixed4 col = tex2Dproj(_CustomGrabTexture, i.screenPos);

                return col;
            }
            ENDCG
        }
    }
}
