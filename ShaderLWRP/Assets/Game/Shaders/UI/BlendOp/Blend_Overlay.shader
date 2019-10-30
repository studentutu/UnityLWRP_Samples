Shader "Custom/BlendOverlay"
{
	Properties
	{
		[HideInInspector] _MainTex ("Texture", 2D) = "white" {}
		_Color (" Tint Color", Color) = (1,1,1,1)

		// these six unused properties are required when a shader
		// is used in the UI system, or you get a warning.
		// look to UI-Default.shader to see these.
		[HideInInspector] _StencilComp ("Stencil Comparison", Float) = 8
		[HideInInspector] _Stencil ("Stencil ID", Float) = 0
		[HideInInspector] _StencilOp ("Stencil Operation", Float) = 0
		[HideInInspector] _StencilWriteMask ("Stencil Write Mask", Float) = 255
		[HideInInspector] _StencilReadMask ("Stencil Read Mask", Float) = 255
		[HideInInspector] _ColorMask ("Color Mask", Float) = 15

		// see for example
 		// http://answers.unity3d.com/questions/980924/ui-mask-with-shader.html
	}
	SubShader
	{

		Tags 
		{ 
		"Queue" = "Transparent" 
		"RenderType" = "Transparent"  // Opaque  Transparent
		"IgnoreProjector"="True" 
		"PreviewType"="Plane"
		"ForceNoShadowCasting" = "True"
		"RenderPipeline" = "LightweightPipeline"

		} 

		Blend SrcAlpha OneMinusSrcAlpha
		
		Pass
		{
			CGPROGRAM
			
			#include "UnityCG.cginc"
			
			#pragma vertex ComputeVertex
			#pragma fragment ComputeFragment
			
			sampler2D _MainTex;
			sampler2D _CameraOpaqueTexture;
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
				fixed4 color : COLOR;
				half2 texcoord : TEXCOORD0;
				float4 screenPos : TEXCOORD1;
			};
			
			VertexOutput ComputeVertex (VertexInput vertexInput)
			{
				VertexOutput vertexOutput;
				
				vertexOutput.vertex = UnityObjectToClipPos(vertexInput.vertex);
				vertexOutput.screenPos = vertexOutput.vertex;	
				vertexOutput.texcoord = vertexInput.texcoord;
				vertexOutput.color = vertexInput.color * _Color;
							
				return vertexOutput;
			}
			
			fixed4 Overlay (fixed4 a, fixed4 b) 
			{
				fixed4 r = a > .5 ? 1.0 - 2.0 * (1.0 - a) * (1.0 - b) : 2.0 * a * b;
				r.a = b.a;
				return r;
			}
			
			fixed4 ComputeFragment (VertexOutput vertexOutput) : SV_Target
			{
				half4 color = tex2D(_MainTex, vertexOutput.texcoord) * vertexOutput.color;
				
				float2 grabTexcoord = vertexOutput.screenPos.xy / vertexOutput.screenPos.w; 
				grabTexcoord.x = (grabTexcoord.x + 1.0) * .5;
				grabTexcoord.y = (grabTexcoord.y + 1.0) * .5; 
				#if UNITY_UV_STARTS_AT_TOP
				grabTexcoord.y = 1.0 - grabTexcoord.y;
				#endif
				
				fixed4 grabColor = tex2D(_CameraOpaqueTexture, grabTexcoord); 
				
				return Overlay(grabColor, color);
			}
			
			ENDCG
		}
		
	}
}
