// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

#if !defined(RAMP_LIGHTING)
#define RAMP_LIGHTING

#include "UnityPBSLighting.cginc"
#include "AutoLight.cginc"

struct appdata
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
};

struct v2f
{
    float4 vertex : SV_POSITION;
    float3 worldNormal : NORMAL;
    float3 worldPos : TEXCOORD3;
};

sampler2D _Ramp;

v2f vert (appdata v)
{
    v2f o;
    o.vertex = UnityObjectToClipPos(v.vertex);
    o.worldNormal = UnityObjectToWorldNormal(v.normal);
    o.worldPos = mul(unity_ObjectToWorld, v.vertex);

    return o;
}

fixed4 frag (v2f i) : SV_Target
{
    #ifdef POINT
        float3 lightVec = _WorldSpaceLightPos0.xyz - i.worldPos;
        float3 lightDir = -normalize(lightVec);
    #else
        float3 lightDir = -_WorldSpaceLightPos0.xyz;
        if(length(lightDir) == 0) return tex2D(_Ramp, 1);
    #endif

    float ndotl = saturate((dot(normalize(i.worldNormal), lightDir)) * 0.5 + 0.5);

    #ifdef POINT
        UNITY_LIGHT_ATTENUATION(attenuation, 0, i.worldPos);
        float3 lightCoords = mul(unity_WorldToLight, i.worldPos).xyz;
        float range = dot(lightVec, lightVec) / dot(lightCoords, lightCoords);
        if(ndotl < range) ndotl = 1;
    #endif

    float2 rampUV = half2(ndotl, ndotl);
    fixed4 col = tex2D(_Ramp, rampUV);

    // #if defined(DIRECTIONAL)
    //     return 0;
    // #endif

    return col;
}

#endif