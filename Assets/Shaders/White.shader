// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/White"
{
    Properties
    {
        
    }
    SubShader
    {
        Pass{

        CGPROGRAM
        #pragma vertex vert
        #pragma fragment frag

        float4 vert(float4 v:POSITION):SV_POSITION{
            return UnityObjectToClipPos(v);
        }

        float4 frag():SV_TARGET{
            return float4(1,1,1,1);
        }
        ENDCG
        }
    }
    FallBack "Diffuse"
}
