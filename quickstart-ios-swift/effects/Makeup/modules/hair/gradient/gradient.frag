#include <bnb/glsl.frag>

BNB_IN(0)
vec2 var_uv;

BNB_DECLARE_SAMPLER_2D(0, 1, tex_mask);

void main()
{
    vec2 minmax = texelFetch(BNB_SAMPLER_2D(tex_mask), ivec2(0, 0), 0).xy;

    float gradient = smoothstep(minmax.x, minmax.y, 1. - var_uv.y);

    bnb_FragColor = vec4(gradient, 0., 0., 1.);
}