Shader "bShaders/ChannelDebugger"
{
	Properties
	{
		[KeywordEnum(Color, ColorAlpha, Uvs0, Uvs1, Uvs2, Normal, WorldNormal, Tangent, ScreenNormal)] _Channel ("Channel", Float) = 0
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
			#pragma shader_feature _CHANNEL_COLOR
			#pragma shader_feature _CHANNEL_COLORALPHA
			#pragma shader_feature _CHANNEL_UVS0
			#pragma shader_feature _CHANNEL_UVS1
			#pragma shader_feature _CHANNEL_UVS2
			#pragma shader_feature _CHANNEL_NORMAL
			#pragma shader_feature _CHANNEL_TANGENT
			#pragma shader_feature _CHANNEL_WORLDNORMAL
			#pragma shader_feature _CHANNEL_SCREENNORMAL
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float3 normal : NORMAL;
				float3 tangent : TANGENT;
				float2 uv : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				float2 uv2 : TEXCOORD2;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 color : COLOR;
				float3 normal : NORMAL;
				float3 tangent : TANGENT;
				float2 uv : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				float2 uv2 : TEXCOORD2;
				float3 worldNormal : TEXCOORD4;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.uv1 = v.uv1;
				o.uv2 = v.uv2;
				o.color = v.color;
				o.normal = v.normal;
				o.tangent = v.tangent;
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = float4(1,0,1,1);

				#if _CHANNEL_COLOR
					col = float4(i.color.rgb, 1);
				#elif _CHANNEL_COLORALPHA
					col = float4(i.color.aaa, 1);
				#elif _CHANNEL_UVS0
					col = float4(i.uv, 0, 1);
				#elif _CHANNEL_UVS1
					col = float4(i.uv1, 0, 1);					
				#elif _CHANNEL_UVS2
					col = float4(i.uv2, 0, 1);
				#elif _CHANNEL_NORMAL
					col = float4(i.normal, 1);
				#elif _CHANNEL_TANGENT
					col = float4(i.tangent, 1);					
				#elif _CHANNEL_WORLDNORMAL
					col = float4(i.worldNormal, 1);					
				#elif _CHANNEL_SCREENNORMAL
					col = mul(UNITY_MATRIX_V, i.worldNormal);
				#endif

				return col;
			}
			ENDCG
		}
	}
}
