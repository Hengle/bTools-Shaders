using UnityEngine;
using UnityEditor;

public class VertexBlendShaderGUI : ShaderGUI
{
    // Properties.
    MaterialProperty redAlbedo = null;
    MaterialProperty greenAlbedo = null;
    MaterialProperty blueAlbedo = null;
    MaterialProperty redNormal = null;
    MaterialProperty greenNormal = null;
    MaterialProperty blueNormal = null;
    MaterialProperty redMetalRough = null;
    MaterialProperty greenMetalRough = null;
    MaterialProperty blueMetalRough = null;
    MaterialEditor m_MaterialEditor = null;
    // Styles.
    GUIContent albedoLabel = new GUIContent("Albedo");
    GUIContent normalLabel = new GUIContent("Normal");
    GUIContent metalRoughLabel = new GUIContent("(R)Metal (G) Height (A)Rough");

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        FindProperties(properties);
        m_MaterialEditor = materialEditor;

        EditorGUILayout.LabelField("Background" + TextureName(redAlbedo), EditorStyles.boldLabel);
        m_MaterialEditor.TexturePropertySingleLine(albedoLabel, redAlbedo);
        EditorGUIUtility.labelWidth = 256;
        m_MaterialEditor.TexturePropertySingleLine(metalRoughLabel, redMetalRough);
        EditorGUIUtility.labelWidth = 0;
        m_MaterialEditor.TexturePropertySingleLine(normalLabel, redNormal);
        m_MaterialEditor.TextureScaleOffsetProperty(redAlbedo);
        GUILayout.Space(8);

        EditorGUILayout.LabelField("Overlay 1" + TextureName(greenAlbedo), EditorStyles.boldLabel);
        m_MaterialEditor.TexturePropertySingleLine(albedoLabel, greenAlbedo);
        EditorGUIUtility.labelWidth = 256;
        m_MaterialEditor.TexturePropertySingleLine(metalRoughLabel, greenMetalRough);
        EditorGUIUtility.labelWidth = 0;
        m_MaterialEditor.TexturePropertySingleLine(normalLabel, greenNormal);
        m_MaterialEditor.TextureScaleOffsetProperty(greenAlbedo);
        GUILayout.Space(8);

        EditorGUILayout.LabelField("Overlay 2" + TextureName(blueAlbedo), EditorStyles.boldLabel);
        m_MaterialEditor.TexturePropertySingleLine(albedoLabel, blueAlbedo);
        EditorGUIUtility.labelWidth = 256;
        m_MaterialEditor.TexturePropertySingleLine(metalRoughLabel, blueMetalRough);
        EditorGUIUtility.labelWidth = 0;
        m_MaterialEditor.TexturePropertySingleLine(normalLabel, blueNormal);
        m_MaterialEditor.TextureScaleOffsetProperty(blueAlbedo);
    }

    public void FindProperties(MaterialProperty[] props)
    {
        redAlbedo = FindProperty("_BackgroundVertexAlbedo", props);
        greenAlbedo = FindProperty("_GreenVertexAlbedo", props);
        blueAlbedo = FindProperty("_BlueVertexAlbedo", props);

        redNormal = FindProperty("_BackgroundVertexNormal", props);
        greenNormal = FindProperty("_GreenVertexNormal", props);
        blueNormal = FindProperty("_BlueVertexNormal", props);

        redMetalRough = FindProperty("_BackgroundMetalRough", props);
        greenMetalRough = FindProperty("_GreenMetalRough", props);
        blueMetalRough = FindProperty("_BlueMetalRough", props);
    }

    private string TextureName(MaterialProperty prop)
    {
        if (prop.textureValue)
        {
            return " (" + prop.textureValue.name + ")";
        }

        return string.Empty;
    }
}
