Shader "Unlit/DissolveColorSpace"
{
    Properties
    {
        _SliceGuide ("Slice Guide (RGB)", 2D) = "white" {}
        _SliceAmount ("Slice Amount", Range(0.0, 1.0)) = 0.5
        [IntRange] _StencilRef ("Stencil Reference Value", Range(0,255)) = 0
    }
    SubShader {
        Tags 
        { 
            "Queue" = "Geometry-11" 
            "RenderType" = "Transparent" 
        }
        Stencil
        {
            Ref [_StencilRef]
            Comp Always
            Pass Replace
        }
        // Cull Off
        Lighting Off

        ZWrite Off

        Blend One OneMinusSrcColor

        CGPROGRAM
        //if you're not planning on using shadows, remove "addshadow" for better performance
        #pragma surface surf Lambert addshadow
        struct Input 
        {
            float2 uv_SliceGuide;
            float _SliceAmount;
        };

        sampler2D _SliceGuide;
        float _SliceAmount;
        void surf (Input IN, inout SurfaceOutput o) 
        {
            clip(tex2D (_SliceGuide, IN.uv_SliceGuide).r - _SliceAmount);
            o.Albedo = float4(0,0,0,0);
        }
        ENDCG
    } 
    Fallback "Diffuse"
}
