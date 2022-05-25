#include <bnb/glsl.frag>
#include "filtered_mask.glsl"
#include "yuv.glsl"

BNB_IN(0)
vec2 var_uv;
BNB_IN(1)
vec2 var_hair_mask_uv;
BNB_IN(2)
vec2 var_strands_mask_uv;

BNB_DECLARE_SAMPLER_2D(0, 1, tex_camera);
BNB_DECLARE_SAMPLER_2D(2, 3, tex_hair_mask);
BNB_DECLARE_SAMPLER_2D(4, 5, tex_gradient_mask);
BNB_DECLARE_SAMPLER_2D(6, 7, tex_strands_mask);

/*
    in hair_strand mode
    var_hair_colors[0] - small strand, represents hair deep shadows
    var_hair_colors[1] - average strand, represents hair sub-shadows
    var_hair_colors[2] - the biggest strand, represents base hair color
    var_hair_colors[3] - average strand, represents hair sub-highlights
    var_hair_colors[4] - small strand, represents hair highlights
*/

vec4 get_color(int index)
{
    if (index == 0)
        return var_hair_color0;
    if (index == 1)
        return var_hair_color1;
    if (index == 2)
        return var_hair_color2;
    if (index == 3)
        return var_hair_color3;
    if (index == 4)
        return var_hair_color4;
    return vec4(0.);
}

/* returns interpolated color */
vec4 hair_color_linear(float x)
{
    float sample0 = x;

    int sample1 = int(floor(sample0));
    int sample2 = int(ceil(sample0));
    float ratio = fract(sample0);

    vec4 color1 = get_color(sample1);
    vec4 color2 = get_color(sample2);

    return mix(color1, color2, ratio);
}


vec4 color(vec4 base, vec4 target, float alpha)
{
    const float beta = 0.5;

    vec3 pixel1 = rgb2yuv(base.rgb);
    vec3 yuv1 = rgb2yuv(target.rgb);

    pixel1[1] = mix(pixel1[1], mix(pixel1[1], yuv1[1], beta), alpha);
    pixel1[2] = mix(pixel1[2], mix(pixel1[2], yuv1[2], beta), alpha);

    return vec4(yuv2rgb(pixel1), target.a);
}

void main()
{
    float var_hair_colors_count = var_hair_colors_count_mode.x;
    float var_hair_coloring_mode = var_hair_colors_count_mode.y;
    float mask = hair_mask(BNB_PASS_SAMPLER_ARGUMENT(tex_hair_mask), var_hair_mask_uv);
    vec4 camera = BNB_TEXTURE_2D(BNB_SAMPLER_2D(tex_camera), var_uv);

    float target_color_idx = 0.;

    if (var_hair_coloring_mode == 1.)
        target_color_idx = gradient_mask(BNB_PASS_SAMPLER_ARGUMENT(tex_gradient_mask), var_uv, var_hair_colors_count);
    if (var_hair_coloring_mode == 2.)
        target_color_idx = strands_mask(BNB_PASS_SAMPLER_ARGUMENT(tex_strands_mask), var_strands_mask_uv);

    vec4 target_color = hair_color_linear(target_color_idx);

    vec4 colored = color(camera, target_color, mask);

    bnb_FragColor = vec4(colored.rgb, colored.a * mask);
}