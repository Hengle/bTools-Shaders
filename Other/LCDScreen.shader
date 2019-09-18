Shader "bTools/LCDScreen"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ScreenResolution("Resolution", Vector) = (1,1,1,1)
        _Distance("Distance one, zero", Vector) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST, _ScreenResolution, _Distance;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(UNITY_MATRIX_M, v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float uvX = floor(i.uv.x * _ScreenResolution.x) / _ScreenResolution.x;
                float uvY = floor(i.uv.y * _ScreenResolution.y) / _ScreenResolution.y;
                float4 picture = tex2D(_MainTex, float2(uvX, uvY));
                float4 pictureNormal = tex2D(_MainTex, i.uv);

                float borderWidth = _ScreenResolution.z / 2;

                float yRange = frac(i.uv.y * _ScreenResolution.y);
                float yBorder = step(yRange, _ScreenResolution.w);

                float uvRed = frac(i.uv.x * _ScreenResolution.x);
                float redAmount = 1 - step(yRange, 1 - picture.r);
                float redPixel = saturate(step(uvRed, 0.33) - (1 - step(uvRed, 0.33 - borderWidth)) - (step(uvRed, borderWidth))) * redAmount;

                float uvGreen = frac(i.uv.x * _ScreenResolution.x - 0.33);
                float greenAmount = 1 - step(yRange, 1 - picture.g);
                float greenPixel = saturate(step(uvGreen, 0.33) - (1 - step(uvGreen, 0.33 - borderWidth)) - (step(uvGreen, borderWidth))) * greenAmount;

                float uvBlue = frac(i.uv.x * _ScreenResolution.x - 0.66);
                float blueAmount = 1 - step(yRange, 1 - picture.b);
                float bluePixel = saturate(step(uvBlue, 0.33) - (1 - step(uvBlue, 0.33 - borderWidth)) - (step(uvBlue, borderWidth))) * blueAmount;

                float4 LCD = ((bluePixel * float4(0,0,1,1)) + (greenPixel * float4(0,1,0,1)) + (redPixel * float4(1,0,0,1))) * yBorder;

                float4 dist = distance(_WorldSpaceCameraPos, i.worldPos);
                float lerpFactor = saturate((dist - _Distance.x) / _Distance.y - _Distance.x);

                return lerp(picture, LCD, 1 - lerpFactor);

            }
            ENDCG
        }
    }
}
