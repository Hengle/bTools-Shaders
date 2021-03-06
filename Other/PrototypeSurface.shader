﻿Shader "bTools/Prototyping/PrototypeSurface" 
{
	Properties 
{
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Color ("Color", Color) = (1,1,1,1)
		_Scale("Scale", Float) = 1
	}
	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows
		#pragma target 3.0

		sampler2D _MainTex;
		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		float _Scale;

		struct Input 
		{
			float2 uv_MainTex;
			float3 worldPos;
			float3 worldNormal;
		};
		
		void surf (Input IN, inout SurfaceOutputStandard o) 
		{
			fixed4 col;
		   	if(abs(IN.worldNormal.y) > 0.5)
			{
				col = tex2D(_MainTex, IN.worldPos.xz * _Scale);
			}
			else if(abs(IN.worldNormal.x) > 0.5)
			{
				col = tex2D(_MainTex, IN.worldPos.yz * _Scale);
			}
			else
			{
				col = tex2D(_MainTex, IN.worldPos.xy * _Scale);
			}
 
			col = saturate((col * col.a) + (col * _Color * (1 - col.a)));

			o.Albedo = col;
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = 1;
		}
		ENDCG
	}
	FallBack "Diffuse"
}