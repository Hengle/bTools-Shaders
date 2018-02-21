// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "bshaders/ContactBlending" 
{
	Properties 
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		[NoScaleOffset]_MainMetal ("Albedo (RGB)", 2D) = "black" {}
		[NoScaleOffset][Normal]_MainNormal ("Normal", 2D) = "bump" {}


		_TerrainTex ("Terrain Albedo (RGB)", 2D) = "white" {}
		[NoScaleOffset]_TerrainMetal ("Terrain Metal (RGB)", 2D) = "black" {}
		[NoScaleOffset][Normal]_TerrainNormal ("Terrain Normal", 2D) = "bump" {}

		_TexBlend("Tex Blend", range(0, 1)) = 1
		_NormalBlend("Normal Blend", range(0, 1)) = 1
	}
	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows addshadow vertex:vert
		#pragma target 5.0

		struct Input 
		{
			float4 color : COLOR;
			float2 uv_MainTex;
			float2 uv_TerrainTex;
			float3 vertNormal;
			float4 vertTangent;
		};

		sampler2D _MainTex, _TerrainTex, _MainNormal, _TerrainNormal, _MainMetal, _TerrainMetal;
		fixed4 _Color;
		float _TexBlend, _NormalBlend;

		void vert(inout appdata_full v, out Input o)
		{
			float normalBlend = clamp(v.color.a * _NormalBlend, 0, 1);

			float3 objSpaceNrm = UnityWorldToObjectDir(v.color.rgb);
			
			v.normal = normalize(lerp( v.normal, objSpaceNrm, normalBlend));
			v.tangent = normalize(lerp( v.tangent, v.texcoord2, normalBlend));

			UNITY_INITIALIZE_OUTPUT(Input, o);

			o.vertNormal = v.normal;
			o.vertTangent = v.tangent;
		}

		void surf (Input IN, inout SurfaceOutputStandard o) 
		{
			fixed4 mainColor = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			float3 mainNormal = UnpackNormal(tex2D(_MainNormal, IN.uv_MainTex));
			fixed4 mainMetalRough = tex2D (_MainMetal, IN.uv_MainTex);

			fixed4 terrainColor = tex2D (_TerrainTex, IN.uv_TerrainTex);
			float3 terrainNormal = UnpackNormal(tex2D(_TerrainNormal, IN.uv_TerrainTex));
			fixed4 terrainMetalRough = tex2D (_TerrainMetal, IN.uv_TerrainTex);

			float blend = IN.color.a * _TexBlend;

			o.Albedo = lerp( mainColor.rgb, terrainColor.rgb, blend);
			o.Normal = normalize(lerp(mainNormal, terrainNormal, blend));

			o.Metallic = round(lerp( mainMetalRough.r, terrainMetalRough.r, blend));
			o.Smoothness = lerp( mainMetalRough.a, terrainMetalRough.a, blend);
			o.Alpha = 1;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
