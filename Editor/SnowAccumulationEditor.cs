using System;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;

public class SnowAccumulationEditor : ShaderGUI
{
    // Properties.
    MaterialProperty color = null;
    MaterialProperty mainTex = null;
    MaterialProperty metalRough = null;
    MaterialProperty ambientOcclu = null;
    MaterialProperty normalMap = null;
    MaterialProperty snowColor = null;
    MaterialProperty snowTex = null;
    MaterialProperty snowMetalRough = null;
    MaterialProperty snowNormal = null;
    MaterialProperty upVector = null;
    MaterialProperty tolerance = null;
    MaterialProperty useAOasMask = null;
    MaterialProperty useVertexBlending = null;
    MaterialProperty displaceAmount = null;

    MaterialEditor m_MaterialEditor = null;

    // Styles.
    GUIContent mainTexName = null;
    GUIContent metalRoughName = null;
    GUIContent ambientOccluName = null;
    GUIContent normalMapName = null;
    GUIContent snowTexName = null;
    GUIContent snowMetalRoughName = null;
    GUIContent snowNormalName = null;
    GUIContent useAOasMaskName = null;
    GUIContent useVertexBlendingName = null;

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        FindProperties(properties);
        m_MaterialEditor = materialEditor;
        EditorGUI.BeginChangeCheck();

        EditorGUILayout.LabelField("Main Texture", EditorStyles.boldLabel);
        m_MaterialEditor.ColorProperty(color, color.displayName);
        m_MaterialEditor.TexturePropertySingleLine(mainTexName, mainTex);
        m_MaterialEditor.TexturePropertySingleLine(metalRoughName, metalRough);
        m_MaterialEditor.TexturePropertySingleLine(ambientOccluName, ambientOcclu);
        m_MaterialEditor.TexturePropertySingleLine(normalMapName, normalMap);
        m_MaterialEditor.TextureScaleOffsetProperty(mainTex);
        GUILayout.Space(8);

        EditorGUILayout.LabelField("Snow Texture", EditorStyles.boldLabel);
        m_MaterialEditor.ColorProperty(snowColor, snowColor.displayName);
        m_MaterialEditor.TexturePropertySingleLine(snowTexName, snowTex);
        m_MaterialEditor.TexturePropertySingleLine(snowMetalRoughName, snowMetalRough);
        m_MaterialEditor.TexturePropertySingleLine(snowNormalName, snowNormal);
        m_MaterialEditor.TextureScaleOffsetProperty(snowTex);
        GUILayout.Space(8);

        EditorGUILayout.LabelField("Blend Settings", EditorStyles.boldLabel);
        m_MaterialEditor.VectorProperty(upVector, upVector.displayName);
        m_MaterialEditor.RangeProperty(tolerance, tolerance.displayName);

        Material targetMat = materialEditor.target as Material;
        bool useVertex = Array.IndexOf(targetMat.shaderKeywords, "DO_DISPLACE") != -1;
        bool useAOMask = Array.IndexOf(targetMat.shaderKeywords, "AO_MASK") != -1;

        useAOMask = EditorGUILayout.Toggle(useAOasMaskName, useAOMask);
        useVertex = EditorGUILayout.Toggle(useVertexBlendingName, useVertex);

        if (useVertex)
        {
            m_MaterialEditor.FloatProperty(displaceAmount, displaceAmount.displayName);
        }

        if (EditorGUI.EndChangeCheck())
        {
            if (useAOMask) targetMat.EnableKeyword("AO_MASK");
            else targetMat.DisableKeyword("AO_MASK");

            if (useVertex) targetMat.EnableKeyword("DO_DISPLACE");
            else targetMat.DisableKeyword("DO_DISPLACE");
        }

        GUILayout.Space(8);
    }

    public void FindProperties(MaterialProperty[] props)
    {
        color = FindProperty("_Color", props);
        mainTex = FindProperty("_MainTex", props);
        mainTexName = new GUIContent(mainTex.displayName);
        metalRough = FindProperty("_Metallic", props);
        metalRoughName = new GUIContent(metalRough.displayName);
        ambientOcclu = FindProperty("_AmbientOcclu", props);
        ambientOccluName = new GUIContent(ambientOcclu.displayName);
        normalMap = FindProperty("_NormalMap", props);
        normalMapName = new GUIContent(normalMap.displayName);

        snowColor = FindProperty("_SnowColor", props);
        snowTex = FindProperty("_SnowMainTex", props);
        snowTexName = new GUIContent(snowTex.displayName);
        snowMetalRough = FindProperty("_SnowMetallic", props);
        snowMetalRoughName = new GUIContent(snowMetalRough.displayName);
        snowNormal = FindProperty("_SnowNormalMap", props);
        snowNormalName = new GUIContent(snowNormal.displayName);

        upVector = FindProperty("_UpVector", props);
        tolerance = FindProperty("_Tolerance", props);
        useAOasMask = FindProperty("_AO_MASK", props);
        useAOasMaskName = new GUIContent(useAOasMask.displayName);
        useVertexBlending = FindProperty("_DO_DISPLACE", props);
        useVertexBlendingName = new GUIContent(useVertexBlending.displayName);
        displaceAmount = FindProperty("_DisplaceAmount", props);
    }
}