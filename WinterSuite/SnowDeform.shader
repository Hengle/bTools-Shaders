Shader "bTools/Winter/SnowDeform"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_MainNormal("Main Normal", 2D) = "bump" {}
		_CrunchTex("Crunched Albedo (RGB)", 2D) = "white" {}
		_CrunchNormal("Crunched Normal (RGB)", 2D) = "bump" {}
		[NoScaleOffset]_HeightMap("Height", 2D) = "black"{}
		[NoScaleOffset]_GlitterMap("Glitter", 2D) = "black"{}
		_DepthFactor("Depth Factor", range(-1,1)) = 0
		_Tess("Tessellation", Range(1,32)) = 4
		_BlurAmount("Input Blur Amount", range(0,0.01)) = 0.015
		_MainGloss("Main Gloss", range(0,1)) = 0.25
		_CrunchGloss("Crunch Gloss", range(0,1)) = 0.9
	}

		SubShader
		{
			Tags { "RenderType" = "Opaque" }
			LOD 200

			CGPROGRAM

				#pragma surface surf Standard fullforwardshadows addshadow tessellate:tess vertex:vert 
				#pragma target 4.6

				sampler2D _MainTex;
				sampler2D _MainNormal;
				sampler2D _HeightMap;
				sampler2D _CrunchTex;
				sampler2D _CrunchNormal;
				sampler2D _GlitterMap;
				fixed4 _Color;
				float _BlurAmount;
				float _DepthFactor;
				float _Tess;
				float _MainGloss;
				float _CrunchGloss;

				struct Input
				{
					float2 uv_MainTex;
					float2 uv_MainNormal;
					float2 uv_CrunchTex;
					float2 uv_CrunchNormal;
					float heightValue;
					float4 screenPos;
					float4 color : COLOR; //Actually used to pass height data from vert to surf
				};

				float normpdf(float x, float sigma)
				{
					return 0.39894*exp(-0.5*x*x / (sigma*sigma)) / sigma;
				}

				half4 blur(sampler2D tex, float4 uv, float blurAmount)
				{
					half4 col = tex2Dlod(tex, uv);

					const int mSize = 11;
					const int iter = (mSize - 1) / 2;

					for (int i = -iter; i <= iter; ++i)
					{
						for (int j = -iter; j <= iter; ++j)
						{
							col += tex2Dlod(tex, float4(uv.x + i * blurAmount, uv.y + j * blurAmount,0 ,0)) * normpdf(float(i), 7);
						}
					}

					return col / mSize;
				}

				float4 tess()
				{
					return _Tess;
				}

				void vert(inout appdata_full v)
				{
					// Sample the depth and blur it
					float3 depth = blur(_HeightMap,  float4(v.texcoord.xy, 0, 0), _BlurAmount / 10);
					v.color.x = depth.x + depth.y;

					float depthFac = _DepthFactor * 0.1;

					depth *= depthFac;
					depth -= depthFac / 1.5;

					v.vertex.xyz -= v.normal * depth.r;
				}

				void surf(Input IN, inout SurfaceOutputStandard o)
				{
					float height = saturate(IN.color.x);

					fixed4 mainTex = tex2D(_MainTex, IN.uv_MainTex);
					fixed4 crunchTex = tex2D(_CrunchTex, IN.uv_CrunchTex);

					fixed3 mainNormal = UnpackNormal(tex2D(_MainNormal, IN.uv_MainNormal)) ;
					fixed3 crunchNormal = UnpackNormal(tex2D(_CrunchNormal, IN.uv_CrunchNormal));

					o.Albedo = lerp(mainTex, crunchTex, height);
					o.Normal = lerp(mainNormal, crunchNormal, height);
					//o.Occlusion = 1-height;
					o.Alpha = 1;
					o.Metallic = 0;
					o.Smoothness = lerp(_MainGloss, _CrunchGloss, height);

					//Glitter
					float2 ScreenUV = IN.screenPos.xy / max(0.0001, IN.screenPos.w);
					fixed glitterScreen = tex2D(_GlitterMap, ScreenUV).r;
					fixed glitterWorld = tex2D(_GlitterMap, IN.uv_MainTex).r;
					o.Emission = glitterScreen * glitterWorld;
				}

			ENDCG
		}
	FallBack "Diffuse"
}
