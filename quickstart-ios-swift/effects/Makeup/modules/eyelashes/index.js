'use strict';

require('bnb_js/global');
const modules_scene_index = require('../scene/index.js');

const EyelashesMesh = "modules/eyelashes/eyelashes.bsm2";

const EyeLashesFragmentShader = "modules/eyelashes/eyelashes.frag";

const DefaultEyelashesTexture = "modules/eyelashes/eyelashes.ktx";

const EyeLashesVertexShader = "modules/eyelashes/eyelashes.vert";

class Eyelashes {
    constructor() {
        Object.defineProperty(this, "_face", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: new modules_scene_index.Mesh(new modules_scene_index.FaceGeometry(), [])
        });
        Object.defineProperty(this, "_lashes", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: new modules_scene_index.Mesh(new modules_scene_index.Geometry(EyelashesMesh), new modules_scene_index.ShaderMaterial({
                vertexShader: EyeLashesVertexShader,
                fragmentShader: EyeLashesFragmentShader,
                uniforms: {
                    tex_diffuse: new modules_scene_index.Image(DefaultEyelashesTexture),
                    var_eyelashes_color: new modules_scene_index.Vector4(0, 0, 0, 0),
                },
                builtIns: ["bnb_BONES", "bnb_MORPH"],
                state: {
                    backFaces: true,
                    zWrite: true,
                },
            }))
        });
        const onChange = () => {
            const [, , , a] = this._lashes.material.uniforms.var_eyelashes_color.value();
            const isCorrectionNeeded = this._lashes.visible(a > 0);
            if (isCorrectionNeeded)
                modules_scene_index.enable("EYES_CORRECTION", this);
            else
                modules_scene_index.disable("EYES_CORRECTION", this);
        };
        this._lashes.material.uniforms.var_eyelashes_color.subscribe(onChange);
        this._face.add(this._lashes);
        modules_scene_index.add(this._face, this._lashes);
    }
    color(color) {
        if (typeof color !== "undefined") {
            if (!this._lashes.material.uniforms.tex_diffuse.filename) {
                this._lashes.material.uniforms.tex_diffuse.load(DefaultEyelashesTexture);
            }
            this._lashes.material.uniforms.var_eyelashes_color.value(color);
        }
        return this._lashes.material.uniforms.var_eyelashes_color.value().join(" ");
    }
    texture(filename) {
        this._lashes.material.uniforms.tex_diffuse.load(filename);
    }
    clear() {
        this.color("0 0 0 0");
    }
}

exports.Eyelashes = Eyelashes;
