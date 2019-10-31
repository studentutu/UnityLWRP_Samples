
using System;
using UnityEngine;
using UnityEditor;

namespace ShaderRandomOffset
{
    public class NXMaterialEditorMetalicWithNoise : ShaderGUI
    {
        #region  custom
        private const string worldFlowMetalic = "_METALIC_SETUP_CUSTON";
        private const string worldFlowRougness = "_METALIC_SETUP_ROUGHNESS_CUSTON";
        private const string worldFlowSpecular = "_METALIC_SETUP_SPECULAR_CUSTON";

        private MaterialProperty RandomizeNoiseMap = (MaterialProperty)null;
        private MaterialProperty NoiseColor = (MaterialProperty)null;

        private MaterialProperty TilesNoiseStrength = (MaterialProperty)null;
        private MaterialProperty TilesSaturationStrenght = (MaterialProperty)null;

        #endregion // custom


        private MaterialProperty blendMode = (MaterialProperty)null;
        private MaterialProperty albedoMap = (MaterialProperty)null;
        private MaterialProperty albedoColor = (MaterialProperty)null;

        private MaterialProperty alphaCutoff = (MaterialProperty)null;
        private MaterialProperty specularMap = (MaterialProperty)null;
        private MaterialProperty specularColor = (MaterialProperty)null;
        private MaterialProperty metallicMap = (MaterialProperty)null;
        private MaterialProperty metallic = (MaterialProperty)null;
        private MaterialProperty smoothness = (MaterialProperty)null;
        private MaterialProperty smoothnessScale = (MaterialProperty)null;
        private MaterialProperty smoothnessMapChannel = (MaterialProperty)null;
        private MaterialProperty highlights = (MaterialProperty)null;
        private MaterialProperty reflections = (MaterialProperty)null;
        private MaterialProperty bumpScale = (MaterialProperty)null;
        private MaterialProperty bumpMap = (MaterialProperty)null;
        private MaterialProperty occlusionStrength = (MaterialProperty)null;
        private MaterialProperty occlusionMap = (MaterialProperty)null;
        // private MaterialProperty heigtMapScale = (MaterialProperty)null;
        // private MaterialProperty heightMap = (MaterialProperty)null;
        private MaterialProperty emissionColorForRendering = (MaterialProperty)null;
        private MaterialProperty emissionMap = (MaterialProperty)null;
        // private MaterialProperty detailMask = (MaterialProperty)null;
        // private MaterialProperty detailAlbedoMap = (MaterialProperty)null;
        // private MaterialProperty detailNormalMapScale = (MaterialProperty)null;
        // private MaterialProperty detailNormalMap = (MaterialProperty)null;
        private MaterialProperty uvSetSecondary = (MaterialProperty)null;
        private NXMaterialEditorMetalicWithNoise.WorkflowMode m_WorkflowMode = NXMaterialEditorMetalicWithNoise.WorkflowMode.Metallic;
        private bool m_FirstTimeApply = true;
        private MaterialEditor m_MaterialEditor;

