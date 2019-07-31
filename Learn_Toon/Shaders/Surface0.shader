Shader "Custom/Surface0" 
{
	Properties 
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
	}

	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Surface0 vertex:vert

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma lighting Surface0
        inline half4 LightingSurface0(SurfaceOutput s, half3 lightDir, half atten) 
		{
            half4 c;
            c.rgb = s.Albedo * _LightColor0 + half3(0, 1, 0);
            c.a = s.Alpha;
            return c;
        }

		sampler2D _MainTex;

		struct Input 
		{
			float2 uv_MainTex;
		};
  
		fixed4 _Color;

        void vert(inout appdata_full v, out Input o) 
		{
            v.vertex.y = v.vertex.y + sin(_Time) * 10;
            UNITY_INITIALIZE_OUTPUT(Input, o);
        }

		void surf (Input IN, inout SurfaceOutput o)
		 {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
