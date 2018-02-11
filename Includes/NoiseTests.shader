Shader "Unlit/NoiseTests"
{
	Properties
	{
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
			#include "PixelNoise.cginc"
			#include "ClassicNoise.cginc"
			#include "Shapes.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = 0;

				//Pixel grid
				//col = pixel_noise(i.uv, 75);

				// Simplex
				//col = simplex_noise(i.uv * 10) * 0.5 + 0.5;

				// Perlin
				//col = perlin_noise(i.uv * 15) * 0.5 + 0.5;

				// Sliding bars
				// float2 p = i.uv * 25;
				// float row = rand(floor(p.y)) + 1;
				// p.x += _Time.y * 15 * (rand(row) - 0.5);
				// col = step(rand(floor(p.x)), 0.66);

				int scale = 1;
				float2 uvs = 1 - i.uv * scale;
				uvs = frac(uvs);

				float row = rand(floor(uvs.y)) + 0.5;
				float column = rand(floor(uvs.x)) + 0.5;
				float time = _Time.y;

				float poly = polySDF(uvs, 5);
				float circle = raysSDF(uvs,1);

				float fillVal = step(circle, frac(time));
				fillVal = lerp(fillVal, 1 - fillVal, step(sin(_Time.y * 05), 1));

				float shape = 0;
				//shape += fill(poly, 0.33);
				shape += fill(poly, 0.33) *  fillVal;
				shape -= fill(poly, 0.22) * 2;

				col =  shape;

				return col;
			}
			ENDCG
		}
	}
}
