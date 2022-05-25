'use strict';

require('bnb_js/global');
const modules_scene_index = require('../../../scene/index.js');

const vertexShader = "modules/hair/gradient/downscale/downscale.vert";

const fragmentShader = "modules/hair/gradient/downscale/downscale.frag";

const Downscale = (texture, width, height = width) => new modules_scene_index.Pass(new modules_scene_index.ShaderMaterial({
    vertexShader,
    fragmentShader,
    uniforms: {
        tex_camera: texture,
    },
    state: {
        blending: "OFF",
    },
}), {
    width,
    height,
    filtering: "LINEAR",
});

exports.Downscale = Downscale;
