﻿Shader "Custom/sphere fade"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MainColor("Main Color", Color) = (1.0, 1.0, 1.0, 0)

        [Space(40)]
        _OutlineColor("Outline Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _OutlineWidth("Outline Width", float) = 0.0

        [Space(40)]
        [Toggle(SPECULAR)] _REFRECTION("use Specular", float) = 0
        _SpecularPower("Specular Power", float) = 1
        [Space(40)]


        [Toggle(USETOON)] _TOON("Use Toon", float) = 0
        _ToonThreshold("Toon  Threshold", Range(0, 1)) = 0
        _ToonShadeColor("Toon Shade Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _DiffuseShade("Diffuse", Range(0,1)) = 1.0

        [Space(40)]
        [Toggle(NORMALMAP)] _NORMALMAP("Use Normalmap", float) = 0
        [Normal] _NormalTex("Normal map", 2D) = "bump" {}
        [Spapce(80)]
        [Toggle(RIMLIGHT)] _RIMLIGHT("Use Rimlight", float) = 0
        _RimColor("Rimlight Color", Color) = (0.0, 0.0, 0.0, 1.0)
        [Space(40)]
        [HDR]_EmissionColor("Emission Color", Color) = (0.0, 0.0, 0.0, 1.0)
        _EmissionMap("Emission Map", 2D) = "black" {}

        [Space(40)]
        [Toggle(MATCAP)] _MATCAP("Use Matcap", float) = 0
        _MatcapTex("Matcap Texture", 2d) = "black" {}
        _MatcapBlend("Matcap Blend", Range(0, 1)) = 1.0
        [Toggle(MATCAPMASK)] _MATCAPMASK("Use Matcap Mask", float) = 0
        _MatcapMaskTex("Matcap Mask Texture", 2D) = "black" {} 

        _Center("Sphere center", float) = (0.0, 0.0, 0.0)
        _Distant("Fading ratio", float) = 0

        [HDR] _BoundaryEmissionColor("Boundary Emission Color", Color) = (0.0, 0.0, 0.0, 1.0)
        _BoundaryWidth("Boundary Width", float) = 0.01
        _BoundaryNoiseTex("Boundary Noisemap", 2D) = "black" {}
        _BoundaryCutoutThreshold("Dissolve", Range(0, 1)) = 0

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Cull Front

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "cginc/base.cginc"


            struct appdata
            {
                half4 vertex : POSITION;
                half3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                half4 pos : SV_POSITION;
                float3 modelPos : TEXCOORD1;
                float2 uv : TEXCOORD0;
            };

            float4 _MainTex_ST;

            float _OutlineWidth;
            float4 _OutlineColor;

            float3 _Center;
            float _Distant;

            half _BoundaryWidth;
            half _BoundaryCutoutThreshold;
            float4 _BoundaryEmissionColor;
            sampler2D _BoundaryNoiseTex;

            v2f vert(appdata v)
            {
                v2f o;
                //通常のアウトライン
                o.pos = UnityObjectToClipPos(v.vertex + v.normal * _OutlineWidth*0.001);
                o.modelPos = v.vertex;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) :SV_Target
            {
                half l = length(i.modelPos - _Center)*10;
                fixed4 noise = tex2D(_BoundaryNoiseTex, i.uv + _Time.x);
                float alpha = monochrome(noise.rgb);

                float4 col = step(l, _Distant + _BoundaryWidth + rand(i.uv)*0.08)*_BoundaryEmissionColor;

                if(l < _Distant)
                {
                    discard;
                }

                if(step(l, _Distant + _BoundaryWidth + rand(i.uv)*0.07) && alpha < _BoundaryCutoutThreshold)
                {
                    discard;
                }

                return _OutlineColor += col;
            }
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma shader_feature SPECULAR
            #pragma shader_feature METALIC
            #pragma shader_feature RIMLIGHT
            #pragma shader_feature MATCAP
            #pragma shader_feature MATCAPMASK
            #pragma shader_feature NORMALMAP
            #pragma shader_feature USETOON

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "cginc/base.cginc"


            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float3 worldPos : TEXCOORD1;
                float3 viewNormal : TEXCOORD2;
                float3 modelPos : TEXCOORD3;
                float3 tangent : TEXCOORD4;
                float3 binormal : TEXCOORD5;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _MainColor;
            
            float _SpecularPower;
            half _MetalicPower;
            
            float _DiffuseShade;    

            sampler2D _NormalTex;

            float4 _RimColor;

            sampler2D _EmissionMap;
            float4 _EmissionColor;

            sampler2D _MatcapTex;
            half _MatcapBlend;

            half _ToonThreshold;
            float4 _ToonShadeColor;

            float3 _Center;
            float _Distant;

            half _BoundaryWidth;
            half _BoundaryCutoutThreshold;
            float4 _BoundaryEmissionColor;
            sampler2D _BoundaryNoiseTex;

            v2f vert (appdata v)
            {
                v2f o;
                o.modelPos = v.vertex;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.viewNormal = mul((float3x3)UNITY_MATRIX_V, UnityObjectToWorldNormal(v.normal));
                o.tangent = normalize(mul(unity_ObjectToWorld, v.tangent)).xyz;
                o.binormal = cross(v.normal, v.tangent) * v.tangent.w;
                o.binormal = normalize(mul(unity_ObjectToWorld, o.binormal));
                return o;
            }


            fixed4 frag (v2f i) : SV_Target
            {
                
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                
                half3 normalMap = UnpackNormal(tex2D(_NormalTex, i.uv));
                #ifdef NORMALMAP
                    float3 normal = (i.tangent * normalMap.x) + (i.binormal * normalMap.y) + (i.normal * normalMap.z);
                #else
                    float3 normal = normalize(i.normal);
                #endif

                fixed4 col = tex2D(_MainTex, i.uv) * _MainColor;

                #ifdef MATCAP
                    #ifdef MATCAPMASK
                        float3 matColor =  tex2D(_MatcapTex, i.viewNormal.xy*0.5+0.5).rgb * tex2D(_MatcapMaskTex, i.uv);
                    #else
                        float3 matColor =  tex2D(_MatcapTex, i.viewNormal.xy*0.5+0.5).rgb;
                    #endif
                    col = lerp(col, fixed4(matColor, col.a), _MatcapBlend);
                #else                

                    #ifdef USETOON
                        col = toonshade(normal, lightDir, _ToonThreshold, _ToonShadeColor, col);
                    #else
                        col = diffuse(lightDir, normal, _DiffuseShade, col);
                    #endif
                    // col = diffuse(lightDir, normal, _DiffuseShade, col);

                    #ifdef SPECULAR
                        col += specular(lightDir, normal, viewDir, _SpecularPower);
                    #endif

                    col += emission(_EmissionMap, i.uv, _EmissionColor);
                    
                    //rimlight
                    #ifdef RIMLIGHT
                    col += rim(viewDir, normal, _RimColor);
                    #endif
               
                #endif

                half l = length(i.modelPos - _Center)*10;
                fixed4 noise = tex2D(_BoundaryNoiseTex, i.uv + _Time.x);
                float alpha = monochrome(noise.rgb);

                col += step(l, _Distant + _BoundaryWidth + rand(i.uv)*0.08)*_BoundaryEmissionColor;

                if(l < _Distant)
                {
                    discard;
                }

                if(step(l, _Distant + _BoundaryWidth + rand(i.uv)*0.07) && alpha < _BoundaryCutoutThreshold)
                {
                    discard;
                }
                
                return col;                
            }
            ENDCG
        }
    }
}
