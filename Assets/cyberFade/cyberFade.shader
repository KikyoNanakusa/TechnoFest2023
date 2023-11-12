Shader "Custom/cyberFade"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [MainColor]_MainColor("Main Color", Color) = (1.0, 1.0, 1.0, 0)

        [Space(40)]
        _OutlineColor("Outline Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _OutlineWidth("Outline Width", float) = 0
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
        [Spapce(120)]

        [Toggle(RIMLIGHT)] _RIMLIGHT("Use Rimlight", float) = 0
        _RimColor("Rimlight Color", Color) = (0.0, 0.0, 0.0, 1.0)
        _RimPower("Rimlight Power", Range(0, 1)) = 1.0
        [Space(40)]
        [HDR]_EmissionColor("Emission Color", Color) = (0.0, 0.0, 0.0, 1.0)
        _EmissionMap("Emission Map", 2D) = "white" {}

        [Space(40)]
        [Toggle(MATCAP)] _MATCAP("Use Matcap", float) = 0
        _MatcapTex("Matcap Texture", 2d) = "black" {}
        _MatcapBlend("Matcap Blend", Range(0, 1)) = 1.0
        [Toggle(MATCAPMASK)] _MATCAPMASK("Use Matcap Mask", float) = 0
        _MatcapMaskTex("Matcap Mask Texture", 2D) = "black" {} 

        [Header(Fade)]
        [Toggle(DISCARD)] _DISCARD("Use fade", float) = 1
        _XThreshold("X axis threshold", float) = 0
        _YThreshold("Y axis threshold", float) = 0
        _ZThreshold("Z axis threshold", float) = 0
        [Toggle(REVERTX)] _REVERTX("Revert X", float) = 0 
        [Toggle(REVERTY)] _REVERTY("Revert Y", float) = 0 
        [Toggle(REVERTZ)] _REVERTZ("Revert Z", float) = 0 
        [HDR] _BoundaryEmissionColor("Boundary Emission Color", Color) = (0.0, 0.0, 0.0, 1.0)
        _BoundaryWidth("Boundary Width", float) = 0.01
        _BoundaryNoiseTex("Boundary Noisemap", 2D) = "black" {}
        _BoundaryCutoutThreshold("Boundary Cutout Threshold", Range(0, 1)) = 0

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass{
            Cull Front

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma shader_feature DISCARD
            #pragma shader_feature REVERTX
            #pragma shader_feature REVERTY
            #pragma shader_feature REVERTZ

            #include "UnityCG.cginc"
            #include "cginc\base.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float3 modelPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _OutlineColor;
            half _OutlineWidth;

            half _XThreshold;
            half _YThreshold;
            half _ZThreshold;
            sampler2D _BoundaryNoiseTex;
            half _BoundaryWidth;
            float4 _BoundaryEmissionColor;
            half _BoundaryCutoutThreshold;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex + v.normal*_OutlineWidth * 0.001);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.modelPos = v.vertex;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 col = _OutlineColor;
                #ifdef DISCARD
                    fixed4 noise = tex2D(_BoundaryNoiseTex, i.uv + _Time.x);
                    float alpha = monochrome(noise.rgb);
                    half XTh = _XThreshold * 0.01;
                    half YTh = _YThreshold * 0.01;
                    half ZTh = _ZThreshold * 0.01;
                    half boundaryWidth = _BoundaryWidth * 0.01;
                    float3 modelPos = i.modelPos;

                    #ifdef REVERTX
                        modelPos.x *= -1.0;
                    #endif

                    #ifdef REVERTY
                        modelPos.y *= -1.0;
                    #endif
                    
                    #ifdef REVERTZ
                        modelPos.z *= -1.0;
                    #endif

                    if(modelPos.x <=XTh)
                    {
                        discard;
                    }else if(modelPos.y <= YTh)
                    {
                        discard;
                    }else if(modelPos.z <= ZTh)
                    {
                        discard;
                    }

                    float4 boundaryColorX = step(modelPos.x,XTh + boundaryWidth) * _BoundaryEmissionColor;
                    float4 boundaryColorY = step(modelPos.y, YTh + boundaryWidth) * _BoundaryEmissionColor;
                    float4 boundaryColorZ = step(modelPos.z, ZTh + boundaryWidth) * _BoundaryEmissionColor;
                    
                    if(alpha < _BoundaryCutoutThreshold)
                    {
                        if(step(modelPos.y, YTh + boundaryWidth) == 1 || step(modelPos.x,XTh + boundaryWidth) || step(modelPos.z, ZTh + boundaryWidth))
                        {
                            discard;
                        }
                    }

                    col += boundaryColorX + boundaryColorY + boundaryColorZ;
                #endif

                return saturate(col);
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
            #pragma shader_feature DISCARD
            #pragma shader_feature REVERTX
            #pragma shader_feature REVERTY
            #pragma shader_feature REVERTZ
            #pragma shader_feature USETOON

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "cginc\base.cginc"


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
            half _ToonThreshold;
            float4 _ToonShadeColor;

            sampler2D _NormalTex;

            float4 _RimColor;
            half _RimPower;

            sampler2D _EmissionMap;
            float4 _EmissionColor;

            sampler2D _MatcapTex;
            half _MatcapBlend;

            half _XThreshold;
            half _YThreshold;
            half _ZThreshold;
            float4 _BoundaryEmissionColor;
            half _BoundaryWidth;
            sampler2D _BoundaryNoiseTex;
            half _BoundaryCutoutThreshold;

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
                
                //normal mapping
                #ifdef NORMALMAP
                    fixed3 normalMap = UnpackNormal(tex2D(_NormalTex, i.uv));
                    float3 normal = (i.tangent * normalMap.x) + (i.binormal * normalMap.y) + (i.normal * normalMap.z);
                #else
                    float3 normal = normalize(i.normal);
                #endif
                

                //samplimg main texture                
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


                    #ifdef SPECULAR
                        col += saturate(specular(lightDir, normal, viewDir, _SpecularPower));
                    #endif

                    col += emission(_EmissionMap, i.uv, _EmissionColor);
                    
                    //rimlight
                    #ifdef RIMLIGHT
                    col += rim(viewDir, normal, _RimColor, _RimPower);
                    #endif
                

                #endif

                #ifdef DISCARD
                    fixed4 noise = tex2D(_BoundaryNoiseTex, i.uv + _Time.x);
                    float alpha = monochrome(noise.rgb);

                    half XTh = _XThreshold * 0.01;
                    half YTh = _YThreshold * 0.01;
                    half ZTh = _ZThreshold * 0.01;
                    half boundaryWidth = _BoundaryWidth * 0.01;
                    float3 modelPos = i.modelPos;
                    #ifdef REVERTX
                        modelPos.x *= -1.0;
                    #endif

                    #ifdef REVERTY
                        modelPos.y *= -1.0;
                    #endif
                    
                    #ifdef REVERTZ
                        modelPos.z *= -1.0;
                    #endif

                    if(modelPos.x <=XTh)
                    {
                        discard;
                    }else if(modelPos.y <= YTh)
                    {
                        discard;
                    }else if(modelPos.z <= ZTh)
                    {
                        discard;
                    }
                    
                    float4 boundaryColorX = step(modelPos.x,XTh + boundaryWidth) * _BoundaryEmissionColor;
                    float4 boundaryColorY = step(modelPos.y, YTh + boundaryWidth) * _BoundaryEmissionColor;
                    float4 boundaryColorZ = step(modelPos.z, ZTh + boundaryWidth) * _BoundaryEmissionColor;
                    
                    if(alpha < _BoundaryCutoutThreshold)
                    {
                        if(step(modelPos.y, YTh + boundaryWidth) == 1 || step(modelPos.x,XTh + boundaryWidth) || step(modelPos.z, ZTh + boundaryWidth))
                        {
                            discard;
                        }
                    }

                    col += boundaryColorX + boundaryColorY + boundaryColorZ;
                #endif


                return col;                
            }
            ENDCG
        }
    }
}
