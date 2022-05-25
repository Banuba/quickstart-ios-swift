'use strict';

require('bnb_js/global');
const modules_scene_index = require('../../scene/index.js');
const modules_hair_gradient_downscale_index = require('./downscale/index.js');

const HairMaskVertexShader = "modules/hair/gradient/hair_mask.vert";

const HairMaskFragmentShader = "modules/hair/gradient/hair_mask.frag";

const BoundsVertexShader = "modules/hair/gradient/bounds.vert";

const BoundsFragmentShader = "modules/hair/gradient/bounds.frag";

const GradientVertexShader = "modules/hair/gradient/gradient.vert";

const GradientFragmentShader = "modules/hair/gradient/gradient.frag";

function Gradient() {
    let downscaled = new modules_scene_index.Pass(new modules_scene_index.ShaderMaterial({
        vertexShader: HairMaskVertexShader,
        fragmentShader: HairMaskFragmentShader,
        uniforms: {
            tex_mask: new modules_scene_index.SegmentationMask("HAIR"),
        },
        state: {
            blending: "OFF",
        },
    }), {
        filtering: "LINEAR",
    });
    let width = 256;
    const height = width;
    do {
        downscaled = modules_hair_gradient_downscale_index.Downscale(downscaled, width, height);
    } while ((width /= 2) >= 1);
    const minmax = new modules_scene_index.Pass(new modules_scene_index.ShaderMaterial({
        vertexShader: BoundsVertexShader,
        fragmentShader: BoundsFragmentShader,
        uniforms: {
            tex_mask: downscaled,
        },
        state: {
            blending: "OFF",
        },
    }), {
        filtering: "LINEAR",
        width: 1,
        height: 1,
    });
    return new modules_scene_index.Pass(new modules_scene_index.ShaderMaterial({
        vertexShader: GradientVertexShader,
        fragmentShader: GradientFragmentShader,
        uniforms: {
            tex_mask: minmax,
        },
        state: {
            blending: "OFF",
        },
    }));
}

exports.Gradient = Gradient;
