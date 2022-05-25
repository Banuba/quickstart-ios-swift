#include <bnb/glsl.frag>

vec4 soften(BNB_DECLARE_SAMPLER_2D_ARGUMENT(tex_camera), vec2 uv, float factor)
{
    vec4 camera = BNB_TEXTURE_2D(BNB_SAMPLER_2D(tex_camera), uv);
    vec3 originalColor = camera.xyz;
    vec3 screenColor = originalColor;

    float dx = 4.5 / bnb_SCREEN.x;
    float dy = 4.5 / bnb_SCREEN.y;

    vec3 nextColor0 = BNB_TEXTURE_2D(BNB_SAMPLER_2D(tex_camera), vec2(uv.x - dx, uv.y - dy)).xyz;
    vec3 nextColor1 = BNB_TEXTURE_2D(BNB_SAMPLER_2D(tex_camera), vec2(uv.x + dx, uv.y - dy)).xyz;
    vec3 nextColor2 = BNB_TEXTURE_2D(BNB_SAMPLER_2D(tex_camera), vec2(uv.x - dx, uv.y + dy)).xyz;
    vec3 nextColor3 = BNB_TEXTURE_2D(BNB_SAMPLER_2D(tex_camera), vec2(uv.x + dx, uv.y + dy)).xyz;

    float intensity = screenColor.g;
    vec4 nextIntensity = vec4(nextColor0.g, nextColor1.g, nextColor2.g, nextColor3.g);
    vec4 lg = nextIntensity - intensity;

    const float PSI = 0.05;
    vec4 curr = max(0.367 - abs(lg * (0.367 * 0.6 / (1.41 * PSI))), 0.);

    float summ = 1.0 + curr.x + curr.y + curr.z + curr.w;
    screenColor += (nextColor0 * curr.x + nextColor1 * curr.y + nextColor2 * curr.z + nextColor3 * curr.w);
    screenColor = screenColor * (factor / summ);

    screenColor = originalColor * (1. - factor) + screenColor;
    return vec4(screenColor, camera.a);
}