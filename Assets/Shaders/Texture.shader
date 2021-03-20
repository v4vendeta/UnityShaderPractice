// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/Texture"
{
    Properties
    {
        _Diffuse("Diff",Color)=(1,1,1,1)
        _Specular("Spec",Color)=(1,1,1,1)
        _Gloss("Gloss",Range(8.0,256))=20
        _MainTex("Main tex",2D)="White"{}
    }
    SubShader
    {
        Pass{

        Tags { "RenderType"="Opaque" }
        LOD 200
        Tags{"LightingMode"="ForwardBase"}

        CGPROGRAM
        #pragma vertex vert
        #pragma fragment frag
        #include "Lighting.cginc"
        #include "UnityCG.cginc"
        float4 _Diffuse;
        float4 _Specular;
        float _Gloss;
        sampler2D _MainTex;
        float4 _MainTex_ST;

        struct VSInput{
            float4 vertex:POSITION;
            float3 normal:NORMAL;
            float4 texcoord:TEXCOORD0;
        };
        struct PSInput{
            float4 pos:SV_POSITION;
            float4 world_pos:TEXCOORD0;
            float3 world_normal:TEXCOORD1;
            float2 uv:TEXCOORD2;
        };

        PSInput vert(VSInput vsin){
            PSInput o;
            o.pos=UnityObjectToClipPos(vsin.vertex);
            o.world_pos=mul(unity_ObjectToWorld,vsin.vertex);
            o.world_normal=UnityObjectToWorldNormal(vsin.normal);
            //o.uv=vsin.texcoord.xy*_MainTex_ST.xy+_MainTex_ST.zw;
            o.uv=TRANSFORM_TEX(vsin.texcoord,_MainTex);
            return o;
        }
        fixed4 frag(PSInput psin):SV_Target{
            float3 world_normal=normalize(psin.world_normal);
            float3 world_light_dir=normalize(UnityWorldSpaceLightDir(psin.world_pos));
            float3 view_dir=normalize(UnityWorldSpaceViewDir(psin.world_pos));
            float3 half_dir=normalize(view_dir+world_light_dir);


            float3 albedo=tex2D(_MainTex,psin.uv).rgb*_Diffuse.rgb;
            float3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;
            float3 diff=albedo*_Diffuse.rgb*_LightColor0.rgb*saturate(dot(world_normal,world_light_dir));
            float3 spec=_Specular.rgb*_LightColor0.rgb*pow(saturate(dot(half_dir,world_normal)),_Gloss);
            return fixed4(ambient+diff+spec,1.0);
        }
        ENDCG
        }
    }
    FallBack "Diffuse"
}
