Shader "UI/Blend/Darken"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color("Tint", Color) = (1,1,1,1)
	}
	SubShader
	{
		Tags
		{
			"Queue"="Transparent"
			"RenderType"="Transparent" 
		}
		
		BlendOp Min
		Blend One One

		Pass
		{
			CGPROGRAM

			#include "UnityCG.cginc"
			#pragma vertex vert
			#pragma fragment frag
			
			sampler2D _MainTex;
			fixed4 _Color;

			struct VertexInput
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct VertexOutput
			{
				float4 vertex : SV_POSITION;
				float4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};
			
			VertexOutput vert (VertexInput v)
			{
				VertexOutput o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord = v.texcoord;
				o.color = v.color * _Color;
				return o;
			}
			
			fixed4 frag (VertexOutput o) : SV_Target
			{
				return tex2D(_MainTex, o.texcoord) * o.color;
			}
			ENDCG
		}
	}

	Fallback "UI/Default"
}
