using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Light))]
public class RangeIntensityLinker : MonoBehaviour
{
    private Light thisLight;

    void Start()
    {
        thisLight = GetComponent<Light>();
    }

    void Update()
    {
        thisLight.intensity = thisLight.range;
    }
}
