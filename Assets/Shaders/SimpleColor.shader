Shader "Custom/SimpleColor"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        //_MainTex ("Albedo (RGB)", 2D) = "white" {}
        //_Glossiness ("Smoothness", Range(0,1)) = 0.5
        //_Metallic ("Metallic", Range(0,1)) = 0.0
    }// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

    SubShader
    {
        Pass{

        CGPROGRAM
        #pragma vertex vert
        #pragma fragment frag

        float4 _Color;

        struct VSInput{
            float4 vertex:POSITION;
            float3 normal:NORMAL;
            float4 texcoord:TEXCOORD0;
        };
        struct VSOutput{
            float4 pos:SV_POSITION;
            float3 color:COLOR0;
        };

        VSOutput vert(VSInput vsin){
            VSOutput o;
            o.pos=UnityObjectToClipPos(vsin.vertex);
            o.color=vsin.normal*0.5*float3(0.5,0.5,0.5);
            return o;
        }

        float4 frag(VSOutput vso):SV_TARGET{
            return float4(vso.color*_Color.rgb,1.0);
        }
        ENDCG
        }
    }

    FallBack "Diffuse"
}
