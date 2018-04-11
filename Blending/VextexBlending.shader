Shader "bTools/Blending/VextexBlending" 
{
	Properties
	{
		//Background
		_BackgroundVertexAlbedo("Albedo (Red)", 2D) = "white" {}
		[NoScaleOffset]_BackgroundVertexNormal("Normal (Red)", 2D) = "bump" {}
		[NoScaleOffset]_BackgroundMetalRough("(R)Metal (G) Height (A)Rough (Red)", 2D) = "black" {}

		// Overlay1
		_GreenVertexAlbedo("Albedo (Green)", 2D) = "white" {}
		[NoScaleOffset]_GreenVertexNormal("Normal (Green)", 2D) = "bump" {}
		[NoScaleOffset]_GreenMetalRough("(R)Metal (G) Height (A)Rough (Green)", 2D) = "black" {}

		// Overlay2
		_BlueVertexAlbedo("Albedo (Blue)", 2D) = "white" {}
		[NoScaleOffset]_BlueVertexNormal("Normal (Blue)", 2D) = "bump" {}
		[NoScaleOffset]_BlueMetalRough("(R)Metal (G) Height  (A)Rough (Blue)", 2D) = "black" {}
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 200

		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows vertex:vert
		#pragma target 5.0

		sampler2D _BackgroundVertexAlbedo;
		sampler2D _BackgroundVertexNormal;
		sampler2D _BackgroundMetalRough;

		sampler2D _GreenVertexAlbedo;
		sampler2D _GreenVertexNormal;
		sampler2D _GreenMetalRough;

		sampler2D _BlueVertexAlbedo;
		sampler2D _BlueVertexNormal;
		sampler2D _BlueMetalRough;

		struct Input
		{
			float4 color : COLOR;
			float4 texCoord0;
			float4 texCoord1;
			float4 texCoord2;
			float4 texCoord3;
			float2 uv_BackgroundVertexAlbedo;
			float2 uv_GreenVertexAlbedo;
			float2 uv_BlueVertexAlbedo;
		};

		void vert (inout appdata_full v, out Input o) 
		{
			UNITY_INITIALIZE_OUTPUT(Input, o);
			o.texCoord0 = v.texcoord;
			o.texCoord1 = v.texcoord1;
			o.texCoord2 = v.texcoord2;
			o.texCoord3 = v.texcoord3;
		}

		void surf(Input IN, inout SurfaceOutputStandard o)
		{
			// Texture blends are stored in the vertex color
			// Height value is stored inside texCoord3.z
			// Falloff value is stored inside texCoord3.w

			// Unwrap maps - Albedo
			fixed4 BackgroundAlbedo = tex2D(_BackgroundVertexAlbedo, IN.uv_BackgroundVertexAlbedo);
			fixed4 greenAlbedo = tex2D(_GreenVertexAlbedo, IN.uv_GreenVertexAlbedo);
			fixed4 blueAlbedo = tex2D(_BlueVertexAlbedo, IN.uv_BlueVertexAlbedo);

			// MetalRough
			fixed4 BackgroundMetalRough = tex2D(_BackgroundMetalRough, IN.uv_BackgroundVertexAlbedo);
			fixed4 greenMetalRough = tex2D(_GreenMetalRough, IN.uv_GreenVertexAlbedo);
			fixed4 blueMetalRough = tex2D(_BlueMetalRough, IN.uv_BlueVertexAlbedo);

			// Normal
			fixed3 BackgroundNormal = UnpackNormal(tex2D(_BackgroundVertexNormal, IN.uv_BackgroundVertexAlbedo));
			fixed3 greenNormal = UnpackNormal(tex2D(_GreenVertexNormal, IN.uv_GreenVertexAlbedo));
			fixed3 blueNormal = UnpackNormal(tex2D(_BlueVertexNormal, IN.uv_BlueVertexAlbedo));

			// Calc blends
			float blendBase = ( ( 1 - ( BackgroundMetalRough.g - IN.texCoord3.z ) ) / IN.texCoord3.w);
			float greenBlend = saturate(blendBase * IN.color.g ); 
			float blueBlend = saturate( blendBase * IN.color.b ); 

			// Apply
			o.Albedo = lerp(lerp( BackgroundAlbedo, greenAlbedo, greenBlend ), blueAlbedo, blueBlend);
			o.Metallic = lerp(lerp( BackgroundMetalRough.r, greenMetalRough.r, greenBlend ), blueMetalRough.r, blueBlend);
			o.Smoothness = lerp(lerp( BackgroundMetalRough.a, greenMetalRough.a, greenBlend ), blueMetalRough.a, blueBlend);
			o.Normal = lerp(lerp( BackgroundNormal, greenNormal, greenBlend ), blueNormal, blueBlend);

			o.Alpha = 1;
		}

		ENDCG
	}

	FallBack "Diffuse"
	CustomEditor "VertexBlendShaderGUI"
}