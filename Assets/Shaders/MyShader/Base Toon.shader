Shader "Custom/Base"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MainColor("Main Color", Color) = (0, 0, 0, 1)

        _FirstShadowColor("1st shadow color", Color) = (0, 0, 0, 1)
        _ShadowThreshold("Shadow Threshold", Range(0, 1)) = 0.22

        _EmissionMap("Emission map", 2D) ="black" {}
        [HDR]_EmissionColor("Emission Color", Color) = (0.0, 0.0, 0.0, 0.0)
        
        
        _RimColor("Rimlight Color", Color) = (1, 1, 1, 1)
        _RimPower("Rimlight Power", Range(0, 1)) = 0.0

        _OutlineWidth("Outline Width", Range(0, 1)) = 0.007
        _OutlineColor("Outline Color", Color) = (1.0, 1.0, 1.0, 1.0)

        _LightIntensity("Light Intensity", Range(0, 1)) = 1

        _UGOUGOPower("UGOUGO Power", float) = 0.0
        _UNYOUNYOPower("UNYOUNYO Power", float) = 5
    }


    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry"}
        LOD 100

        Pass
        {
            Cull Front

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                half4 vertex : POSITION;
                half3 normal : NORMAL;
            };

            struct v2f
            {
                half4 pos : SV_POSITION;
            };

            float _OutlineWidth;
            float4 _OutlineColor;

            float _UGOUGOPower;
            float _UNYOUNYOPower;


            float rand(float2 co)
            {
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
            }

            v2f vert(appdata v)
            {
                v2f o;
                //通常のアウトライン
                o.pos = UnityObjectToClipPos(v.vertex + v.normal * _OutlineWidth*0.001);
                return o;
            }

            fixed4 frag(v2f i) :SV_Target
            {
                return _OutlineColor;
            }
            ENDCG
        }

        Pass
        {
            Tags{
                "LightMode" = "ForwardBase"
            }
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

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
                float3 worldNormal : TEXCOORD1;
                float3 world_pos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _MainColor;

            float4 _FirstShadowColor;
            float _ShadowThreshold;

            float4 _RimColor;
            float _RimPower;
            
            float4 _EmissionColor;
            sampler2D _EmissionMap;

            float _LightIntensity;

            float _UGOUGOPower;
            float _UNYOUNYOPower;

            float _AmbientColor;

            float rand(float2 co)
            {
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.world_pos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 normal = normalize(i.worldNormal);
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0;
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.world_pos.xyz);

                float4 light = _LightIntensity * _LightColor0;


                float p = dot(normal, lightDir)*0.5 + 0.5;
                half d = step(_ShadowThreshold, max(0, p*p));
                half rim = 1.0 - saturate(dot(viewDir, normal));
                fixed4 rimColor = lerp(0, 1, rim);
                
                fixed4 col  = lerp(lerp(_FirstShadowColor, tex2D(_MainTex, i.uv)*_MainColor, d), _RimColor, rim*_RimPower) + tex2D(_EmissionMap, i.uv) * _EmissionColor;
    
                return col * light;
            }
            ENDCG
        }
    }
}
