using UnityEngine;

[RequireComponent(typeof(Camera))]
public class DeformSnowCamera : MonoBehaviour
{
    public RenderTexture finalTexture;
    public float refillSpeed;

    Material mat;
    Camera cam;

    void Awake()
    {
        cam = GetComponent<Camera>();
        cam.SetReplacementShader(Shader.Find("Hidden/SnowDeformCameraShader"), string.Empty);
        cam.depthTextureMode = DepthTextureMode.Depth;
        cam.targetTexture.Release();
        finalTexture.Release();

        mat = new Material(Shader.Find("bShaders/SnowDeformAdder"));
        mat.SetFloat("_RefillSpeed", refillSpeed);
        mat.SetTexture("_CurrentHeight", finalTexture);
    }

    void Update()
    {
        var buffer = RenderTexture.GetTemporary(finalTexture.width, finalTexture.height, finalTexture.depth, finalTexture.format);

        Graphics.Blit(cam.targetTexture, buffer, mat);
        Graphics.Blit(buffer, finalTexture);

        RenderTexture.ReleaseTemporary(buffer);
    }
}
