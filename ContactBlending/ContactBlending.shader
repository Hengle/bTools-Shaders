Shader "bshaders/ContactBlending" 
{
	Properties 
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_TerrainTex ("Terrain Albedo (RGB)", 2D) = "white" {}
		[NoScaleOffset][Normal]_MainNormal ("Normal", 2D) = "bump" {}
		[NoScaleOffset][Normal]_TerrainNormal ("Terrain Normal", 2D) = "bump" {}

		_Hardness("Hardness", range(0.001, 1)) = 1
		_Test("Test", float) = 1
	}
	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows vertex:vert
		#pragma target 3.0

		struct Input 
		{
			float4 color : COLOR;
			float2 uv_MainTex;
			float2 uv_TerrainTex;
			float3 vertNormal;
			float4 vertTangent;
		};

		sampler2D _MainTex, _TerrainTex, _MainNormal, _TerrainNormal;
		fixed4 _Color;
		float _Hardness, _Test;


		void vert(inout appdata_full v, out Input o)
		{
			UNITY_INITIALIZE_OUTPUT(Input, o);
			o.vertNormal = v.normal;
			o.vertTangent = v.tangent;
		}

		void surf (Input IN, inout SurfaceOutputStandard o) 
		{
			fixed4 baseColor = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			fixed4 terrainColor = tex2D (_TerrainTex, IN.uv_TerrainTex);
			float3 mainNormal = UnpackNormal(tex2D(_MainNormal, IN.uv_MainTex));
			float3 terrainNormal = UnpackNormal(tex2D(_TerrainNormal, IN.uv_TerrainTex));

			float3 vertBinormal = cross(IN.vertNormal, IN.vertTangent.xyz) * IN.vertTangent.w;
			float3x3 rotation = float3x3(IN.vertTangent.xyz, vertBinormal, IN.vertNormal );

			float3 terrainUpInTangent = mul(IN.color.rgb, rotation);


			float blend = saturate(IN.color.a + _Hardness);
			o.Albedo = lerp( baseColor.rgb, terrainColor.rgb, blend);
			o.Normal = lerp( mainNormal, terrainUpInTangent, blend);
			//o.Normal = float3(0,1,0);




			o.Metallic = 0;
			o.Smoothness = 0;
			o.Alpha = 1;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
