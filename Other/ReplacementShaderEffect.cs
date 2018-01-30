using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ReplacementShaderEffect : MonoBehaviour {

    public Shader replacementShader;

    void OnEnable() {

        if (replacementShader) {
            GetComponent<Camera>().SetReplacementShader(replacementShader, "XRay");
        }
    }

    void OnDisable() {

        GetComponent<Camera>().ResetReplacementShader();
    }

}
