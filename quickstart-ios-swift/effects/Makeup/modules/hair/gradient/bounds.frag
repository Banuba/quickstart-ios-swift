#include <bnb/glsl.frag>

BNB_IN(0)
vec2 var_uv;

BNB_DECLARE_SAMPLER_2D(0, 1, tex_mask);

void main()
{
    vec2 minmax = vec2(0., 1.);

    for (int y = 0; y < 256; ++y) {
        if (texelFetch(BNB_SAMPLER_2D(tex_mask), ivec2(0, y), 0).x > 0.5) {
            minmax[0] = float(y) / 256.;
            break;
        }
    }

    for (int y = 255; y > 0; --y) {
        if (texelFetch(BNB_SAMPLER_2D(tex_mask), ivec2(0, y), 0).x > 0.5) {
            minmax[1] = float(y) / 256.;
            break;
        }
    }

    bnb_FragColor = vec4(minmax, 0., 1.);
}