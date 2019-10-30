// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Based on cician's shader from: https://forum.unity3d.com/threads/simple-optimized-blur-shader.185327/#post-1267642

Shader "Blur/MaskedUIBlurOpt" {
    Properties {
        _Size ("Blur", Range(0, 30)) = 1
        [HideInInspector]_MainTex ("Tint Color (RGB)", 2D) = "white" {}  // PerRendererData
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
			Blend SrcAlpha OneMinusSrcAlpha
            Pass 
            {   
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma fragmentoption ARB_precision_hint_fastest
                #include "UnityCG.cginc"
                
                struct appdata_t 
                {
                    float4 vertex : POSITION;
                    half2 texcoord: TEXCOORD0;
                };
                
                struct v2f 
                {
                    float4 vertex : POSITION;
                    float4 uvgrab : TEXCOORD0;
                    half2 uvmain : TEXCOORD1;
                    half2 helper : TEXCOORD2;

                };

                sampler2D _MainTex;
                sampler2D _CameraOpaqueTexture;
                half _Size;

                v2f vert (appdata_t v)
                {
                    v2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.uvmain = v.texcoord;
                    o.helper = half2((1.0 / _ScreenParams.x),(1.0 / _ScreenParams.y) ) * _Size;
                    o.uvgrab = ComputeGrabScreenPos(o.vertex);
                    return o;
                }
                

                fixed4 frag( v2f i ) : SV_TARGET 
                {      

                    half alpha = tex2D(_MainTex, i.uvmain).a;
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

                    return lerp(sum,sum1,0.5) ;
                }
                ENDCG
            }

           
        }
    }
}