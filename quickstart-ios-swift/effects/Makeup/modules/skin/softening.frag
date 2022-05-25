#include <bnb/glsl.frag>
#include "soften.glsl"

BNB_IN(0)
vec2 var_uv;
BNB_IN(1)
vec3 var_red_mask;

BNB_DECLARE_SAMPLER_2D(0, 1, tex_camera);

void main()
{
    float mask = var_red_mask.r * var_skin_softening_strength.x;

    vec4 softened = soften(BNB_PASS_SAMPLER_ARGUMENT(tex_camera), var_uv, mask);

    bnb_FragColor = vec4(softened.rgb, mask);
}
