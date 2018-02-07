using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;

public class HeightBlendEditor : ShaderGUI
{
	// Properties.
	MaterialProperty color = null;
	MaterialProperty blendColor = null;
	MaterialProperty mainAlbedo = null;
	MaterialProperty blendAlbedo = null;
	MaterialProperty mainMetalRough = null;
	MaterialProperty blendMetalRough = null;
	MaterialProperty mainNormal = null;
	MaterialProperty blendNormal = null;
	MaterialProperty blendMap = null;
	MaterialProperty heightValue = null;
	MaterialProperty heightFalloff = null;
	MaterialProperty paralaxValue = null;

	MaterialEditor m_MaterialEditor = null;
	// Styles.

	GUIContent albedoLabel = new GUIContent( "Albedo" );
	GUIContent normalLabel = new GUIContent( "Normal" );
	GUIContent metalRoughLabel = new GUIContent( "Maps", "(R)Metal (G)Occlusion (B)Height (A)Roughness" );
	GUIContent blandMapLabel = new GUIContent( "Blend Height" );

	public override void OnGUI( MaterialEditor materialEditor, MaterialProperty[] properties )
	{
		FindProperties( properties );
		m_MaterialEditor = materialEditor;

		EditorGUILayout.LabelField( "Main Texture" + TextureName( mainAlbedo ), EditorStyles.boldLabel );
		m_MaterialEditor.ColorProperty( color, color.displayName );
		m_MaterialEditor.TexturePropertySingleLine( albedoLabel, mainAlbedo );
		EditorGUIUtility.labelWidth = 164;
		m_MaterialEditor.TexturePropertySingleLine( metalRoughLabel, mainMetalRough );
		EditorGUIUtility.labelWidth = 0;
		m_MaterialEditor.TexturePropertySingleLine( normalLabel, mainNormal );
		m_MaterialEditor.TextureScaleOffsetProperty( mainAlbedo );
		GUILayout.Space( 8 );

		EditorGUILayout.LabelField( "Blend Texture" + TextureName( blendAlbedo ), EditorStyles.boldLabel );
		m_MaterialEditor.ColorProperty( blendColor, blendColor.displayName );
		m_MaterialEditor.TexturePropertySingleLine( albedoLabel, blendAlbedo );
		EditorGUIUtility.labelWidth = 200;
		m_MaterialEditor.TexturePropertySingleLine( metalRoughLabel, blendMetalRough );
		EditorGUIUtility.labelWidth = 0;
		m_MaterialEditor.TexturePropertySingleLine( normalLabel, blendNormal );
		m_MaterialEditor.TextureScaleOffsetProperty( blendAlbedo );
		GUILayout.Space( 8 );

		EditorGUILayout.LabelField( "Blend Params", EditorStyles.boldLabel );
		EditorGUIUtility.labelWidth = 200;
		m_MaterialEditor.TexturePropertySingleLine( blandMapLabel, blendMap );
		EditorGUIUtility.labelWidth = 0;
		m_MaterialEditor.RangeProperty( heightValue, heightValue.displayName );
		m_MaterialEditor.RangeProperty( heightFalloff, heightFalloff.displayName );
		m_MaterialEditor.RangeProperty( paralaxValue, paralaxValue.displayName );

		//Toggle
		Material targetMat = m_MaterialEditor.target as Material;
		string[] keyWords = targetMat.shaderKeywords;

		bool toggle = keyWords.Contains( "VERTEX_BLEND" );
		EditorGUI.BeginChangeCheck();
		toggle = EditorGUILayout.Toggle( "Use Vertex Blending (Green)", toggle );

		if ( EditorGUI.EndChangeCheck() )
		{
			// if the checkbox is changed, reset the shader keywords
			var keywords = new List<string> { toggle ? "VERTEX_BLEND" : string.Empty };
			targetMat.shaderKeywords = keywords.ToArray();
			EditorUtility.SetDirty( targetMat );
		}

		GUILayout.Space( 8 );
	}

	public void FindProperties( MaterialProperty[] props )
	{
		color = FindProperty( "_Color", props );
		blendColor = FindProperty( "_BlendColor", props );
		mainAlbedo = FindProperty( "_MainTex", props );
		blendAlbedo = FindProperty( "_BlendTex", props );
		mainMetalRough = FindProperty( "_MetalRough", props );
		blendMetalRough = FindProperty( "_BlendMetalRough", props );
		mainNormal = FindProperty( "_Normal", props );
		blendNormal = FindProperty( "_BlendNormal", props );
		blendMap = FindProperty( "_HeightMap", props );
		heightValue = FindProperty( "_HeightValue", props );
		heightFalloff = FindProperty( "_HeightFalloff", props );
		paralaxValue = FindProperty( "_Parallax", props );
	}

	string TextureName( MaterialProperty prop )
	{
		if ( prop.textureValue )
		{
			return " (" + prop.textureValue.name + ")";
		}

		return string.Empty;
	}
}
