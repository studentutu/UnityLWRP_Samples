﻿Shader "MiniGolf/Minimalist_Gradient_LWRPv0.3"
{
    Properties
    {
        _TOP_COLOR_START("TOP Color Start", Color) = (0,0,0,0)
        _TOP_COLOR_End("TOP Color End", Color) = (0,0,0,0)
        _TOP_Height("TOP Height ", Float) = 1
        _Top_Rotation("TOP Rotation ", Float) = 0
        _Top_Position("TOP Position", Vector) = (0,0,0,0)
        _Bottom_COLOR_START("BOTTOM Color Start", Color) = (0,0,0,0)
        _Bottom_COLOR_End("BOTTOM Color End", Color) = (0,0,0,0)
        _Bottom_Height("BOTTOM Height ", Float) = 1
        _Bottom_Rotation("BOTTOM Rotation ", Float) = 0
        _Bottom_Position("BOTTOM Position", Vector) = (0,0,0,0)
        _Front_COLOR_START_1("FRONT Color Start", Color) = (0,1,0.2470588,1)
        _Front_COLOR_End("FRONT Color End", Color) = (0,0,0,1)
        _Front_Height("FRONT Height ", Float) = 1
        _Front_Rotation("FRONT Rotation ", Float) = 0
        _Front_Position("FRONT Position", Vector) = (0,0,0,0)
        _Back_Color_Start("BACK Color Start", Color) = (0,0,0,0)
        _Back_Color_End("BACK Color End", Color) = (0,0,0,0)
        _Back_Height("BACK Height ", Float) = 1
        _Back_Rotation("BACK Rotation ", Float) = 0
        _Back_Position("BACK Position", Vector) = (0,0,0,0)
        _Left_Color_Start("LEFT Color Start", Color) = (0,0,0,0)
        _Left_Color_End("LEFT Color End", Color) = (0,0,0,0)
        _Left_Height("LEFT Height ", Float) = 1
        _Left_Rotation("LEFT Rotation ", Float) = 0
        _Left_Position("LEFT Position", Vector) = (0,0,0,0)
        _Right_Color_Start("RIGHT Color Start", Color) = (0,0,0,0)
        _Right_Color_End("RIGHT Color End", Color) = (0,0,0,0)
        _Right_Height("RIGHT Height ", Float) = 1
        _Right_Rotation("RIGHT Rotation ", Float) = 0
        _Right_Position("RIGHT Position", Vector) = (0,0,0,0)
        _Emmision("Emission", Color) = (0,0,0,0)
        _IS_LOCAL("isLocal ", Range(0, 1)) = 0

    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="LightweightPipeline"
            "RenderType"="Opaque"
            "Queue"="Geometry+0"
        }
        Pass
        {
        	Tags{"LightMode" = "LightweightForward"}

        	// Material options generated by graph

            Blend One Zero, One Zero

            Cull Back

            ZTest LEqual

            ZWrite On

        	HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

        	// -------------------------------------
            // Lightweight Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            // #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            // #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT
            // #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
            
        	// -------------------------------------
            // Unity defined keywords
            // #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            // #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fog

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #pragma vertex vert
        	#pragma fragment frag

            #define DONTMIX 1

        	// Defines generated by graph

        	#include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
        	#include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Lighting.hlsl"
        	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
        	#include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/ShaderGraphFunctions.hlsl"

            CBUFFER_START(UnityPerMaterial)
            half4 _TOP_COLOR_START;
            half4 _TOP_COLOR_End;
            half _TOP_Height;
            half _Top_Rotation;
            half2 _Top_Position;
            half4 _Bottom_COLOR_START;
            half4 _Bottom_COLOR_End;
            half _Bottom_Height;
            half _Bottom_Rotation;
            half2 _Bottom_Position;
            half4 _Front_COLOR_START_1;
            half4 _Front_COLOR_End;
            half _Front_Height;
            half _Front_Rotation;
            half2 _Front_Position;
            half4 _Back_Color_Start;
            half4 _Back_Color_End;
            half _Back_Height;
            half _Back_Rotation;
            half2 _Back_Position;
            half4 _Left_Color_Start;
            half4 _Left_Color_End;
            half _Left_Height;
            half _Left_Rotation;
            half2 _Left_Position;
            half4 _Right_Color_Start;
            half4 _Right_Color_End;
            half _Right_Height;
            half _Right_Rotation;
            half2 _Right_Position;
            half4 _Emmision;
            half _IS_LOCAL;
            CBUFFER_END

            //Direction vector constants
            static const half3 FrontDir = half3(0, 0, 1);
            static const half3 BackDir = half3(0, 0, -1);
            static const half3 LeftDir = half3(1, 0, 0);
            static const half3 RightDir = half3(-1, 0, 0);
            static const half3 TopDir = half3(0, 1, 0);
            static const half3 BottomDir = half3(0, -1, 0);
            static const half3 whiteColor = half3(1, 1, 1);


            void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
            {
                Out = lerp(A, B, T);
            }

            void SG_IsLocalGradient(float3 ObjectSpacePos, float IsLocal, out float3 Position)
            {
                Unity_Lerp_float3(TransformObjectToWorld(ObjectSpacePos.xyz).xyz, ObjectSpacePos.xyz, float3(IsLocal, IsLocal, IsLocal), Position);
            }

            void Unity_Divide_float(float A, float B, out float Out)
            {
                Out = A / B;
            }

            void Unity_Sine_float(float In, out float Out)
            {
                Out = sin(In);
            }

            void Unity_Subtract_float(float A, float B, out float Out)
            {
                Out = A - B;
            }

            void Unity_Multiply_float (float A, float B, out float Out)
            {
                Out = A * B;
            }

            void Unity_Cosine_float(float In, out float Out)
            {
                Out = cos(In);
            }

            void Unity_Add_float(float A, float B, out float Out)
            {
                Out = A + B;
            }

            void Unity_Saturate_float(float In, out float Out)
            {
                Out = saturate(In);
            }

            void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
            {
                Out = lerp(A, B, T);
            }

           

            void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
            {
                Out = dot(A, B);
            }

            void Unity_Maximum_float(float A, float B, out float Out)
            {
                Out = max(A, B);
            }

            

            void SG_DirectionMixFinalColors(float3 NormalToUSe, float3 DirectionToUse, float4 ColorFromSide, out float4 OutVector4)
            {
                float _ResultMixing;
                Unity_DotProduct_float3(NormalToUSe, DirectionToUse, _ResultMixing);

                Unity_Maximum_float(_ResultMixing, 0, _ResultMixing);

                Unity_Subtract_float(1, _ResultMixing, _ResultMixing);

                Unity_Lerp_float4(ColorFromSide, float4(1, 1, 1, 1), (_ResultMixing.xxxx), OutVector4);
            }

            void Unity_Multiply_float (float4 A, float4 B, out float4 Out)
            {
                Out = A * B;
            }

            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                half4 albedo;
            };
            struct VertexDescriptionInputs
            {
                float4 ObjectSpacePosition;
                float3 WorldSpaceNormal;
            };



            VertexDescription PopulateVertexData(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;

                //getting GradientFactor position (world/local)
                float3 GradPos = lerp(TransformObjectToWorld(IN.ObjectSpacePosition), IN.ObjectSpacePosition.xyz, float3(_IS_LOCAL,_IS_LOCAL,_IS_LOCAL));

                half3 colorFront, colorBack, colorLeft, colorRight, colorTop, colorDown;
                half dirFront  = max(dot(IN.WorldSpaceNormal, FrontDir),  0.0);
                half dirBack   = max(dot(IN.WorldSpaceNormal, BackDir),   0.0);
                half dirLeft   = max(dot(IN.WorldSpaceNormal, LeftDir),   0.0);
                half dirRight  = max(dot(IN.WorldSpaceNormal, RightDir),  0.0);
                half dirTop    = max(dot(IN.WorldSpaceNormal, TopDir),    0.0);
                half dirBottom = max(dot(IN.WorldSpaceNormal, BottomDir), 0.0);

                // #if FRONTSOLID 
                //     colorFront = _Front_COLOR_START_1; 
                // #endif
                // #if BACKSOLID
                //     colorBack = _Back_Color_Start;
                // #endif
                // #if LEFTSOLID
                //     colorLeft = _Left_Color_Start;
                // #endif
                // #if RIGHTSOLID
                //     colorRight = _Right_Color_Start;
                // #endif
                // #if TOPSOLID
                //     colorTop = _TOP_COLOR_START;
                // #endif
                // #if BOTTOMSOLID
                //     colorDown = _Bottom_COLOR_START;
                // #endif

                // #if FRONTGRADIENT
                half RotatedGrad_F = (GradPos.x - _Front_Position.x) * sin(_Front_Rotation/57.32) + (GradPos.y - _Front_Position.y) * cos(_Front_Rotation/57.32);
                half GradientFactor_F = saturate(RotatedGrad_F / -_Front_Height);
                colorFront = lerp(_Front_COLOR_START_1, _Front_COLOR_End, GradientFactor_F);
                // #endif

                // #if BACKGRADIENT
                half RotatedGrad_B = (GradPos.x - _Back_Position.x) * sin(_Back_Rotation/57.32) + (GradPos.y - _Back_Position.y) * cos(_Back_Rotation/57.32);
                half GradientFactor_B = saturate(RotatedGrad_B / -_Back_Height);
                colorBack  = lerp(_Back_Color_Start, _Back_Color_End, GradientFactor_B);
                // #endif

                // #if LEFTGRADIENT
                half RotatedGrad_L = (GradPos.z - _Left_Position.x) * sin(_Left_Rotation/57.32) + (GradPos.y - _Left_Position.y) * cos(_Left_Rotation/57.32);
                half GradientFactor_L = saturate(RotatedGrad_L / -_Left_Height);
                colorLeft  = lerp(_Left_Color_Start, _Left_Color_End, GradientFactor_L);
                // #endif

                // #if RIGHTGRADIENT
                half RotatedGrad_R = (GradPos.z - _Right_Position.x) * sin(_Right_Rotation/57.32) + (GradPos.y - _Right_Position.y) * cos(_Right_Rotation/57.32);
                half GradientFactor_R = saturate(RotatedGrad_R / -_Right_Height);
                colorRight = lerp(_Right_Color_Start, _Right_Color_End, GradientFactor_R);
                // #endif

                // #if TOPGRADIENT
                half RotatedGrad_T = (GradPos.z - _Top_Position.x) * cos(_Top_Rotation/57.32) + (GradPos.x - _Top_Position.y) * sin(_Top_Rotation/57.32);
                half GradientFactor_T = saturate(RotatedGrad_T / -_TOP_Height);
                colorTop   = lerp(_TOP_COLOR_START, _TOP_COLOR_End, GradientFactor_T);
                // #endif

                // #if BOTTOMGRADIENT
                half RotatedGrad_D = (GradPos.z - _Bottom_Position.x) * cos(_Bottom_Rotation/57.32) + (GradPos.x - _Bottom_Position.y) * sin(_Bottom_Rotation/57.32);
                half GradientFactor_D = saturate(RotatedGrad_D / -_Bottom_Height);
                colorDown  = lerp(_Bottom_COLOR_START, _Bottom_COLOR_End, GradientFactor_D);
                // #endif


                half3 Maincolor;
            #if DONTMIX
                Maincolor = colorFront * dirFront + colorBack * dirBack + colorLeft * dirLeft + colorRight * dirRight + colorTop * dirTop + colorDown * dirBottom;
            #else
                Maincolor = lerp(colorFront, whiteColor, 1-dirFront) * lerp(colorBack, whiteColor, 1-dirBack) * lerp(colorLeft, whiteColor, 1-dirLeft) * lerp(colorRight, whiteColor, 1-dirRight) * lerp(colorTop, whiteColor, 1-dirTop) * lerp(colorDown, whiteColor, 1-dirBottom);
            #endif

            
                half4 result = half4(Maincolor.xyz,1);
                description.albedo = result;

                return description;
            }

            

            struct GraphVertexInput
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord1 : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };


        	struct GraphVertexOutput
            {
                float4 clipPos                : SV_POSITION;
                DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 0);
        		half4 fogFactorAndVertexLight : TEXCOORD1; // x: fogFactor, yzw: vertex light
            	float4 shadowCoord            : TEXCOORD2;
        		// Interpolators defined by graph
                float3 WorldSpacePosition : TEXCOORD3;
                float3 WorldSpaceNormal : TEXCOORD4;
                float3 WorldSpaceViewDirection : TEXCOORD5;
                half4 uv1 : TEXCOORD6;
                half4 albedo : TEXCOORD7;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            GraphVertexOutput vert (GraphVertexInput v)
        	{
        		GraphVertexOutput o = (GraphVertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
            	UNITY_TRANSFER_INSTANCE_ID(v, o);

        		// Vertex transformations performed by graph
                float3 WorldSpacePosition = mul(UNITY_MATRIX_M,v.vertex).xyz;
                float3 WorldSpaceNormal = TransformObjectToWorldNormal(v.normal);
                float3 WorldSpaceViewDirection = _WorldSpaceCameraPos.xyz - mul(GetObjectToWorldMatrix(), float4(v.vertex.xyz, 1.0)).xyz;
                float4 uv1 = v.texcoord1;
                float4 ObjectSpacePosition = mul(UNITY_MATRIX_I_M,float4(WorldSpacePosition,1.0));

        		VertexDescriptionInputs vdi = (VertexDescriptionInputs)0;

        		// Vertex description inputs defined by graph
                vdi.ObjectSpacePosition = ObjectSpacePosition;
                vdi.WorldSpaceNormal = WorldSpaceNormal;

        	    VertexDescription vd = PopulateVertexData(vdi);
        		v.vertex.xyz = vd.Position;

        		// Vertex shader outputs defined by graph
                o.WorldSpacePosition = WorldSpacePosition;
                o.WorldSpaceNormal = WorldSpaceNormal;
                o.WorldSpaceViewDirection = WorldSpaceViewDirection;
                o.uv1 = uv1;
                o.albedo = vd.albedo;

                VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);
                
         		// We either sample GI from lightmap or SH.
        	    // Lightmap UV and vertex SH coefficients use the same interpolator ("float2 lightmapUV" for lightmap or "half3 vertexSH" for SH)
                // see DECLARE_LIGHTMAP_OR_SH macro.
        	    // The following funcions initialize the correct variable with correct data
        	    OUTPUT_LIGHTMAP_UV(v.texcoord1, unity_LightmapST, o.lightmapUV);
        	    OUTPUT_SH(WorldSpaceNormal, o.vertexSH);

        	    half3 vertexLight = VertexLighting(vertexInput.positionWS, WorldSpaceNormal);
        	    // half fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
        	    o.fogFactorAndVertexLight = half4(0, vertexLight);
        	    o.clipPos = vertexInput.positionCS;

        	#ifdef _MAIN_LIGHT_SHADOWS
        		o.shadowCoord = GetShadowCoord(vertexInput);
        	#endif
        		return o;
        	}

        	half4 frag (GraphVertexOutput IN ) : SV_Target
            {
            	UNITY_SETUP_INSTANCE_ID(IN);

        		// Pixel transformations performed by graph
                float3 WorldSpacePosition = IN.WorldSpacePosition;
                float3 WorldSpaceNormal = IN.WorldSpaceNormal;
                float3 WorldSpaceViewDirection = IN.WorldSpaceViewDirection;

        		float3 Albedo = IN.albedo.xyz;
        		float Metallic = 0;
        		float3 Specular = float3(0.5, 0.5, 0.5);
        		float3 Emission = _Emmision.xyz;
        		float Occlusion = 1;
        		float Smoothness = 0;
        		float Alpha = 1;
        		float AlphaClipThreshold = 0.5;


        		InputData inputData;
        		inputData.positionWS = WorldSpacePosition;
                inputData.normalWS = WorldSpaceNormal;
        	    // viewDirection should be normalized here, but we avoid doing it as it's close enough and we save some ALU.
        	    inputData.viewDirectionWS = WorldSpaceViewDirection;
        	    inputData.shadowCoord = IN.shadowCoord;
        	    inputData.fogCoord = IN.fogFactorAndVertexLight.x;
        	    inputData.vertexLighting = IN.fogFactorAndVertexLight.yzw;
        	    inputData.bakedGI = float3(1,1,1); 
                half4 color = half4(Albedo.xyz,1);

        		color = color * LightweightFragmentPBR(
        			inputData, 
        			float3(1,1,1),  // Albedo
        			Metallic, 
        			Specular, 
        			Smoothness, 
        			Occlusion, 
        			Emission, 
        			Alpha);

        		// Computes fog factor per-vertex
            	// color.rgb = MixFog(color.rgb, IN.fogFactorAndVertexLight.x);

                // #if _AlphaClip
                // 		clip(Alpha - AlphaClipThreshold);
                // #endif
        		return color; 
            }

        	ENDHLSL
        }

    }
    // CustomEditor "UnityEditor.ShaderGraph.PBRMasterGUI"
    FallBack "Hidden/InternalErrorShader"
    // CustomEditor "Minimalist.MinimalistStandardEditor"
}