        public void FindProperties(MaterialProperty[] props)
        {
            this.blendMode = ShaderGUI.FindProperty("_Mode", props);
            this.albedoMap = ShaderGUI.FindProperty("_MainTex", props);
            this.albedoColor = ShaderGUI.FindProperty("_Color", props);
            this.alphaCutoff = ShaderGUI.FindProperty("_Cutoff", props);
            this.specularMap = ShaderGUI.FindProperty("_SpecGlossMap", props, false);
            this.specularColor = ShaderGUI.FindProperty("_SpecColor", props, false);
            this.metallicMap = ShaderGUI.FindProperty("_MetallicGlossMap", props, false);
            this.metallic = ShaderGUI.FindProperty("_Metallic", props, false);
            this.m_WorkflowMode = this.specularMap == null || this.specularColor == null ? (this.metallicMap == null || this.metallic == null ? NXMaterialEditorMetalicWithNoise.WorkflowMode.Dielectric : NXMaterialEditorMetalicWithNoise.WorkflowMode.Metallic) : NXMaterialEditorMetalicWithNoise.WorkflowMode.Specular;
            this.smoothness = ShaderGUI.FindProperty("_Glossiness", props);
            this.smoothnessScale = ShaderGUI.FindProperty("_GlossMapScale", props, false);
            this.smoothnessMapChannel = ShaderGUI.FindProperty("_SmoothnessTextureChannel", props, false);
            this.highlights = ShaderGUI.FindProperty("_SpecularHighlights", props, false);
            this.reflections = ShaderGUI.FindProperty("_GlossyReflections", props, false);
            this.bumpScale = ShaderGUI.FindProperty("_BumpScale", props);
            this.bumpMap = ShaderGUI.FindProperty("_BumpMap", props);
            // this.heigtMapScale = ShaderGUI.FindProperty("_Parallax", props);
            // this.heightMap = ShaderGUI.FindProperty("_ParallaxMap", props);
            this.occlusionStrength = ShaderGUI.FindProperty("_OcclusionStrength", props);
            this.occlusionMap = ShaderGUI.FindProperty("_OcclusionMap", props);
            this.emissionColorForRendering = ShaderGUI.FindProperty("_EmissionColor", props);
            this.emissionMap = ShaderGUI.FindProperty("_EmissionMap", props);
            // this.detailMask = ShaderGUI.FindProperty("_DetailMask", props);
            // this.detailAlbedoMap = ShaderGUI.FindProperty("_DetailAlbedoMap", props);
            // this.detailNormalMapScale = ShaderGUI.FindProperty("_DetailNormalMapScale", props);
            // this.detailNormalMap = ShaderGUI.FindProperty("_DetailNormalMap", props);
            this.uvSetSecondary = ShaderGUI.FindProperty("_UVSec", props);


            this.RandomizeNoiseMap = ShaderGUI.FindProperty("_RandomizatonOfTilesScaleMap", props);
            this.NoiseColor = ShaderGUI.FindProperty("_ColorTOBeUsedFor", props);
            this.TilesNoiseStrength = ShaderGUI.FindProperty("_RandomizatonOfTiles", props);
            this.TilesSaturationStrenght = ShaderGUI.FindProperty("_SaturationStrenght", props);

        }

        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
        {
            this.FindProperties(props);
            this.m_MaterialEditor = materialEditor;
            Material target = materialEditor.target as Material;
            if (this.m_FirstTimeApply)
            {
                NXMaterialEditorMetalicWithNoise.MaterialChanged(target, this.m_WorkflowMode);
                this.m_FirstTimeApply = false;
            }
            this.ShaderPropertiesGUI(target);
        }

