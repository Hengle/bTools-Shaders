Shader "Hidden/SnowDeformAdder"
{
	Properties
	{
		[HideInInspector]_MainTex("MainTex", 2D) = "white" {}
		[HideInInspector]_CurrentHeight("Current Height", 2D) = "black" {}
		[HideInInspector]_RefillSpeed("RefillSpeed", Float) = 0
	}

	SubShader
	{
		Cull Off
		ZWrite Off
		ZTest Always

		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			sampler2D  _CurrentHeight;
			float _RefillSpeed;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			float frag(v2f i) : SV_Target
			{
				float2 uv = float2( 1 - i.uv.x , i.uv.y);

				float camHeight = tex2D(_MainTex, uv);
				float currentHeight = tex2D(_CurrentHeight, i.uv);

				// Only update height if the input height is deeper than the current height
				currentHeight = max(currentHeight.r, camHeight.r);
				
				currentHeight -= _RefillSpeed * unity_DeltaTime.x;

				return currentHeight;
			}

			ENDCG
		}
	}
}
