#ifndef NOISE_BASE
#define NOISE_BASE

float rand(float n) 
{ 
	return frac(sin(n) * 43758.5453);
}

float rand(float2 n) 
{ 
	return frac(sin(dot(n, float2(12.9898, 78.233))) * 43758.5453);
}

float4 mod289(float4 x)
{
	return x - floor(x * (1.0 / 289.0)) * 289.0;
}

float3 mod289(float3 x) 
{
  	return x - floor(x * (1.0 / 289.0)) * 289.0;
}

float2 mod289(float2 x) 
{
	return x - floor(x * (1.0 / 289.0)) * 289.0;
}

float4 permute(float4 x)
{
	return mod289(((x*34.0)+1.0)*x);
}

float3 permute(float3 x) 
{
	return mod289(((x*34.0)+1.0)*x);
}

float4 taylorInvSqrt(float4 r)
{
  return 1.79284291400159 - 0.85373472095314 * r;
}

float3 taylorInvSqrt (float3 r) 
{
	return 1.79284291400159 - 0.85373472095314 * r ; 
}

float2 fade(float2 t) 
{
  	return t*t*t*(t*(t*6.0-15.0)+10.0);
}

#endif