        public void ShaderPropertiesGUI(Material material)
        {
            EditorGUIUtility.labelWidth = 0.0f;
            EditorGUI.BeginChangeCheck();
            this.BlendModePopup();
            GUILayout.Label(NXMaterialEditorMetalicWithNoise.Styles.primaryMapsText, EditorStyles.boldLabel);
            this.DoAlbedoArea(material);
            EditorGUILayout.Space();
            GUILayout.Label(NXMaterialEditorMetalicWithNoise.Styles.NoiseMapsText, EditorStyles.boldLabel);
            this.DoNoiseMetalicArea();

            EditorGUILayout.Space();
            GUILayout.Label(NXMaterialEditorMetalicWithNoise.Styles.SurfaceWorkFLowText, EditorStyles.boldLabel);

            this.DoSpecularMetallicArea();
            this.DoNormalArea();
            // this.m_MaterialEditor.TexturePropertySingleLine(NXMaterialEditorMetalicWithNoise.Styles.heightMapText, this.heightMap, !((UnityEngine.Object)this.heightMap.textureValue != (UnityEngine.Object)null) ? (MaterialProperty)null : this.heigtMapScale);
            this.m_MaterialEditor.TexturePropertySingleLine(NXMaterialEditorMetalicWithNoise.Styles.occlusionText, this.occlusionMap, !((UnityEngine.Object)this.occlusionMap.textureValue != (UnityEngine.Object)null) ? (MaterialProperty)null : this.occlusionStrength);
            // this.m_MaterialEditor.TexturePropertySingleLine(NXMaterialEditorMetalicWithNoise.Styles.detailMaskText, this.detailMask);
            this.DoEmissionArea(material);

            if (EditorGUI.EndChangeCheck())
            {
                if(emissionMap != null)
                this.emissionMap.textureScaleAndOffset = this.albedoMap.textureScaleAndOffset;
                if(specularMap != null)
                this.specularMap.textureScaleAndOffset = this.albedoMap.textureScaleAndOffset;
                if(metallicMap != null)
                this.metallicMap.textureScaleAndOffset = this.albedoMap.textureScaleAndOffset;
                if(occlusionMap != null)
                this.occlusionMap.textureScaleAndOffset = this.albedoMap.textureScaleAndOffset;
                if(bumpMap != null)
                this.bumpMap.textureScaleAndOffset = this.albedoMap.textureScaleAndOffset;
            }

            EditorGUILayout.Space();
            GUILayout.Label(NXMaterialEditorMetalicWithNoise.Styles.secondaryMapsText, EditorStyles.boldLabel);

            EditorGUI.BeginChangeCheck();
            // this.m_MaterialEditor.TexturePropertySingleLine(NXMaterialEditorMetalicWithNoise.Styles.detailAlbedoText, this.detailAlbedoMap);
            // this.m_MaterialEditor.TexturePropertySingleLine(NXMaterialEditorMetalicWithNoise.Styles.detailNormalMapText, this.detailNormalMap, this.detailNormalMapScale);
            // this.m_MaterialEditor.TextureScaleOffsetProperty(this.detailAlbedoMap);
            this.m_MaterialEditor.ShaderProperty(this.uvSetSecondary, NXMaterialEditorMetalicWithNoise.Styles.uvSetLabel.text);
            GUILayout.Label(NXMaterialEditorMetalicWithNoise.Styles.forwardText, EditorStyles.boldLabel);
            if (this.highlights != null)
                this.m_MaterialEditor.ShaderProperty(this.highlights, NXMaterialEditorMetalicWithNoise.Styles.highlightsText);
            if (this.reflections != null)
                this.m_MaterialEditor.ShaderProperty(this.reflections, NXMaterialEditorMetalicWithNoise.Styles.reflectionsText);
            if (EditorGUI.EndChangeCheck())
            {
                foreach (Material target in this.blendMode.targets)
                    NXMaterialEditorMetalicWithNoise.MaterialChanged(target, this.m_WorkflowMode);
            }
            EditorGUILayout.Space();
            GUILayout.Label(NXMaterialEditorMetalicWithNoise.Styles.advancedText, EditorStyles.boldLabel);
            this.m_MaterialEditor.EnableInstancingField();
            this.m_MaterialEditor.DoubleSidedGIField();
        }

        internal void DetermineWorkflow(MaterialProperty[] props)
        {
            if (ShaderGUI.FindProperty("_SpecGlossMap", props, false) != null && ShaderGUI.FindProperty("_SpecColor", props, false) != null)
                this.m_WorkflowMode = NXMaterialEditorMetalicWithNoise.WorkflowMode.Specular;
            else if (ShaderGUI.FindProperty("_MetallicGlossMap", props, false) != null && ShaderGUI.FindProperty("_Metallic", props, false) != null)
                this.m_WorkflowMode = NXMaterialEditorMetalicWithNoise.WorkflowMode.Metallic;
            else
                this.m_WorkflowMode = NXMaterialEditorMetalicWithNoise.WorkflowMode.Dielectric;
        }

        public override void AssignNewShaderToMaterial(
          Material material,
          Shader oldShader,
          Shader newShader)
        {
            if (material.HasProperty("_Emission"))
                material.SetColor("_EmissionColor", material.GetColor("_Emission"));
            base.AssignNewShaderToMaterial(material, oldShader, newShader);
            if ((UnityEngine.Object)oldShader == (UnityEngine.Object)null || !oldShader.name.Contains("Legacy Shaders/"))
            {
                NXMaterialEditorMetalicWithNoise.SetupMaterialWithBlendMode(material, (NXMaterialEditorMetalicWithNoise.BlendMode)material.GetFloat("_Mode"));
            }
            else
            {
                NXMaterialEditorMetalicWithNoise.BlendMode blendMode = NXMaterialEditorMetalicWithNoise.BlendMode.Opaque;
                if (oldShader.name.Contains("/Transparent/Cutout/"))
                    blendMode = NXMaterialEditorMetalicWithNoise.BlendMode.Cutout;
                else if (oldShader.name.Contains("/Transparent/"))
                    blendMode = NXMaterialEditorMetalicWithNoise.BlendMode.Fade;
                material.SetFloat("_Mode", (float)blendMode);
                this.DetermineWorkflow(MaterialEditor.GetMaterialProperties((UnityEngine.Object[])new Material[1]
                {
          material
                }));
                NXMaterialEditorMetalicWithNoise.MaterialChanged(material, this.m_WorkflowMode);
            }
        }

