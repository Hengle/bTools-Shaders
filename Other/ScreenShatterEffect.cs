using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ScreenShatterEffect : MonoBehaviour
{
    public Texture2D shatterMap;
    public bool updateSnapshot;
    public bool generateNewPattern;
    [Range(0, 2)]
    public float tileDistance;

    private Material mat;
    private Camera cam;
    private RenderTexture screenSnapshot;

    private Vector2[] vertices;
    private int[] triangles;

    void Awake()
    {
        cam = Camera.main;
        mat = new Material(Shader.Find("Hidden/ScreenShatter"));
    }

    void Update()
    {
        if (updateSnapshot)
        {
            screenSnapshot = new RenderTexture(Screen.width, Screen.height, 24);
            screenSnapshot.wrapMode = TextureWrapMode.Mirror;

            cam.targetTexture = screenSnapshot;
            cam.Render();
            cam.targetTexture = null;

            mat.SetTexture("_Snapshot", screenSnapshot);

            updateSnapshot = false;
        }

        if (generateNewPattern)
        {


            generateNewPattern = false;
        }
    }

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (!updateSnapshot)
        {
            Graphics.Blit(src, dest, mat);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }

    void OnValidate()
    {
        mat.SetTexture("_ShatterMap", shatterMap);
        mat.SetFloat("_TileDistance", tileDistance);
    }
}
