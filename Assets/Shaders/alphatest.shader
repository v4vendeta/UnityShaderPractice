// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/alphatest"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Cutoff("Alpha cutoff",Range(0,1))=0.0
    }
    SubShader
    {
        Tags { "RenderType"="TransparentCutot" 
                "Queue"="AlphaTest" 
                "IgnoreProector"="True" }
        Pass{ 
            //Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Lighting.cginc"
            #include "UnityCG.cginc"
            float4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Cutoff;

            struct vs_input{
                float4 vertex:POSITION;
                float3 normal:NORMAL;
                float4 texcoord:TEXCOORD0;
            };
            struct ps_input{
                float4 pos:SV_POSITION;
                float3 world_normal:TEXCOORD0;
                float3 world_pos:TEXCOORD1;
                float2 uv:TEXCOORD2;

            };

            ps_input vert(vs_input vsin){
                ps_input o;
                o.pos=UnityObjectToClipPos(vsin.vertex);
                o.world_normal=UnityObjectToWorldNormal(vsin.normal);
                o.world_pos=mul(unity_ObjectToWorld,vsin.vertex).xyz;
                o.uv=TRANSFORM_TEX(vsin.texcoord,_MainTex);
                return o;
            }

            float4 frag(ps_input psin):SV_Target{
                float3 world_normal=normalize(psin.world_normal);
                float3 world_light_dir=normalize(UnityWorldSpaceLightDir(psin.world_pos));
                float4 tex_color=tex2D(_MainTex,psin.uv);

                clip(tex_color.a-_Cutoff);
                float3 albedo=tex_color.rgb*_Color.rgb;
                float3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;
                float3 diff=_LightColor0.rgb*albedo*saturate(dot(world_normal,world_light_dir));


                return float4(ambient+diff,1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
