Shader "Custom/distract fade"
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
        _RimPower("Rimlight Power", Range(0, 1)) = 0
        [Space(40)]
        [HDR]_EmissionColor("Emission Color", Color) = (0.0, 0.0, 0.0, 1.0)
        _EmissionMap("Emission Map", 2D) = "black" {}

        [Space(40)]
        [Toggle(MATCAP)] _MATCAP("Use Matcap", float) = 0
        _MatcapTex("Matcap Texture", 2d) = "black" {}
        _MatcapBlend("Matcap Blend", Range(0, 1)) = 1.0
        [Toggle(MATCAPMASK)] _MATCAPMASK("Use Matcap Mask", float) = 0
        _MatcapMaskTex("Matcap Mask Texture", 2D) = "black" {}

        _time("Time", float) = 0
        [HDR]_DistEmissionColor("Emission Color", Color) = (0.0, 0.0, 0.0, 1.0)
        _XRadius("X axisRadius", float) = 0.5 
        _YRadius("Y axis Radius", float) = 0.5 
        _ZRadius("Z axisRadius", float) = 0.5 
        _EmissionWidth("Emission Width", float) = 0.3
        _Speed("Speed", float) = 1
        _SmallerSpeed("Smaller speed", float) = 0.3

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
            #pragma geometry geom

            #pragma fragment frag

            #include "UnityCG.cginc"


            struct appdata
            {
                half4 vertex : POSITION;
                half3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct g2f
            {
                half4 vertex : SV_POSITION;
                float3 originalCenter : TEXCOORD0;
				float2 uv:TEXCOORD1;
            };

            float4 _MainTex_ST;

            float _OutlineWidth;
            float4 _OutlineColor;

            float _time;
            float4 _DistEmissionColor;
            half _XRadius;
            half _YRadius;
            half _ZRadius;
            half _EmissionWidth;
            half _Speed;
            half _SmallerSpeed;

            float3 rotate(float3 p, float angle, float3 axis)
            {
                float3 a = normalize(axis);
                float s = sin(angle);
                float c = cos(angle);
                float r = 1.0 - c;
                float3x3 m = float3x3(
                    a.x * a.x * r + c, a.y * a.x * r + a.z * s, a.z * a.x * r - a.y * s,
                    a.x * a.y * r - a.z * s, a.y * a.y * r + c, a.z * a.y * r + a.x * s,
                    a.x * a.z * r + a.y * s, a.y * a.z * r - a.x * s, a.z * a.z * r + c
                );

                return mul(m, p);
            }

            float rand(float2 co) 
            {
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
            }

            appdata vert (appdata v)
            {
                return v;
            }

            [maxvertexcount(3)]
            void geom(triangle appdata vg[3], inout TriangleStream<g2f> outStream)
            {
                [unroll]
                for(int i = 0; i < 3; i++)
                {
                    vg[i].vertex.xyz += vg[i].normal*_OutlineWidth * 0.001;
                }

                float3 originalCenter = (vg[0].vertex + vg[1].vertex + vg[2].vertex) / 3;

                half time = (_time + originalCenter.y*20)*0.1;

                float3 e1 = vg[1].vertex.xyz - vg[0].vertex.xyz;
                float3 e2 = vg[2].vertex.xyz - vg[0].vertex.xyz;
                float3 triNormal = normalize(cross(e1, e2));
                triNormal.y = min(-0.5, abs(triNormal.y)*-1);


                [unroll]
                for(int i = 0; i < 3; i++)
                {
                    vg[i].vertex.x += (_XRadius + (rand(originalCenter.xy) - 0.5) * 2.0) * cos(time * _Speed) * 0.03 * step(0, time * _Speed);
                    vg[i].vertex.y -= sin(max(0, time * _Speed)) * (_YRadius + rand(originalCenter.yy)); 
                    vg[i].vertex.z += (_ZRadius + (rand(originalCenter.xz) - 0.5) * 2.0) * sin(time * _Speed) * 0.03 * step(0, time * _Speed);
                }


                float3 center = (vg[0].vertex + vg[1].vertex + vg[2].vertex) / 3;


                float3 axis = normalize(float3(rand(center.xz), 1, rand(center.xz)));


                [unroll]
                for(int i = 0; i < 3; i++)
                {
                    appdata v = vg[i];
                    g2f o;

                    UNITY_INITIALIZE_OUTPUT(g2f, o);

                    v.vertex.xyz += (center - v.vertex.xyz) * min(max(0, (_time + _SmallerSpeed + originalCenter.y*20)*1), 1);
                    v.vertex.xyz = center + rotate(v.vertex.xyz - center, (time*0.5+ rand(originalCenter.xz))*step(0, time), float3(rand(originalCenter.xy), 1, rand(originalCenter.xz)));

                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                    o.originalCenter = originalCenter;

                    outStream.Append(o);
                }
            }


            fixed4 frag(g2f i) :SV_Target
            {
                return _OutlineColor + step(0, _time + i.originalCenter.y*20 + rand(i.uv)) * step(_time + i.originalCenter.y*20 + rand(i.uv), _EmissionWidth) * _DistEmissionColor;
            }
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma geometry geom
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

			struct g2f 
            {
				float4 vertex:SV_POSITION;
				float2 uv:TEXCOORD0;
                float3 normal : NORMAL;
                float3 worldPos : TEXCOORD1;
                float3 viewNormal : TEXCOORD2;
                float3 modelPos : TEXCOORD3;
                float3 tangent : TEXCOORD4;
                float3 binormal : TEXCOORD5;
                float3 originalCenter : TEXCOORD6;
			};

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _MainColor;
            
            float _SpecularPower;
            half _MetalicPower;
            
            float _DiffuseShade;    

            sampler2D _NormalTex;

            float4 _RimColor;
            half _RimPower;

            sampler2D _EmissionMap;
            float4 _EmissionColor;

            sampler2D _MatcapTex;
            half _MatcapBlend;

            half _ToonThreshold;
            float4 _ToonShadeColor;

            float _time;
            float4 _DistEmissionColor;
            half _XRadius;
            half _YRadius;
            half _ZRadius;
            half _EmissionWidth;
            half _Speed;
            half _SmallerSpeed;

            float PI = 3.14159265358;


            float3 rotate(float3 p, float angle, float3 axis)
            {
                float3 a = normalize(axis);
                float s = sin(angle);
                float c = cos(angle);
                float r = 1.0 - c;
                float3x3 m = float3x3(
                    a.x * a.x * r + c, a.y * a.x * r + a.z * s, a.z * a.x * r - a.y * s,
                    a.x * a.y * r - a.z * s, a.y * a.y * r + c, a.z * a.y * r + a.x * s,
                    a.x * a.z * r + a.y * s, a.y * a.z * r - a.x * s, a.z * a.z * r + c
                );

                return mul(m, p);
            }

            appdata vert (appdata v)
            {
                return v;
            }

            [maxvertexcount(3)]
            void geom(triangle appdata vg[3], inout TriangleStream<g2f> outStream)
            {
                float3 originalCenter = (vg[0].vertex + vg[1].vertex + vg[2].vertex) / 3;

                half time = (_time + originalCenter.y*20)*0.1;

                float3 e1 = vg[1].vertex.xyz - vg[0].vertex.xyz;
                float3 e2 = vg[2].vertex.xyz - vg[0].vertex.xyz;
                float3 triNormal = normalize(cross(e1, e2));
                triNormal.y = min(-0.5, abs(triNormal.y)*-1);


                [unroll]
                for(int i = 0; i < 3; i++)
                {
                    vg[i].vertex.x += (_XRadius + (rand(originalCenter.xy) - 0.5) * 2.0) * cos(time * _Speed) * 0.03 * step(0, time * _Speed);
                    vg[i].vertex.y -= sin(max(0, time * _Speed)) * (_YRadius + rand(originalCenter.yy)); 
                    vg[i].vertex.z += (_ZRadius + (rand(originalCenter.xz) - 0.5) * 2.0) * sin(time * _Speed) * 0.03 * step(0, time * _Speed);
                }


                float3 center = (vg[0].vertex + vg[1].vertex + vg[2].vertex) / 3;


                float3 axis = normalize(float3(rand(center.xz), 1, rand(center.xz)));


                [unroll]
                for(int i = 0; i < 3; i++)
                {
                    appdata v = vg[i];
                    g2f o;

                    UNITY_INITIALIZE_OUTPUT(g2f, o);

                    v.vertex.xyz += (center - v.vertex.xyz) * min(max(0, (_time + _SmallerSpeed + originalCenter.y*20)*1), 1);


                    v.vertex.xyz = center + rotate(v.vertex.xyz - center, (time*0.5+ rand(originalCenter.xz))*step(0, time), float3(rand(originalCenter.xy), 1, rand(originalCenter.xz)));


                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.normal = UnityObjectToWorldNormal(v.normal);
                    o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                    o.viewNormal = mul((float3x3)UNITY_MATRIX_V, UnityObjectToWorldNormal(v.normal));
                    o.tangent = normalize(mul(unity_ObjectToWorld, v.tangent)).xyz;
                    o.binormal = cross(v.normal, v.tangent) * v.tangent.w;
                    o.binormal = normalize(mul(unity_ObjectToWorld, o.binormal));
                    o.originalCenter = originalCenter;

                    outStream.Append(o);
                }
            }

            fixed4 frag (g2f i) : SV_Target
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

                    #ifdef SPECULAR
                        col += specular(lightDir, normal, viewDir, _SpecularPower);
                    #endif

                    col += emission(_EmissionMap, i.uv, _EmissionColor);
                    
                    //rimlight
                    #ifdef RIMLIGHT
                    col += rim(viewDir, normal, _RimColor, _RimPower);
                    #endif
               
                #endif

                col += step(0, _time + i.originalCenter.y*20 + rand(i.uv)) * step(_time + i.originalCenter.y*20 + rand(i.uv), _EmissionWidth) * _DistEmissionColor;
                

                return col;                
            }
            ENDCG
        }
    }
}
