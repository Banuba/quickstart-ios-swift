'use strict';

require('bnb_js/global');
const modules_scene_index = require('../scene/index.js');

const GlitterTexture = "modules/lips/glitter.png";

const mattVertexShader = "modules/lips/matt.vert";

const mattFragmentShader = "modules/lips/matt.frag";

const shinyVertexShader = "modules/lips/shiny.vert";

const shinyFragmentShader = "modules/lips/shiny.frag";

class Lips {
    constructor() {
        Object.defineProperty(this, "_shared", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: {
                tex_camera: new modules_scene_index.Camera(),
                tex_lips_mask: new modules_scene_index.SegmentationMask("LIPS"),
                tex_shine_mask: new modules_scene_index.SegmentationMask("LIPS_SHINING"),
                var_lips_color: new modules_scene_index.Vector4(0, 0, 0, 0),
                var_lips_saturation_brightness: new modules_scene_index.Vector4(1, 1),
            }
        });
        Object.defineProperty(this, "_matt", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: new modules_scene_index.Mesh(new modules_scene_index.QuadGeometry(), new modules_scene_index.ShaderMaterial({
                vertexShader: mattVertexShader,
                fragmentShader: mattFragmentShader,
                uniforms: {
                    tex_camera: this._shared.tex_camera,
                    tex_lips_mask: this._shared.tex_lips_mask,
                    var_lips_color: this._shared.var_lips_color,
                    var_lips_saturation_brightness: this._shared.var_lips_saturation_brightness,
                },
                state: {
                    backFaces: true,
                },
            }))
        });
        Object.defineProperty(this, "_shiny", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: new modules_scene_index.Mesh(new modules_scene_index.QuadGeometry(), new modules_scene_index.ShaderMaterial({
                vertexShader: shinyVertexShader,
                fragmentShader: shinyFragmentShader,
                uniforms: {
                    tex_camera: this._shared.tex_camera,
                    tex_lips_mask: this._shared.tex_lips_mask,
                    tex_shine_mask: this._shared.tex_shine_mask,
                    tex_noise: new modules_scene_index.Image(GlitterTexture),
                    var_lips_color: this._shared.var_lips_color,
                    var_lips_saturation_brightness: this._shared.var_lips_saturation_brightness,
                    var_lips_shine_intensity_bleeding_scale: new modules_scene_index.Vector4(0, 0, 0),
                    var_lips_glitter_bleeding_intensity_grain: new modules_scene_index.Vector4(0, 0, 0),
                },
                state: {
                    backFaces: true,
                },
            }))
        });
        const onChange = () => {
            const [, , , a] = this._shared.var_lips_color.value();
            const shine = this._shiny.material.uniforms.var_lips_shine_intensity_bleeding_scale.value();
            const glitter = this._shiny.material.uniforms.var_lips_glitter_bleeding_intensity_grain.value();
            const isColored = a > 0;
            if (!isColored) {
                this._matt.visible(false);
                this._shiny.visible(false);
                this._matt.material.uniforms.tex_lips_mask.disable();
                this._shiny.material.uniforms.tex_shine_mask.disable();
                return;
            }
            this._matt.material.uniforms.tex_lips_mask.enable();
            const isShineEnabled = shine[0] !== 0 || shine[1] !== 0 || shine[2] !== 0;
            const isGlitterEnabled = glitter[0] !== 0 || glitter[1] !== 0 || glitter[2] !== 0;
            if (isShineEnabled || isGlitterEnabled) {
                this._matt.visible(false);
                this._shiny.material.uniforms.tex_shine_mask.enable();
                this._shiny.visible(true);
            }
            else {
                this._shiny.visible(false);
                this._shiny.material.uniforms.tex_shine_mask.disable();
                this._matt.visible(true);
            }
        };
        this._shared.var_lips_color.subscribe(onChange);
        this._shiny.material.uniforms.var_lips_shine_intensity_bleeding_scale.subscribe(onChange);
        this._shiny.material.uniforms.var_lips_glitter_bleeding_intensity_grain.subscribe(onChange);
        modules_scene_index.add(this._matt, this._shiny);
    }
    /**
     * Sets matt lips color
     * This is a helper method and equivalent of
     * ```js
     * Lips
     *  .color(rgba)
     *  .saturation(1)
     *  .shineIntensity(0)
     *  .shineBleeding(0)
     *  .shineScale(0)
     *  .glitterIntensity(0)
     *  .glitterBleeding(0)
     * ```
     */
    matt(color) {
        if (typeof color !== "undefined") {
            this.color(color);
            this._matt.material.uniforms.var_lips_saturation_brightness.value(1, 1);
            this._shiny.material.uniforms.var_lips_shine_intensity_bleeding_scale.value(0, 0, 0);
            this._shiny.material.uniforms.var_lips_glitter_bleeding_intensity_grain.value(0, 0);
        }
        return this.color();
    }
    /**
     * Sets shiny lips color
     * This is a helper method and equivalent of
     * ```js
     * Lips
     *  .color(rgba)
     *  .saturation(1.5)
     *  .shineIntensity(1)
     *  .shineBleeding(0.5)
     *  .shineScale(1)
     *  .glitterIntensity(0)
     *  .glitterBleeding(0)
     * ```
     */
    shiny(color) {
        if (typeof color !== "undefined") {
            this.color(color);
            this._matt.material.uniforms.var_lips_saturation_brightness.value(1.5, 1);
            this._shiny.material.uniforms.var_lips_shine_intensity_bleeding_scale.value(1, 0.5, 1);
            this._shiny.material.uniforms.var_lips_glitter_bleeding_intensity_grain.value(0, 0);
        }
        return this.color();
    }
    /**
     * Sets glitter lips color
     * This is a helper method and equivalent of
     * ```js
     * Lips
     *  .color(rgba)
     *  .saturation(1)
     *  .shineIntensity(0.9)
     *  .shineBleeding(0.6)
     *  .shineScale(1)
     *  .glitterGrain(0.4)
     *  .glitterIntensity(1)
     *  .glitterBleeding(1)
     * ```
     */
    glitter(color) {
        if (typeof color !== "undefined") {
            this.color(color);
            this._matt.material.uniforms.var_lips_saturation_brightness.value(1, 1);
            this._shiny.material.uniforms.var_lips_shine_intensity_bleeding_scale.value(0.9, 0.6, 1);
            this._shiny.material.uniforms.var_lips_glitter_bleeding_intensity_grain.value(1, 1, 0.4);
        }
        return this.color();
    }
    /** Sets the lips color */
    color(color) {
        if (typeof color !== "undefined") {
            this._shared.var_lips_color.value(color);
        }
        return this._shared.var_lips_color.value().join(" ");
    }
    /** Sets the lips color saturation */
    saturation(value) {
        this._shared.var_lips_saturation_brightness.x(value);
    }
    /** Sets the lips color brightness */
    brightness(value) {
        this._shared.var_lips_saturation_brightness.y(value);
    }
    /** Sets the lips shine intensity */
    shineIntensity(value) {
        this._shiny.material.uniforms.var_lips_shine_intensity_bleeding_scale.x(value);
    }
    /** Sets the lips shine bleeding */
    shineBleeding(value) {
        this._shiny.material.uniforms.var_lips_shine_intensity_bleeding_scale.y(value);
    }
    shineScale(value) {
        this._shiny.material.uniforms.var_lips_shine_intensity_bleeding_scale.z(value);
    }
    glitterGrain(value) {
        this._shiny.material.uniforms.var_lips_glitter_bleeding_intensity_grain.z(value);
    }
    glitterIntensity(value) {
        this._shiny.material.uniforms.var_lips_glitter_bleeding_intensity_grain.y(value);
    }
    glitterBleeding(value) {
        this._shiny.material.uniforms.var_lips_glitter_bleeding_intensity_grain.x(value);
    }
    /** Removes the lips color, resets any setting applied */
    clear() {
        this.color("0 0 0 0");
        this._matt.material.uniforms.var_lips_saturation_brightness.value(1, 1);
        this._shiny.material.uniforms.var_lips_shine_intensity_bleeding_scale.value(0, 0, 0);
        this._shiny.material.uniforms.var_lips_glitter_bleeding_intensity_grain.value(0, 0, 0);
    }
}

exports.Lips = Lips;