        private void BlendModePopup()
        {
            EditorGUI.showMixedValue = this.blendMode.hasMixedValue;
            NXMaterialEditorMetalicWithNoise.BlendMode floatValue = (NXMaterialEditorMetalicWithNoise.BlendMode)this.blendMode.floatValue;
            EditorGUI.BeginChangeCheck();
            NXMaterialEditorMetalicWithNoise.BlendMode blendMode = (NXMaterialEditorMetalicWithNoise.BlendMode)EditorGUILayout.Popup(NXMaterialEditorMetalicWithNoise.Styles.renderingMode, (int)floatValue, NXMaterialEditorMetalicWithNoise.Styles.blendNames);
            if (EditorGUI.EndChangeCheck())
            {
                this.m_MaterialEditor.RegisterPropertyChangeUndo("Rendering Mode");
                this.blendMode.floatValue = (float)blendMode;
            }
            EditorGUI.showMixedValue = false;
        }

        private void DoNormalArea()
        {
            this.m_MaterialEditor.TexturePropertySingleLine(NXMaterialEditorMetalicWithNoise.Styles.normalMapText, this.bumpMap, !((UnityEngine.Object)this.bumpMap.textureValue != (UnityEngine.Object)null) ? (MaterialProperty)null : this.bumpScale);
            //   if ((double) this.bumpScale.floatValue == 1.0 || !BuildTargetDiscovery.PlatformHasFlag(EditorUserBuildSettings.activeBuildTarget, BuildTargetDiscovery.TargetAttributes.HasIntegratedGPU) || !this.m_MaterialEditor.HelpBoxWithButton(EditorGUIUtility.TrTextContent("Bump scale is not supported on mobile platforms", (string) null, (Texture) null), EditorGUIUtility.TrTextContent("Fix Now", (string) null, (Texture) null)))
            //     return;
            this.bumpScale.floatValue = 1f;
        }

        private void DoAlbedoArea(Material material)
        {
            this.m_MaterialEditor.TexturePropertySingleLine(NXMaterialEditorMetalicWithNoise.Styles.albedoText, this.albedoMap, this.albedoColor);
            this.m_MaterialEditor.TextureScaleOffsetProperty(this.albedoMap);
            if ((int)material.GetFloat("_Mode") != 1)
                return;
            this.m_MaterialEditor.ShaderProperty(this.alphaCutoff, NXMaterialEditorMetalicWithNoise.Styles.alphaCutoffText.text, 3);
        }

        private void DoEmissionArea(Material material)
        {
            if (!this.m_MaterialEditor.EmissionEnabledProperty())
                return;
            bool flag = (UnityEngine.Object)this.emissionMap.textureValue != (UnityEngine.Object)null;
            this.m_MaterialEditor.TexturePropertyWithHDRColor(NXMaterialEditorMetalicWithNoise.Styles.emissionText, this.emissionMap, this.emissionColorForRendering, false);
            float maxColorComponent = this.emissionColorForRendering.colorValue.maxColorComponent;
            if ((UnityEngine.Object)this.emissionMap.textureValue != (UnityEngine.Object)null && !flag && (double)maxColorComponent <= 0.0)
                this.emissionColorForRendering.colorValue = Color.white;
            this.m_MaterialEditor.LightmapEmissionFlagsProperty(2, true);
        }

