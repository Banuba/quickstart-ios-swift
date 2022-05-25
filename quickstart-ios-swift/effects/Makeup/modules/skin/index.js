'use strict';

require('bnb_js/global');
const modules_scene_index = require('../scene/index.js');

const SofteningVertexShader = "modules/skin/softening.vert";

const SofteningFragmentShader = "modules/skin/softening.frag";

const SkinVertexShader = "modules/skin/skin.vert";

const SkinFragmentShader = "modules/skin/skin.frag";

class Skin {
    constructor() {
        Object.defineProperty(this, "_skin", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: new modules_scene_index.Mesh(new modules_scene_index.PlaneGeometry(), new modules_scene_index.ShaderMaterial({
                vertexShader: SkinVertexShader,
                fragmentShader: SkinFragmentShader,
                uniforms: {
                    tex_camera: new modules_scene_index.Camera(),
                    tex_mask: new modules_scene_index.SegmentationMask("SKIN"),
                    var_skin_color: new modules_scene_index.Vector4(0, 0, 0, 0),
                    var_skin_softening_strength: new modules_scene_index.Vector4(0),
                },
            }))
        });
        /**
         * FRX version of skin softening.
         * It's designed to be used as a faster alternative to `skin_nn` softening
         * for the cases not leveraging skin coloration.
         */
        Object.defineProperty(this, "_softening", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: new modules_scene_index.Mesh(new modules_scene_index.FaceGeometry(), new modules_scene_index.ShaderMaterial({
                vertexShader: SofteningVertexShader,
                fragmentShader: SofteningFragmentShader,
                uniforms: {
                    tex_camera: new modules_scene_index.Camera(),
                    var_skin_softening_strength: this._skin.material.uniforms.var_skin_softening_strength,
                },
                state: { zTest: true, zWrite: true },
            }))
        });
        const onChange = () => {
            const [softening] = this._skin.material.uniforms.var_skin_softening_strength.value();
            const [, , , a] = this._skin.material.uniforms.var_skin_color.value();
            const isSkinColored = a > 0;
            const isSkinSoftened = softening > 0;
            this._skin.visible(isSkinColored);
            this._softening.visible(!isSkinColored && isSkinSoftened);
            if (isSkinColored)
                this._skin.material.uniforms.tex_mask.enable();
            else
                this._skin.material.uniforms.tex_mask.disable();
        };
        this._skin.material.uniforms.var_skin_color.subscribe(onChange);
        this._skin.material.uniforms.var_skin_softening_strength.subscribe(onChange);
        modules_scene_index.add(this._skin, this._softening);
    }
    color(color) {
        if (typeof color !== "undefined")
            this._skin.material.uniforms.var_skin_color.value(color);
        return this._skin.material.uniforms.var_skin_color.value().join(" ");
    }
    softening(strength) {
        if (typeof strength !== "undefined")
            this._skin.material.uniforms.var_skin_softening_strength.value(strength);
        return this._skin.material.uniforms.var_skin_softening_strength.value()[0];
    }
    clear() {
        this.color("0 0 0 0");
        this.softening(0);
    }
}

exports.Skin = Skin;
