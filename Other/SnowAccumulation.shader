Shader "bShaders/SnowAccumulation" 
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		[NoScaleOffset]_Metallic("Metal (R) Roughness (A)", 2D) = "white" {}
		[NoScaleOffset]_AmbientOcclu("Ambient Occlusion", 2D) = "white" {}
		[NoScaleOffset][Normal]_NormalMap("Normal Map", 2D) = "bump" {}

		_UpVector("Up Vector", vector) = (0,1,0,0)
		_Tolerance("Tolerance", range(-1,1)) = 0
		[Toggle(AO_MASK)]_AO_MASK("Use AO as a mask", float) = 0
		[Toggle(DO_DISPLACE)]_DO_DISPLACE("Use Vertex", float) = 0
		_DisplaceAmount("Displace Amount", float) = 1
		_SnowColor("Color", Color) = (1,1,1,1)
		_SnowMainTex("Albedo (RGB)", 2D) = "white" {}
		[NoScaleOffset]_SnowMetallic("Metal (R) Roughness (A)", 2D) = "black" {}
		[NoScaleOffset][Normal]_SnowNormalMap("Normal Map", 2D) = "bump" {}
	}
	SubShader
	{
		Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
		LOD 200

		CGPROGRAM
		#pragma surface surf Standard vertex:vert fullforwardshadows
		#pragma target 3.0
		#pragma shader_feature AO_MASK
		#pragma shader_feature DO_DISPLACE

		sampler2D _MainTex, _Metallic, _AmbientOcclu, _NormalMap;
		sampler2D _SnowMainTex, _SnowMetallic, _SnowNormalMap;
		fixed4 _Color, _SnowColor;
		fixed3 _UpVector;
		fixed _DisplaceAmount, _Tolerance;

		struct Input
		{
			float2 uv_MainTex;
			float2 uv_SnowMainTex;
			float upDot;
		};

		void vert(inout appdata_full v, out Input o)
		{
			UNITY_INITIALIZE_OUTPUT(Input, o);
			
			#if DO_DISPLACE
			fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
			o.upDot =  saturate(dot(worldNormal, _UpVector) + _Tolerance);
			v.vertex.xyz += UnityWorldToObjectDir(_UpVector) * _DisplaceAmount * o.upDot;
			#endif
		}

		void surf(Input IN, inout SurfaceOutputStandard o)
		{
			fixed4 col = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			fixed4 metalRough = tex2D(_Metallic, IN.uv_MainTex);
			fixed4 ao = tex2D(_AmbientOcclu, IN.uv_MainTex);
			fixed3 normal = UnpackNormal(tex2D(_NormalMap, IN.uv_MainTex));

			#if !DO_DISPLACE
			fixed3 worldNormal = UnityObjectToWorldNormal(normal);
			IN.upDot = saturate(dot(normal, _UpVector) + _Tolerance);
			#endif

			#if AO_MASK
			IN.upDot *= ao;
			#endif 

			fixed4 snowCol = tex2D(_SnowMainTex, IN.uv_SnowMainTex) * _SnowColor;
			fixed4 snowMetalRough = tex2D(_SnowMetallic, IN.uv_SnowMainTex);
			fixed3 snowNormal = UnpackNormal(tex2D(_SnowNormalMap, IN.uv_SnowMainTex));

			o.Albedo = lerp(col, snowCol, IN.upDot);
			o.Metallic = round(lerp(metalRough.r, snowMetalRough.r, IN.upDot));
			o.Smoothness = lerp(metalRough.a, snowMetalRough.a, IN.upDot);
			o.Normal = lerp(normal, snowNormal, IN.upDot);
			o.Occlusion = ao;
			o.Alpha = 1;
		}
		ENDCG
	}
	FallBack "Diffuse"
	CustomEditor "SnowAccumulationEditor"
}
