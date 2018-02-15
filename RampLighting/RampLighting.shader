Shader "bShaders/RampLighting"
{
	Properties
	{
		_Ramp ("Ramp", 2D) = "white" {}
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
			
			#include "RampLighting.cginc"

			ENDCG
		}

		Pass
		{
			Tags {"LightMode" = "ForwardAdd"}
			Blend One Zero
			ZWrite Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile DIRECTIONAL POINT

			#include "RampLighting.cginc"

			ENDCG
		}
	}
}
