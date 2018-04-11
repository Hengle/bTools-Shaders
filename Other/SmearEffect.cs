using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace bTools.Shaders
{
    public class SmearEffect : MonoBehaviour
    {
        Material smearMat;

        void Start()
        {
            smearMat = GetComponent<MeshRenderer>().material;
            StartCoroutine(UpdateLastPos());
        }

        void LateUpdate()
        {
            smearMat.SetVector("_CurrentPos", transform.position);
        }

        IEnumerator UpdateLastPos()
        {
            WaitForEndOfFrame eof = new WaitForEndOfFrame();

            while (true)
            {
                smearMat.SetVector("_LastPos", transform.position);
                yield return eof;
            }
        }
    }
}