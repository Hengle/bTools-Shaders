Shader "bTools/Other/WorldSpaceCubeMap" 
{
	Properties 
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", Cube) = "white" {}
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

		samplerCUBE _MainTex;
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
			float4 workingNormal =  float4(IN.worldNormal, 1);
			workingNormal = round( workingNormal / sqrt(0.5) * 0.5);

			float3 cleanup =  1 - abs(workingNormal);
			
			// Build translation matrix based on world  position
			float xPart = (frac(IN.worldPos.x * _Scale )) - 0.5;
			float yPart = (frac(IN.worldPos.y * _Scale )) - 0.5;
			float zPart = (frac(IN.worldPos.z * _Scale )) - 0.5;

			float4x4 mat = {1, 0, 0, xPart,
							0, 1, 0, yPart,
							0, 0, 1, zPart,
							0, 0, 0, 1};
			// Translate world normal
			float3 result = mul(mat, workingNormal).xyz;
			// Remove 3rd axis from the resulting translation
			result = result * cleanup;
			result -= workingNormal;
			
			// sample cubemap using result
			o.Albedo = texCUBE(_MainTex, result).rgb * _Color;
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = 1;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
