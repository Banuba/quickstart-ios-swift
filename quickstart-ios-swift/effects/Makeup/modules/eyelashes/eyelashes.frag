#include <bnb/glsl.frag>

BNB_IN(0)
vec2 var_uv;

BNB_DECLARE_SAMPLER_2D(0, 1, tex_diffuse);

void main()
{
    vec4 lashes = BNB_TEXTURE_2D(BNB_SAMPLER_2D(tex_diffuse), var_uv);

    bnb_FragColor = vec4(lashes.rgb + var_eyelashes_color.rgb, lashes.a * var_lashes_color.a);
}
