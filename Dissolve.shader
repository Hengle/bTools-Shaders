Shader "bShaders/Dissolve" 
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}

		_DissMap("Dissolve Map", 2D) = "white" {}
		[NoScaleOffset]_Ramp("Ramp Dissolve", 2D) = "white" {}
		_CutOut("CutOut", Range(0,1)) = 0.0
		_RampSize("RampSize", Range(0,1)) = 0.0

		[NoScaleOffset]_MetalRough("Metal Smoothness", 2D) = "white" {}
		_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
	}
	SubShader
	{
		Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
		LOD 200
		Zwrite Off

		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _DissMap;
		sampler2D _Ramp;
		sampler2D _MetalRough;

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		float _CutOut;
		float _RampSize;

		struct Input
		{
			float2 uv_MainTex;
			float2 uv_DissMap;
		};

		void surf(Input IN, inout SurfaceOutputStandard o)
		{
			// Main Color
			fixed4 col = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			fixed4 metalRough = tex2D(_MetalRough, IN.uv_MainTex);
			// Dissolve value
			fixed dissolve = tex2D(_DissMap, IN.uv_DissMap) - _CutOut;
			// Ramp color for the given dissolve value
			fixed4 ramp = tex2D(_Ramp, float2(step(dissolve, _RampSize) *  ((min(dissolve, _RampSize)) / _RampSize),0.0));

			o.Albedo = (1 - step(dissolve, _RampSize)) * col + (step(dissolve, _RampSize)) * ramp;
			o.Metallic = _Metallic * metalRough.r;
			o.Smoothness = _Glossiness * metalRough.a;
			o.Alpha = dissolve;

			clip(o.Alpha);
		}
		ENDCG
	}
	FallBack "Diffuse"
}

