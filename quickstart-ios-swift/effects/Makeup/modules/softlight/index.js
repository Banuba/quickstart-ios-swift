'use strict';

require('bnb_js/global');
const modules_scene_index = require('../scene/index.js');

const vertexShader = "modules/softlight/soflight.vert";

const fragmentShader = "modules/softlight/soflight.frag";

const SoftLight = "modules/softlight/soft.ktx";

class Softlight {
    constructor() {
        Object.defineProperty(this, "_softlight", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: new modules_scene_index.Mesh(new modules_scene_index.FaceGeometry(), new modules_scene_index.ShaderMaterial({
                vertexShader,
                fragmentShader,
                uniforms: {
                    tex_camera: new modules_scene_index.Scene(),
                    tex_softlight: new modules_scene_index.Image(SoftLight),
                    var_softlight_strength: new modules_scene_index.Vector4(0),
                },
                state: { zTest: true, zWrite: true },
            }))
        });
        this._softlight.material.uniforms.var_softlight_strength.subscribe(([strength]) => this._softlight.visible(strength > 0));
        modules_scene_index.add(this._softlight);
    }
    /** Sets the softlight strength from 0 to 1 */
    strength(strength) {
        if (typeof strength !== "undefined")
            this._softlight.material.uniforms.var_softlight_strength.value(strength);
        return this._softlight.material.uniforms.var_softlight_strength.value()[0];
    }
    /** Removes the softlight */
    clear() {
        this.strength(0);
    }
}

exports.Softlight = Softlight;
