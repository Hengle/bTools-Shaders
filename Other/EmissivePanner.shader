Shader "bShaders/EmissivePanner"
{//TODO : Replace panning map with vector map
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		[NoScaleOffset]_MetalRough("(R)Metallic (G)Rough", 2D) = "black" {}
		[NoScaleOffset]_Emissive("Emissive", 2D) = "white" {}
		[HDR]_EmissiveColor("Emissive Color", Color) = (1,1,1,1)
		_PanningMap("Panning Map", 2D) = "white" {}
		_SpeedX("Speed X", range(-100,100)) = 0
		_SpeedY("Speed Y", range(-100,100)) = 0
		_StencilValue("StencilValue", Float) = 0
		[Toggle] _Clip("Cutout", Float) = 0
		_ClipCutoff("Cutoff", range(0,1)) = 0.5
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" }
			LOD 200

			Stencil
			{
				Ref[_StencilValue]
				Comp Always
				Pass Replace
			}

			CGPROGRAM
			#pragma surface surf Standard fullforwardshadows
			#pragma multi_compile __ _CLIP_ON
			#pragma target 3.0

			sampler2D _MainTex;
			sampler2D _MetalRough;
			sampler2D _Emissive;
			sampler2D _PanningMap;

			struct Input
			{
				float2 uv_MainTex;
				float2 uv_PanningMap;
				float4 _Time;
			};

			fixed4 _Color;
			fixed4 _EmissiveColor;
			fixed _SpeedX;
			fixed _SpeedY;
			#if _CLIP_ON
			fixed _ClipCutoff;
			#endif

			void surf(Input IN, inout SurfaceOutputStandard o)
			{
				fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
				fixed4 metalRough = tex2D(_MetalRough, IN.uv_MainTex);
				fixed4 emissiveMap = tex2D(_Emissive, IN.uv_MainTex);

				fixed2 panUV = fixed2(IN.uv_PanningMap.x + (_Time.x * _SpeedX), IN.uv_PanningMap.y + (_Time.x * _SpeedY));
				fixed4 panMap = tex2D(_PanningMap, panUV);

				o.Emission = (emissiveMap*panMap) * _EmissiveColor;

				#if _CLIP_ON
				clip(emissiveMap - _ClipCutoff);
				#endif

				o.Albedo = c.rgb;
				o.Metallic = metalRough.r;
				o.Smoothness = metalRough.g;
				o.Alpha = c.a;
			}
			ENDCG
		}
			FallBack "Diffuse"
}
