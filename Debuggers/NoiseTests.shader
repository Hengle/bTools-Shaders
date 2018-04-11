Shader "bTools/Debuggers/NoiseTests"
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
			#include "../Includes/PixelNoise.cginc"
			#include "../Includes/ClassicNoise.cginc"
			#include "../Includes/Shapes.cginc"

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

				// ---------- Pixel grid ----------
				//col = pixel_noise(i.uv, 75);

				// ---------- Simplex ----------
				//col = simplex_noise(i.uv * 10) * 0.5 + 0.5;

				// ---------- Perlin ---------
				//col = perlin_noise(i.uv * 15) * 0.5 + 0.5;

				// Sliding bars
				// float2 p = i.uv * 25;
				// float row = rand(floor(p.y)) + 1;
				// p.x += _Time.y * 15 * (rand(row) - 0.5);
				// col = step(rand(floor(p.x)), 0.66);
				// ---------- END Perlin ----------

				// ---------- Pentagon ----------
				// int scale = 1;
				// float2 uvs = 1 - i.uv * scale;
				// uvs = frac(uvs);

				// float row = rand(floor(uvs.y)) + 0.5;
				// float column = rand(floor(uvs.x)) + 0.5;

				// float poly = polySDF(uvs, 5);
				// float circle = raysSDF(uvs, 1);
				// float rays = raysSDF(rotate(uvs, radians(22.5)), 5);

				// float shape = 0;
				// shape += fill(rays, 0.1) *  pow(circleSDF(uvs), 12 );

				// for(float i = 1; i < 10; i++)
				// {
				// 	float timeScale = (_Time.y + i/10 + (pow(rand(row * column), 3))) ;
				// 	float time = pow(sin(timeScale), 2);
				// 	float side = round(pow(cos(timeScale + (PI / 4)), 2));
				// 	float fillVal = step(lerp(circle, 1 - circle, side), frac(time));

				// 	shape = saturate(shape + fill(poly,  0.9 - (i/ 10))  / pow(i,3));
				// 	shape = saturate(shape + fill(poly,  0.9 - (i/ 10)) *  fillVal / pow(i,2));
				// 	shape = saturate(shape - fill(poly,  0.85 - (i/ 10)));
				// }

				// shape = saturate(shape + fill(poly, 0.1));
				// col = shape;
				// ---------- END Pentagon ----------

				// ---------- Matrix ----------
				// int scale = 14;
				// float2 uvs = i.uv;
				// uvs.x = 1 - uvs.x;
				// uvs *= scale;
				// float2 grid = frac(uvs) * 1.05;

				// float row = (floor(uvs.y)) + 1;
				// float column = (floor(uvs.x)) + 1;

				// float time = _Time.y * 28;
				// time += abs(rand(row) * rand(column) * 10);

				// float tiling = 0;
				// tiling = row * column;
				// tiling = step(row + 1, fmod(time / scale, scale));
				// tiling += step(column, fmod(time , scale)) *  step(row, fmod(time / scale, scale));

				// const uint LETTER_COUNT = 8;
				// float letters[LETTER_COUNT];

				// // LEFT BAR
				// // fill(rectSDF(grid + float2(0.35, 0), float2(0.15, 0.85)), 1);
				// // RIGHT BAR
				// // fill(rectSDF(grid + float2(-0.35, 0), float2(0.15, 0.85)), 1); 
				// // TOP BAR
				// // fill(rectSDF(grid + float2(0, 0.35), float2(0.85, 0.15)), 1);
				// // BOTTOM BAR
				// // fill(rectSDF(grid + float2(0, -0.35), float2(0.85, 0.15)), 1);
				// // SQUARE
				// // fill(rectSDF(grid, float2(0.25, 0.25)), 1); 
				// letters[0] = fill(rectSDF(grid + float2(0.35, 0), float2(0.15, 0.85)), 1) + fill(rectSDF(grid, float2(0.25, 0.25)), 1);
				// letters[1] = fill(rectSDF(grid + float2(0.35, 0), float2(0.15, 0.85)), 1) + fill(rectSDF(grid + float2(0, 0.35), float2(0.85, 0.15)), 1);
				// letters[2] = fill(rectSDF(grid + float2(-0.35, 0), float2(0.15, 0.85)), 1);
				// letters[3] = fill(rectSDF(grid + float2(0, 0.35), float2(0.85, 0.15)), 1) + fill(rectSDF(grid + float2(0, -0.35), float2(0.85, 0.15)), 1) +  fill(rectSDF(grid, float2(0.25, 0.25)), 1);
				// letters[4] = fill(rectSDF(grid, float2(0.25, 0.25)), 1);
				// letters[5] = 1 - fill(rectSDF(grid, float2(0.25, 0.25)), 1);
				// letters[6] =  fill(rectSDF(grid + float2(0.35, 0), float2(0.15, 0.85)), 1) + fill(rectSDF(grid + float2(-0.35, 0), float2(0.15, 0.85)), 1) + fill(rectSDF(grid + float2(0, 0.35), float2(0.85, 0.15)), 1) + fill(rectSDF(grid + float2(0, -0.35), float2(0.85, 0.15)), 1);
				// letters[7] = 1 -  fill(rectSDF(grid + float2(0.35, 0), float2(0.15, 0.85)), 1) + fill(rectSDF(grid, float2(0.25, 0.25)), 1);
				
				// float letterSelect = frac(rand(pow(row, column / scale))) - (frac(rand(_SinTime.y)) / 200); 

				// float finalLetter = 0;

				// for(uint i = 0; i < LETTER_COUNT; i++)
				// {
				// 	float upper = 1 - (float(i) / float(LETTER_COUNT));
				// 	float lower = upper - (1 / float(LETTER_COUNT));
				// 	finalLetter += letters[i] * step(lower, letterSelect ) * (1 - step(upper, letterSelect ) );
				// }

				// col = finalLetter * tiling * float4(step(row, 1), letterSelect * (1 - step(row, 1)),1- step(letterSelect, 0.9), 1);
				// ---------- END Matrix ----------

				// --------- Endless Pentagons ----------
				float2 uvs = i.uv;
				uvs.y = 1 - uvs.y;
				float time = _Time.y * 0.5;

				float poly = polySDF(uvs, 5);
				poly = frac(poly * 5 - time);
				col = fill(poly, 0.3);
				// --------- END Endless Pentagons ----------

				return col;
			}
			ENDCG
		}
	}
}
