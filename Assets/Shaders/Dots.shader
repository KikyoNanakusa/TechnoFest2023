Shader "Unlit/Dots"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [HDR]_Color("Main Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _Threshold("Threshold", Range(0.9, 1.0)) = 0.9
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float _Threshold;

            float rand(float2 co)
            {
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
            }

            float perlinNoise(fixed2 st) 
            {
                fixed2 p = floor(st);
                fixed2 f = frac(st);
                fixed2 u = f*f*(3.0-2.0*f);

                float v00 = rand(p+fixed2(0,0));
                float v10 = rand(p+fixed2(1,0));
                float v01 = rand(p+fixed2(0,1));
                float v11 = rand(p+fixed2(1,1));

                return lerp( lerp( dot( v00, f - fixed2(0,0) ), dot( v10, f - fixed2(1,0) ), u.x ),
                             lerp( dot( v01, f - fixed2(0,1) ), dot( v11, f - fixed2(1,1) ), u.x ), 
                             u.y)+0.5f;
            }

            float fBm (fixed2 st) 
            {
                float f = 0;
                fixed2 q = st;

                f += 0.5000*perlinNoise( q ); q = q*2.01;
                f += 0.2500*perlinNoise( q ); q = q*2.02;
                f += 0.1250*perlinNoise( q ); q = q*2.03;
                f += 0.0625*perlinNoise( q ); q = q*2.01;

                return f;
            }
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // float noise = fBm(i.uv + _Time.x);
                float noise = rand(i.uv + _Time.x/1000000);
                fixed4 col = _Color*step(_Threshold, noise);
                return col;
            }
            ENDCG
        }
    }
}
