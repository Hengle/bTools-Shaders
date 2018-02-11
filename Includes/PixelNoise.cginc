#ifndef PIXEL_NOISE
#define PIXEL_NOISE

#include "NoiseBase.cginc"

// Generates a tv static like pattern
float pixel_noise(float2 uv, int scale)
{
	float2 p = uv * scale;
	float2 ipart = floor(p);
	return rand(ipart);
}

#endif