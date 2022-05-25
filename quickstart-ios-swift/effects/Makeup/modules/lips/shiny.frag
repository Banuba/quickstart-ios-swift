#include <bnb/glsl.frag>
#include <bnb/texture_bicubic.glsl>

BNB_IN(0)
vec4 var_uv;

BNB_DECLARE_SAMPLER_2D(0, 1, tex_camera);
BNB_DECLARE_SAMPLER_2D(2, 3, tex_lips_mask);
BNB_DECLARE_SAMPLER_2D(4, 5, tex_shine_mask);
BNB_DECLARE_SAMPLER_2D(6, 7, tex_noise);

const float eps = 0.0001;

vec3 hsv2rgb(in vec3 c)
{
    vec3 rgb = clamp(abs(mod(c.x * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);
    return c.z * mix(vec3(1.0), rgb, c.y);
}

vec3 rgb2hsv(in vec3 c)
{
    vec4 k = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.zy, k.wz), vec4(c.yz, k.xy), (c.z < c.y) ? 1.0 : 0.0);
    vec4 q = mix(vec4(p.xyw, c.x), vec4(c.x, p.yzx), (p.x < c.x) ? 1.0 : 0.0);
    float d = q.x - min(q.w, q.y);
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + eps)), d / (q.x + eps), q.x);
}

float rgb_v(vec3 rgb)
{
    return max(rgb.r, max(rgb.g, rgb.b));
}

vec3 lipstik(vec3 bg)
{
    vec4 js_lips_color = vec4(var_lips_color);
    vec4 js_lips_shine = vec4(
        var_lips_saturation_brightness.x,
        var_lips_shine_intensity_bleeding_scale.x,
        var_lips_shine_intensity_bleeding_scale.y,
        var_lips_saturation_brightness.y);

    float sCoef = js_lips_shine.x;

    vec3 js_color_hsv = rgb2hsv(js_lips_color.rgb);
    vec3 bg_color_hsv = rgb2hsv(bg);

    float color_hsv_s = js_color_hsv.g * sCoef;
    if (sCoef > 1.) {
        color_hsv_s = js_color_hsv.g + (1. - js_color_hsv.g) * (sCoef - 1.);
    }

    vec3 color_lipstick = vec3(
        js_color_hsv.r,
        color_hsv_s,
        bg_color_hsv.b);

    return color_lipstick;
}

void main()
{
    vec4 js_lips_color = vec4(var_lips_color);

    float js_color_v = rgb_v(js_lips_color.rgb);
    const float v_norm = 1. / 0.85;
    float v_scale = js_color_v * v_norm;

    vec4 js_lips_shine = vec4(
        var_lips_saturation_brightness.x,
        var_lips_shine_intensity_bleeding_scale.x,
        var_lips_shine_intensity_bleeding_scale.y,
        var_lips_saturation_brightness.y);
    vec4 js_lips_glitter = vec4(
        var_lips_glitter_bleeding_intensity_grain.x,
        var_lips_glitter_bleeding_intensity_grain.y,
        var_lips_glitter_bleeding_intensity_grain.z,
        var_lips_shine_intensity_bleeding_scale.z);

    float nUVScale = bnb_SCREEN.y / (js_lips_glitter.z * 256.);
    vec4 noise = BNB_TEXTURE_2D(BNB_SAMPLER_2D(tex_noise), var_uv.zw * nUVScale) * 2. - 1.;

    vec4 maskColor = bnb_texture_bicubic(BNB_PASS_SAMPLER_ARGUMENT(tex_lips_mask), var_uv.zw);
    float maskAlpha = maskColor.x;

    vec2 uv = var_uv.xy;
#ifdef BNB_VK_1
    uv.y = 1. - uv.y;
#endif

    vec3 bg = BNB_TEXTURE_2D(BNB_SAMPLER_2D(tex_camera), uv.xy).xyz;

    float nCoeff = js_lips_glitter.x * 0.0025;
    vec3 bg_noised = BNB_TEXTURE_2D(BNB_SAMPLER_2D(tex_camera), uv.xy + noise.xy * nCoeff).xyz;

    // Lipstick
    vec3 color_lipstick = lipstik(bg);
    float nCoeff2 = js_lips_glitter.y * 0.02;
    float color_lipstick_b_noised = lipstik(bg_noised).z + noise.z * nCoeff2;

    float vCoef = js_lips_shine.y;
    float sCoef1 = js_lips_shine.z;
    float bCoef = js_lips_shine.w * v_scale;
    float a = 20.;
    float b = .75;

    vec3 color_lipstick_b = color_lipstick * vec3(1., 1., bCoef);
    vec3 color = maskAlpha * hsv2rgb(color_lipstick_b) + (1. - maskAlpha) * bg;

    // Shine
    vec4 shineColor = BNB_TEXTURE_2D(BNB_SAMPLER_2D(tex_shine_mask), var_uv.zw);
    float shineAlpha = shineColor.x;

    float scale = 1. - (js_lips_glitter.w - 1.);

    float v_min = lips_shining_shine_params.x;
    float v_max = lips_shining_shine_params.y * scale;

    float x = (color_lipstick_b_noised - v_min) / (v_max - v_min);
    float y = 1. / (1. + exp(-(x - b) * a * (1. + x)));

    float v1 = color_lipstick_b_noised * (1. - maskAlpha) + color_lipstick_b_noised * maskAlpha * bCoef;
    float v2 = color_lipstick_b_noised + (1. - color_lipstick_b_noised) * vCoef * y;
    float v3 = mix(v1, v2, y);

    vec3 color_shine = vec3(
        color_lipstick.x,
        color_lipstick.y * (1. - sCoef1 * y),
        v3);

    color = mix(color, hsv2rgb(color_shine), shineAlpha);

    bnb_FragColor = vec4(mix(bg, color, js_lips_color.w), maskAlpha);
}
