#include <bnb/glsl.frag>
#include "soften.glsl"
#include "skin_color.glsl"

BNB_IN(0)
vec2 var_uv;
BNB_IN(1)
vec2 var_mask_uv;

BNB_DECLARE_SAMPLER_2D(0, 1, tex_camera);
BNB_DECLARE_SAMPLER_2D(2, 3, tex_mask);

void main()
{
    float mask = BNB_TEXTURE_2D(BNB_SAMPLER_2D(tex_mask), var_mask_uv).x;
    vec4 softened = soften(BNB_PASS_SAMPLER_ARGUMENT(tex_camera), var_uv, var_skin_softening_strength.x);
    vec4 colored = skin_color(softened, BNB_PASS_SAMPLER_ARGUMENT(tex_mask), var_mask_uv, var_skin_color);

    bnb_FragColor = vec4(colored.rgb, mask);
}
