using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace ShaderRandomOffset
{
    [ExecuteAlways]
    public class RandomFloatOffsetView : MonoBehaviour
    {
        private const string VectorToSet = "_AllowedOffsett"; // previous _AllowedOffsett
        private const string ColorToSet = "_ColorTint"; // previous _ColorTint


        [SerializeField] private Renderer rendererToUse;
        [SerializeField] private Vector2 offsetNoise;
        [HideInInspector] [SerializeField] private float Saturation;
        [HideInInspector] [SerializeField] private string uniqId;

        [SerializeField] private Color colorMin;
        [SerializeField] private Color colorMax;

        private MaterialPropertyBlock propBlock;
        private bool generateNew = false;


        private Renderer RendereToUse
        {
            get
            {
                if (rendererToUse == null)
                {
                    var renderer = GetComponentInChildren<Renderer>();
                    if (!CheckAndSetRenderer(renderer))
                    {
                        renderer = GetComponentInParent<Renderer>();
                        CheckAndSetRenderer(renderer);
                    }
                }
                return rendererToUse;
            }
        }

        private MaterialPropertyBlock PropBlock
        {
            get
            {
                if (propBlock == null)
                {
                    propBlock = new MaterialPropertyBlock();
                }
                return propBlock;
            }
        }


#if UNITY_EDITOR
        public bool isTesting = false;
        private void OnValidate()
        {
            if (isTesting)
            {
                Saturation = GenerateNewColorGrayScale();
            }
            RenewVector();
        }
#endif

        private void Awake()
        {
#if UNITY_EDITOR
            // Fix when Copied with Ctrl+D or with instance of the prefab
            if (!Application.isPlaying && uniqId != getUniqIdFromScene())
            {
                uniqId = getUniqIdFromScene();
                generateNew = true;

                UnityEditor.PrefabUtility.RecordPrefabInstancePropertyModifications(this);
                var serObject = new UnityEditor.SerializedObject(this);
                serObject.ApplyModifiedProperties();
                UnityEditor.SceneManagement.EditorSceneManager.MarkSceneDirty(this.gameObject.scene);
            }
#endif

            // Random offset Noise
            if (offsetNoise.x == 0 && offsetNoise.y == 0 || generateNew)
            {
                offsetNoise = new Vector2(RandomRangeIn(), RandomRangeIn());
            }

            // Random Tint Color
            if (Saturation == 0 || generateNew)
            {
                Saturation = GenerateNewColorGrayScale();
            }

            generateNew = false;
            RenewVector();
        }

        public void RenewVector()
        {
            RendereToUse.GetPropertyBlock(PropBlock);
            PropBlock.SetVector(VectorToSet, new Vector4(offsetNoise.x, offsetNoise.y, 0, 0));

            // smallColorTint = new Color(smallColorTint.r * 0.3f, smallColorTint.g * 0.59f, smallColorTint.r * 0.11f); // col.r * 0.3f + col.g * 0.59f + col.b * 0.11f;
            PropBlock.SetFloat(ColorToSet, Saturation);
            RendereToUse.SetPropertyBlock(PropBlock);
        }

        private float GenerateNewColorGrayScale()
        {
            Color toBeused = new Color(
                Random.Range(colorMin.r, colorMax.r),
                Random.Range(colorMin.g, colorMax.g),
                Random.Range(colorMin.b, colorMax.b)
            );
            Debug.LogWarning( $" object {this.gameObject.name} grayscale {toBeused.grayscale}",this.gameObject);
            return toBeused.grayscale;
        }

        private bool CheckAndSetRenderer(Renderer any)
        {
            if (any == null) return false;
            rendererToUse = any;
            return true;
        }

        private float RandomRangeIn()
        {
            return Random.Range(-100, 100);
        }

        private string getUniqIdFromScene()
        {
            return $"{this.gameObject.name}";
        }
    }

}