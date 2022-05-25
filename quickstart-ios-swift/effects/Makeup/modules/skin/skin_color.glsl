#include <bnb/glsl.frag>
#include <bnb/color_spaces.glsl>

vec4 skin_color(vec4 camera_color, BNB_DECLARE_SAMPLER_2D_ARGUMENT(tex_mask), vec2 mask_uv, vec4 target_skin_color)
{
    vec4 js_yuva = bnb_rgba_to_yuva(target_skin_color);

    vec2 maskColor = js_yuva.yz;
    float beta = js_yuva.x;

    float y = bnb_rgba_to_yuva(camera_color).x;
    vec2 uv_src = bnb_rgba_to_yuva(camera_color).yz;

    float alpha = abs(skin_nn_transform[1].w - BNB_TEXTURE_2D(BNB_SAMPLER_2D(tex_mask), mask_uv).a) * js_yuva.w;

    vec2 uv = (1.0 - alpha) * uv_src + alpha * ((1.0 - beta) * maskColor + beta * uv_src);

    float u = uv.x - 0.5;
    float v = uv.y - 0.5;

    float r = y + bnb_color_spaces_YUV2RGB_RED_CrV * v;
    float g = y - bnb_color_spaces_YUV2RGB_GREEN_CbU * u - bnb_color_spaces_YUV2RGB_GREEN_CrV * v;
    float b = y + bnb_color_spaces_YUV2RGB_BLUE_CbU * u;

    return vec4(r, g, b, 1.0);
}