#include <bnb/glsl.frag>

BNB_IN(0)
vec2 var_uv;
BNB_IN(1)
vec2 var_face_uv;
BNB_IN(2)
vec3 var_red_mask;

BNB_DECLARE_SAMPLER_2D(0, 1, tex_camera);
BNB_DECLARE_SAMPLER_2D(2, 3, tex_softlight);

float softlight_blend_1ch(float a, float b)
{
    return ((1. - 2. * b) * a + 2. * b) * a;
}

vec3 softlight_blend_1ch(vec3 base, vec3 blend)
{
    return vec3(softlight_blend_1ch(base.r, blend.r), softlight_blend_1ch(base.g, blend.g), softlight_blend_1ch(base.b, blend.b));
}

void main()
{
    vec4 camera = BNB_TEXTURE_2D(BNB_SAMPLER_2D(tex_camera), var_uv);
    vec4 softlight = BNB_TEXTURE_2D(BNB_SAMPLER_2D(tex_softlight), var_face_uv);

    float softlight_alpha = var_red_mask.r * var_softlight_strength.x;

    const float soft_cutoff0 = 0.3;
    const float soft_cutoff1 = 0.7;
    float brightness = camera.g;
    float light_factor = smoothstep(soft_cutoff0, soft_cutoff1, brightness);

    float luma = dot(softlight.rgb, vec3(0.299, 0.587, 0.114));
    vec3 luminance = vec3(luma);

    softlight.rgb = mix(luminance, softlight.rgb, light_factor);

    vec3 softlight_color = softlight_blend_1ch(camera.rgb, softlight.rgb);

    bnb_FragColor = vec4(mix(camera.rgb, softlight_color, softlight_alpha), 1.);
}
