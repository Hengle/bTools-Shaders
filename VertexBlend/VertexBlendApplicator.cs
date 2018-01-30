using System;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.Internal;

[RequireComponent( typeof( MeshFilter ) )]
[RequireComponent( typeof( MeshRenderer ) )]
[RequireComponent( typeof( MeshCollider ) )]
[ExecuteInEditMode, ExcludeFromDocs]
public class VertexBlendApplicator : MonoBehaviour
{
	public Mesh editedMesh = null;

#if UNITY_EDITOR
	[NonSerialized] public List<Vector3> cachedPos = new List<Vector3>();
	[NonSerialized] public List<Color> cachedColors = new List<Color>();
	//[NonSerialized] public List<Vector4> cachedUV0 = new List<Vector4>();
	//[NonSerialized] public List<Vector4> cachedUV1 = new List<Vector4>();
	//[NonSerialized] public List<Vector4> cachedUV2 = new List<Vector4>();
	[NonSerialized] public List<Vector4> cachedUV3 = new List<Vector4>();

	private void OnEnable()
	{
		Mesh mesh = GetComponent<MeshFilter>().sharedMesh;
		MeshRenderer meshRenderer = GetComponent<MeshRenderer>();

		if ( mesh == null )
		{
			Debug.LogError( "Cannot use VertexEditor if there is no mesh !" );
			return;
		}

		if ( editedMesh == null )
		{
			editedMesh = Instantiate( mesh );
		}

		editedMesh.GetVertices( cachedPos );
		editedMesh.GetColors( cachedColors );
		//editedMesh.GetUVs( 0, cachedUV0 );
		//editedMesh.GetUVs( 1, cachedUV1 );
		//editedMesh.GetUVs( 2, cachedUV2 );
		editedMesh.GetUVs( 3, cachedUV3 );

		if ( cachedColors.Count == 0 )
		{
			for ( int i = 0 ; i < cachedPos.Count ; i++ )
			{
				cachedColors.Add( Color.black );
			}
			if ( mesh.colors == null || mesh.colors.Length == 0 )
			{
				mesh.SetColors( cachedColors );
			}
		}

		//if ( cachedUV0.Count == 0 )
		//{
		//	for ( int i = 0 ; i < cachedPos.Count ; i++ )
		//	{
		//		cachedUV0.Add( Vector4.one );
		//	}
		//	if ( mesh.uv == null || mesh.uv.Length == 0 )
		//	{
		//		mesh.SetUVs( 0, cachedUV0 );
		//	}
		//}

		//if ( cachedUV1.Count == 0 )
		//{
		//	for ( int i = 0 ; i < cachedPos.Count ; i++ )
		//	{
		//		cachedUV1.Add( Vector4.one );
		//	}
		//	if ( mesh.uv2 == null || mesh.uv2.Length == 0 )
		//	{
		//		mesh.SetUVs( 1, cachedUV1 );
		//	}
		//}

		//if ( cachedUV2.Count == 0 )
		//{
		//	for ( int i = 0 ; i < cachedPos.Count ; i++ )
		//	{
		//		cachedUV2.Add( Vector4.one );
		//	}
		//	if ( mesh.uv3 == null || mesh.uv3.Length == 0 )
		//	{
		//		mesh.SetUVs( 2, cachedUV2 );
		//	}
		//}

		if ( cachedUV3.Count == 0 )
		{
			for ( int i = 0 ; i < cachedPos.Count ; i++ )
			{
				cachedUV3.Add( Vector4.one );
			}
			if ( mesh.uv4 == null || mesh.uv4.Length == 0 )
			{
				mesh.SetUVs( 3, cachedUV3 );
			}
		}

		meshRenderer.additionalVertexStreams = editedMesh;
	}

	private void Reset()
	{
		OnEnable();
	}

	public void FixStream()
	{
		var mr = GetComponent<MeshRenderer>();
		if ( mr != null ) mr.additionalVertexStreams = editedMesh;
	}

	public void ApplyCache( VertexEditFlags editFlags )
	{
		UnityEditor.Undo.RecordObject( editedMesh, "Edited Mesh" );

		if ( ( editFlags & VertexEditFlags.Position ) != 0 )
		{
			editedMesh.SetVertices( cachedPos );
			editedMesh.RecalculateNormals();
			editedMesh.RecalculateBounds();
		}

		if ( ( editFlags & VertexEditFlags.Color ) != 0 )
		{
			editedMesh.SetColors( cachedColors );
		}

		if ( ( editFlags & VertexEditFlags.UV3 ) != 0 )
		{
			editedMesh.SetUVs( 3, cachedUV3 );
		}

		//editedMesh.SetUVs( 0, cachedUV0 );
		//editedMesh.SetUVs( 1, cachedUV1 );
		//editedMesh.SetUVs( 2, cachedUV2 );
	}

	public void SaveMeshToAsset()
	{
		var mr = GetComponent<MeshFilter>();
		Mesh originalMesh = mr.sharedMesh;
		var path = UnityEditor.AssetDatabase.GenerateUniqueAssetPath( UnityEditor.AssetDatabase.GetAssetPath( mr.sharedMesh ) );
		path = path.Replace( ".fbx", ".asset" );
		path = path.Replace( ".FBX", ".asset" );

		UnityEditor.AssetDatabase.CreateAsset( editedMesh, path );
		UnityEditor.AssetDatabase.SaveAssets();
		UnityEditor.AssetDatabase.Refresh();
		var newAsset = UnityEditor.AssetDatabase.LoadAssetAtPath<Mesh>( path );
		UnityEditor.EditorGUIUtility.PingObject( newAsset );
	}

	public void UpdateCache()
	{
		editedMesh.GetVertices( cachedPos );
		editedMesh.GetColors( cachedColors );
		//editedMesh.GetUVs( 0, cachedUV0 );
		//editedMesh.GetUVs( 1, cachedUV1 );
		//editedMesh.GetUVs( 2, cachedUV2 );
		editedMesh.GetUVs( 3, cachedUV3 );
	}

	[Flags]
	public enum VertexEditFlags
	{
		None = 0,
		Position = 1,
		Color = 2,
		UV0 = 4,
		UV1 = 8,
		UV2 = 16,
		UV3 = 32
	}

#endif

	private void OnDestroy()
	{
		if ( !Application.isPlaying )
		{
			var mr = GetComponent<MeshRenderer>();
			if ( mr != null ) mr.additionalVertexStreams = null;
		}
	}
}

