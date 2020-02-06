Shader "N-IX/RandomizeTileColors"
{
    Properties
    {
        _Color("Tinting Color ", Color) = (1,1,1,1)
        _MainTex("Albedo Map", 2D) = "white" {}

        _RandomizatonOfTilesScaleMap("Randomize Noise Map", 2D) = "white" {}
        _ColorTOBeUsedFor(" Noise Color ", Color) = (0,0,0)
        _RandomizatonOfTiles("Tiles Noise Strength", Range(0.0, 1.0)) = 0
        _SaturationStrenght(" Tiles saturation Noise Strength", Range(-2, 2.0)) = 0.5

        [PerRendererData] _AllowedOffsett (" Offset  X Y of the UV", Vector) = (0,0,0,0)
        [PerRendererData] _ColorTint (" _ColorTint", Float) = 1


        _Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5

        _Glossiness("Smoothness", Range(0.0, 1.0)) = 0.5
        _GlossMapScale("Smoothness Scale", Range(0.0, 1.0)) = 1.0
        [Enum(Metallic Alpha,0,Albedo Alpha,1)] _SmoothnessTextureChannel ("Smoothness texture channel", Float) = 0

        [Gamma] _Metallic("Metallic Strength", Range(0.0, 1.0)) = 0.0
        _MetallicGlossMap("Metallic Map", 2D) = "white" {}

        [ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
        [ToggleOff] _GlossyReflections("Glossy Reflections", Float) = 1.0

        _BumpScale("Bump Scale", Float) = 1.0
        [Normal] _BumpMap("Normal Map", 2D) = "bump" {}

        // [HideInInspector] _Parallax ("Height Scale", Range (0.005, 0.08)) = 0.02
        // [HideInInspector] _ParallaxMap ("Height Map", 2D) = "black" {}

        _OcclusionStrength("Occlusion Strength", Range(0.0, 1.0)) = 1.0
        _OcclusionMap("Occlusion Map", 2D) = "white" {}

        _EmissionColor("Emission Color", Color) = (0,0,0)
        _EmissionMap("Emission Map", 2D) = "white" {}

        // _DetailMask("Detail Mask", 2D) = "white" {}

        // _DetailAlbedoMap("Detail Albedo x2", 2D) = "grey" {}
        // _DetailNormalMapScale("Scale", Float) = 1.0
        // [Normal] _DetailNormalMap("Normal Map", 2D) = "bump" {}

        [Enum(UV0,0,UV1,1)] _UVSec ("UV Set for secondary textures", Float) = 0


        // Blending state
        [HideInInspector] _Mode ("__mode", Float) = 0.0
        [HideInInspector] _SrcBlend ("__src", Float) = 1.0
        [HideInInspector] _DstBlend ("__dst", Float) = 0.0
        [HideInInspector] _ZWrite ("__zw", Float) = 1.0
    }

    CGINCLUDE
    // #define _EMISSION 1
    // #define _NORMALMAP 1
    // #define CUSTOM_METALLIC_WORKFLOW RoughnessSetup_Custom
    ENDCG

    SubShader
    {

        // Forward Pass
        //
        Pass
        {
            Tags 
            { 
                "Queue"="Geometry" 
                "RenderType"="Opaque" 
                "LightMode" = "ForwardBase"
            }
            LOD 100
            Blend [_SrcBlend] [_DstBlend]
            ZWrite [_ZWrite]

            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vertBase
            #pragma fragment  frag  
            // custom frag
            // native Unity fragBase
            #pragma fragmentoption ARB_precision_hint_fastest


            // #pragma shader_feature_local _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
            #pragma shader_feature _NORMALMAP
            #pragma shader_feature _EMISSION
            #pragma shader_feature_local _METALLICGLOSSMAP
            #pragma shader_feature_local _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature_local _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature_local _GLOSSYREFLECTIONS_OFF

            // #pragma shader_feature_local _DETAIL_MULX2 // not really needed
            // #pragma shader_feature_local _PARALLAXMAP // not really needed

            #pragma shader_feature_local _METALIC_SETUP_CUSTON
            #pragma shader_feature_local _METALIC_SETUP_ROUGHNESS_CUSTON
            #pragma shader_feature_local _METALIC_SETUP_SPECULAR_CUSTON

            //#pragma multi_compile _ LOD_FADE_CROSSFADE

            // make Light/Shadows Work
            #pragma multi_compile_fwdbase

            // make fog work
            #pragma multi_compile_fog

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing


            #include "UnityCG.cginc"
            // #include "AutoLight.cginc"
            #include "UnityStandardCoreForward.cginc"

            // #include "UnityStandardCoreForwardSimple.cginc"
            // VertexOutputBaseSimple vertBase (VertexInput v) { return vertForwardBaseSimple(v); }
            // VertexOutputForwardAddSimple vertAdd (VertexInput v) { return vertForwardAddSimple(v); }
            // half4 fragBase (VertexOutputBaseSimple i) : SV_Target { return fragForwardBaseSimpleInternal(i); }
            // half4 fragAdd (VertexOutputForwardAddSimple i) : SV_Target { return fragForwardAddSimpleInternal(i); }
            // #include "UnityStandardCore.cginc" 
            // Standart Default Shader
            // VertexOutputForwardBase vertBase (VertexInput v) { return vertForwardBase(v); }
            // VertexOutputForwardAdd vertAdd (VertexInput v) { return vertForwardAdd(v); }
            // half4 fragBase (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i); }
            // half4 fragAdd (VertexOutputForwardAdd i) : SV_Target { return fragForwardAddInternal(i); }

            // struct appdata
            // {
                //     float4 position_OS : POSITION;
                //     float2 uv : TEXCOORD0;
                //     float4 uv1 : TEXCOORD1;
                //     float4 uv2 : TEXCOORD2;                
                //     float3 normal : NORMAL;
                //     float4 tangent   : TANGENT;
                //     UNITY_VERTEX_INPUT_INSTANCE_ID
            // };
            
            // struct v2f
            // {
                //     float4 position_CS                    : SV_POSITION;
                //     float2 uv                             : TEXCOORD0;
                //     UNITY_FOG_COORDS(1)                   // TEXCOORD[number]
                //     float4 ambientOrLightmapUV            : TEXCOORD2;
                //     float4 tangentToWorldAndPackedData[3] : TEXCOORD3;    // [3x3:tangentToWorld | 1x3:viewDirForParallax or worldPos]
                //     float4 eyeVecCustom                   : TEXCOORD8;  // eyeVecCustom.xyz | fogCoord
                //     #if UNITY_REQUIRE_FRAG_WORLDPOS && !UNITY_PACK_WORLDPOS_WITH_TANGENT
                //         float3 posWorld                    : TEXCOORD5;
                //     #endif

                //     LIGHTING_COORDS(6, 7) // TEXCOORD[number1], TEXCOORD[number2]
                //     UNITY_VERTEX_INPUT_INSTANCE_ID
                //     UNITY_VERTEX_OUTPUT_STEREO
            // };

            // float _RandomizatonOfTilesScale;
            uniform fixed _RandomizatonOfTiles;
            uniform fixed _SaturationStrenght;
            uniform half4 _ColorTOBeUsedFor;    
            uniform sampler2D _RandomizatonOfTilesScaleMap;
            uniform float4 _RandomizatonOfTilesScaleMap_ST;

            UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
            UNITY_DEFINE_INSTANCED_PROP(  float4, _AllowedOffsett)  // acces via UNITY_ACCESS_INSTANCED_PROP(Props, _AllowedOffsett);
            UNITY_DEFINE_INSTANCED_PROP(  float, _ColorTint)  // acces via UNITY_ACCESS_INSTANCED_PROP(Props, _ColorTint);
            
            UNITY_INSTANCING_BUFFER_END(Props)

            // half4 GetAmbientOrLightFromUV_Custom(appdata input, float3 posWorld, half3 normalWorld)
            // {
                //     half4 ambientOrLightmapUV = 0;

                //     // Static lightmaps
                //     #ifdef LIGHTMAP_ON
                //         ambientOrLightmapUV.xy = input.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
                //         ambientOrLightmapUV.zw = 0;
                //         // Sample light probe for Dynamic objects only (no static or dynamic lightmaps)
                //     #elif UNITY_SHOULD_SAMPLE_SH
                //         #ifdef VERTEXLIGHT_ON
                //             // Approximated illumination from non-important point lights
                //             ambientOrLightmapUV.rgb = Shade4PointLights (
                //             unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
                //             unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
                //             unity_4LightAtten0, posWorld, normalWorld);
                //         #endif

                //         ambientOrLightmapUV.rgb = ShadeSHPerVertex (normalWorld, ambientOrLightmapUV.rgb);
                //     #endif

                //     #ifdef DYNAMICLIGHTMAP_ON
                //         ambientOrLightmapUV.zw = input.uv2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
                //     #endif

                //     return ambientOrLightmapUV;
            // }

            // Function
            // inline float3 applyHue(float3 aColor, float aHue)
            // {
                // 	float angle = radians(aHue);
                // 	float3 k = float3(0.57735, 0.57735, 0.57735);
                // 	float cosAngle = cos(angle);
                // 	//Rodrigues' rotation formula
                // 	return aColor * cosAngle + cross(k, aColor) * sin(angle) + k * dot(k, aColor) * (1 - cosAngle);
            // }


            inline float4 applySatEffect(float4 startColor, fixed sat)
            {
                // float hue = 360 * hsbc.r;
                float saturation = sat * 2;
                // float brightness = hsbc.b * 2 - 1;
                // float contrast = hsbc.a * 2;

                float4 outputColor = startColor;
                // outputColor.rgb = applyHue(outputColor.rgb, hue);
                // outputColor.rgb = (outputColor.rgb - 0.5f) * contrast + 0.5f + brightness;
                outputColor.rgb = lerp(Luminance(outputColor.rgb), outputColor.rgb, saturation);
                
                return outputColor;
            }

            inline float3 CustomAlbedo(float4 i_tex, float3 posWorld)
            {
                // noise
                float StrenghOfNoise;


                float4 offestInstanced = UNITY_ACCESS_INSTANCED_PROP(Props, _AllowedOffsett);
                float2 uv_texture = i_tex.xy + offestInstanced.xy;
                

                float2 currenUVTarget =  float2(posWorld.x + uv_texture.x,posWorld.z + uv_texture.y);
                currenUVTarget = TRANSFORM_TEX(currenUVTarget,_RandomizatonOfTilesScaleMap);
                StrenghOfNoise = tex2D(_RandomizatonOfTilesScaleMap, currenUVTarget);

                
                half3 albedoColor = Albedo(i_tex);

                albedoColor = lerp(albedoColor,applySatEffect(float4(albedoColor.xyz,1),  UNITY_ACCESS_INSTANCED_PROP(Props, _ColorTint)) .xyz, _SaturationStrenght);
                albedoColor = lerp(albedoColor,albedoColor * _ColorTOBeUsedFor, StrenghOfNoise *  _RandomizatonOfTiles);
                return albedoColor;
            }

            
            #if defined(_METALIC_SETUP_CUSTON) 
                #define CUSTOM_METALLIC_WORKFLOW MetallicSetup_Custom
            #elif  defined(_METALIC_SETUP_ROUGHNESS_CUSTON) 
                #define CUSTOM_METALLIC_WORKFLOW RoughnessSetup_Custom
            #elif defined(_METALIC_SETUP_SPECULAR_CUSTON )
                #define CUSTOM_METALLIC_WORKFLOW SpecularSetup_Custom
            #else
                #define CUSTOM_METALLIC_WORKFLOW RoughnessSetup_Custom
            #endif

            inline FragmentCommonData SpecularSetup_Custom (float4 i_tex, float3 posWorld)
            {
                half4 specGloss = SpecularGloss(i_tex.xy);
                half3 specColor = specGloss.rgb;
                half smoothness = specGloss.a;

                half oneMinusReflectivity;
                half3 finalAlbedo = CustomAlbedo(i_tex,posWorld);
                half3 diffColor = EnergyConservationBetweenDiffuseAndSpecular (finalAlbedo, specColor, /*out*/ oneMinusReflectivity);

                FragmentCommonData o = (FragmentCommonData)0;
                o.diffColor = diffColor;
                o.specColor = specColor;
                o.oneMinusReflectivity = oneMinusReflectivity;
                o.smoothness = smoothness;
                return o;
            }

            inline FragmentCommonData RoughnessSetup_Custom(float4 i_tex, float3 posWorld)
            {
                half2 metallicGloss = MetallicRough(i_tex.xy);
                half metallic = metallicGloss.x;
                half smoothness = metallicGloss.y; // this is 1 minus the square root of real roughness m.

                half oneMinusReflectivity;
                half3 specColor;
                half3 finalAlbedo = CustomAlbedo(i_tex,posWorld);
                half3 diffColor = DiffuseAndSpecularFromMetallic(finalAlbedo, metallic, /*out*/ specColor, /*out*/ oneMinusReflectivity);

                FragmentCommonData o = (FragmentCommonData)0;
                o.diffColor = diffColor;
                o.specColor = specColor;
                o.oneMinusReflectivity = oneMinusReflectivity;
                o.smoothness = smoothness;
                return o;
            }

            // parallax transformed texcoord is used to sample occlusion
            inline FragmentCommonData MetallicSetup_Custom (float4 i_tex, float3 posWorld)
            {
                half2 metallicGloss = MetallicGloss(i_tex.xy);
                half metallic = metallicGloss.x;
                half smoothness = metallicGloss.y; // this is 1 minus the square root of real roughness m.

                half oneMinusReflectivity;
                half3 specColor;


                half3 finalAlbedo = CustomAlbedo(i_tex,posWorld);
                half3 diffColor = DiffuseAndSpecularFromMetallic ( finalAlbedo, metallic, /*out*/ specColor, /*out*/ oneMinusReflectivity);

                FragmentCommonData o = (FragmentCommonData)0;
                o.diffColor = diffColor;
                o.specColor = specColor;
                o.oneMinusReflectivity = oneMinusReflectivity;
                o.smoothness = smoothness;
                return o;
            }

            inline FragmentCommonData FragmentSetup_Custom (float4 i_tex, float3 i_eyeVecCustom, half3 i_viewDirForParallax, float4 tangentToWorld[3], float3 i_posWorld)
            {
                i_tex = Parallax(i_tex, i_viewDirForParallax);

                half alpha = Alpha(i_tex.xy);
                #if defined(_ALPHATEST_ON)
                    clip (alpha - _Cutoff);
                #endif

                FragmentCommonData o = CUSTOM_METALLIC_WORKFLOW (i_tex, i_posWorld);
                o.normalWorld = PerPixelWorldNormal(i_tex, tangentToWorld);
                o.eyeVec = NormalizePerPixelNormal(i_eyeVecCustom);
                o.posWorld = i_posWorld;

                // NOTE: shader relies on pre-multiply alpha-blend (_SrcBlend = One, _DstBlend = OneMinusSrcAlpha)
                o.diffColor = PreMultiplyAlpha (o.diffColor, alpha, o.oneMinusReflectivity, /*out*/ o.alpha);
                return o;
            }


            half4 frag (VertexOutputForwardBase i) : SV_Target
            {
                UNITY_APPLY_DITHER_CROSSFADE(i.pos.xy);
                UNITY_SETUP_INSTANCE_ID(i);

                FragmentCommonData s = FragmentSetup_Custom(i.tex, i.eyeVec, IN_VIEWDIR4PARALLAX(i), i.tangentToWorldAndPackedData,IN_WORLDPOS(i));

                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

                UnityLight mainLight = MainLight ();
                UNITY_LIGHT_ATTENUATION(atten, i, s.posWorld);

                half occlusion = Occlusion(i.tex.xy);
                UnityGI gi = FragmentGI (s, occlusion, i.ambientOrLightmapUV, atten, mainLight);

                half4 c = UNITY_BRDF_PBS (s.diffColor, s.specColor, s.oneMinusReflectivity, s.smoothness, s.normalWorld, -s.eyeVec, gi.light, gi.indirect);
                c.rgb += Emission(i.tex.xy);

                UNITY_EXTRACT_FOG_FROM_EYE_VEC(i);
                UNITY_APPLY_FOG(_unity_fogCoord, c.rgb);
                return OutputForward (c, s.alpha);
            }

            ENDCG
        }
        //Pass Forward base ------------------------------------------------------------------

        //  Shadow rendering pass
        //
        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            ZWrite On ZTest LEqual

            CGPROGRAM
            #pragma target 3.0

            // -------------------------------------


            #pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
            #pragma shader_feature _METALLICGLOSSMAP
            #pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature _PARALLAXMAP
            #pragma multi_compile_shadowcaster
            #pragma multi_compile_instancing
            // Uncomment the following line to enable dithering LOD crossfade. 
            // Note: there are more in the file to uncomment for other passes.
            //#pragma multi_compile _ LOD_FADE_CROSSFADE

            #pragma vertex vertShadowCaster
            #pragma fragment fragShadowCaster

            #include "UnityStandardShadow.cginc"

            ENDCG
        }
        // Pass Shadow ------------------------------------------------------------------

        // //  Deferred pass
        // // 
        // Pass
        // {
            //     Name "DEFERRED"
            //     Tags { "LightMode" = "Deferred" }

            //     CGPROGRAM
            //     #pragma target 3.0
            //     #pragma exclude_renderers nomrt


            //     // -------------------------------------

            //     #pragma shader_feature _NORMALMAP
            //     #pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
            //     #pragma shader_feature _EMISSION
            //     #pragma shader_feature _METALLICGLOSSMAP
            //     #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            //     #pragma shader_feature _ _SPECULARHIGHLIGHTS_OFF
            //     #pragma shader_feature ___ _DETAIL_MULX2
            //     #pragma shader_feature _PARALLAXMAP

            //     #pragma multi_compile_prepassfinal
            //     #pragma multi_compile_instancing
            //     // Uncomment the following line to enable dithering LOD crossfade. Note: there are more in the file to uncomment for other passes.
            //     //#pragma multi_compile _ LOD_FADE_CROSSFADE

            //     #pragma vertex vertDeferred
            //     #pragma fragment fragDeferred

            //     #include "UnityStandardCore.cginc"

            //     ENDCG
        // }
        // // Pass Deferred------------------------------------------------------------------

        // Extracts information for lightmapping, GI (emission, albedo, ...)
        // This pass it not used during regular rendering.
        Pass
        {
            Name "META"
            Tags { "LightMode"="Meta" }

            Cull Off

            CGPROGRAM
            #pragma vertex vert_meta
            #pragma fragment frag_meta

            #pragma shader_feature _EMISSION
            #pragma shader_feature _METALLICGLOSSMAP
            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature ___ _DETAIL_MULX2
            #pragma shader_feature EDITOR_VISUALIZATION

            #include "UnityStandardMeta.cginc"
            ENDCG
        }
    }
    
    Fallback "VertexLit"
    // nameSpace also exists as a path!
    CustomEditor "ShaderRandomOffset.NXMaterialEditorMetalicWithNoise"
    // CustomEditor "StandardShaderGUI"

}
