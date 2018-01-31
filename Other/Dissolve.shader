Shader "bShaders/Dissolve" 
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		[NoScaleOffset]_Metallic("Metal (R) Roughness (A)", 2D) = "white" {}
		_Metalness("Metallic", Range(0,1)) = 0.5
		_Glossiness("Smoothness", Range(0,1)) = 0.5

		_DissMap("Ramp (RGB) - Dissolve (A)", 2D) = "white" {}
		_CutOut("Dissolve Value", Range(0,1)) = 0.5
		_RampSize("Ramp Size", Range(0,1)) = 0.1
		_RampSharp("Ramp Sharpness", Range(0,1)) = 0.1

	}
	SubShader
	{
		Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
		LOD 200
		ZWrite Off

		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _Metallic;
		sampler2D _DissMap;

		half _Glossiness;
		half _Metalness;
		fixed4 _Color;
		float _CutOut;
		float _RampSize;
		float _RampSharp;

		struct Input
		{
			float2 uv_MainTex;
			float2 uv_DissMap;
		};

		void surf(Input IN, inout SurfaceOutputStandard o)
		{
			// Main Color
			fixed4 col = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			fixed4 metalRough = tex2D(_Metallic, IN.uv_MainTex);

			// Dissolve value
			fixed dissolve = tex2D(_DissMap, IN.uv_DissMap).a - _CutOut;

			// Ramp color for the given dissolve value
			fixed stepVal = step(dissolve, _RampSize);
			fixed smoothVal = smoothstep(_RampSize, _RampSize - _RampSharp, dissolve);
			
			fixed4 ramp = tex2D(_DissMap, float2(stepVal *  ((min(dissolve, _RampSize)) / _RampSize), 0.0));

			o.Albedo = (1 - smoothVal) * col + (smoothVal) * ramp;
			o.Metallic = _Metalness * metalRough.r;
			o.Smoothness = _Glossiness * metalRough.a;
			o.Alpha = dissolve;

			clip(o.Alpha);
		}
		ENDCG
	}
	FallBack "Diffuse"
}

