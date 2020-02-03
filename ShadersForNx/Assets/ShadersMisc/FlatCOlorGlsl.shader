// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Test1Combo - Flat Color"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
    }
 
    SubShader
    {
        Pass
        {
            GLSLPROGRAM
 
            // includes
            #include "UnityCG.glslinc"
 
            // user-defined variables
            uniform lowp vec4 _Color;
 
            // vertex program
            #ifdef VERTEX
            void main() {
                gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
            }
            #endif
 
            // fragment program
            #ifdef FRAGMENT
            void main() {
                gl_FragColor = vec4(1.0, 0.6, 0.0, 1); // = _Color;
            }
            #endif
 
            ENDGLSL
        }
    }
 
    SubShader
    {
        Pass
        {
            CGPROGRAM
            // pragmas and includes
            #pragma vertex vert
            #pragma fragment frag
 
            #include "UnityCG.cginc"
 
            // user-defined variables
            uniform float4 _Color;
 
            // base input structs
            struct vertexInput
            {
                float4 vertex : POSITION;
            };
 
            struct vertexOutput
            {
                float4 pos : SV_POSITION;
            };
 
            // vertex program
            vertexOutput vert(vertexInput v)
            {
                vertexOutput o;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }
 
            // fragment program
            float4 frag(vertexOutput i) : COLOR
            {
                return _Color;
            }
 
            ENDCG
        }
    }
    //TODO decomment fallback when testing is finished
    //Fallback "Diffuse"
}