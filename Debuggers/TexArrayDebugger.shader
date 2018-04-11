Shader "bTools/Debuggers/TexArrayDebugger"
{
	Properties
	{
		_TexArray ("Tex", 2DArray) = "" {}
		[KeywordEnum(RGBA, RGB, A)] _Channel ("Channel", Float) = 0
        [IntRange]_SliceRange ("Slices", Range(0,16)) = 6
        _UVScale ("UVScale", Float) = 1.0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.5
			#pragma shader_feature _CHANNEL_RGBA
			#pragma shader_feature _CHANNEL_RGB
			#pragma shader_feature _CHANNEL_A

			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;

			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 uv : TEXCOORD0;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _UVScale, _SliceRange;

			UNITY_DECLARE_TEX2DARRAY(_TexArray);
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
	            o.uv.xy = v.uv.xy * _UVScale;
                o.uv.z = _SliceRange;
                return o;

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				#if _CHANNEL_RGBA
					return UNITY_SAMPLE_TEX2DARRAY(_TexArray, i.uv);
				#elif _CHANNEL_RGB
					return fixed4(UNITY_SAMPLE_TEX2DARRAY(_TexArray, i.uv).rgb, 1);
				#elif _CHANNEL_A
					return UNITY_SAMPLE_TEX2DARRAY(_TexArray, i.uv).a;
				#endif

				return 0;
			}
			ENDCG
		}
	}
}
