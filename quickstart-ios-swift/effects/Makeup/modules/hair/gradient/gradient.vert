#include <bnb/glsl.vert>

BNB_LAYOUT_LOCATION(0)
BNB_IN vec2 attrib_pos;

BNB_OUT(0)
vec2 var_uv;

void main()
{
    var_uv = attrib_pos.xy * 0.5 + 0.5;

    gl_Position = vec4(attrib_pos.xy, 0., 1.);
}