        private void DoSpecularMetallicArea()
        {
            bool flag1 = false;
            if (this.m_WorkflowMode == NXMaterialEditorMetalicWithNoise.WorkflowMode.Specular)
            {
                flag1 = (UnityEngine.Object)this.specularMap.textureValue != (UnityEngine.Object)null;
                this.m_MaterialEditor.TexturePropertySingleLine(NXMaterialEditorMetalicWithNoise.Styles.specularMapText, this.specularMap, !flag1 ? this.specularColor : (MaterialProperty)null);
            }
            else if (this.m_WorkflowMode == NXMaterialEditorMetalicWithNoise.WorkflowMode.Metallic)
            {
                flag1 = (UnityEngine.Object)this.metallicMap.textureValue != (UnityEngine.Object)null;
                this.m_MaterialEditor.TexturePropertySingleLine(NXMaterialEditorMetalicWithNoise.Styles.metallicMapText, this.metallicMap, !flag1 ? this.metallic : (MaterialProperty)null);
            }
            bool flag2 = flag1;
            if (this.smoothnessMapChannel != null && (int)this.smoothnessMapChannel.floatValue == 1)
                flag2 = true;
            int labelIndent1 = 2;
            this.m_MaterialEditor.ShaderProperty(!flag2 ? this.smoothness : this.smoothnessScale, !flag2 ? NXMaterialEditorMetalicWithNoise.Styles.smoothnessText : NXMaterialEditorMetalicWithNoise.Styles.smoothnessScaleText, labelIndent1);
            int labelIndent2 = labelIndent1 + 1;
            if (this.smoothnessMapChannel == null)
                return;
            this.m_MaterialEditor.ShaderProperty(this.smoothnessMapChannel, NXMaterialEditorMetalicWithNoise.Styles.smoothnessMapChannelText, labelIndent2);
        }

        private void DoNoiseMetalicArea()
        {

            bool flagTextureNoise = (UnityEngine.Object)this.RandomizeNoiseMap.textureValue != (UnityEngine.Object)null;
            this.m_MaterialEditor.TexturePropertySingleLine(NXMaterialEditorMetalicWithNoise.Styles.NoiseMapText, 
                                                            this.RandomizeNoiseMap, flagTextureNoise ? this.TilesNoiseStrength : (MaterialProperty)null);
            
            if(flagTextureNoise) this.m_MaterialEditor.TextureScaleOffsetProperty(this.RandomizeNoiseMap);

            int labelIndent1 = 2;
            this.m_MaterialEditor.ShaderProperty( this.NoiseColor, NXMaterialEditorMetalicWithNoise.Styles.NoiseColorText, labelIndent1);

            this.m_MaterialEditor.ShaderProperty( this.TilesSaturationStrenght, NXMaterialEditorMetalicWithNoise.Styles.NoiseColorSaturatioNRandomText, labelIndent1);


            // int labelIndent2 = labelIndent1 + 1;
            // if (this.smoothnessMapChannel == null)
            //     return;
            // this.m_MaterialEditor.ShaderProperty(this.smoothnessMapChannel, NXMaterialEditorMetalicWithNoise.Styles.smoothnessMapChannelText, labelIndent2);

        }

        public static void SetupMaterialWithBlendMode(
          Material material,
          NXMaterialEditorMetalicWithNoise.BlendMode blendMode)
        {
            switch (blendMode)
            {
                case NXMaterialEditorMetalicWithNoise.BlendMode.Opaque:
                    material.SetOverrideTag("RenderType", "");
                    material.SetInt("_SrcBlend", 1);
                    material.SetInt("_DstBlend", 0);
                    material.SetInt("_ZWrite", 1);
                    material.DisableKeyword("_ALPHATEST_ON");
                    material.DisableKeyword("_ALPHABLEND_ON");
                    material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                    material.renderQueue = -1;
                    break;
                case NXMaterialEditorMetalicWithNoise.BlendMode.Cutout:
                    material.SetOverrideTag("RenderType", "TransparentCutout");
                    material.SetInt("_SrcBlend", 1);
                    material.SetInt("_DstBlend", 0);
                    material.SetInt("_ZWrite", 1);
                    material.EnableKeyword("_ALPHATEST_ON");
                    material.DisableKeyword("_ALPHABLEND_ON");
                    material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                    material.renderQueue = 2450;
                    break;
                case NXMaterialEditorMetalicWithNoise.BlendMode.Fade:
                    material.SetOverrideTag("RenderType", "Transparent");
                    material.SetInt("_SrcBlend", 5);
                    material.SetInt("_DstBlend", 10);
                    material.SetInt("_ZWrite", 0);
                    material.DisableKeyword("_ALPHATEST_ON");
                    material.EnableKeyword("_ALPHABLEND_ON");
                    material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                    material.renderQueue = 3000;
                    break;
                case NXMaterialEditorMetalicWithNoise.BlendMode.Transparent:
                    material.SetOverrideTag("RenderType", "Transparent");
                    material.SetInt("_SrcBlend", 1);
                    material.SetInt("_DstBlend", 10);
                    material.SetInt("_ZWrite", 0);
                    material.DisableKeyword("_ALPHATEST_ON");
                    material.DisableKeyword("_ALPHABLEND_ON");
                    material.EnableKeyword("_ALPHAPREMULTIPLY_ON");
                    material.renderQueue = 3000;
                    break;
            }
        }

