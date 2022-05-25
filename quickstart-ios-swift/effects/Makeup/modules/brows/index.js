'use strict';

require('bnb_js/global');
const modules_scene_index = require('../scene/index.js');

const LBrowVertexShader = "modules/brows/lbrow.vert";

const LBrowFragmentShader = "modules/brows/lbrow.frag";

const RBrowVertexShader = "modules/brows/rbrow.vert";

const RBrowFragmentShader = "modules/brows/rbrow.frag";

const QuadMesh = "modules/brows/quad.bsm2";

class Brows {
    constructor() {
        Object.defineProperty(this, "_brows_color", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: new modules_scene_index.Vector4(0, 0, 0, 0)
        });
        Object.defineProperty(this, "_brows", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: new modules_scene_index.Mesh(new modules_scene_index.Geometry(QuadMesh), [
                new modules_scene_index.ShaderMaterial({
                    vertexShader: LBrowVertexShader,
                    fragmentShader: LBrowFragmentShader,
                    uniforms: {
                        tex_camera: new modules_scene_index.Camera(),
                        tex_mask: new modules_scene_index.SegmentationMask("L_BROW"),
                        var_brows_color: this._brows_color,
                    },
                    state: { backFaces: true },
                }),
                new modules_scene_index.ShaderMaterial({
                    vertexShader: RBrowVertexShader,
                    fragmentShader: RBrowFragmentShader,
                    uniforms: {
                        tex_camera: new modules_scene_index.Camera(),
                        tex_mask: new modules_scene_index.SegmentationMask("R_BROW"),
                        var_brows_color: this._brows_color,
                    },
                    state: { backFaces: true },
                }),
            ])
        });
        this._brows_color.subscribe(([, , , a]) => {
            const areBrowsVisible = a > 0;
            if (areBrowsVisible) {
                this._brows.material[0].uniforms.tex_mask.enable();
                this._brows.material[1].uniforms.tex_mask.enable();
            }
            else {
                this._brows.material[0].uniforms.tex_mask.disable();
                this._brows.material[1].uniforms.tex_mask.disable();
            }
            this._brows.visible(areBrowsVisible);
            if (areBrowsVisible)
                modules_scene_index.enable("BROWS_CORRECTION", this);
            else
                modules_scene_index.disable("BROWS_CORRECTION", this);
        });
        modules_scene_index.add(this._brows);
    }
    color(color) {
        if (typeof color !== "undefined") {
            this._brows_color.value(color);
        }
        return this._brows_color.value().join(" ");
    }
    clear() {
        this.color("0 0 0 0");
    }
}

exports.Brows = Brows;
