'use strict';

require('bnb_js/global');
const modules_scene_index = require('../scene/index.js');

const vertexShader = "modules/lut-filter/lut_filter.vert";

const fragmentShader = "modules/lut-filter/lut_filter.frag";

class LutFilter {
    constructor() {
        Object.defineProperty(this, "_filter", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: new modules_scene_index.Mesh(new modules_scene_index.PlaneGeometry(), new modules_scene_index.ShaderMaterial({
                vertexShader,
                fragmentShader,
                uniforms: {
                    tex_camera: new modules_scene_index.Scene(),
                    tex_filter: new modules_scene_index.LUT(),
                    var_lut_filter_strength: new modules_scene_index.Vector4(1),
                },
            }))
        });
        this._filter.material.uniforms.var_lut_filter_strength.subscribe(([strength]) => {
            const hasLut = Boolean(this._filter.material.uniforms.tex_filter.filename);
            const hasStrength = strength > 0;
            const isVisible = hasLut && hasStrength;
            this._filter.visible(isVisible);
        });
        modules_scene_index.add(this._filter);
    }
    /** Sets the filter LUT */
    set(filename) {
        this._filter.material.uniforms.tex_filter.load(filename);
        this.strength(this.strength());
    }
    /** Sets the filter strength from 0 to 1 */
    strength(strength) {
        if (typeof strength !== "undefined")
            this._filter.material.uniforms.var_lut_filter_strength.value(strength);
        return this._filter.material.uniforms.var_lut_filter_strength.value()[0];
    }
    /** Resets any settings applied */
    clear() {
        this.set("");
        this.strength(1);
    }
}

exports.LutFilter = LutFilter;
