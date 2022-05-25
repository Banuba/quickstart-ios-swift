#include <bnb/glsl.frag>
#include <bnb/texture_bicubic.glsl>

BNB_IN(0)
vec4 var_uv;

BNB_DECLARE_SAMPLER_2D(0, 1, tex_camera);
BNB_DECLARE_SAMPLER_2D(2, 3, tex_lips_mask);

vec2 rgb_hs(vec3 rgb)
{
    float cmax = max(rgb.r, max(rgb.g, rgb.b));
    float cmin = min(rgb.r, min(rgb.g, rgb.b));
    float delta = cmax - cmin;
    vec2 hs = vec2(0.);
    if (cmax > cmin) {
        hs.y = delta / cmax;
        if (rgb.r == cmax)
            hs.x = (rgb.g - rgb.b) / delta;
        else {
            if (rgb.g == cmax)
                hs.x = 2. + (rgb.b - rgb.r) / delta;
            else
                hs.x = 4. + (rgb.r - rgb.g) / delta;
        }
        hs.x = fract(hs.x / 6.);
    }
    return hs;
}

float rgb_v(vec3 rgb)
{
    return max(rgb.r, max(rgb.g, rgb.b));
}

vec3 hsv_rgb(float h, float s, float v)
{
    return v * mix(vec3(1.), clamp(abs(fract(vec3(1., 2. / 3., 1. / 3.) + h) * 6. - 3.) - 1., 0., 1.), s);
}

vec3 blendColor(vec3 base, vec3 blend, vec2 brightness_contrast)
{
    float v = rgb_v(base) * brightness_contrast.y;
    vec2 hs = rgb_hs(blend);
    return hsv_rgb(hs.x, hs.y - brightness_contrast.x, v);
}

vec3 blendColor(vec3 base, vec3 blend, float opacity, vec2 brightness_contrast)
{
    return (blendColor(base, blend, brightness_contrast) * opacity + base * (1.0 - opacity));
}

void main()
{
    vec4 js_lips_color = vec4(var_lips_color);
    vec4 js_lips_brightness_contrast = vec4(1.0 - var_lips_saturation_brightness.x, var_lips_saturation_brightness.y, 0., 0.);

    float js_color_v = rgb_v(js_lips_color.rgb);
    const float v_norm = 1. / 0.85;
    float v_scale = js_color_v * v_norm;
    js_lips_brightness_contrast.y *= v_scale;

    vec2 uv = var_uv.xy;
#ifdef BNB_VK_1
    uv.y = 1. - uv.y;
#endif

    vec3 bg = BNB_TEXTURE_2D(BNB_SAMPLER_2D(tex_camera), uv.xy).rgb;

    float alpha = bnb_texture_bicubic(BNB_PASS_SAMPLER_ARGUMENT(tex_lips_mask), var_uv.zw).x;

    bnb_FragColor = vec4(blendColor(bg, js_lips_color.xyz, alpha * js_lips_color.w, js_lips_brightness_contrast.xy), alpha);
}