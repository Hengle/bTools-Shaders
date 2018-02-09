Shader "Hidden/ScreenShatter"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Snapshot("Snapshot", 2D) = "white" {}
		_ShatterMap("Shatter Map", 2D) = "white" {}
		_TileDistance("Tile Distance", float) = 0
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma geometry geom
			
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
				float4 col : TEXCOORD1;
			};

			sampler2D _MainTex, _Snapshot, _ShatterMap;
			float _TileDistance;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.col = 0;
				return o;
			}

            [maxvertexcount(32)]
            void geom(point v2f input[1], inout TriangleStream<v2f> OutputStream)
            {
                v2f tri = (v2f)0;
				tri.col = fixed4(1, 1, 0, 1);

				// FIRST TRI
				tri.vertex = input[0].vertex;
				tri.vertex.y -= _TileDistance;
				tri.uv = input[0].uv;
				OutputStream.Append(tri);

				tri.vertex = fixed4(input[0].vertex.x + 1, input[0].vertex.y, 0, 1);
				tri.vertex.y -= _TileDistance;
				tri.uv = fixed2(input[0].uv.x + 0.5, input[0].uv.y);
				OutputStream.Append(tri);

				tri.vertex = fixed4(input[0].vertex.x, input[0].vertex.y + 1, 0, 1);
				tri.vertex.y -= _TileDistance;
				tri.uv = fixed2(input[0].uv.x, input[0].uv.y + 0.5);
				OutputStream.Append(tri);

				// SECOND TRI
				tri.col = fixed4(0, 1, 1, 1);
				tri.vertex = fixed4(input[0].vertex.x, input[0].vertex.y + 1, 0, 1);
				tri.vertex.y -= _TileDistance;
				tri.uv = fixed2(input[0].uv.x, input[0].uv.y + 0.5);
				OutputStream.Append(tri);

				tri.vertex = fixed4(input[0].vertex.x + 1, input[0].vertex.y + 1, 0, 1);
				tri.vertex.y -= _TileDistance;
				tri.uv = fixed2(input[0].uv.x + 0.5, input[0].uv.y + 0.5);
				OutputStream.Append(tri);

				tri.vertex = fixed4(input[0].vertex.x + 1, input[0].vertex.y, 0, 1);
				tri.vertex.y -= _TileDistance;
				tri.uv = fixed2(input[0].uv.x + 0.5, input[0].uv.y);
				OutputStream.Append(tri);
            }

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 screen = tex2D(_Snapshot, i.uv);
				fixed4 voronoi = tex2D(_ShatterMap, i.uv) + 0.1;

				fixed2 uvTest = i.uv;
				uvTest.x += voronoi.a * _TileDistance;
				fixed2 uvTest2 = i.uv;
				uvTest2.x -= voronoi.a * _TileDistance;

				fixed4 shatterMap = tex2D(_ShatterMap, uvTest);


				// fixed2 noiseSample = tex2D(_ShatterMap, shatterMap.a).gb - 0.5;
				// fixed4 displacedShatterMap = tex2D(_ShatterMap, i.uv + noiseSample);
				// fixed2 snapShotUV = i.uv + noiseSample * _TileDistance * shatterMap.a;
				// fixed4 tiles = tex2D(_Snapshot, snapShotUV);
				//return tiles * (1-step(shatterMap.a, 0.01));


				return screen * i.col;
			}
			ENDCG
		}
	}
}
