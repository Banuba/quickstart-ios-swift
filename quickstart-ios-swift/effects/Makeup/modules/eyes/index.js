'use strict';

require('bnb_js/global');
const modules_scene_index = require('../scene/index.js');

const Flare = "modules/eyes/FLARE_38_512.png";

const colorFragmentShader = "modules/eyes/color.frag";

const colorVertexShader = "modules/eyes/color.vert";

const flareFragmentShader = "modules/eyes/flare.frag";

const flareVertexShader = "modules/eyes/flare.vert";

const whiteningVertexShader = "modules/eyes/whitening.vert";

const whiteningFragmentShader = "modules/eyes/whitening.frag";

const Whitening = "modules/eyes/lut3d_eyes_high.png";

class Eyes {
    constructor() {
        Object.defineProperty(this, "_shared", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: {
                var_eyes_whitening_flare: new modules_scene_index.Vector4(0, 0),
            }
        });
        Object.defineProperty(this, "_whitening", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: new modules_scene_index.Mesh(new modules_scene_index.FaceGeometry(), new modules_scene_index.ShaderMaterial({
                vertexShader: whiteningVertexShader,
                fragmentShader: whiteningFragmentShader,
                uniforms: {
                    tex_camera: new modules_scene_index.Camera(),
                    tex_whitening: new modules_scene_index.LUT(Whitening),
                    var_eyes_whitening_flare: this._shared.var_eyes_whitening_flare,
                },
            }))
        });
        Object.defineProperty(this, "_color", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: new modules_scene_index.Mesh(new modules_scene_index.PlaneGeometry(), new modules_scene_index.ShaderMaterial({
                vertexShader: colorVertexShader,
                fragmentShader: colorFragmentShader,
                uniforms: {
                    tex_camera: new modules_scene_index.Camera(),
                    tex_l_eye_mask: new modules_scene_index.SegmentationMask("L_EYE"),
                    tex_r_eye_mask: new modules_scene_index.SegmentationMask("R_EYE"),
                    var_eyes_color: new modules_scene_index.Vector4(0, 0, 0, 0),
                },
            }))
        });
        Object.defineProperty(this, "_flare", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: new modules_scene_index.Mesh(new modules_scene_index.FaceGeometry(), new modules_scene_index.ShaderMaterial({
                vertexShader: flareVertexShader,
                fragmentShader: flareFragmentShader,
                uniforms: {
                    tex_flare: new modules_scene_index.Image(Flare),
                    var_eyes_whitening_flare: this._shared.var_eyes_whitening_flare,
                },
            }))
        });
        const onChange = () => {
            const [whitening, flare] = this._whitening.material.uniforms.var_eyes_whitening_flare.value();
            const [, , , a] = this._color.material.uniforms.var_eyes_color.value();
            if (a > 0) {
                this._color.material.uniforms.tex_l_eye_mask.enable();
                this._color.material.uniforms.tex_r_eye_mask.enable();
            }
            else {
                this._color.material.uniforms.tex_l_eye_mask.disable();
                this._color.material.uniforms.tex_r_eye_mask.disable();
            }
            this._whitening.visible(whitening > 0);
            this._color.visible(a > 0);
            this._flare.visible(flare > 0);
            const isCorrectionNeeded = this._whitening.visible() || this._flare.visible();
            if (isCorrectionNeeded)
                modules_scene_index.enable("EYES_CORRECTION", this);
            else
                modules_scene_index.disable("EYES_CORRECTION", this);
        };
        this._whitening.material.uniforms.var_eyes_whitening_flare.subscribe(onChange);
        this._color.material.uniforms.var_eyes_color.subscribe(onChange);
        modules_scene_index.add(this._whitening, this._flare, this._color);
    }
    /** Sets the eyes sclera whitening strength from 0 to 1 */
    whitening(strength) {
        return this._whitening.material.uniforms.var_eyes_whitening_flare.x(strength);
    }
    /** Sets the eyes color */
    color(color) {
        if (typeof color !== "undefined")
            this._color.material.uniforms.var_eyes_color.value(color);
        return this._color.material.uniforms.var_eyes_color.value().join(" ");
    }
    /** Sets the eyes flare strength from 0 to 1 */
    flare(strength) {
        return this._flare.material.uniforms.var_eyes_whitening_flare.y(strength);
    }
    /** Removes the eyes color, resets any settings applied */
    clear() {
        this.whitening(0);
        this.color("0 0 0 0");
        this.flare(0);
    }
}

exports.Eyes = Eyes;
