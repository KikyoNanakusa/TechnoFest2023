#ifndef EXAMPLE_INCLUDED
#define EXAMPLE_INCLUDED

#include "UnityCG.cginc"
#include "Lighting.cginc"

sampler2D _MainTex;
float4 _MainTex_TexelSize;
float _OutlineThickness;

//乱数生成
float rand(float2 co) 
{
    return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
}

//グレースケール化
float monochrome(float3 col)
{
    return 0.299 * col.r + 0.58 * col.g + 0.144 * col.b;
}

//ソーベルフィルタ　輪郭検出
//０～１の間で隣接ピクセルとの輝度の差が大きいほど１に近い数値を返す
half Sobel(float2 uv)
{
    float diffU = (1 / _MainTex_TexelSize.x) * _OutlineThickness * 0.000001;
    float diffV = (1 / _MainTex_TexelSize.y) * _OutlineThickness * 0.000001;
    half4 col00rgba = tex2D(_MainTex, uv + half2(-diffU, -diffV));
    half4 col01rgba = tex2D(_MainTex, uv + half2(-diffU, 0.0));
    half4 col02rgba = tex2D(_MainTex, uv + half2(-diffU, diffV));
    half4 col10rgba = tex2D(_MainTex, uv + half2(0.0, -diffV));
    half4 col12rgba = tex2D(_MainTex, uv + half2(0.0, diffV));
    half4 col20rgba = tex2D(_MainTex, uv + half2(diffU, -diffV));
    half4 col21rgba = tex2D(_MainTex, uv + half2(diffU, 0.0));
    half4 col22rgba = tex2D(_MainTex, uv + half2(diffU, diffV));

    float col00 = monochrome(col00rgba);
    float col01 = monochrome(col01rgba);
    float col02 = monochrome(col02rgba);
    float col10 = monochrome(col10rgba);
    float col12 = monochrome(col12rgba);
    float col20 = monochrome(col20rgba);
    float col21 = monochrome(col21rgba);
    float col22 = monochrome(col22rgba);



    half horizontalColor = 0;
    horizontalColor += col00 * -1.0;
    horizontalColor += col01 * -2.0;
    horizontalColor += col02 * -1.0;
    horizontalColor += col20;
    horizontalColor += col21 * 2.0;
    horizontalColor += col22;

    half verticalColor = 0;
    verticalColor += col00;
    verticalColor += col10 * 2.0;
    verticalColor += col20;
    verticalColor += col02 * -1.0;
    verticalColor += col12 * -2.0;
    verticalColor += col22 * -1.0;

    half horizontalAlpha = 0;
    horizontalAlpha += col00rgba.a * -1.0;
    horizontalAlpha += col01rgba.a * -2.0;
    horizontalAlpha += col02rgba.a * -1.0;
    horizontalAlpha += col20rgba.a;
    horizontalAlpha += col21rgba.a * 2.0;
    horizontalAlpha += col22rgba.a;

    half verticalAlpha = 0;
    verticalAlpha += col00rgba.a * -1.0;
    verticalAlpha += col01rgba.a * -2.0;
    verticalAlpha += col02rgba.a * -1.0;
    verticalAlpha += col20rgba.a;
    verticalAlpha += col21rgba.a * 2.0;
    verticalAlpha += col22rgba.a;

    half outlineColor = sqrt(horizontalColor * horizontalColor + verticalColor * verticalColor);
    half outlineAlpha = sqrt(horizontalAlpha * horizontalAlpha + verticalAlpha * verticalAlpha);
    half outline = max(outlineColor, outlineAlpha);
    outline = saturate(outline);
    return outline;
}

//uvを０～１で繰り返す
float2 uv_repeat(float2 uv, half repeat_count)
{
    return frac(uv * repeat_count);
}