        private static NXMaterialEditorMetalicWithNoise.SmoothnessMapChannel GetSmoothnessMapChannel(
          Material material)
        {
            return (int)material.GetFloat("_SmoothnessTextureChannel") == 1 ? NXMaterialEditorMetalicWithNoise.SmoothnessMapChannel.AlbedoAlpha :
                                       NXMaterialEditorMetalicWithNoise.SmoothnessMapChannel.SpecularMetallicAlpha;
        }

        private static void SetMaterialKeywords(
          Material material,
          NXMaterialEditorMetalicWithNoise.WorkflowMode workflowMode)
        {
            NXMaterialEditorMetalicWithNoise.SetKeyword(material, "_NORMALMAP", (bool)((UnityEngine.Object)material.GetTexture("_BumpMap"))); // || (bool)((UnityEngine.Object)material.GetTexture("_DetailNormalMap")));
            switch (workflowMode)
            {
                case NXMaterialEditorMetalicWithNoise.WorkflowMode.Specular:
                    NXMaterialEditorMetalicWithNoise.SetKeyword(material, "_SPECGLOSSMAP", (bool)((UnityEngine.Object)material.GetTexture("_SpecGlossMap")));
                    SetmaterialKeywordsMetalicSetup(material, worldFlowSpecular);
                    break;
                case NXMaterialEditorMetalicWithNoise.WorkflowMode.Metallic:
                    NXMaterialEditorMetalicWithNoise.SetKeyword(material, "_METALLICGLOSSMAP", (bool)((UnityEngine.Object)material.GetTexture("_MetallicGlossMap")));
                    SetmaterialKeywordsMetalicSetup(material, worldFlowMetalic);
                    break;
                default:
                    SetmaterialKeywordsMetalicSetup(material, worldFlowRougness);
                    break;
            }
            // NXMaterialEditorMetalicWithNoise.SetKeyword(material, "_PARALLAXMAP", (bool)((UnityEngine.Object)material.GetTexture("_ParallaxMap")));
            // NXMaterialEditorMetalicWithNoise.SetKeyword(material, "_DETAIL_MULX2", (bool)((UnityEngine.Object)material.GetTexture("_DetailAlbedoMap")) || (bool)((UnityEngine.Object)material.GetTexture("_DetailNormalMap")));
            MaterialEditor.FixupEmissiveFlag(material);
            bool state = (material.globalIlluminationFlags & MaterialGlobalIlluminationFlags.EmissiveIsBlack) == MaterialGlobalIlluminationFlags.None;
            NXMaterialEditorMetalicWithNoise.SetKeyword(material, "_EMISSION", state);
            if (!material.HasProperty("_SmoothnessTextureChannel"))
                return;
            NXMaterialEditorMetalicWithNoise.SetKeyword(material, "_SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A", NXMaterialEditorMetalicWithNoise.GetSmoothnessMapChannel(material) == NXMaterialEditorMetalicWithNoise.SmoothnessMapChannel.AlbedoAlpha);
        }

        private static void SetmaterialKeywordsMetalicSetup(Material material, string toSetUp)
        {
            if (worldFlowMetalic != toSetUp) NXMaterialEditorMetalicWithNoise.SetKeyword(material, worldFlowMetalic, false);
            if (worldFlowRougness != toSetUp) NXMaterialEditorMetalicWithNoise.SetKeyword(material, worldFlowRougness, false);
            if (worldFlowSpecular != toSetUp) NXMaterialEditorMetalicWithNoise.SetKeyword(material, worldFlowSpecular, false);

            NXMaterialEditorMetalicWithNoise.SetKeyword(material, toSetUp, true);
        }

