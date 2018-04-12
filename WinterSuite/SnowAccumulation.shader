Shader "bTools/Winter/SnowAccumulation" 
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		[NoScaleOffset]_MetallicGlossMap("Metal (R) Roughness (A)", 2D) = "white" {}
		[NoScaleOffset]_OcclusionMap("Ambient Occlusion", 2D) = "white" {}
		[NoScaleOffset][Normal]_BumpMap("Normal Map", 2D) = "bump" {}

		_SnowColor("Color", Color) = (1,1,1,1)
		_SnowMainTex("Albedo (RGB)", 2D) = "white" {}
		[NoScaleOffset]_SnowMetallic("Metal (R) Roughness (A)", 2D) = "black" {}
		[NoScaleOffset][Normal]_SnowNormalMap("Normal Map", 2D) = "bump" {}

		_UpVector("Accumulation Dir", Vector) = (0,1,0,0)
		_Tolerance("Tolerance", Range(-1,1)) = 0
		_Softness("Softness", Range(0,1)) = 0.75

		[Toggle(AO_MASK)]_AO_MASK("Use AO as a mask", float) = 0
		_AOContribution("AO Contribution", Range(0,1)) = 0
		[Toggle(DO_DISPLACE)]_DO_DISPLACE("Use Displacement", Float) = 0
		_DisplaceAmount("Displace Amount", Float) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue"="Geometry" }
		LOD 200

		CGPROGRAM
		#pragma surface surf Standard vertex:vert fullforwardshadows addshadow
		#pragma target 3.0
		#pragma shader_feature AO_MASK
		#pragma shader_feature DO_DISPLACE

		sampler2D _MainTex, _MetallicGlossMap, _OcclusionMap, _BumpMap;
 		fixed4 _Color;
		 
		sampler2D _SnowMainTex, _SnowMetallic, _SnowNormalMap;
		fixed4 _SnowColor;
		fixed3 _UpVector;
		fixed _DisplaceAmount, _Tolerance, _AOContribution, _Softness;

		struct Input
		{
			float2 uv_MainTex;
			float2 uv_SnowMainTex;
			float upDot;
			float4 vertTangent;
			float3 vertNormal;
		};

		void vert(inout appdata_full v, out Input o)
		{
			UNITY_INITIALIZE_OUTPUT(Input, o);
			o.vertTangent = v.tangent;
			o.vertNormal = v.normal;
			
			#if DO_DISPLACE
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				o.upDot =  saturate(dot(worldNormal, _UpVector) + _Tolerance);
				v.vertex.xyz += UnityWorldToObjectDir(_UpVector) * _DisplaceAmount * o.upDot;
			#endif
		}

		void surf(Input IN, inout SurfaceOutputStandard o)
		{
			fixed4 BC = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			fixed4 MR = tex2D(_MetallicGlossMap, IN.uv_MainTex);
			half AO = tex2D(_OcclusionMap, IN.uv_MainTex).r;
			half3 N = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex));

			//Get normal map in world space
			float3 vertBinormal = cross(IN.vertNormal, IN.vertTangent.xyz) * IN.vertTangent.w;
			float3x3 rotation = float3x3(IN.vertTangent.xyz, vertBinormal, IN.vertNormal );
			half3 worldNormal = UnityObjectToWorldNormal( mul(N, rotation));

			// More precise updot using normal map
			IN.upDot = saturate(dot(worldNormal, _UpVector) + _Tolerance);
			#if AO_MASK
				IN.upDot *= AO * (1 - _AOContribution);
			#endif 
			IN.upDot = saturate(IN.upDot / _Softness);

			fixed4 snowCol = tex2D(_SnowMainTex, IN.uv_SnowMainTex) * _SnowColor;
			fixed4 snowMetalRough = tex2D(_SnowMetallic, IN.uv_SnowMainTex);
			fixed3 snowNormal = UnpackNormal(tex2D(_SnowNormalMap, IN.uv_SnowMainTex));

			o.Albedo = lerp(BC, snowCol, IN.upDot);
			o.Metallic = round(lerp(MR.r, snowMetalRough.r, IN.upDot));
			o.Smoothness = lerp(MR.a, snowMetalRough.a, IN.upDot);
			o.Normal = lerp(N, snowNormal, IN.upDot);
			o.Occlusion = AO;
			o.Alpha = 1;
		}
		ENDCG
	}
	FallBack "Diffuse"
	CustomEditor "SnowAccumulationShaderGUI"
}
