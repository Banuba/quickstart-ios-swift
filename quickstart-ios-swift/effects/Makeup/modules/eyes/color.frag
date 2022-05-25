#include <bnb/glsl.frag>
#include <bnb/color_spaces.glsl>

BNB_IN(0)
vec2 var_uv;
BNB_IN(1)
vec2 var_l_eye_mask_uv;
BNB_IN(2)
vec2 var_r_eye_mask_uv;

BNB_DECLARE_SAMPLER_2D(0, 1, tex_camera);
BNB_DECLARE_SAMPLER_2D(2, 3, tex_l_eye_mask);
BNB_DECLARE_SAMPLER_2D(4, 5, tex_r_eye_mask);

vec4 color(vec4 base, vec4 target)
{
    vec3 base_LCh = bnb_rgb_to_LCh(base.rgb);
    vec3 target_LCh = bnb_rgb_to_LCh(target.rgb);

    vec3 res_LCh = vec3(
        base_LCh.x,
        target_LCh.y,
        target_LCh.z);

    vec3 res_rgb = bnb_LCh_to_rgb(res_LCh);

    vec3 colored = mix(base.rgb, res_rgb, target.a);

    return vec4(colored, base.a);
}

void main()
{
    vec4 l_eye = BNB_TEXTURE_2D(BNB_SAMPLER_2D(tex_l_eye_mask), var_l_eye_mask_uv);
    vec4 r_eye = BNB_TEXTURE_2D(BNB_SAMPLER_2D(tex_r_eye_mask), var_r_eye_mask_uv);
    float mask = l_eye.x + r_eye.x;

    vec4 camera = BNB_TEXTURE_2D(BNB_SAMPLER_2D(tex_camera), var_uv);

    vec4 colored = color(camera, var_eyes_color);

    bnb_FragColor = vec4(colored.rgb, var_eyes_color.a * mask);
}
