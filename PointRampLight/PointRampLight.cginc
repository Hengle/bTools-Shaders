#if !defined(RAMP_LIGHTING)
#define RAMP_LIGHTING

#include "UnityPBSLighting.cginc"
#include "AutoLight.cginc"
#include "../Includes/Shapes.cginc"
#include "../Includes/Constants.cginc"

struct appdata
{
    float4 vertex : POSITION;
    half2 uv : TEXCOORD0;
    float3 normal : NORMAL;
};

struct v2f
{
    float4 pos : SV_POSITION;
    float3 worldNormal : NORMAL;
    half2 uv : TEXCOORD0;
    float3 worldPos : TEXCOORD3;
    float4 scrPos : TEXCOORD4;
    float3 viewDir : TEXCOORD5;
    SHADOW_COORDS(6)
};

sampler2D _MainTex, _Ramp, _Pattern, _ShadowPattern;
half4 _MainTex_ST;
float _PatternSize, _RadialSize;

v2f vert (appdata v)
{
    v2f o;
    o.pos = UnityObjectToClipPos(v.vertex);
    o.worldNormal = UnityObjectToWorldNormal(v.normal);
    o.worldPos = mul(unity_ObjectToWorld, v.vertex);
    o.scrPos = ComputeScreenPos(o.pos) * 2 - 1;
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
    o.viewDir = UnityWorldSpaceViewDir(o.worldPos);
    TRANSFER_SHADOW(o);

    return o;
}

fixed4 frag (v2f i) : SV_Target
{
    i.worldNormal = normalize(i.worldNormal);

    #if defined(POINT)
        // 1D Ramp
        float4 lightCoords =  mul(unity_WorldToLight, float4(i.worldPos, 1));
        float2 ldot = dot(lightCoords.xyz, lightCoords.xyz);
        
        fixed4 col = fixed4(tex2D(_Ramp, ldot.rr).rgb, 1 - ldot.r);
        fixed4 tex = tex2D(_MainTex, i.uv);

        // 2D Ramp
        float xMask = 1 - step(abs(i.worldNormal.x), 0.5);
        float zMask = 1 - step(abs(i.worldNormal.z), 0.5);
        float rad = atan2(lightCoords.z * (1 - zMask) + lightCoords.y * zMask,
                          lightCoords.x * (1 - xMask) + lightCoords.y * xMask);

        rad = rad * (PI / _RadialSize);

        #if defined(USE_PATTERN_SIZE)
            float2 worldPos2D = float2(i.worldPos.z * (1 - zMask) + i.worldPos.y * zMask,
                                        i.worldPos.x * (1 - xMask) + i.worldPos.y * xMask);
            float2 lightPos2D = float2(_WorldSpaceLightPos0.z * (1 - zMask) + _WorldSpaceLightPos0.y * zMask,
                                        _WorldSpaceLightPos0.x * (1 - xMask) + _WorldSpaceLightPos0.y * xMask);

            // Can't access light's range, so use intensity instead
            float distance2D = length(worldPos2D - lightPos2D) * _PatternSize * (1 / _LightColor0.a);
        #else
            float distance2D = ldot;
        #endif

        float4 mask = fixed4(tex2D(_Pattern, float2(distance2D, rad)).rgb, 1.1 - ldot.r);

        #if defined(SHADOWS_CUBE)
            float shadow = SHADOW_ATTENUATION(i);

            #if defined(USE_SHADOW_PATTERN)
                float4 shadowPattern = fixed4(tex2D(_ShadowPattern, float2(distance2D, rad)).rgb, 1.1 - ldot.r);
                shadowPattern = shadowPattern * (1 - shadow);
                col = col * shadow + shadowPattern;
            #else
                col.a = shadow;
            #endif

        #endif

        // Final compositing
        col = mask * col * tex;

        // Clip outside of the light's range using alpha or clip
        col.a *= step(ldot.r, 1); 
        clip(1 - ldot);
    #elif defined(SPOT)
        fixed4 col = fixed4(tex2D(_Ramp, 1).rgb, 0);
    #else
        float3 lightDir = -_WorldSpaceLightPos0.xyz;
        //float ndotl = saturate((dot(i.worldNormal, lightDir)) * 0.5 + 0.5);
        fixed4 col = tex2D(_Ramp, half2(1, 0));
        //fixed4 col = ndotl * _LightColor0;
        if(length(lightDir) == 0) 
        {
            col = fixed4(tex2D(_Ramp, 1).rgb, 0);
        }
        col.a = 0;
    #endif

    return col;
}

#endif