#include <bnb/glsl.frag>

BNB_IN(0)
vec2 var_uv;

BNB_DECLARE_SAMPLER_2D(0, 1, tex_camera);

void main()
{
    bnb_FragColor = BNB_TEXTURE_2D(BNB_SAMPLER_2D(tex_camera), var_uv);

    if (bnb_FragColor.a != 0.)
        bnb_FragColor /= bnb_FragColor.a;
}
