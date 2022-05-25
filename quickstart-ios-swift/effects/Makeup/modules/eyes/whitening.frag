#include <bnb/glsl.frag>
#include <bnb/lut.glsl>

BNB_IN(0)
vec2 var_uv;
BNB_IN(1)
vec2 var_face_uv;
BNB_IN(2)
vec3 var_red_mask;

BNB_DECLARE_SAMPLER_2D(0, 1, tex_camera);
BNB_DECLARE_SAMPLER_LUT(2, 3, tex_whitening);

void main()
{
    float var_eyes_whitening_strength = var_eyes_whitening_flare.x;
    vec4 camera = BNB_TEXTURE_2D(BNB_SAMPLER_2D(tex_camera), var_uv);
    vec3 whitening = BNB_TEXTURE_LUT_SMALL(camera.rgb, BNB_PASS_SAMPLER_ARGUMENT(tex_whitening));

    float whitening_mask = var_red_mask.b * var_eyes_whitening_strength;

    bnb_FragColor = vec4(whitening.rgb, whitening_mask);
}
