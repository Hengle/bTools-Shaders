using UnityEngine;

namespace bTools.Shaders
{
	public class GlowingObject : MonoBehaviour
	{
		public Color outlineColor;
		[HideInInspector] public Renderer[] renderers;

		private void Awake()
		{
			renderers = GetComponentsInChildren<Renderer>();
		}
	}
}