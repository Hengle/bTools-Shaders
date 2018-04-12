Shader "bTools/Dissolve/SphereDissolve" 
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		[NoScaleOffset]_MetallicGlossMap("Metal (R) Roughness (A)", 2D) = "white" {}
		[NoScaleOffset]_OcclusionMap("Ambient Occlusion", 2D) = "white" {}
		[NoScaleOffset][Normal]_BumpMap("Normal Map", 2D) = "bump" {}

		[Enum(UnityEngine.Rendering.CullMode)] _CullMode ("Cull", Float) = 0
		[NoScaleOffset]_RampMap("Ramp (Left to right)", 2D) = "white" {}
		_RampSize("Ramp Size", Range(0,1)) = 0.1
		_RampSharpness("Ramp Sharpness", Range(0,1)) = 0.1
		[Toggle(EMISSIVE_RAMP)]_EmissiveRamp("Emissive Ramp", Float ) = 0
		_EmissiveStrength("Emissive Strength", Float ) = 1

		[Header(Sphere)]
		[Toggle(WORLD_SPACE_DISSOLVE)]_IsWorldSpace("Is World Space", Float) = 0
		[Toggle(INSIDE_DISSOLVE)]_IsInsideDissolve("Is Inside", Float) = 0
		_SpherePosWidth("Pos (XYZ) Scale (W)", Vector) = (0,0,0,1)
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
		LOD 200
		Cull [_CullMode]

		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows addshadow vertex:vert
		#pragma target 3.0
		#pragma shader_feature EMISSIVE_RAMP
		#pragma shader_feature WORLD_SPACE_DISSOLVE
		#pragma shader_feature INSIDE_DISSOLVE

		sampler2D _MainTex, _MetallicGlossMap, _OcclusionMap, _BumpMap;
		fixed4 _Color;

		sampler2D _RampMap;
		fixed4 _SpherePosWidth;
		float _RampSize, _RampSharpness, _EmissiveStrength;

		struct Input
		{
			float2 uv_MainTex;
			float2 uv_DissolveMap;
			float3 dissolvePos;
		};

		void vert(inout appdata_full v, out Input o)
		{
			UNITY_INITIALIZE_OUTPUT(Input, o);

			#if WORLD_SPACE_DISSOLVE
				o.dissolvePos = mul(unity_ObjectToWorld, v.vertex.xyz);
			#else
				o.dissolvePos = v.vertex.xyz;
			#endif
		}

		void surf(Input IN, inout SurfaceOutputStandard o)
		{
			// Main textures
			fixed4 BC = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			fixed4 MR = tex2D(_MetallicGlossMap, IN.uv_MainTex);
			half AO = tex2D(_OcclusionMap, IN.uv_MainTex).r;
			half3 N = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex));

			// Dissolve value
			 #if INSIDE_DISSOLVE
			 	fixed dissolve = smoothstep(1, 0, distance(IN.dissolvePos, _SpherePosWidth.xyz) - (_SpherePosWidth.w/2));
			 #else
				fixed dissolve = smoothstep(0, 1, distance(IN.dissolvePos, _SpherePosWidth.xyz) - (_SpherePosWidth.w/2));
			 #endif

			clip(dissolve - 0.0001);

			// Ramp color for the given dissolve value
			fixed stepVal = step(dissolve, _RampSize);
			fixed smoothVal = smoothstep(_RampSize, _RampSize - _RampSharpness, dissolve);
			fixed4 rampColor = tex2D(_RampMap, float2(stepVal *  ((min(dissolve, _RampSize)) / _RampSize), 0.0));

			// Apply
			o.Albedo = (1 - smoothVal) * BC + smoothVal * rampColor;
			// #if EMISSIVE_RAMP
			// 	o.Emission = smoothVal * rampColor * _EmissiveStrength;
			// #endif
			// o.Metallic = MR.r;
			// o.Smoothness = MR.a;
			// o.Normal = N;
			// o.Occlusion = AO;
			// o.Alpha = 1;
		}
		ENDCG
	}
	FallBack "Diffuse"
}