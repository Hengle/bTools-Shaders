Shader "bShaders/RimFade"
{
	Properties
	{
		[HDR]_Color("Color", Color) = (1,1,1,1)
		_MainTex("MainTex", 2D) = "white" {}
		_Falloff("Falloff", Range(0,10)) = 1
	}
		SubShader
		{
			Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
			LOD 200
			ZWrite off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma surface surf Standard fullforwardshadows alpha:fade

			#pragma target 3.0

			sampler2D _MainTex;

			struct Input
			{
				float2 uv_MainTex;
				float3 viewDir;
			};

			fixed4 _Color;
			fixed _Falloff;

			void surf(Input IN, inout SurfaceOutputStandard o)
			{
				float rim = saturate(dot(IN.viewDir, o.Normal) *_Falloff);

				fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
				o.Albedo = _Color;
				o.Alpha = c.r * rim *_Color.a;
				o.Emission = _Color * c.r;

				o.Metallic = 0;
				o.Smoothness = 0;
			}
			ENDCG
		}
			FallBack "Diffuse"
}
