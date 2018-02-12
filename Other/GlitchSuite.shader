Shader "bShaders/GlitchSuite"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_DistortMap ("Distort Map", 2D) = "bump" {}
		_DistortIntensityX("Distort Intensity X", range(0,10)) = 0
		_DistortIntensityY("Distort Intensity Y", range(0,10)) = 0
		[Toggle]_InvColor ("Invert Color", float) = 0
		_BleedXStart("Bleed X Start", range(0,1)) = 1
		_BleedXWidth("Bleed X Width", range(0,1)) = 0
		_BleedYStart("Bleed Y Start", range(0,1)) = 1
		_BleedYWidth("Bleed Y Width", range(0,1)) = 0
		_RedOffsetX("RedOffset X", range(-1,1)) = 0
		_RedOffsetY("RedOffset Y", range(-1,1)) = 0
		_GreenOffsetX("GreenOffset X", range(-1,1)) = 0
		_GreenOffsetY("GreenOffset Y", range(-1,1)) = 0
		_BlueOffsetX("BlueOffset X", range(-1,1)) = 0
		_BlueOffsetY("BlueOffset Y", range(-1,1)) = 0
	}
	SubShader
	{
		Cull Off
		ZWrite Off
		ZTest Always

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
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			sampler2D _DistortMap;
			fixed _DistortIntensityX;
			fixed _DistortIntensityY;
			fixed _InvColor;
			fixed _BleedXStart;
			fixed _BleedXWidth;
			fixed _BleedYStart;
			fixed _BleedYWidth;
			fixed _RedOffsetX;
			fixed _RedOffsetY;
			fixed _GreenOffsetX;
			fixed _GreenOffsetY;
			fixed _BlueOffsetX;
			fixed _BlueOffsetY;

			fixed4 frag (v2f i) : SV_Target
			{
				float2 preUV = i.uv;

				if(preUV.x > _BleedXStart && preUV.x < _BleedXStart + _BleedXWidth)
				{
					preUV.x = _BleedXStart;
				}

				if(preUV.y > _BleedYStart && preUV.y < _BleedYStart + _BleedYWidth)
				{
					preUV.y = _BleedYStart;
				}

				fixed3 distort =  UnpackNormal(tex2D(_DistortMap, i.uv));
				preUV.x += distort.x * _DistortIntensityX;
				preUV.y += distort.y * _DistortIntensityY;

				float2 redUV = preUV;
				redUV.x += _RedOffsetX;
				redUV.y += _RedOffsetY;
				float2 greenUV = preUV;
				greenUV.x += _GreenOffsetX;
				greenUV.y += _GreenOffsetY;
				float2 blueUV = preUV;
				blueUV.x += _BlueOffsetX;
				blueUV.y += _BlueOffsetY;

				fixed4 redPixel = tex2D(_MainTex, redUV);
				fixed4 greenPixel = tex2D(_MainTex, greenUV);
				fixed4 bluePixel = tex2D(_MainTex, blueUV);
				fixed4 final = fixed4(redPixel.r, greenPixel.g, bluePixel.b, 1 );




				final = abs(_InvColor - final);

				return final;
			}

			ENDCG
		}
	}
}
