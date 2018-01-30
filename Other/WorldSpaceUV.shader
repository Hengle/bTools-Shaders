Shader "bShaders/WorldSpaceUV" 
{
	Properties 
{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Scale("Scale", float) = 1
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
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
		   if(abs(IN.worldNormal.y) > 0.5)
			{
				o.Albedo = tex2D(_MainTex, IN.worldPos.xz * _Scale) * _Color;
			}
			else if(abs(IN.worldNormal.x) > 0.5)
			{
				o.Albedo = tex2D(_MainTex, IN.worldPos.yz * _Scale) * _Color;
			}
			else
			{
				o.Albedo = tex2D(_MainTex, IN.worldPos.xy * _Scale) * _Color;
			}
 
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = 1;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
