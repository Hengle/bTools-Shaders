Shader "bShaders/RampLighting"
{
	Properties
	{
		_MainTex ("Color", 2D) = "white" {}
		[NoScaleOffset]_Ramp ("Ramp", 2D) = "white" {}
		[NoScaleOffset]_Pattern ("Pattern", 2D) = "white" {}
		[Toggle(USE_PATTERN_SIZE)]_USE_PATTERN_SIZE("Use Pattern Size", float) = 0
		_PatternSize("Pattern Size", range(0, 1)) = 0.2
		_RadialSize("Radial Size", range(2, 16)) = 2
		[Toggle(USE_SHADOW_PATTERN)]_USE_SHADOW_PATTERN("Use Shadow Pattern", float) = 0
		[NoScaleOffset]_ShadowPattern ("Shadow Pattern", 2D) = "black" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque"}
		LOD 100

		Pass
		{
			Tags {"LightMode" = "ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag


			#include "PointRampLight.cginc"

			ENDCG
		}

		Pass
		{
			Tags {"LightMode" = "ForwardAdd"}
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			//Blend One One

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdadd_fullshadows nolightmap nodirlightmap nodynlightmap novertexlight
			#pragma shader_feature USE_PATTERN_SIZE
			#pragma shader_feature USE_SHADOW_PATTERN

			#include "PointRampLight.cginc"

			ENDCG
		}

		Pass
		{
			Tags {"LightMode" = "ShadowCaster"}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_shadowcaster

            #include "UnityCG.cginc"

            struct v2f 
			{ 
                V2F_SHADOW_CASTER;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i)
            }

			ENDCG
		}
	}
}
