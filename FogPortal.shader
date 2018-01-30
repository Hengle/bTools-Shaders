﻿Shader "bShaders/FogPortal"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_EmissiveColor("Emissive Color", Color) = (1,1,1,1)
		_DepthFactor("Depth Factor", Float) = 1.0
		[Toggle(USE_DISTANCE)]_UseDistance("Use Distance", Float) = 1
		_DistanceFactor("Distance Factor", Range(1,1000)) = 1
		_BlueRadius("Blur Radius", Range(0.0001,1)) = 1
		_BlurSub("Blur Sub", Range(-10,10)) = 0
		[Enum(UnityEngine.Rendering.CompareFunction)]_ZWriteMode("ZTest Mode", Float) = 0
	}
		SubShader
	{
		Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }
		LOD 200
		Blend One One
		ZWrite Off
		ZTest[_ZWriteMode]

		CGPROGRAM
		#pragma surface surf Standard vertex:vert alpha:fade nolightmap
		#pragma target 3.0
		#pragma shader_feature USE_DISTANCE

		sampler2D _CameraDepthTexture;
		sampler2D _MainTex;

		fixed4 _Color;
		fixed4 _EmissiveColor;
		float _DepthFactor;
		float _DistanceFactor;
		float _BlueRadius;
		float _BlurSub;

		struct Input
		{
			float2 uv_MainTex;
			float4 screenPos;
			float eyeDepth;
			float3 viewDir;
			float dist;
			float3 worldPos;
		};

		void vert(inout appdata_full v, out Input o)
		{
			UNITY_INITIALIZE_OUTPUT(Input,o);
			o.dist = distance(_WorldSpaceCameraPos, mul(unity_ObjectToWorld, v.vertex));
		}

		void surf(Input IN, inout SurfaceOutputStandard o)
		{
			// Depth
			float w = max(0.0001 , IN.screenPos.w);
			float2 screenUV = IN.screenPos.xy / w;
			float3 depth = tex2D(_CameraDepthTexture , screenUV).x;

			depth = 1 - saturate(depth * _DepthFactor);
#if USE_DISTANCE
			depth = depth * (IN.dist / _DistanceFactor);
#endif
			depth = saturate(depth);

			// Edge Blur
			float x = IN.uv_MainTex.x / _BlueRadius;
			float invX = (1 - IN.uv_MainTex.x) / _BlueRadius;
			float y = IN.uv_MainTex.y / _BlueRadius;
			float invY = (1 - IN.uv_MainTex.y) / _BlueRadius;
			float gradient = x * y * invX * invY;
			gradient = saturate(gradient - _BlurSub);

			o.Albedo = _Color;
			o.Emission = _EmissiveColor;
			o.Metallic = 0;
			o.Smoothness = 0;
			o.Alpha = min(gradient , depth);
		}

		ENDCG
	}
}