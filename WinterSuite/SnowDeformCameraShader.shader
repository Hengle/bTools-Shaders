Shader "Hidden/SnowDeformCameraShader"
{
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			float4 vert(appdata v) : SV_POSITION
			{
				return UnityObjectToClipPos( v.vertex );
			}

			fixed4 frag(float4 vertex : SV_POSITION) : SV_Target
			{
				return vertex.z;
			}

			ENDCG
		}
	}
}
