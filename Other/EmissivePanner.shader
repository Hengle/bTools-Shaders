Shader "bTools/Other/EmissivePanner"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		[NoScaleOffset]_Metallic("Metal (R) Roughness (A)", 2D) = "white" {}
		_Metalness("Metallic", Range(0,1)) = 0.5
		_Glossiness("Smoothness", Range(0,1)) = 0.5

		[HDR]_EmissiveColor("Emissive Color", Color) = (1,1,1,1)
		[NoScaleOffset]_Emissive("Emissive", 2D) = "black" {}
		_PanningMap("Panning Map", 2D) = "white" {}
		_SpeedX("Speed X", range(-100,100)) = 0
		_SpeedY("Speed Y", range(-100,100)) = 0
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" }
			LOD 200

			CGPROGRAM
			#pragma surface surf Standard fullforwardshadows
			#pragma target 3.0

			sampler2D _MainTex;
			sampler2D _Metallic;
			half _Glossiness;
			half _Metalness;
			fixed4 _Color;

			sampler2D _PanningMap;
			sampler2D _Emissive;
			fixed4 _EmissiveColor;
			fixed _SpeedX;
			fixed _SpeedY;

			struct Input
			{
				float2 uv_MainTex;
				float2 uv_PanningMap;
				float4 _Time;
			};

			void surf(Input IN, inout SurfaceOutputStandard o)
			{
				// Main Texture
				fixed4 col = tex2D(_MainTex, IN.uv_MainTex) * _Color;
				fixed4 metalRough = tex2D(_Metallic, IN.uv_MainTex);

				o.Albedo = col.rgb;
				o.Metallic = _Metalness * metalRough.r;
				o.Smoothness = _Glossiness * metalRough.a;
				o.Alpha = col.a;

				// Emissive
				fixed4 emissiveMap = tex2D(_Emissive, IN.uv_MainTex);
				fixed4 panMap = tex2D(_PanningMap, IN.uv_PanningMap);
				// We get the move direction from the pan map, multiply it by time and speed.
				fixed2 panDir = fixed2(panMap.r - 0.5, panMap.g - 0.5);
				panDir = normalize(panDir);
				panDir.x = round(panDir.x);
				panDir.y = round(panDir.y);

				fixed2 panUV = fixed2(IN.uv_MainTex.x  + (_Time.x * _SpeedX * panDir.x), IN.uv_MainTex.y + (panDir.g * _Time.x * _SpeedY));
				// We get the the pan mask from the alpha
				fixed panMask = tex2D(_PanningMap, panUV).a;
				fixed3 emissive = tex2D(_Emissive, IN.uv_MainTex).rgb;

				o.Emission = _EmissiveColor * panMask;
			}
			ENDCG
		}
		FallBack "Diffuse"
}
