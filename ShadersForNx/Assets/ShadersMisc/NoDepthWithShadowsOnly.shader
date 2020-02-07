// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/NoDepthWithShadowsOnly"
{
    Properties
    {
        [IntRange] _StencilRef ("Stencil Reference Value", Range(0,255)) = 0
        [IntRange] _IsOn ("Is On ", Range(0,1) ) = 1
    }

    // CGINCLUDE
    // #define UNITY_NO_SCREENSPACE_SHADOWS 1
    // ENDCG
    
    SubShader
    {
        Tags
        { 
            "DisableBatching" = "False" 
            "LightMode" = "ForwardBase"
            "Queue" = "Geometry-1" 
            "IgnoreProjector" = "true" 
            "RenderType" = "Transparent" 
            "ForceNoShadowCasting" = "true"
            "PreviewType" = "Plane"
        }

        Stencil
        {
            Ref [_StencilRef]
            Comp NotEqual
            Pass keep
        }
        
        Blend SrcAlpha OneMinusSrcAlpha
        Lighting Off
        ZTest LEqual
        ZWrite off
        Fog {Mode Off}

        Pass
        {
            // Blend SrcAlpha OneMinusSrcAlpha
            // Lighting Off
            // ZTest LEqual
            // ZWrite On

            // ColorMask 0

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest

            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile_fwdbase_fullshadows

            // Skip variants
            #pragma skip_variants POINT 
            #pragma skip_variants SPOT 
            #pragma skip_variants POINT_COOKIE 
            #pragma skip_variants LIGHTPROBE_SH 
            #pragma skip_variants UNITY_HDR_ON 
            #pragma skip_variants FOG_LINEAR 
            #pragma skip_variants FOG_EXP 
            #pragma skip_variants FOG_EXP2 
            #pragma skip_variants DIRECTIONAL_COOKIE

            
            #include "UnityCG.cginc"
            // #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct appdata_t 
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            struct v2f 
            {
                float4 vertex : SV_POSITION;
                // float4 posWorld : TEXCOORD0;
                float4 normalDir : TEXCOORD0;
                // float2 uv : TEXCOORD1;
                LIGHTING_COORDS(1, 2)  // _LightCoord  _ShadowCoord
            };
            
            // UNITY_INSTANCING_BUFFER_START(Props)
            // // put more per-instance properties here
            // // UNITY_DEFINE_INSTANCED_PROP(  float4, _AllowedOffsett)  // acces via UNITY_ACCESS_INSTANCED_PROP(Props, _AllowedOffsett);
            // // UNITY_DEFINE_INSTANCED_PROP(  float4, _ColorTint)  // acces via UNITY_ACCESS_INSTANCED_PROP(Props, _ColorTint);
            // UNITY_INSTANCING_BUFFER_END(Props)

            // get via UNITY_ACCESS_INSTANCED_PROP(Props, _ColorTint).xyz
            int _IsOn = 1; 
            
            v2f vert (appdata_t v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                o.vertex = UnityObjectToClipPos(v.vertex);
                float4x4 modelMatrix = unity_ObjectToWorld;
                float4x4 modelMatrixInverse = unity_WorldToObject; 
                
                // o.posWorld = mul(modelMatrix, v.vertex);
                o.normalDir.xyz = normalize(
                mul(float4(v.normal, 0.0), modelMatrixInverse).xyz);
                // Diffuse reflection by four "vertex lights"      
                // o.vertexLighting = float3(0.0, 0.0, 0.0);
                o.normalDir.w = dot(o.normalDir.rgb, _WorldSpaceLightPos0);
                // o.uv = v.uv;
                TRANSFER_SHADOW(o);
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                // fixed3 normalDirection = normalize(i.normalDir); 
                // fixed3 viewDirection = normalize(
                // _WorldSpaceCameraPos - i.posWorld.xyz);
                // fixed3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                // fixed attenuation = 1.0;// no attenuation
                
                // fixed fwidthFrom = (1 - fwidth(i.uv)*100); // the far this plane it the less shadows it will receive
                
                // fixed3 vertexToLightSource =  _WorldSpaceLightPos0.xyz - i.posWorld.xyz;
                // fixed distance = length(vertexToLightSource);
                // attenuation = 1.0 / distance; // linear attenuation 
                // lightDirection = normalize(vertexToLightSource);
                
                // fixed3 ambientLighting = 
                // UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb;

                // fixed3 diffuseReflection = 
                // attenuation * _LightColor0.rgb * _Color.rgb 
                // * max(0.0, dot(normalDirection, lightDirection));

                fixed4 shadowInfo = SHADOW_ATTENUATION(i);
                fixed4 col = fixed4(0,0,0,1)* shadowInfo;
                // + ambientLighting 
                // + diffuseReflection
                // attenuation * shadowInfo;
                col.a = 1-shadowInfo;

                // fixed4 originalcolor  = lerp(0, col.a, i.normalDir.w);
                // col.rgb = ShadeSH9(float4(i.normalDir, 1));
                // col.a = originalcolor *fwidthFrom;
                col.a = lerp(0, col.a, i.normalDir.w);

                col.a *= _IsOn;
                return col;
            }
            ENDCG
        }

        // why ?
        // Additional Pass to render the geometry!
        // Pass
        // {
        //     ZWrite On
        //     ColorMask 0
        // }

        // Shadow Pass : Adding the shadows (from Directional Light)
        // by blending the light attenuation
        // Pass 
        // {
            //     Name "ShadowCaster"
            //     Tags { "LightMode" = "ShadowCaster" }

            //     ZWrite On ZTest LEqual
            
            //     CGPROGRAM 
            //     // Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members lightDir)
            //     #pragma exclude_renderers d3d11
            //     // #pragma vertex vert
            //     // #pragma fragment frag
            //     #pragma vertex vertShadowCaster
            //     #pragma fragment fragShadowCaster

            //     // #pragma multi_compile_fwdbase

            //     #pragma multi_compile_shadowcaster
            

            //     #pragma fragmentoption ARB_precision_hint_fastest
            //     // GPU Instancing
            //     #pragma multi_compile_instancing
            //     // #include "UnityCG.cginc"
            //     // #include "AutoLight.cginc"
            //     #include "UnityStandardShadow.cginc"

            //     // struct appdata_t 
            //     // {
                //         //     float4 vertex : POSITION;
                //         //     float3 normal : NORMAL;
                //         //     UNITY_VERTEX_INPUT_INSTANCE_ID
            //     // };

            //     // struct v2f
            //     // { 
                //     //     float2 uv_MainTex : TEXCOORD1;
                //     //     float4 pos : SV_POSITION;
                //     //     LIGHTING_COORDS(3,4)
                //     //     float3	lightDir;

            //     // };
            
            //     // float4 _Color;
            //     // float _ShadowIntensity;
            //     // UNITY_INSTANCING_BUFFER_START(Props)
            //     // // put more per-instance properties here
            //     // // UNITY_DEFINE_INSTANCED_PROP(  float4, _AllowedOffsett)  // acces via UNITY_ACCESS_INSTANCED_PROP(Props, _AllowedOffsett);
            //     // // UNITY_DEFINE_INSTANCED_PROP(  float4, _ColorTint)  // acces via UNITY_ACCESS_INSTANCED_PROP(Props, _ColorTint);
            //     // UNITY_INSTANCING_BUFFER_END(Props)
            
            //     // v2f vert (appdata_full v)
            //     // {
                //     //     v2f o;
                //     //     UNITY_SETUP_INSTANCE_ID(v);

                //     //     o.uv_MainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
                //     //     o.pos = UnityObjectToClipPos (v.vertex);
                //     //     o.lightDir = ObjSpaceLightDir( v.vertex );
                //     //     TRANSFER_VERTEX_TO_FRAGMENT(o);
                //     //     return o;
            //     // }
            
            //     // float4 frag (v2f i) : SV_TARGET
            //     // {
                //     //     float atten = LIGHT_ATTENUATION(i);
                
                //     //     half4 c;
                //     //     c.rgb =  atten;
                //     //     c.a = (1-atten) ; 
                //     //     return c;
            //     // }
            //     ENDCG
        // }
        
    }

    // Fallback "Transparent/Cutout/VertexLit"
}
