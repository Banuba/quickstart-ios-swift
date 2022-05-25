#include <bnb/glsl.vert>

#define MORPH_MULTIPLIER 1.3

BNB_LAYOUT_LOCATION(0)
BNB_IN vec3 attrib_pos;
#ifdef BNB_VK_1
BNB_LAYOUT_LOCATION(1)
BNB_IN uint attrib_n;
#else
BNB_LAYOUT_LOCATION(1)
BNB_IN vec4 attrib_n;
#endif
#ifdef BNB_VK_1
BNB_LAYOUT_LOCATION(2)
BNB_IN uint attrib_t;
#else
BNB_LAYOUT_LOCATION(2)
BNB_IN vec4 attrib_t;
#endif
BNB_LAYOUT_LOCATION(3)
BNB_IN vec2 attrib_uv;
#ifndef BNB_GL_ES_1
BNB_LAYOUT_LOCATION(4)
BNB_IN uvec4 attrib_bones;
#else
BNB_LAYOUT_LOCATION(4)
BNB_IN vec4 attrib_bones;
#endif
#ifndef BNB_1_BONE
BNB_LAYOUT_LOCATION(5)
BNB_IN vec4 attrib_weights;
#endif

BNB_DECLARE_SAMPLER_2D(2, 3, bnb_BONES);
BNB_DECLARE_SAMPLER_2D(4, 5, bnb_MORPH);

BNB_OUT(0)
vec2 var_uv;

#define BNB_USE_AUTOMORPH
#include <bnb/morph_transform.glsl>

#ifdef BNB_GL_ES_1
    #include <bnb/matrix_operations.glsl>
mat4 get_bone(float b, float db)
{
    mat4 m = transpose(mat4(
        BNB_TEXTURE_2D(BNB_SAMPLER_2D(bnb_BONES), vec2(b, 0.)),
        BNB_TEXTURE_2D(BNB_SAMPLER_2D(bnb_BONES), vec2(b + db, 0.)),
        BNB_TEXTURE_2D(BNB_SAMPLER_2D(bnb_BONES), vec2(b + 2. * db, 0.)),
        vec4(0., 0., 0., 1.)));

    vec2 morph_uv = bnb_morph_coord(m[3].xyz) * 0.5 + 0.5;
    vec3 translation = BNB_TEXTURE_2D(BNB_SAMPLER_2D(bnb_MORPH), morph_uv).xyz;
    m[3].xyz += translation * MORPH_MULTIPLIER;

    mat4 ibp = transpose(mat4(
        BNB_TEXTURE_2D(BNB_SAMPLER_2D(bnb_BONES), vec2(b, 1.)),
        BNB_TEXTURE_2D(BNB_SAMPLER_2D(bnb_BONES), vec2(b + db, 1.)),
        BNB_TEXTURE_2D(BNB_SAMPLER_2D(bnb_BONES), vec2(b + 2. * db, 1.)),
        vec4(0., 0., 0., 1.)));

    return m * ibp;
}

mat4 get_transform()
{
    float db = 1. / (bnb_ANIM.z * 3.);
    mat4 m = get_bone((float(attrib_bones[0]) * 3. + 0.5) * db, db);
    if (attrib_weights[1] > 0.) {
        m = m * attrib_weights[0]
            + get_bone((float(attrib_bones[1]) * 3. + 0.5) * db, db) * attrib_weights[1];

        if (attrib_weights[2] > 0.) {
            m += get_bone((float(attrib_bones[2]) * 3. + 0.5) * db, db) * attrib_weights[2];

            if (attrib_weights[3] > 0.) {
                m += get_bone((float(attrib_bones[3]) * 3. + 0.5) * db, db) * attrib_weights[3];
            }
        }
    }
    return m;
}
#else
mat4 get_bone(uint bone_idx)
{
    int b = int(bone_idx) * 3;
    mat4 m = transpose(mat4(
        texelFetch(BNB_SAMPLER_2D(bnb_BONES), ivec2(b, 0), 0),
        texelFetch(BNB_SAMPLER_2D(bnb_BONES), ivec2(b + 1, 0), 0),
        texelFetch(BNB_SAMPLER_2D(bnb_BONES), ivec2(b + 2, 0), 0),
        vec4(0., 0., 0., 1.)));

    vec2 morph_uv = bnb_morph_coord(m[3].xyz) * 0.5 + 0.5;
    #ifdef BNB_VK_1
    morph_uv.y = 1. - morph_uv.y;
    #endif
    vec3 translation = BNB_TEXTURE_2D(BNB_SAMPLER_2D(bnb_MORPH), morph_uv).xyz;
    m[3].xyz += translation * MORPH_MULTIPLIER;

    mat4 ibp = transpose(mat4(
        texelFetch(BNB_SAMPLER_2D(bnb_BONES), ivec2(b, 1), 0),
        texelFetch(BNB_SAMPLER_2D(bnb_BONES), ivec2(b + 1, 1), 0),
        texelFetch(BNB_SAMPLER_2D(bnb_BONES), ivec2(b + 2, 1), 0),
        vec4(0., 0., 0., 1.)));

    return m * ibp;
}

mat4 get_transform()
{
    mat4 m = get_bone(attrib_bones[0]);
    if (attrib_weights[1] > 0.) {
        m = m * attrib_weights[0] + get_bone(attrib_bones[1]) * attrib_weights[1];
        if (attrib_weights[2] > 0.) {
            m += get_bone(attrib_bones[2]) * attrib_weights[2];
            if (attrib_weights[3] > 0.)
                m += get_bone(attrib_bones[3]) * attrib_weights[3];
        }
    }
    return m;
}
#endif

void main()
{
    mat4 m = get_transform();
    vec3 vpos = vec3(m * vec4(attrib_pos, 1.));

    var_uv = attrib_uv;

    gl_Position = bnb_MVP * vec4(vpos, 1.);
}
