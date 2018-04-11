Shader "bTools/Winter/Crystal" 
{
	Properties 
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		[NoScaleOffset]_MetallicGlossMap("Metallic", 2D) = "white" {}
		[NoScaleOffset]_BumpMap("Normal Map", 2D) = "bump" {}
		_NormalScale("Normal Scale", Float) = 1
		[NoScaleOffset]_OcclusionMap("Occlusion", 2D) = "white" {}
        [HDR]_EmissionColor("Color", Color) = (0,0,0)
        [NoScaleOffset]_EmissionMap("Emission", 2D) = "white" {}

		_NoiseIntensity("Noise Intensity", Range(-1,1)) = 0.1
		_FaceIntensity("Face Intensity", Range(-1,1)) = 0.1
		_NoiseMap("Noise", 2D) = "black" {}
		_OpacityRange("Opacity Range", Range(-0,1)) = 0.5
		_CrystalInside("Inside Visibility", Range(0,1)) = 0.5

		_Glossiness ("Smoothness", Range(0,1)) = 0.5
	}
	SubShader 
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
		LOD 200

		GrabPass{"_CrystalBackgroundGrab"}
		Cull Front

		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows
		#pragma target 5.0

		sampler2D _MainTex, _MetallicGlossMap, _BumpMap, _OcclusionMap, _EmissionMap, _NoiseMap;
		half _Glossiness, _OpacityRange, _NoiseIntensity, _FaceIntensity, _NormalScale;
		fixed4 _Color, _EmissionColor;

		struct Input 
		{
			float2 uv_MainTex;
		};

		void surf (Input IN, inout SurfaceOutputStandard o) 
		{
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			fixed4 mr = tex2D (_MetallicGlossMap, IN.uv_MainTex);
			fixed4 e = tex2D (_EmissionMap, IN.uv_MainTex) * _EmissionColor;
			fixed3 n = UnpackScaleNormal(tex2D (_BumpMap, IN.uv_MainTex), _NormalScale);
			fixed ao = tex2D (_OcclusionMap, IN.uv_MainTex).r;

			o.Albedo = c.rgb;
			o.Metallic = mr.r;
			o.Smoothness = mr.a * _Glossiness;
			o.Occlusion = ao;
			o.Emission = e;
			o.Normal = n;
			o.Alpha = 1;
		}
		ENDCG

		GrabPass{"_CrystalGrab"}
		Cull Back

		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows vertex:vert
		#pragma target 5.0

		sampler2D _MainTex, _MetallicGlossMap, _BumpMap, _OcclusionMap, _EmissionMap, _CrystalBackgroundGrab, _CrystalGrab, _NoiseMap;
		half _Glossiness, _OpacityRange, _NoiseIntensity, _FaceIntensity, _NormalScale, _CrystalInside;
		fixed4 _Color, _EmissionColor;

		struct Input 
		{
			float2 uv_MainTex;
			float2 uv_NoiseMap;
			float4 grabUV;
			float3 vertNormal;
		};

		void vert(inout appdata_full v, out Input o)
		{
			UNITY_INITIALIZE_OUTPUT(Input, o);
			o.grabUV = ComputeGrabScreenPos(UnityObjectToClipPos(v.vertex));
			o.vertNormal = v.normal;
		}

		void surf (Input IN, inout SurfaceOutputStandard o) 
		{
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			fixed4 mr = tex2D (_MetallicGlossMap, IN.uv_MainTex);
			fixed4 e = tex2D (_EmissionMap, IN.uv_MainTex) * _EmissionColor;
			fixed3 n = UnpackScaleNormal(tex2D (_BumpMap, IN.uv_MainTex), _NormalScale);
			fixed ao = tex2D (_OcclusionMap, IN.uv_MainTex).r;
			fixed4 noise = tex2D (_NoiseMap, IN.uv_NoiseMap);

			fixed4 cleanGrab = tex2Dproj(_CrystalGrab, UNITY_PROJ_COORD(IN.grabUV));
			IN.grabUV.xy += ( noise.xy * _NoiseIntensity) + (IN.vertNormal.xy * _FaceIntensity);
			fixed4 grab = tex2Dproj(_CrystalBackgroundGrab, UNITY_PROJ_COORD(IN.grabUV));

			o.Albedo = saturate(lerp(cleanGrab , grab, _CrystalInside) * ((1 - c.rgb) * _OpacityRange));
			o.Metallic = mr.r;
			o.Smoothness = mr.a * _Glossiness;
			o.Occlusion = ao;
			o.Emission = e;
			o.Normal = n;
			o.Alpha = 1;
		}
		ENDCG
	}
	FallBack "Diffuse"
}