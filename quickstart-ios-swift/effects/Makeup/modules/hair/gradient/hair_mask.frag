#include <bnb/glsl.frag>

BNB_IN(0)
vec2 var_uv;

BNB_DECLARE_SAMPLER_2D(0, 1, tex_mask);

void main()
{
    vec4 mask = BNB_TEXTURE_2D(BNB_SAMPLER_2D(tex_mask), var_uv);

    bnb_FragColor = mask * step(0.15, mask.x);
}