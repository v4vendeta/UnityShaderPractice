// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/bump"
{
    Properties
    {
        _Diffuse("Diff",Color)=(1,1,1,1)
        _Specular("Spec",Color)=(1,1,1,1)
        _Gloss("Gloss",Range(8.0,256))=20
        _MainTex("Main tex",2D)="White"{}
        _BumpMap("Bump map",2D)="bump"{}
        _bumpScale("Bump Scale",Float)=1.0

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

        sampler2D _BumpMap;
        float4 _BumpMap_ST;
        float _bumpScale;

        struct VSInput{
            float4 vertex:POSITION;
            float3 normal:NORMAL;
            float4 texcoord:TEXCOORD0;
            float4 tangent:TANGENT;
        };
        struct PSInput{
            float4 pos:SV_POSITION;
            float2 uv:TEXCOORD0;
            float3 light_dir:TEXCOORD1;
            float3 view_dir:TEXCOORD2;
            float2 normal_uv:TEXCOORD3;
        };

        PSInput vert(VSInput vsin){
            PSInput o;
            o.pos=UnityObjectToClipPos(vsin.vertex);

            //o.uv=vsin.texcoord.xy*_MainTex_ST.xy+_MainTex_ST.zw;
            o.uv=TRANSFORM_TEX(vsin.texcoord,_MainTex);
            o.normal_uv=TRANSFORM_TEX(vsin.texcoord,_BumpMap); // transform the texture through *_ST
            //TANGENT_SPACE_ROTATION;
            float3 binomal=cross(normalize(vsin.normal),normalize(vsin.tangent.xyz))*normalize(vsin.tangent.w);
            float3x3 rotation=float3x3(vsin.tangent.xyz,binomal,vsin.normal); // tbn matrix

            o.light_dir=mul(rotation,ObjSpaceLightDir(vsin.vertex)).xyz;
            o.view_dir=mul(rotation,ObjSpaceViewDir(vsin.vertex)).xyz;

            return o;
        }
        fixed4 frag(PSInput psin):SV_Target{

            float3 tangent_light_dir=normalize(psin.light_dir);
            float3 tangent_view_dir=normalize(psin.view_dir);
            float4 packed_normal=tex2D(_BumpMap,psin.normal_uv);

            float3 tangent_normal;
            tangent_normal=UnpackNormal(packed_normal);
            tangent_normal.xy*-_bumpScale;
            tangent_normal.z=sqrt(1.0-saturate(dot(tangent_normal.xy,tangent_normal.xy)));

            float3 half_dir=normalize(tangent_light_dir+tangent_view_dir);


            float3 albedo=tex2D(_MainTex,psin.uv).rgb*_Diffuse.rgb;
            float3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;
            float3 diff=albedo*_Diffuse.rgb*_LightColor0.rgb*saturate(dot(tangent_normal,tangent_light_dir));
            float3 spec=_Specular.rgb*_LightColor0.rgb*pow(saturate(dot(half_dir,tangent_normal)),_Gloss);
            return fixed4(ambient+diff+spec,1.0);
        }
        ENDCG
        }
    }
    FallBack "Diffuse"
}
