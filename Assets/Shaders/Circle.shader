Shader "Unlit/Circle"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [HDR]_Color("Main Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _Radius("Radius", Range(-0.5, 1.0)) = 0.2
        _Thickness("Thickness", Range(0.001, 0.1)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}
        LOD 100
//        Blend SrcAlpha OneMinusSrcAlpha
        
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
            float _Radius;
            float _Thickness;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv -0.5;
                uv.x *= 2.0;
                float dist = length(float2(0.0f, 0.0f) - uv);
                float time = frac(_Time.y);
                
                int circle1 = step(abs(dist - _Radius), _Thickness);
                int circle2 = step(abs(dist - _Radius+0.15), _Thickness);
                int circle3 = step(abs(dist - _Radius+0.3), _Thickness);
                int circle = circle1 + circle2 + circle3;

                clip(circle -0.01);
                fixed4 col = _Color*circle;
                return col;
            }
            ENDCG
        }
    }
}