        private static void MaterialChanged(
          Material material,
          NXMaterialEditorMetalicWithNoise.WorkflowMode workflowMode)
        {
            NXMaterialEditorMetalicWithNoise.SetupMaterialWithBlendMode(material, (NXMaterialEditorMetalicWithNoise.BlendMode)material.GetFloat("_Mode"));
            NXMaterialEditorMetalicWithNoise.SetMaterialKeywords(material, workflowMode);
        }

        private static void SetKeyword(Material m, string keyword, bool state)
        {
            if (state)
                m.EnableKeyword(keyword);
            else
                m.DisableKeyword(keyword);
        }

        private enum WorkflowMode
        {
            Specular,
            Metallic,
            Dielectric,
        }

        public enum BlendMode
        {
            Opaque,
            Cutout,
            Fade,
            Transparent,
        }

        public enum SmoothnessMapChannel
        {
            SpecularMetallicAlpha,
            AlbedoAlpha,
        }

        private static class Styles
        {
            public static GUIContent uvSetLabel = EditorGUIUtility.TrTextContent("UV Set", (string)null, (Texture)null);
            public static GUIContent albedoText = EditorGUIUtility.TrTextContent("Albedo", "Albedo (RGB) and Transparency (A)", (Texture)null);
            public static GUIContent alphaCutoffText = EditorGUIUtility.TrTextContent("Alpha Cutoff", "Threshold for alpha cutoff", (Texture)null);
            public static GUIContent specularMapText = EditorGUIUtility.TrTextContent("Specular", "Specular (RGB) and Smoothness (A)", (Texture)null);
            public static GUIContent metallicMapText = EditorGUIUtility.TrTextContent("Metallic", "Metallic (R) and Smoothness (A)", (Texture)null);
            public static GUIContent NoiseMapText = EditorGUIUtility.TrTextContent("Noise", "Noise Texture", (Texture)null);
            public static GUIContent NoiseColorText = EditorGUIUtility.TrTextContent("Tint", "Noise color tint", (Texture)null);
            public static GUIContent NoiseColorSaturatioNRandomText = EditorGUIUtility.TrTextContent("Saturation", "Noise saturation strength", (Texture)null);



            public static GUIContent smoothnessText = EditorGUIUtility.TrTextContent("Smoothness", "Smoothness value", (Texture)null);
            public static GUIContent smoothnessScaleText = EditorGUIUtility.TrTextContent("Smoothness", "Smoothness scale factor", (Texture)null);
            public static GUIContent smoothnessMapChannelText = EditorGUIUtility.TrTextContent("Source", "Smoothness texture and channel", (Texture)null);
            public static GUIContent highlightsText = EditorGUIUtility.TrTextContent("Specular Highlights", "Specular Highlights", (Texture)null);
            public static GUIContent reflectionsText = EditorGUIUtility.TrTextContent("Reflections", "Glossy Reflections", (Texture)null);
            public static GUIContent normalMapText = EditorGUIUtility.TrTextContent("Normal Map", "Normal Map", (Texture)null);
            public static GUIContent heightMapText = EditorGUIUtility.TrTextContent("Height Map", "Height Map (G)", (Texture)null);
            public static GUIContent occlusionText = EditorGUIUtility.TrTextContent("Occlusion", "Occlusion (G)", (Texture)null);
            public static GUIContent emissionText = EditorGUIUtility.TrTextContent("Color", "Emission (RGB)", (Texture)null);
            public static GUIContent detailMaskText = EditorGUIUtility.TrTextContent("Detail Mask", "Mask for Secondary Maps (A)", (Texture)null);
            public static GUIContent detailAlbedoText = EditorGUIUtility.TrTextContent("Detail Albedo x2", "Albedo (RGB) multiplied by 2", (Texture)null);
            public static GUIContent detailNormalMapText = EditorGUIUtility.TrTextContent("Normal Map", "Normal Map", (Texture)null);
            public static string primaryMapsText = "Main Maps";
            public static string secondaryMapsText = "Secondary Maps";
            public static string NoiseMapsText = "Noise";
            public static string SurfaceWorkFLowText = "Surface Workflow";


            public static string forwardText = "Forward Rendering Options";
            public static string renderingMode = "Rendering Mode";
            public static string advancedText = "Advanced Options";
            public static readonly string[] blendNames = Enum.GetNames(typeof(NXMaterialEditorMetalicWithNoise.BlendMode));
        }
    }
}
