Shader "Unlit/DepthWithShadowsOnly"
{
    Properties
    {
        _SliceGuide ("Slice Guide (RGB)", 2D) = "white" {}
        _Opaqueness ("Slice Amount", Range(0.0, 1.0)) = 0.5
        [IntRange] _StencilRef ("Stencil Reference Value", Range(0,255)) = 0
    }

    SubShader 
    {
        Tags 
        { 
            "Queue" = "Geometry-1" 
            "RenderType" = "transparent" 
            "ForceNoShadowCasting" = "true"
        }
        Pass
        {
            Stencil
            {
                Ref [_StencilRef]
                Comp Always
                Pass Replace
            }

            // Cull both
            Lighting Off
            ZWrite Off

            Blend  Zero One
            // Blend  Zero One

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
                float2 uv_SliceGuide : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _SliceGuide;
            float4 _SliceGuide_ST;
            float _Opaqueness;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv_SliceGuide = TRANSFORM_TEX(v.uv, _SliceGuide);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = float4(0,0,0,0);

                clip(tex2D (_SliceGuide, i.uv_SliceGuide).r - _Opaqueness);
                return col;
            }

            ENDCG
        }
    } 
    Fallback "Diffuse"
}
