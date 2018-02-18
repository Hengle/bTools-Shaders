// SOURCE : PixelSpirit Deck
#ifndef SHAPES
#define SHAPES

#include "Constants.cginc"

// Fill pixels
float stroke(float x, float start, float width)
{
	float d = step (start, x + width * 0.5) - step (start, x - width * 0.5);
	return saturate(d);
}

float fill(float x, float size)
{
	return 1 - step(size, x);
}

float flip(float v, float pct)
{
	return lerp(v, 1-v, pct);
}

float2 rotate(float2 uv, float angle)
{
	float2x2 mat = float2x2 (cos(angle), -sin(angle), sin(angle), cos(angle));
	uv = mul(mat, (uv - 0.5)); 

	return uv + 0.5;
}

float3 bridge(float3 c, float d, float s, float w)
{
	c *= 1 - stroke(d, s, w * 2 );
	return c + stroke(d, s, w);
}

// Signed distance functions
float circleSDF(float2 uv)
{
	return length(uv - 0.5) * 2;
}

float rectSDF(float2 uv, float2 size)
{
	uv = uv * 2 - 1;
	return max (abs(uv.x / size.x), abs(uv.y / size.y));
}

float crossSDF(float2 uv, float size)
{
	float2 s = float2(0.25, size);
	return min(rectSDF(uv.xy, s.xy), rectSDF(uv.xy, s.yx));
}

float vesicaSDF(float2 uv, float width)
{
	float2 offset = float2(width * 0.5, 0);
	return max(circleSDF(uv - offset), circleSDF(uv + offset));
}

float triSDF(float2 uv)
{
	uv = (uv * 2 - 1) * 2;
	return max(abs(uv.x) * 0.866025 + uv.y * 0.5, -uv.y * 0.5);
}

float rhombSDF(float2 uv)
{
	return max(triSDF(uv), triSDF(float2(uv.x, 1-uv.y)));
}

float polySDF(float2 uv, int V)
{
	uv = uv * 2 - 1;
	float a = atan2(uv.x , uv.y) + PI;
	float r = length(uv);
	float v = TAU / float(V);
	return cos(floor(0.5 + a/v) * v-a) * r;
}

float hexSDF(float2 uv)
{
	uv = abs(uv * 2 - 1);
	return max(abs(uv.y), uv.x  * 0.866025 + uv.y * 0.5);
}

float starSDF(float2 uv, int V, float s)
{
	uv = uv * 4 - 2;
	float a = atan2(uv.y, uv.x) / TAU;
	float seg = a * float(V);
	a = ((floor(seg) + 0.5 ) / float(V) + lerp (s, -s, step (0.5, frac(seg)))) * TAU;
	return abs(dot(float2(cos(a), sin (a)), uv));
}

float raysSDF(float2 uv, int N)
{
	uv -= 0.5;
	return frac(atan2(uv.y, uv.x) / TAU * float(N));
}

float heartSDF(float2 uv)
{
	uv -= float2(0.5, 0.8);
	float r = length(uv) * 5;
	uv = normalize(uv);
	return r - ((uv.y * pow(abs(uv.x), 0.67))/(uv.y + 1.5)-(2) * uv.y + 1.26);
}
#endif