Shader "bTools/Other/SubSurfaceScattering" 
{
	Properties 
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		[NoScaleOffset][Normal]_Normal ("Normal", 2D) = "bump" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0

		_SSSColor ("SSS Color", Color) = (1,1,1,1)
		_SSSAmbient ("SSS Ambient", Color) = (1,1,1,1)
		[NoScaleOffset]_Thickness ("Thickness ", 2D) = "white" {}
		_Distortion("Distortion", range(0, 1)) = 0
		_Attenuation("Attenuation", range(0, 1)) = 1
		_Scale("Scale", range(0, 10)) = 1
		_Power("Power", range(1, 64)) = 1
	}
	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		#pragma surface surf StandardSSS fullforwardshadows
		#pragma target 3.0

		struct Input 
		{
			float2 uv_MainTex;
		};

		sampler2D _MainTex, _Thickness, _Normal;
		half _Glossiness, _Metallic;
		fixed4 _Color, _SSSColor, _SSSAmbient;
		float _Distortion, _Power, _Scale, _Attenuation;
		float thickness;

		#include "UnityPBSLighting.cginc"
		inline fixed4 LightingStandardSSS(SurfaceOutputStandard s, fixed3 viewDir, UnityGI gi)
		{
			fixed4 pbr = LightingStandard(s, viewDir, gi);
			float3 lDir = gi.light.dir;

			float3 vLight = lDir + s.Normal * _Distortion;
			float VdotH = pow(saturate(dot(viewDir, -vLight)), _Power) * _Scale;
			float3 I = _Attenuation * (VdotH + _SSSAmbient) * thickness;
			pbr.rgb += gi.light.color * I * _SSSColor;
		
			return pbr;
		}

		void LightingStandardSSS_GI(SurfaceOutputStandard s, UnityGIInput data, inout UnityGI gi)
		{
			LightingStandard_GI(s, data, gi); 
		}

		void surf (Input IN, inout SurfaceOutputStandard o) 
		{
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			thickness = 1 - tex2D(_Thickness, IN.uv_MainTex);

			o.Normal = UnpackNormal(tex2D(_Normal, IN.uv_MainTex));
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
