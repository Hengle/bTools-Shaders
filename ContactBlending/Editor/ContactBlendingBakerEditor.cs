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
		List<Vector3> originalMeshNormals = new List<Vector3>();
		originalMesh.GetNormals( originalMeshNormals );

		float maxDistance = 1.75f;

		bool oldVal = Physics.queriesHitBackfaces;
		Physics.queriesHitBackfaces = true;

		for ( int i = 0 ; i < originalMesh.vertexCount ; i++ )
		{
			Vector3 worldVertexPos = meshFilter.transform.TransformPoint( originalMeshVerts[i] );
			meshColors[i] = meshColors[i].WithAlpha( 0 );

			RaycastHit hitInfoUp, hitInfoDown;
			bool hitUp, hitDown;

			hitUp = Physics.Raycast( worldVertexPos, Vector3.up, out hitInfoUp, maxDistance, Physics.AllLayers, QueryTriggerInteraction.Ignore );
			hitDown = Physics.Raycast( worldVertexPos, Vector3.down, out hitInfoDown, maxDistance, Physics.AllLayers, QueryTriggerInteraction.Ignore );

			Vector3 worldNormal = meshFilter.transform.TransformDirection( originalMeshNormals[i] );

			Color vertColor = new Color( worldNormal.x, worldNormal.y, worldNormal.z, 0 );

			if ( hitUp && hitDown )
			{
				if ( hitInfoUp.distance > hitInfoDown.distance )
				{
					vertColor = new Color( hitInfoDown.normal.x, hitInfoDown.normal.y, hitInfoDown.normal.z, 1 - MathExtensions.Remap01( hitInfoDown.distance, 0, maxDistance ) );
					//Debug.DrawRay( hitInfoDown.point, hitInfoDown.normal, Color.blue, 0.1f );
					//Debug.DrawLine( worldVertexPos, hitInfoDown.point, Color.green, 0.1f );
				}
				else
				{
					vertColor = new Color( hitInfoUp.normal.x, hitInfoUp.normal.y, hitInfoUp.normal.z, 1 - MathExtensions.Remap01( hitInfoUp.distance, 0, maxDistance ) );
					//Debug.DrawRay( hitInfoUp.point, hitInfoUp.normal, Color.blue, 0.1f );
					//Debug.DrawLine( worldVertexPos, hitInfoUp.point, Color.magenta, 0.1f );
				}
			}
			else if ( hitUp )
			{
				vertColor = new Color( hitInfoUp.normal.x, hitInfoUp.normal.y, hitInfoUp.normal.z, 1 - MathExtensions.Remap01( hitInfoUp.distance, 0, maxDistance ) );
				//Debug.DrawRay( hitInfoUp.point, hitInfoUp.normal, Color.blue, 0.1f );
				//Debug.DrawLine( worldVertexPos, hitInfoUp.point, Color.blue, 0.1f );
			}
			else if ( hitDown )
			{
				vertColor = new Color( hitInfoDown.normal.x, hitInfoDown.normal.y, hitInfoDown.normal.z, 1 - MathExtensions.Remap01( hitInfoDown.distance, 0, maxDistance ) );
				//Debug.DrawRay( hitInfoDown.point, hitInfoDown.normal, Color.blue, 0.1f );
				//Debug.DrawLine( worldVertexPos, hitInfoDown.point, Color.red, 0.1f );
			}

			meshColors[i] = vertColor;

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