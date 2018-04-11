Shader "bTools/Other/RimFade"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		[NoScaleOffset]_Metallic("Metal (R) Roughness (A)", 2D) = "white" {}
		[NoScaleOffset][Normal]_Normal("Normal", 2D) = "bump"{}
		_Metalness("Metallic", Range(0, 1)) = 0.5
		_Glossiness("Smoothness", Range(0, 1)) = 0.5

		_Falloff("Falloff", Range(0, 10)) = 1
	}
	SubShader
	{
		Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
		LOD 200
		ZWrite off
		Blend SrcAlpha OneMinusSrcAlpha

		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows alpha:fade

		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _Metallic;
		sampler2D _Normal;
		half _Glossiness;
		half _Metalness;
		fixed4 _Color;

		fixed _Falloff;
		fixed _FalloffSharp;

		struct Input
		{
			float2 uv_MainTex;
			float3 viewDir;
		};

		void surf(Input IN, inout SurfaceOutputStandard o)
		{
			fixed4 col = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			fixed4 metalRough = tex2D(_Metallic, IN.uv_MainTex);
			fixed3 normal = UnpackNormal(tex2D(_Normal, IN.uv_MainTex));

			o.Albedo = col.rgb;
			o.Metallic = _Metalness * metalRough.r;
			o.Smoothness = _Glossiness * metalRough.a;
			o.Normal = normal;
			
			float rim = saturate(dot(IN.viewDir, o.Normal) *_Falloff);

			o.Alpha = rim * col.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
