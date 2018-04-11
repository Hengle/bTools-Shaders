Shader "bTools/Other/Shapes"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
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
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			// Frag !
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 col = 0;
				fixed2 uvs = i.uv;

				// Diagonal
				//col += step(uvs.x, uvs.y);

				// Divide
				//col += step(uvs.x, 0.5);

				// Quadrant
				//col += step(uvs.x, 0.5) * step(uvs.y, 0.5);

				// Waves
				//col += step(0.5 + cos(uvs.y * 7.5) * 0.25, uvs.x);

				// Stroke / Plus
				//col += stroke(uvs.x, 0.5, 0.15);
				//col += stroke(uvs.y, 0.5, 0.15);

				// River
				//float offset = cos(uvs.y * 5) * 0.15;
				//col += stroke(uvs.x, 0.28 + offset, 0.1);
				//col += stroke(uvs.x, 0.5 + offset, 0.1);
				//col += stroke(uvs.x, 0.72 + offset, 0.1);

				// Diagonal Stroke
				//float sdf = 0.5 + (uvs.x - uvs.y) * 0.5;
				//col += stroke(sdf, 0.5, 0.1);

				// Cross
				//float sdf = 0.5 + (uvs.x - uvs.y) * 0.5;
				//float sdf_inv = (uvs.x + uvs.y) * 0.5;
				//col += stroke(sdf, 0.5, 0.1);
				//col += stroke(sdf_inv, 0.5, 0.1);

				// Perimeter
				//col += stroke(circle(uvs), 0.5, 0.05);

				// Circle
				//col += fill(circleSDF(uvs), 0.65);

				// Moon
				//col += fill(circleSDF(uvs), 0.65);
				//float2 offset = float2(0.15, 0.15);
				//col -=fill(circleSDF(uvs - offset), 0.45);

				// Rectangles
				//float sdf = rect(uvs, 1);
				//col += stroke(sdf, 0.5, 0.125); // Perimeter
				//col += fill(sdf,.1); // Fill

				// The Hierophant
				//float rect = rectSDF(uvs, 1);
				//col += fill(rect, 0.5);
				//float cross = crossSDF(uvs,1);
				//col *= step(0.5, frac(cross * 4));
				//col *= step(1, cross);
				//col += fill(cross, 0.5);
				//col += stroke(rect, 0.65, 0.05);
				//col += stroke(rect, 0.75, 0.025);

				// The Tower
				//float rect = rectSDF(uvs, float2(0.5, 1));
				//float diag = (uvs.x + uvs.y) * 0.5;
				//col += flip(fill(rect, 0.6), stroke(diag, 0.5, 0.01));

				// The Merge
				//float2 offset = float2(0.15, 0);
				//float left = circleSDF(uvs + offset);
				//float right = circleSDF(uvs - offset);
				//col += flip(stroke(left, 0.5, 0.05), fill(right, 0.525));

				// Hope
				//float sdf = vesicaSDF(uvs, 0.2);
				//col += flip (fill(sdf, 0.5), step((uvs.x + uvs.y) * 0.5, 0.5));

				// The Temple
				//float2 ts = float2(uvs.x, 0.82 - uvs.y);
				//col += fill(triSDF(uvs), 0.7);
				//col -= fill(triSDF(ts), 0.36);

				// The Summit
				//float circle = circleSDF(uvs - float2(0,0.1));
				//float tri = triSDF(uvs + float2(0, 0.1));
				//col+= stroke(circle, 0.45, 0.1);
				//col *= step(0.55, tri);
				//col += fill(tri, 0.45);

				// The Diamond
				//float sdf = rhombSDF(uvs);
				//col += fill(sdf, 0.425);
				//col += stroke(sdf, 0.5, 0.05);
				//col += stroke (sdf, 0.6, 0.03);

				// The Hermit
				//col += flip(fill(triSDF(uvs), 0.5), fill (rhombSDF(uvs), 0.4));

				// Intuition
				//float2 st = rotate(uvs, radians(-25));
				//float sdf = triSDF(st);
				//sdf /= triSDF(st + float2(0, 0.2));
				//col += fill(abs(sdf), 0.56);


				// The Stone
				//float2 st = rotate(uvs, radians(45));
				//col += fill(rectSDF(st, 1), 0.4);
				//col *= 1 - stroke(st.x, 0.5, 0.02);
				//col *= 1 - stroke(st.y, 0.5, 0.02);

				// The Mountain
				//float2 st = rotate(uvs, radians(-45));
				//float offset = 0.12;
				//float2 size = 1;
				//col += fill(rectSDF(st + offset, size), 0.2);
				//col += fill(rectSDF(st - offset, size), 0.2);
				//float r = rectSDF(st, size);
				//col *= step(0.33, r);
				//col += fill(r, 0.3);

				// The Shadow
				//float2 st = rotate(float2(uvs.x, 1.0 - uvs.y), radians(45));
				//float2 size = 1;
				//col += fill(rectSDF(st - 0.025, size), 0.4);
				//col += fill(rectSDF(st + 0.025, size), 0.4);
				//col *= step(0.38, rectSDF(st + 0.025, size));

				// Opposite
				//float2 st = rotate(uvs, radians(-45));
				//float2 size = 1;
				//float offset = 0.05;
				//col += flip(fill (rectSDF(st - offset, size), 0.4), fill(rectSDF(st + offset, size), 0.4));

				// The Oak
				//float2 st = rotate(uvs, radians(45));
				//float r1 = rectSDF(st, 1);
				//float r2 = rectSDF(st + 0.15, 1);
				//col += stroke(r1, 0.5, 0.05);
				//col *= step(0.325, r2);
				//col += stroke(r2, 0.325, 0.05) * fill(r1, 0.525);
				//col += stroke(r2, 0.2, 0.05);

				// Ripples
				//float2 st = rotate(uvs, radians(-45)) - 0.08;

				//for(int i = 0; i < 4; i++)
				//{
				//	float r = rectSDF(st, 1);
				//	col += stroke(r, 0.19, 0.04);
				//	st += 0.05;
				//}

				// The Empress
				//float d1 = polySDF(uvs, 5);
				//float2 ts = float2(uvs.x, 1-uvs.y);
				//float d2 = polySDF(ts, 5);
				//col += fill(d1, 0.75) * fill(frac(d1 * 5), 0.5);
				//col -= fill (d1, 0.6) * fill(frac(d2 * 4.9), 0.45);

				// Bundle
				//float2 st = uvs.yx;
				//col += stroke(hexSDF(st), 0.6, 0.1);
				//col += fill(hexSDF(st - float2(-0.06, -0.1)), 0.15);
				//col += fill(hexSDF(st - float2(-0.06, 0.1)), 0.15);
				//col += fill(hexSDF(st - float2(0.11, 0)), 0.15);

				// The Devil
				//col += stroke(circleSDF(uvs), 0.8, 0.05);
				//uvs.y = 1 - uvs.y;
				//float s = starSDF(uvs.yx, 5, 0.1);
				//col *= step(0.7, s);
				//col += stroke(s, 0.4, 0.1);

				// The Sun
				//float bg = starSDF(uvs, 16, 0.1);
				//col += fill(bg, 1.3);
				//float l = 0;
				//for(float i = 0; i < 8; i++)
				//{
				//	float2 xy = rotate(uvs, QTR_PI * i);
				//	xy.y -= 0.3;
				//	float tri = polySDF(xy, 3);
				//	col += fill(tri, 0.3);
				//	l += stroke(tri, 0.3, 0.03);
				//}
				//col *= 1-l;
				//float c = polySDF(uvs, 8);
				//col -= stroke(c, 0.15, 0.04);

				// The Star
				col += stroke(raysSDF(uvs, 8), 0.5, 0.15);
				float inner = starSDF(uvs, 6, 0.09);
				float outer = starSDF(uvs.yx, 6, 0.09);
				col *= step(0.7, outer);
				col += fill(outer, 0.5);
				col -= stroke(inner, 0.25, 0.06);
				col += stroke(outer, 0.6, 0.05);

				// Judgement
				//col += flip(stroke(raysSDF(uvs, 28), 0.5, 0.2), fill(uvs.y, 0.5));
				//float rect = rectSDF(uvs, 1);
				//col *= step(0.25, rect);
				//col += fill(rect, 0.2);

				// Wheel of Fortune
				//float sdf = polySDF(uvs.yx, 8);
				//col += fill(sdf, 0.5);
				//col *= stroke(raysSDF(uvs, 8), 0.5, 0.2);
				//col *= step(0.27, sdf);
				//col += stroke(sdf, 0.2, 0.05);
				//col += stroke(sdf, 0.6, 0.1);

				// Vision
				//float v1 = vesicaSDF(uvs, 0.5);
				//float2 uvs2 = uvs.yx + float2(0.04, 0);
				//float v2 = vesicaSDF(uvs2, 0.7);
				//col += stroke(v2, 1, 0.05);
				//col += fill(v2, 1) * stroke(circleSDF(uvs), 0.3, 0.05);
				//col += fill( raysSDF(uvs, 50), 0.2) * fill (v1, 1.25) * step ( 1, v2);
				//col += fill(circleSDF(uvs), 0.1);

				// The Lovers
				//col += fill(heartSDF(uvs), 0.5);
				//col -+ stroke(polySDF(uvs,3), 0.15, 0.05);

				//The Magician
				//uvs.x = flip(uvs.x, step(0.5, uvs.y));
				//float2 offset = float2(0.15, 0);
				//float left = circleSDF(uvs + offset);
				//float right = circleSDF(uvs - offset);
				//col += stroke(left, 0.4, 0.075);
				//col = bridge(col, right, 0.4, 0.075);

				// The Link
				//float2 st = uvs.yx;
				//st.x = lerp(1.0 - st.x, st.x, step(0.5, st.y) );
				//float2 o = float2(0.1,0.0);
				//float2 s = 1.0;
				//float a = radians(45.0);
				//float l = rectSDF(rotate(st+o,a),s);
				//float r = rectSDF(rotate(st-o,-a),s);
				//col += stroke(l,0.3,0.1);
				//col = bridge(col, r,0.3,0.1);
				//col += fill( rhombSDF( abs( st.yx - float2( 0.0, 0.5 ))), 0.1);

				return fixed4(col, 1);
			}
			ENDCG
		}
	}
}
