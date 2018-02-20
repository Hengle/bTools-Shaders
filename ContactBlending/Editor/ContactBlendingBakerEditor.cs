using UnityEngine;
using UnityEditor;
using System;
using System.Collections.Generic;
using bTools.CodeExtensions;

[CustomEditor( typeof( ContactBlendingBaker ) )]
public class ContactBlendingBakerEditor : Editor
{
	ContactBlendingBaker script;
	MeshFilter mf;
	MeshRenderer mr;

	private void OnEnable()
	{
		script = target as ContactBlendingBaker;
		mf = script.GetComponent<MeshFilter>();
		mr = script.GetComponent<MeshRenderer>();
	}
	public override void OnInspectorGUI()
	{
		base.OnInspectorGUI();

		if ( GUILayout.Button( "Bake" ) )
		{
			Bake( mf, mr );
		}
	}

	private void OnSceneGUI()
	{
		if ( script.autoBake ) Bake( mf, mr );
	}

	private void Bake( MeshFilter meshFilter, MeshRenderer meshRenderer )
	{
		Mesh originalMesh = meshFilter.sharedMesh;

		if ( originalMesh == null )
		{
			Debug.LogError( "No source mesh found !" );
			return;
		}

		List<Color> meshColors = new List<Color>();
		originalMesh.GetColors( meshColors );

		if ( meshColors.Count == 0 )
		{
			if ( !originalMesh.isReadable )
			{
				Debug.LogError( "Source mesh has no vertex colors and is not readable - please make it readable and try again" );
				return;
			}

			for ( int i = 0 ; i < originalMesh.vertexCount ; i++ )
			{
				meshColors.Add( Color.black );
			}

			originalMesh.SetColors( meshColors );
		}

		List<Vector3> originalMeshVerts = new List<Vector3>();
		originalMesh.GetVertices( originalMeshVerts );

		float maxDistance = 1.4f;

		bool oldVal = Physics.queriesHitBackfaces;
		Physics.queriesHitBackfaces = true;

		for ( int i = 0 ; i < originalMesh.vertexCount ; i++ )
		{
			Vector3 worldVertexPos = meshFilter.transform.TransformPoint( originalMeshVerts[i] );
			//			meshColors[i] = meshColors[i].WithAlpha( 1 - MathExtensions.Remap01( closestDistance, 0, maxDistance ) );
			meshColors[i] = meshColors[i].WithAlpha( 0 );

			RaycastHit hitInfo;
			float closestDistance = maxDistance;
			if ( Physics.Raycast( worldVertexPos, Vector3.up, out hitInfo, maxDistance, Physics.AllLayers, QueryTriggerInteraction.Ignore ) )
			{
				closestDistance = hitInfo.distance;

				Color vertColor = new Color( hitInfo.normal.x, hitInfo.normal.y, hitInfo.normal.z, 1 - MathExtensions.Remap01( closestDistance, 0, maxDistance ) );
				meshColors[i] = vertColor;
			}
			else if ( Physics.Raycast( worldVertexPos, Vector3.down, out hitInfo, maxDistance, Physics.AllLayers, QueryTriggerInteraction.Ignore ) )
			{
				closestDistance = hitInfo.distance;

				Color vertColor = new Color( hitInfo.normal.x, hitInfo.normal.y, hitInfo.normal.z, 1 - MathExtensions.Remap01( closestDistance, 0, maxDistance ) );
				meshColors[i] = vertColor;
			}


		}

		Physics.queriesHitBackfaces = oldVal;

		// Create vertex stream
		Mesh vStream = new Mesh();
		vStream.vertices = originalMesh.vertices;
		vStream.triangles = originalMesh.triangles;
		vStream.SetColors( meshColors );

		meshRenderer.additionalVertexStreams = vStream;
	}
}