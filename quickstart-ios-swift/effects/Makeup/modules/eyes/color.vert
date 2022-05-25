#include <bnb/glsl.vert>

BNB_LAYOUT_LOCATION(0)
BNB_IN vec2 attrib_pos;

BNB_OUT(0)
vec2 var_uv;
BNB_OUT(1)
vec2 var_l_eye_mask_uv;
BNB_OUT(2)
vec2 var_r_eye_mask_uv;

void main()
{
    var_uv = attrib_pos * 0.5 + 0.5;

#ifdef BNB_VK_1
    var_uv.y = 1. - var_uv.y;
#endif

    var_l_eye_mask_uv = (vec4(attrib_pos, 1., 1.) * left_eye_nn_transform).xy;
    var_r_eye_mask_uv = (vec4(attrib_pos, 1., 1.) * right_eye_nn_transform).xy;

    gl_Position = vec4(attrib_pos, 0., 1.);
}