//===============================================================================
//Copyright (c) 2015 PTC Inc. All Rights Reserved.
//
//Confidential and Proprietary - Protected under copyright and other laws.
//Vuforia is a trademark of PTC Inc., registered in the United States and other
//countries.
//===============================================================================
//===============================================================================
//Copyright (c) 2010-2014 Qualcomm Connected Experiences, Inc.
//All Rights Reserved.
//Confidential and Proprietary - Qualcomm Connected Experiences, Inc.
//===============================================================================

Shader "Unlit/DepthMaskStencilled" 
{
    
    Properties
    {
        [IntRange] _StencilRef ("Stencil Reference Value", Range(0,255)) = 0
    }
    SubShader 
    {
        // Render the mask after regular geometry, but before masked geometry and
        // transparent things.
        
        // Tags {"Queue" = "Geometry-10" }
        
        // Turn off lighting, because it's expensive and the thing is supposed to be
        // invisible anyway.

        // Do nothing specific in the pass:
        // Draw into the depth buffer in the usual way.  This is probably the default,
        // but it doesn't hurt to be explicit.
        Stencil
        {
            Ref [_StencilRef]
            Comp NotEqual
            Pass Zero
        }
        ZTest LEqual
        ZWrite On
        // Don't draw anything into the RGBA channels. This is an undocumented
        // argument to ColorMask which lets us avoid writing to anything except
        // the depth buffer.

        ColorMask 0

        Tags 
        {
            // "RenderType" = "Transparent"             
            "Queue" = "Geometry-1" 
            "ForceNoShadowCasting" = "true"
        }
        Pass 
        {
            Blend One OneMinusSrcColor

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            
            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return float4(0,0,0,0);
            }
            ENDCG
        }
        // Pass 
        // {
        //     Tags 
        //     {
        //         "RenderType" = "Transparent" 
        //     }
        //     // Draw into the depth buffer in the usual way.  This is probably the default,
        //     // but it doesn't hurt to be explicit.
        //     Stencil
        //     {
        //         Ref [_StencilRef]
        //         Comp Equal
        //         Pass Zero
        //     }
        //     // ZTest LEqual
        //     ZWrite Off
        //     // Don't draw anything into the RGBA channels. This is an undocumented
        //     // argument to ColorMask which lets us avoid writing to anything except
        //     // the depth buffer.

        //     ColorMask 0
        //     // Blend Zero One

        //     CGPROGRAM

        //     #pragma vertex vert
        //     #pragma fragment frag

        //     #include "UnityCG.cginc"
            
        //     struct appdata
        //     {
        //         float4 vertex : POSITION;
        //     };

        //     struct v2f
        //     {
        //         float4 vertex : SV_POSITION;
        //     };

        //     v2f vert (appdata v)
        //     {
        //         v2f o;
        //         o.vertex = UnityObjectToClipPos(v.vertex);
        //         return o;
        //     }

        //     fixed4 frag (v2f i) : SV_Target
        //     {
        //         return float4(0,0,0,0);
        //     }
        //     ENDCG
        // }
        // Pass 
        // {
            //     // Draw into the depth buffer in the usual way.  This is probably the default,
            //     // but it doesn't hurt to be explicit.

            //     // ZTest LEqual
            //     ZWrite Off
            
            //     Stencil
            //     {
                //         Ref [_StencilRef]
                //         Comp Equal
                //         Pass Keep
            //     }
            //     // Don't draw anything into the RGBA channels. This is an undocumented
            //     // argument to ColorMask which lets us avoid writing to anything except
            //     // the depth buffer.

            //     // ColorMask 0
            //     Blend One OneMinusSrcColor

            //     CGPROGRAM

            //     #pragma vertex vert
            //     #pragma fragment frag

            //     #include "UnityCG.cginc"
            
            //     struct appdata
            //     {
                //         float4 vertex : POSITION;
            //     };

            //     struct v2f
            //     {
                //         float4 vertex : SV_POSITION;
            //     };

            //     sampler2D _SliceGuide;
            //     float4 _SliceGuide_ST;
            //     float _SliceAmount;

            //     v2f vert (appdata v)
            //     {
                //         v2f o;
                //         o.vertex = UnityObjectToClipPos(v.vertex);
                //         return o;
            //     }

            //     fixed4 frag (v2f i) : SV_Target
            //     {
                //         return float4(0,0,0,0);
            //     }
            //     ENDCG
        // }
    }
}
