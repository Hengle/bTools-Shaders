using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class GlitchSuiteEffect : MonoBehaviour
{
	public Material glitchMat;

	public Vector2 Tiling;
	public Vector2 Offset;
	[Range( 0, 1 )]
	public float DistoryIntensityX;
	[Range( 0, 1 )]
	public float DistoryIntensityY;
	public bool invertColor;
	[Range( 0, 1 )]
	public float BleedXStart;
	[Range( 0, 1 )]
	public float BleedXWidth;
	[Range( 0, 1 )]
	public float BleedYStart;
	[Range( 0, 1 )]
	public float BleedYWidth;
	[Range( 0, 1 )]
	public float RedOffsetX;
	[Range( -1, 1 )]
	public float RedOffsetY;
	[Range( -1, 1 )]
	public float GreenOffsetX;
	[Range( -1, 1 )]
	public float GreenOffsetY;
	[Range( -1, 1 )]
	public float BlueOffsetX;
	[Range( -1, 1 )]
	public float BlueOffsetY;

	private void Update()
	{
		glitchMat.SetTextureScale( "_DistortMap", Tiling );
		glitchMat.SetTextureOffset( "_DistortMap", Offset );

		glitchMat.SetFloat( "_DistortIntensityX", DistoryIntensityX );
		glitchMat.SetFloat( "_DistortIntensityY", DistoryIntensityY );
		glitchMat.SetFloat( "_InvColor", invertColor ? 1 : 0 );
		glitchMat.SetFloat( "_BleedXStart", BleedXStart );
		glitchMat.SetFloat( "_BleedXWidth", BleedXWidth );
		glitchMat.SetFloat( "_BleedYStart", BleedYStart );
		glitchMat.SetFloat( "_BleedYWidth", BleedYWidth );
		glitchMat.SetFloat( "_RedOffsetX", RedOffsetX );
		glitchMat.SetFloat( "_RedOffsetY", RedOffsetY );
		glitchMat.SetFloat( "_GreenOffsetX", GreenOffsetX );
		glitchMat.SetFloat( "_GreenOffsetY", GreenOffsetY );
		glitchMat.SetFloat( "_BlueOffsetX", BlueOffsetX );
		glitchMat.SetFloat( "_BlueOffsetY", BlueOffsetY );
	}

	private void OnRenderImage( RenderTexture source, RenderTexture destination )
	{
		Graphics.Blit( source, destination, glitchMat );
	}
}