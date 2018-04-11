using System;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.Internal;

namespace bTools.Shaders
{
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

    [RequireComponent(typeof(MeshFilter))]
    [RequireComponent(typeof(MeshRenderer))]
    [ExecuteInEditMode, ExcludeFromDocs]
    public class VertexBlendApplicator : MonoBehaviour
    {
#if UNITY_EDITOR

        public Mesh meshStream = null;
        public MeshRenderer meshRenderer;
        public MeshFilter meshFilter;
        public List<Vector3> cachedPos = new List<Vector3>();
        public List<Color> cachedColors = new List<Color>();
        public List<Vector4> cachedUV3 = new List<Vector4>();

        public void Update()
        {
            meshRenderer.additionalVertexStreams = meshStream;
        }

        private void OnEnable()
        {
            InitCache();
        }

        private void Reset()
        {
            meshStream = null;
            InitCache();
        }

        private void OnDestroy()
        {
            if (!Application.isPlaying)
            {
                meshRenderer.additionalVertexStreams = null;
            }
        }

        public void InitCache()
        {
            meshRenderer = GetComponent<MeshRenderer>();
            meshFilter = GetComponent<MeshFilter>();
            Mesh mesh = meshFilter.sharedMesh;

            if (mesh == null)
            {
                Debug.LogError("Cannot use VertexEditor if there is no mesh !");
                return;
            }

            if (meshStream == null)
            {
                meshStream = Instantiate(mesh);
                meshStream.MarkDynamic();
            }

            meshStream.GetVertices(cachedPos);
            meshStream.GetColors(cachedColors);
            meshStream.GetUVs(3, cachedUV3);

            if (cachedColors.Count == 0)
            {
                for (int i = 0; i < cachedPos.Count; i++)
                {
                    cachedColors.Add(Color.black);
                }
                if (mesh.colors == null || mesh.colors.Length == 0)
                {
                    mesh.SetColors(cachedColors);
                }
            }

            if (cachedUV3.Count == 0)
            {
                for (int i = 0; i < cachedPos.Count; i++)
                {
                    cachedUV3.Add(Vector4.one);
                }
                if (mesh.uv4 == null || mesh.uv4.Length == 0)
                {
                    mesh.SetUVs(3, cachedUV3);
                }
            }

            meshRenderer.additionalVertexStreams = meshStream;
        }

        public void ApplyCache(VertexEditFlags editFlags)
        {
            if ((editFlags & VertexEditFlags.Position) != 0)
            {
                meshStream.SetVertices(cachedPos);
                meshStream.RecalculateNormals();
                meshStream.RecalculateBounds();
            }

            if ((editFlags & VertexEditFlags.Color) != 0)
            {
                meshStream.SetColors(cachedColors);
            }

            if ((editFlags & VertexEditFlags.UV3) != 0)
            {
                meshStream.SetUVs(3, cachedUV3);
            }
        }

        public void UpdateCache()
        {
            meshStream.GetVertices(cachedPos);
            meshStream.GetColors(cachedColors);
            meshStream.GetUVs(3, cachedUV3);
        }

        // public void SaveMeshToAsset()
        // {
        //     var mr = GetComponent<MeshFilter>();
        //     Mesh originalMesh = mr.sharedMesh;
        //     var path = UnityEditor.AssetDatabase.GenerateUniqueAssetPath(UnityEditor.AssetDatabase.GetAssetPath(mr.sharedMesh));
        //     path = path.Replace(".fbx", ".asset");
        //     path = path.Replace(".FBX", ".asset");

        //     UnityEditor.AssetDatabase.CreateAsset(editedMesh, path);
        //     UnityEditor.AssetDatabase.SaveAssets();
        //     UnityEditor.AssetDatabase.Refresh();
        //     var newAsset = UnityEditor.AssetDatabase.LoadAssetAtPath<Mesh>(path);
        //     UnityEditor.EditorGUIUtility.PingObject(newAsset);
        // }
#endif
    }
}