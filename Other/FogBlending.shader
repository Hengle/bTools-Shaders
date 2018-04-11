Shader "bTools/Other/FogBlending"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Texture", 2D) = "white" {}
		_FogColor("Fog Color", Color) = (0.3, 0.4, 0.7, 1.0)
		_FogStart("Fog Start", float) = 0
		_FogEnd("Fog End", float) = 0
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque" }

		CGPROGRAM
		#pragma surface surf Lambert finalcolor:lightfunc vertex:vert

		struct Input
		{
			float2 uv_MainTex;
			float3 worldPos;
		};

		fixed4 _Color;
		fixed4 _FogColor;
		half _FogStart;
		half _FogEnd;
		sampler2D _MainTex;

		void vert(inout appdata_full v, out Input o)
		{
			UNITY_INITIALIZE_OUTPUT(Input, o);
			o.worldPos = mul(unity_ObjectToWorld, v.vertex);
		}

		void lightfunc(Input IN, SurfaceOutput o, inout fixed4 color)
		{
			fixed3 fogColor = _FogColor.rgb;
			fixed3 tintColor = _Color.rgb;
			float fog = clamp(lerp(0, 1, (_FogStart - IN.worldPos.y) / (_FogEnd - _FogStart)), 0, 1);

			#ifdef UNITY_PASS_FORWARDADD
			fogColor = 0;
			#endif
			color.rgb = saturate(lerp(color.rgb * tintColor, fogColor, fog));
		}

		void surf(Input IN, inout SurfaceOutput o)
		{
			o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
		}
		ENDCG
	}
	Fallback "Diffuse"
}