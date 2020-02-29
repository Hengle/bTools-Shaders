#ifndef INCLUDE_PROTOTYPING
#define INCLUDE_PROTOTYPING

    void WorldToFlatCoords_float(float3 WorldPosition, float2 WorldNormal, out float2 UV)
    {
        if(abs(WorldNormal.y) > 0.5)
        {
            UV = WorldPosition.xz;
        }
        else if(abs(WorldNormal.x) > 0.5)
        {
            UV = WorldPosition.yz;
        }
        else
        {
            UV = WorldPosition.xy;
        }
    }

    void DrawGrid_float(float2 UVs, float GridSize, float2 Offsets, float LineWidth, float LineSmooth,
                    float4 ColumnColor, float4 RowColor, float4 IntersectionColor, float4 BackgroundColor,
                    out float4 Grid)
    {
        float rowMask =  frac(UVs.x * GridSize + Offsets.x);
        rowMask = rowMask * (1 - rowMask) - LineWidth + LineSmooth;
        rowMask = smoothstep(LineSmooth, 0.0, rowMask);

        float columnMask =  frac(UVs.y * GridSize + Offsets.y);
        columnMask = columnMask * (1 - columnMask) - LineWidth + LineSmooth;
        columnMask = smoothstep(LineSmooth, 0.0, columnMask);

        float intersectionMask = rowMask * columnMask;
        rowMask -= intersectionMask;
        columnMask -= intersectionMask;
        
        columnMask *= ColumnColor.a;
        rowMask *= RowColor.a;
        intersectionMask *= IntersectionColor.a;

        float backgroundMask = saturate(1 - columnMask - rowMask - intersectionMask) * BackgroundColor.a;
        Grid.rgb = (rowMask * RowColor.rgb) + (columnMask * ColumnColor.rgb) + (intersectionMask * IntersectionColor.rgb) + (backgroundMask * BackgroundColor.rgb);
        Grid.a = saturate(columnMask + rowMask + intersectionMask);
    }
#endif
