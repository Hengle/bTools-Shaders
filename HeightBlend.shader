Shader "bShaders/HeightBlend" 
{
	Properties 
	{
		_Color ("Color", Color) = (1,1,1,1)
		_BlendColor ("Blend Color", Color) = (1,1,1,1)

		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_BlendTex ("Blend Albedo (RGB)", 2D) = "white" {}

		[NoScaleOffset]_MetalRough ("Metal (R) AO (G) Height (B) Roughness (A)", 2D) = "black" {}
		[NoScaleOffset]_BlendMetalRough ("Metal (R) AO (G) Height (B) Roughness (A)", 2D) = "black" {}

		[NoScaleOffset]_Normal ("Normal Map", 2D) = "bump" {}
		[NoScaleOffset]_BlendNormal ("Blend Normal", 2D) = "bump" {}
		_Parallax("Parallax Value", Range(0,1)) = 0.1

		[NoScaleOffset]_HeightMap ("Blend Height", 2D) = "black" {}
		_HeightValue("Height Value", Range(-1,1)) = 0.5
		_HeightFalloff("Height Falloff", Range(0.001,1)) = 1
		[Toggle] _VertexBlend ("Use Vertex Blending", Float) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows
		#pragma shader_feature VERTEX_BLEND

		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _BlendTex;
		sampler2D _HeightMap;
		sampler2D _MetalRough;
		sampler2D _BlendMetalRough;
		sampler2D _Normal;
		sampler2D _BlendNormal;

		struct Input 
		{
			float2 uv_MainTex;
			float2 uv_BlendTex;
			float3 viewDir;
			float4 color : COLOR;
		};

		fixed4 _Color;
		fixed4 _BlendColor;
		fixed _HeightValue;
		fixed _HeightFalloff;
		fixed _Parallax;

		void surf (Input IN, inout SurfaceOutputStandard o) 
		{
			// Lerp 
			fixed4 heightMask = tex2D ( _HeightMap , IN.uv_MainTex );

			#if VERTEX_BLEND
			fixed lerpValue =  saturate( ( ( 1 - ( heightMask - _HeightValue ) ) / _HeightFalloff) * (1- IN.color.r ) ); // Use Vertex Blending too
			#else
			fixed lerpValue =  saturate( ( 1 - ( heightMask - _HeightValue ) ) / _HeightFalloff ); // Height blending only
			#endif

			// Parallax 
			fixed heightMain = tex2D (_MetalRough, IN.uv_MainTex).b;
			fixed heightBlend = tex2D (_BlendMetalRough, IN.uv_BlendTex).b;
			fixed2 texOffset = ParallaxOffset( lerp( heightMain ,heightBlend, lerpValue ), _Parallax,IN.viewDir );

			// Maps
			fixed4 main = tex2D (_MainTex, IN.uv_MainTex + texOffset) * _Color;
			fixed4 blend = tex2D (_BlendTex, IN.uv_BlendTex+texOffset) * _BlendColor;

			fixed4 mainMetal = tex2D(_MetalRough, IN.uv_MainTex);
			fixed4 blendMetal = tex2D(_BlendMetalRough, IN.uv_BlendTex);

			fixed3 mainNormal = UnpackNormal(tex2D(_Normal, IN.uv_MainTex+texOffset));
			fixed3 blendNormal = UnpackNormal(tex2D(_BlendNormal, IN.uv_BlendTex+texOffset));

			// Output
			o.Albedo = lerp( main, blend, lerpValue );
			o.Metallic = lerp( mainMetal.r,blendMetal.r, lerpValue );
			o.Occlusion =  lerp( mainMetal.g,blendMetal.g, lerpValue );
			o.Smoothness = lerp( mainMetal.a,blendMetal.a, lerpValue );
			o.Normal = lerp( mainNormal, blendNormal, lerpValue );

			o.Alpha = main.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
	CustomEditor "HeightBlendEditor"
}
