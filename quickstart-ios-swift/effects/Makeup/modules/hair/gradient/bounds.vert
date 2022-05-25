#include <bnb/glsl.vert>

BNB_LAYOUT_LOCATION(0)
BNB_IN vec2 attrib_pos;

void main()
{
    gl_Position = vec4(attrib_pos.xy, 0., 1.);
}