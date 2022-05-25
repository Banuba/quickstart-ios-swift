#include <bnb/texture_bicubic.glsl>

float filter_mask(float mask)
{
    const float magnification = 1.25;
    const float treshold = 0.2;

    // mask = pow(mask, magnification);
    // mask = max(0., (mask - treshold) / (1. - treshold));

    return mask;
}

float hair_mask(BNB_DECLARE_SAMPLER_2D_ARGUMENT(tex_mask), vec2 uv)
{
    vec4 mask = bnb_texture_bicubic(BNB_PASS_SAMPLER_ARGUMENT(tex_mask), uv);

    return filter_mask(mask.x);
}

/* returns index of the color to be used in [0-4] range */
float strands_mask(BNB_DECLARE_SAMPLER_2D_ARGUMENT(tex_mask), vec2 uv)
{
    // TODO: WebGL1 has no support for textureSize
    vec2 xy = uv * vec2(textureSize(BNB_SAMPLER_2D(tex_mask), 0));

    // TODO: WebGL1 has no support for texelFetch
    vec4 mask = texelFetch(BNB_SAMPLER_2D(tex_mask), ivec2(xy), 0);

    // the strands mask consist of bytes of *integers* in [0-4] range
    // since the bytes are fetched as *floats*, we have to multiply them by 255 to get the integers back
    mask *= 255.;

    return mask.x;
}

/* returns index of the color to be used in [0-(num_of_colors-1)] range */
float gradient_mask(BNB_DECLARE_SAMPLER_2D_ARGUMENT(tex_mask), vec2 uv, float num_of_colors)
{
    vec4 mask = BNB_TEXTURE_2D(BNB_SAMPLER_2D(tex_mask), uv);

    return mask.x * (num_of_colors - 1.);
}