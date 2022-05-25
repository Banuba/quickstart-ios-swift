'use strict';

require('bnb_js/console');
require('bnb_js/global');
const modules_scene_index = require('../scene/index.js');

const isLipsMorphingSupported = typeof bnb.MorphingType.LIPS !== "undefined";
class FaceMorph {
    constructor() {
        Object.defineProperty(this, "_face", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: new modules_scene_index.Mesh(new modules_scene_index.FaceGeometry(), [])
        });
        Object.defineProperty(this, "_beauty", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: this._face.geometry.addMorphing("$builtin$meshes/beauty")
        });
        Object.defineProperty(this, "_lips", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: isLipsMorphingSupported
                ? this._face.geometry.addMorphing("$builtin$meshes/lips_morph")
                : null
        });
        modules_scene_index.add(this._face);
    }
    /** Sets eyes grow strength from 0 to 1 */
    eyes(weight) {
        return this._beauty.weight("eyes", 2 * weight);
    }
    /** Sets nose shrink strength from 0 to 1 */
    nose(weight) {
        return this._beauty.weight("nose", weight);
    }
    /** Sets face (cheeks) shrink strength from 0 to 1 */
    face(weight) {
        return this._beauty.weight("face", weight);
    }
    lips(weight) {
        return this._lips
            ? this._lips.weight(weight)
            : console.warn("The FaceMorph.lips() is not available on the current SDK version. Please update to SDK 1.3.0 or higher.");
    }
    /** Resets all morphs */
    clear() {
        this.eyes(0);
        this.nose(0);
        this.face(0);
        this.lips(0);
    }
}

exports.FaceMorph = FaceMorph;
