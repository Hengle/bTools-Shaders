Shader "bTools/Prototyping/PrototypeGrid" 
{
	Properties 
	{
		[Header(Main Grid)]
		_BackgroundColor ("Background Color", Color) = (1,1,1,1)
		_RowColor ("Row  Color", Color) = (1,1,1,1)
		_ColumnColor ("Column  Color", Color) = (1,1,1,1)
		_IntersectionColor ("Intersection  Color", Color) = (1,1,1,1)
		_GridSize("Grid Spacing", Float) = 1
		_LineWidth("Line Width", Range(0,1)) = 0.1
		[Space(8)]
		[Header(Sub Grid)]
		[Toggle(DRAW_SUBGRID)]_DrawSubgrid("Draw Subgrid", Float) = 0
		_SubRowColor ("Row  Color", Color) = (1,1,1,1)
		_SubColumnColor ("Column  Color", Color) = (1,1,1,1)
		_SubIntersectionColor ("Intersection  Color", Color) = (1,1,1,1)
		_SubGridSize("Grid Spacing", Float) = 1
		_SubLineWidth("Line Width", Range(0,1)) = 0.1

		[Space(8)]
		[Header(Other)]
		_Offsets ("Offsets (Grid, Subgrid)", Vector) = (0,0,0,0)
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
	}
	SubShader 
	{
		Pass 
		{
			Tags 
			{
				"RenderType" = "Opaque"
				"RenderPipeline" = "LightweightPipeline"
				"IgnoreProjector" = "True"
			}
			LOD 100
			
			HLSLPROGRAM
			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x
			#pragma target 2.0

			#pragma vertex vert
			#pragma fragment frag

			#pragma shader_feature DRAW_SUBGRID

			#include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"

			float4 _BackgroundColor, _RowColor, _ColumnColor, _IntersectionColor;
			float4 _SubRowColor, _SubColumnColor, _SubIntersectionColor;
			float4 _Offsets;
			float _GridSize, _LineWidth;
			float _SubGridSize, _SubLineWidth;

			struct Attributes 
			{
				float3 positionOS : POSITION;
				float3 normalOS   : NORMAL;
			};

			struct Varyings 
			{
				float4 positionCS : SV_POSITION;
				float3 positionWS : TEXCOORD0;
				float3 normalWS   : NORMAL;
			};
			
			Varyings vert (Attributes input) 
			{
				Varyings output;
				output.positionWS = TransformObjectToWorld(input.positionOS);
				output.positionCS = TransformWorldToHClip(output.positionWS);
				output.normalWS = TransformObjectToWorldNormal(input.normalOS);
				return output;
			}

			float4 frag (Varyings input) : SV_Target
			{
				float4 col;
				float2 UVs;
				if(abs(input.normalWS.y) > 0.5)
				{
					UVs = input.positionWS.xz;
				}
				else if(abs(input.normalWS.x) > 0.5)
				{
					UVs = input.positionWS.yz;
				}
				else
				{
					UVs = input.positionWS.xy;
				}
	
				float rowMask =  step(frac(UVs.x * _GridSize + _Offsets.x), _LineWidth );
				float columnMask = step(frac(UVs.y * _GridSize + _Offsets.y), _LineWidth );
				float intersectionMask = rowMask * columnMask;
				rowMask -= intersectionMask;
				columnMask -= intersectionMask;
				
				columnMask *= _ColumnColor.a;
				rowMask *= _RowColor.a;
				intersectionMask *= _IntersectionColor.a;

				float backgroundMask = saturate(1 - columnMask - rowMask - intersectionMask);
				col = (rowMask * _RowColor ) + (columnMask * _ColumnColor) + (intersectionMask * _IntersectionColor) + (backgroundMask * _BackgroundColor);

				#if DRAW_SUBGRID
					float subRowMask =  step(frac(UVs.x * _SubGridSize + _Offsets.z), _SubLineWidth );
					float subColumnMask = step(frac(UVs.y * _SubGridSize + _Offsets.w), _SubLineWidth );
					float subIntersectionMask = subRowMask * subColumnMask;
					subRowMask -= subIntersectionMask;
					subColumnMask -= subIntersectionMask;


					float subGridMask = saturate(subRowMask + subColumnMask + subIntersectionMask);
					col = saturate(col - subGridMask * 10);
					col += ((subRowMask * _SubRowColor) + (subColumnMask * _SubColumnColor) + (subIntersectionMask * _SubIntersectionColor)) * subGridMask;
				#endif

				return col;
			}
			ENDHLSL	
		}
	}
}