// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Based on cician's shader from: https://forum.unity3d.com/threads/simple-optimized-blur-shader.185327/#post-1267642

Shader "Blur/MaskedUIBlurOptGrayScale" 
{
    Properties 
    {
        _Size ("Blur", Range(0, 30)) = 1
        _Blend (" GrayScale Value", Range(0,1)) = 0.5

        [HideInInspector] _MainTex ("Tint Color (RGB)", 2D) = "white" {}  // PerRendererData
    }
    
    Category 
    {
        
        // We must be transparent, so other objects are drawn before this one.
        Tags 
        { 
            "Queue"="Transparent" 
            "IgnoreProjector"="True" 
            "RenderType"="Opaque" 
            "ForceNoShadowCasting" = "True"
            "RenderPipeline" = "LightweightPipeline"
        }
        
        ZWrite Off
        Lighting Off
        
        SubShader 
        {
            Pass 
            {   
                Blend SrcAlpha OneMinusSrcAlpha

                HLSLPROGRAM
                // Required to compile gles 2.0 with standard SRP library
                // All shaders must be compiled with HLSLcc and currently only gles is not using HLSLcc by default
                #pragma prefer_hlslcc gles
                #pragma exclude_renderers d3d11_9x
                #pragma target 2.0

                #pragma vertex vert
                #pragma fragment frag
                #pragma fragmentoption ARB_precision_hint_fastest

                //--------------------------------------
                // GPU Instancing
                #pragma multi_compile_instancing

                // #include "UnityCG.cginc"
                //#include "Packages/com.unity.render-pipelines.lightweight/Shaders/UnlitInput.hlsl" 
                #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Macros.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"


                struct appdata_t 
                {
                    float4 vertex : POSITION;
                    half2 texcoord: TEXCOORD0;
                    UNITY_VERTEX_INPUT_INSTANCE_ID
                };
                
                struct v2f 
                {
                    float4 vertex : POSITION;
                    float4 uvgrab : TEXCOORD0;
                    half2 uvmain : TEXCOORD1;
                    half2 helper : TEXCOORD2;
                    UNITY_VERTEX_INPUT_INSTANCE_ID
                    UNITY_VERTEX_OUTPUT_STEREO
                };

                TEXTURE2D(_MainTex);       SAMPLER(sampler_MainTex);
                SAMPLER(_CameraOpaqueTexture);

                // SRP Compatibility
                // UnityPerMaterial
                CBUFFER_START(UnityPerMaterial)
                float4  _MainTex_ST;
                half _Size;
                half _Blend;
                CBUFFER_END

                

                float4 ComputeGrabPosition( float4 position_CS)
                {
                    float4 uvGrab = (float4)0;
                    #if UNITY_UV_STARTS_AT_TOP
                        float scale = -1.0;
                    #else
                        float scale = 1.0;
                    #endif
                    uvGrab.xy = (float2(position_CS.x, position_CS.y*scale) + position_CS.w) * 0.5;
                    uvGrab.zw = position_CS.zw;
                    return uvGrab;
                }
                
                v2f vert (appdata_t v)
                {
                    v2f o;
                    UNITY_SETUP_INSTANCE_ID(v);
                    UNITY_TRANSFER_INSTANCE_ID(v, o);
                    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                    VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex);
                    o.vertex = vertexInput.positionCS;
                    // GET_TEXELSIZE_NAME(_MainTex) 
                    o.uvmain = TRANSFORM_TEX(v.texcoord, _MainTex);
                    o.helper = half2((1.0 / _ScreenParams.x),(1.0 / _ScreenParams.y) ) * _Size;
                    o.uvgrab = ComputeGrabPosition(o.vertex);
                    return o;
                }


                half4 frag( v2f i ) : SV_TARGET 
                {      
                    UNITY_SETUP_INSTANCE_ID(i);
                    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

                    half alpha = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uvmain).a;
                    half4 sum = half4(0,0,0,0);
                    half SAH = i.helper.x * 1.0;

                    // #define GRABPIXEL_H(weight,kernelx) tex2Dproj( _HBlur, float4(i.uvgrab.x + _HBlur_TexelSize.x * kernelx * _Size * alpha, i.uvgrab.y, i.uvgrab.z, i.uvgrab.w)) * weight
                    #define GRABPIXEL_H(weight,kernely) tex2Dproj( _CameraOpaqueTexture, half4(i.uvgrab.x +  kernely * SAH, i.uvgrab.y , i.uvgrab.z, i.uvgrab.w)) * weight

                    // sum += GRABPIXEL_H(0.06, -4.0);
                    sum += GRABPIXEL_H(0.13, -3.0);
                    sum += GRABPIXEL_H(0.15, -2.0);
                    sum += GRABPIXEL_H(0.17, -1.0);
                    sum += GRABPIXEL_H(0.09,  0.0);
                    sum += GRABPIXEL_H(0.17, +1.0);
                    sum += GRABPIXEL_H(0.15, +2.0);
                    sum += GRABPIXEL_H(0.13, +3.0);
                    // sum += GRABPIXEL_H(0.06, +4.0);
                    // sum.a =  alpha;// step(alpha, _AlfaClip);
                    
                    half4 sum1 = half4(0,0,0,0);
                    half SAV = i.helper.y * 1.0;//alpha;

                    #define GRABPIXEL_V(weight,kernely) tex2Dproj( _CameraOpaqueTexture, half4(i.uvgrab.x, i.uvgrab.y +  kernely * SAV, i.uvgrab.z, i.uvgrab.w)) * weight

                    // sum1 += GRABPIXEL_V(0.06, -4.0);
                    sum1 += GRABPIXEL_V(0.13, -3.0);
                    sum1 += GRABPIXEL_V(0.15, -2.0);
                    sum1 += GRABPIXEL_V(0.17, -1.0);
                    sum1 += GRABPIXEL_V(0.09,  0.0);
                    sum1 += GRABPIXEL_V(0.17, +1.0);
                    sum1 += GRABPIXEL_V(0.15, +2.0);
                    sum1 += GRABPIXEL_V(0.13, +3.0);

                    half4 col = lerp(sum,sum1,0.5); // half is Horizontal + Vertical
                    half3 grayscale = col.r * 0.3f + col.g * 0.59f + col.b * 0.11f;
                    col.rgb = lerp(col.rgb, grayscale, _Blend);

                    col.a = alpha;
                    return col;
                }
                ENDHLSL
            }

            
        }
    }
}