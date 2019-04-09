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
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows
		#pragma target 3.0
		#pragma shader_feature DRAW_SUBGRID

		sampler2D _MainTex;
		half _Glossiness;
		half _Metallic;
		fixed4 _BackgroundColor, _RowColor, _ColumnColor, _IntersectionColor;
		fixed4 _SubRowColor, _SubColumnColor, _SubIntersectionColor;
		fixed4 _Offsets;
		float _GridSize, _LineWidth;
		float _SubGridSize, _SubLineWidth;

		struct Input 
		{
			float3 worldPos;
			float3 worldNormal;
		};
		
		void surf (Input IN, inout SurfaceOutputStandard o) 
		{
			fixed4 col;
			fixed2 UVs;
		   	if(abs(IN.worldNormal.y) > 0.5)
			{
				UVs = IN.worldPos.xz;
			}
			else if(abs(IN.worldNormal.x) > 0.5)
			{
				UVs = IN.worldPos.yz;
			}
			else
			{
				UVs = IN.worldPos.xy;
			}
 
			fixed rowMask =  step(frac(UVs.x * _GridSize + _Offsets.x), _LineWidth );
			fixed columnMask = step(frac(UVs.y * _GridSize + _Offsets.y), _LineWidth );
			fixed intersectionMask = rowMask * columnMask;
			rowMask -= intersectionMask;
			columnMask -= intersectionMask;
			
			columnMask *= _ColumnColor.a;
			rowMask *= _RowColor.a;
			intersectionMask *= _IntersectionColor.a;

			fixed backgroundMask = saturate(1 - columnMask - rowMask - intersectionMask);
			col = (rowMask * _RowColor ) + (columnMask * _ColumnColor) + (intersectionMask * _IntersectionColor) + (backgroundMask * _BackgroundColor);

			#if DRAW_SUBGRID
				fixed subRowMask =  step(frac(UVs.x * _SubGridSize + _Offsets.z), _SubLineWidth );
				fixed subColumnMask = step(frac(UVs.y * _SubGridSize + _Offsets.w), _SubLineWidth );
				fixed subIntersectionMask = subRowMask * subColumnMask;
				subRowMask -= subIntersectionMask;
				subColumnMask -= subIntersectionMask;


				fixed subGridMask = saturate(subRowMask + subColumnMask + subIntersectionMask);
				col = saturate(col - subGridMask * 10);
				col += ((subRowMask * _SubRowColor) + (subColumnMask * _SubColumnColor) + (subIntersectionMask * _SubIntersectionColor)) * subGridMask;
			#endif

			o.Albedo = col;
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = 1;
		}
		ENDCG
	}
	FallBack "Diffuse"
}