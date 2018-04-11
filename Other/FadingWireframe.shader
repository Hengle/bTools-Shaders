Shader "bTools/Other/FadingWireframe"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		[NoScaleOffset]_Metallic("Metal (R) Roughness (A)", 2D) = "white" {}
		_Metalness("Metallic", Range(0,1)) = 0.5
		_Glossiness("Smoothness", Range(0,1)) = 0.5

		[Space(30)]
		_WireColor ("Wire Color", Color) = (0.0, 1.0, 0.0, 1.0)
		_WireThickness ("Wire Thickness", Range(0, 800)) = 100
		_FadeSharpness ("Fade Sharpness", Range(0.001, 1)) = 1
		_Distance ("Distance", float) = 1.0
		[Toggle(INVERSE_MODE)]_InverseMode("Inverse", float) = 0
	}

	SubShader
	{
		Tags 
		{
			"Queue"="Transparent"
			"RenderType"="Opaque"
		}

		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _Metallic;
		half _Glossiness;
		half _Metalness;
		fixed4 _Color;

		struct Input
		{
			float2 uv_MainTex;
		};

		void surf(Input IN, inout SurfaceOutputStandard o)
		{
			// Main Texture
			fixed4 col = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			fixed4 metalRough = tex2D(_Metallic, IN.uv_MainTex);

			o.Albedo = col.rgb;
			o.Metallic = _Metalness * metalRough.r;
			o.Smoothness = _Glossiness * metalRough.a;
			o.Alpha = col.a;
		}
		ENDCG
		
		Pass 
		{
			Tags 
			{
				"IgnoreProjector"="True"
				"Queue"="Transparent"
				"RenderType"="Transparent"
			}

			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			Cull Back

			CGPROGRAM
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag
			#pragma shader_feature INVERSE_MODE

			#include "UnityCG.cginc"

			float _WireThickness;
			float _Distance;
			float _FadeSharpness;
			uniform float4 _WireColor; 

			struct appdata
			{
				float4 vertex : POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2g
			{
				float4 projectionSpaceVertex : SV_POSITION;
				float4 worldSpacePosition : TEXCOORD1;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			struct g2f
			{
				float4 projectionSpaceVertex : SV_POSITION;
				float4 worldSpacePosition : TEXCOORD0;
				float4 dist : TEXCOORD1;
				float distToCam : TEXCOORD2;
				UNITY_VERTEX_OUTPUT_STEREO
			};
			
			v2g vert (appdata v)
			{
				v2g o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				o.projectionSpaceVertex = UnityObjectToClipPos(v.vertex);
				o.worldSpacePosition = mul(unity_ObjectToWorld, v.vertex);
				return o;
			}
			
			[maxvertexcount(3)]
			void geom(triangle v2g i[3], inout TriangleStream<g2f> triangleStream)
			{
				float2 p0 = i[0].projectionSpaceVertex.xy / i[0].projectionSpaceVertex.w;
				float2 p1 = i[1].projectionSpaceVertex.xy / i[1].projectionSpaceVertex.w;
				float2 p2 = i[2].projectionSpaceVertex.xy / i[2].projectionSpaceVertex.w;

				float2 edge0 = p2 - p1;
				float2 edge1 = p2 - p0;
				float2 edge2 = p1 - p0;

				// To find the distance to the opposite edge, we take the
				// formula for finding the area of a triangle Area = Base/2 * Height, 
				// and solve for the Height = (Area * 2)/Base.
				// We can get the area of a triangle by taking its cross product
				// divided by 2.  However we can avoid dividing our area/base by 2
				// since our cross product will already be double our area.
				float area = abs(edge1.x * edge2.y - edge1.y * edge2.x);
				float wireThickness = 800 - _WireThickness;

				g2f o;

				o.worldSpacePosition = i[0].worldSpacePosition;
				o.projectionSpaceVertex = i[0].projectionSpaceVertex;
				o.dist.xyz = float3( (area / length(edge0)), 0.0, 0.0) * o.projectionSpaceVertex.w * wireThickness;
				o.dist.w = 1.0 / o.projectionSpaceVertex.w;
				o.distToCam  = distance(_WorldSpaceCameraPos, o.worldSpacePosition);
				UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(i[0], o);
				triangleStream.Append(o);

				o.worldSpacePosition = i[1].worldSpacePosition;
				o.projectionSpaceVertex = i[1].projectionSpaceVertex;
				o.dist.xyz = float3(0.0, (area / length(edge1)), 0.0) * o.projectionSpaceVertex.w * wireThickness;
				o.dist.w = 1.0 / o.projectionSpaceVertex.w;
				o.distToCam  = distance(_WorldSpaceCameraPos, o.worldSpacePosition);
				UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(i[1], o);
				triangleStream.Append(o);

				o.worldSpacePosition = i[2].worldSpacePosition;
				o.projectionSpaceVertex = i[2].projectionSpaceVertex;
				o.dist.xyz = float3(0.0, 0.0, (area / length(edge2))) * o.projectionSpaceVertex.w * wireThickness;
				o.dist.w = 1.0 / o.projectionSpaceVertex.w;
				o.distToCam  = distance(_WorldSpaceCameraPos, o.worldSpacePosition);
				UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(i[2], o);
				triangleStream.Append(o);
			}

			fixed4 frag (g2f i) : SV_Target
			{
				float minDistanceToEdge = min(i.dist[0], min(i.dist[1], i.dist[2])) * i.dist[3];

				// Early out if we know we are not on a line segment.
				if(minDistanceToEdge > 0.5)
				{
					return 0;
				}

				// Smooth our line out
				float t = exp2(2 * minDistanceToEdge * minDistanceToEdge);

				fixed4 transparentCol = fixed4(_WireColor.rgb, 0);
				fixed4 finalColor = lerp(transparentCol, _WireColor, t);

				#if INVERSE_MODE
				finalColor.a *= min(saturate((_Distance - i.distToCam) /_FadeSharpness), finalColor.a);
				#else
				finalColor.a = 1 - max(saturate((_Distance - i.distToCam) / _FadeSharpness), finalColor.a);
				#endif

				return finalColor;
			}
			ENDCG
		}
	}
}