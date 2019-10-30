using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace ShaderRandomOffset
{
    [ExecuteAlways]
    public class RandomFloatOffsetView : MonoBehaviour
    {
        private const string VectorToSet = "_AllowedOffsett"; // previous _AllowedOffsett


        [SerializeField] private Renderer rendererToUse;
        [SerializeField] private Vector2 currentOffset;
        private MaterialPropertyBlock propBlock;


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
        private void OnValidate()
        {
            RenewVector();
        }
#endif

        private void Awake()
        {
            currentOffset = new Vector2(RandomRangeIn(), RandomRangeIn());
            RenewVector();
        }

        public void RenewVector()
        {
            RendereToUse.GetPropertyBlock(PropBlock);
            PropBlock.SetVector(VectorToSet, new Vector4(currentOffset.x, currentOffset.y, 0, 0));
            RendereToUse.SetPropertyBlock(PropBlock);
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
    }

}