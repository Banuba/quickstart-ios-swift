#include <bnb/glsl.frag>

BNB_IN(0)
vec2 var_uv;
BNB_IN(1)
vec2 var_face_uv;
BNB_IN(2)
vec3 var_red_mask;

BNB_DECLARE_SAMPLER_2D(0, 1, tex_flare);

void main()
{
    float var_eyes_flare_strength = var_eyes_whitening_flare.y;
    vec4 flare = BNB_TEXTURE_2D(BNB_SAMPLER_2D(tex_flare), var_face_uv);

    float flare_mask = (flare.r + flare.g + flare.b) / 3. * var_eyes_flare_strength;

    bnb_FragColor = vec4(flare.rgb, flare_mask);
}
