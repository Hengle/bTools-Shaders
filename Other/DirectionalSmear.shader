Shader "bTools/Other/DirectionalSmear" 
{
	Properties 
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		[NoScaleOffset]_Metallic("Metal (R) Roughness (A)", 2D) = "white" {}
		_Metalness("Metallic", Range(0,1)) = 0.5
		_Glossiness("Smoothness", Range(0,1)) = 0.5

		_LastPos("Last Position", vector) = (0,0,0,0)
		_CurrentPos("Current Position", vector) = (0,0,0,0)
	}
	SubShader 
	{
		Tags { "RenderType"="Opaque"  "DisableBatching" = "True"}
		LOD 200

		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows vertex:vert
		#pragma target 3.0

		#include "../Includes/NoiseBase.cginc"

		struct Input 
		{
			float2 uv_MainTex;
		};

		sampler2D _MainTex;
		sampler2D _Metallic;
		sampler2D _DissMap;
		half _Glossiness;
		half _Metalness;
		fixed4 _Color;
		float4 _LastPos, _CurrentPos;

		void vert(inout appdata_full v, out Input o)
		{
			float4 toLastPos = _LastPos - _CurrentPos;
			v.vertex += toLastPos * rand(v.vertex.y);

			UNITY_INITIALIZE_OUTPUT(Input, o);
		}

		void surf (Input IN, inout SurfaceOutputStandard o) 
		{
			fixed4 col = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			fixed4 metalRough = tex2D(_Metallic, IN.uv_MainTex);

			o.Albedo = col;
			o.Metallic = _Metalness * metalRough.r;
			o.Smoothness = _Glossiness * metalRough.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
