Shader "Unlit/BubbleShield"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color("Tint Color", Color) = (1,1,1,1)
		_RimColor("Rim Color", Color) = (1,1,1,1)
		_PatternColor("Tint Color", Color) = (1,1,1,1)

		[Normal]_DistortNormal ("Distort Normal", 2D) = "bump" {}
		_DistortSpeed ("Distort Speed", Range(0, 500)) = 0
		_DistortIntensity ("Distort Intensity", Range(0, 5)) = 1
		_DistortDistance ("Distort Distance", Range(1, 50)) = 25

		_RimSize("Rim Size", range(0,3)) = 1
		_RimHardness("Rim Hardness", range(0.001,1)) = 1

		_Fresnel("Fresnel", range(0,0.5)) = 1
		_FresnelGradient("Fresnel Gradient", range(0.001, 1)) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
		LOD 100
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha

		GrabPass {}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
				float4 scrPos : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
				float4 grabPos : TEXCOORD3;
			};

			sampler2D _MainTex, _GrabTexture, _DistortNormal;
			uniform sampler2D _CameraDepthTexture;
			float4 _MainTex_ST, _DistortNormal_ST, _Color, _RimColor, _PatternColor;
			float _RimSize,_RimHardness, _Fresnel, _DistortSpeed, _DistortDistance, _DistortIntensity, _FresnelGradient;
			
			v2f vert (appdata v)
			{
				v2f o;

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.normal = v.normal;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.scrPos = ComputeScreenPos(o.vertex);
				o.viewDir = normalize(ObjSpaceViewDir(v.vertex));
				o.grabPos = ComputeGrabScreenPos(o.vertex);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{

				float depth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.scrPos)));
				float frenel = saturate(((1 - dot(normalize(i.viewDir), i.normal)) - _Fresnel) * _FresnelGradient / _Fresnel);
				float rim = saturate(1 - (depth - i.scrPos.w) * _RimSize / 0.2 );
				rim /= _RimHardness;

				float2 noiseUV = 0;
				noiseUV.x += sin((_Time.x ) * _DistortSpeed ) / _DistortDistance;
				noiseUV.y += cos((_Time.x ) * _DistortSpeed ) / _DistortDistance;
				float3 noiseNormal = UnpackNormal(tex2D(_DistortNormal, (i.grabPos + noiseUV) * _DistortNormal_ST.xy));

				float4 distortUV = i.grabPos;
				distortUV.xy += noiseNormal.xy * _DistortIntensity;

				fixed4 distortedBG = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(distortUV));
				fixed3 shieldMask = saturate(frenel + rim);
				fixed4 pattern = tex2D(_MainTex, i.uv);

				fixed4 final = (distortedBG * _Color) + (frenel * pattern * _PatternColor) + (rim * _RimColor * _RimColor.a);
				return final;
			}

			ENDCG
		}
	}
}
