#include <bnb/glsl.frag>
#include "softlight.glsl"

BNB_IN(0)
vec2 var_uv;
BNB_IN(1)
vec2 var_mask_uv;

BNB_DECLARE_SAMPLER_2D(0, 1, tex_camera);
BNB_DECLARE_SAMPLER_2D(2, 3, tex_mask);

void main()
{
    vec4 camera = BNB_TEXTURE_2D(BNB_SAMPLER_2D(tex_camera), var_uv);
    float mask = BNB_TEXTURE_2D(BNB_SAMPLER_2D(tex_mask), var_mask_uv).x;

    vec3 colored = blendSoftLight(camera.rgb, var_brows_color.rgb, var_brows_color.a);

    bnb_FragColor = vec4(colored.rgb, mask);
}