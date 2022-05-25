'use strict';

require('bnb_js/global');
require('bnb_js/console');

const castArray = (value) => (Array.isArray(value) ? value : [value]);
const id = (prefix = "") => {
    var _a;
    const idx = (_a = id.prefixes.get(prefix)) !== null && _a !== void 0 ? _a : 0;
    id.prefixes.set(prefix, idx + 1);
    return `${prefix}${idx}`;
};
id.prefixes = new Map();
function createNanoEvents() {
    return {
        events: {},
        emit(event, ...args) {
            var _a;
            (_a = (this.events[event] || [])) === null || _a === void 0 ? void 0 : _a.forEach((i) => i(...args));
        },
        on(event, cb) {
            var _a;
            (_a = (this.events[event] = this.events[event] || [])) === null || _a === void 0 ? void 0 : _a.push(cb);
            return () => { var _a; return (this.events[event] = (_a = (this.events[event] || [])) === null || _a === void 0 ? void 0 : _a.filter((i) => i !== cb)); };
        },
    };
}

class Attribute {
    constructor(value) {
        Object.defineProperty(this, "_emitter", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: createNanoEvents()
        });
        Object.defineProperty(this, "_value", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: void 0
        });
        this._value = value;
    }
    value(value) {
        if (typeof value !== "undefined") {
            this._value = value;
            this._emitter.emit("value", this._value);
        }
        return this._value;
    }
    subscribe(listener) {
        const unsubscribe = this._emitter.on("value", listener);
        listener(this._value);
        return unsubscribe;
    }
}
class Vector4 extends Attribute {
    constructor(x = 0, y = 0, z = 0, w = 1) {
        super([x, y, z, w]);
    }
    value(x, y = 0, z = 0, w = 1) {
        if (typeof x === "undefined")
            return super.value();
        if (typeof x === "string")
            return this.value(...x.split(" ").map((x) => Number(x)));
        return super.value([Number(x), Number(y), Number(z), Number(w)]);
    }
    at(index, value) {
        const components = super.value();
        if (typeof value !== "undefined") {
            components[index] = Number(value);
            super.value(components);
        }
        return components[index];
    }
    x(value) {
        return this.at(0, value);
    }
    y(value) {
        return this.at(1, value);
    }
    z(value) {
        return this.at(2, value);
    }
    w(value) {
        return this.at(3, value);
    }
}

const assets$4 = bnb.scene.getAssetManager();
const createMesh = (filename, name) => {
    /**
     * Backward compatibility with SDK versions < v1.4.0
     * which have a single `AssetManager.createMesh` method
     * instead of `AssetManager.createDynamicMesh` and `AssetManager.createStaticMesh` methods
     */
    const factory = assets$4;
    let mesh = null;
    if (!mesh && factory.createDynamicMesh)
        mesh = factory.createDynamicMesh(name, filename);
    if (!mesh && factory.createStaticMesh)
        mesh = factory.createStaticMesh(name);
    if (!mesh && factory.createMesh)
        mesh = factory.createMesh(name);
    if (!mesh)
        throw new Error(`Unable to create mesh "${name}" from ${filename}`);
    factory.uploadMeshData(mesh, filename);
    return mesh;
};
class Geometry {
    constructor(filename, name) {
        Object.defineProperty(this, "$$", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: void 0
        });
        name !== null && name !== void 0 ? name : (name = id("_scene_mesh"));
        this.$$ = assets$4.findMesh(name) || createMesh(filename, name);
    }
}
class PlaneGeometry extends Geometry {
    constructor() {
        super("$builtin$meshes/fs_tri", id("_scene_plane"));
    }
}
class QuadGeometry extends Geometry {
    constructor() {
        super("$builtin$meshes/quad", id("_scene_quad"));
    }
}
class FaceGeometry extends Geometry {
    constructor(index = 0) {
        super(`$builtin$meshes/face.stream:${index}`, `_scene_face${index}`);
        Object.defineProperty(this, "index", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: void 0
        });
        Object.defineProperty(this, "morphings", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: []
        });
        this.index = index;
    }
    addMorphing(filename) {
        const morphing = filename === "$builtin$meshes/beauty" ? new BeautyMorphing() : new FaceMorphing(filename);
        this.morphings.push(morphing);
        return morphing;
    }
}
class BeautyMorphing {
    constructor() {
        Object.defineProperty(this, "_emitter", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: createNanoEvents()
        });
        Object.defineProperty(this, "_weights", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: {
                eyes: 0,
                nose: 0,
                face: 0,
            }
        });
        Object.defineProperty(this, "$$", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: void 0
        });
        const name = id("_scene_beauty_morphing");
        this.$$ = assets$4.findMesh(name) || createMesh("$builtin$meshes/beauty", name);
    }
    weight(type, value) {
        if (typeof value !== "undefined") {
            this._weights[type] = value;
            this._emitter.emit("weight", this._weights);
        }
        return this._weights[type];
    }
    subscribe(listener) {
        const unsubscribe = this._emitter.on("weight", listener);
        listener(this._weights);
        return unsubscribe;
    }
}
class FaceMorphing {
    constructor(filename) {
        Object.defineProperty(this, "_emitter", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: createNanoEvents()
        });
        Object.defineProperty(this, "_weight", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: 0
        });
        Object.defineProperty(this, "$$", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: void 0
        });
        const name = filename === "$builtin$meshes/lips_morph"
            ? id("_scene_lips_morphing")
            : id("_scene_face_morphing");
        this.$$ = assets$4.findMesh(name) || createMesh(filename, name);
    }
    weight(value) {
        if (typeof value !== "undefined") {
            this._weight = value;
            this._emitter.emit("weight", this._weight);
        }
        return this._weight;
    }
    subscribe(listener) {
        const unsubscribe = this._emitter.on("weight", listener);
        listener(this._weight);
        return unsubscribe;
    }
}
const isGeometry = (obj) => obj instanceof PlaneGeometry || obj instanceof QuadGeometry || obj instanceof FaceGeometry;

const assets$3 = bnb.scene.getAssetManager();
class ShaderMaterial {
    constructor({ vertexShader, fragmentShader, builtIns = [], uniforms = {}, state = {}, }) {
        var _a, _b, _c, _d, _e, _f;
        Object.defineProperty(this, "$$", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: void 0
        });
        Object.defineProperty(this, "uniforms", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: void 0
        });
        const isBuiltin = vertexShader.startsWith("$builtin$materials/");
        if (!isBuiltin) {
            if (!vertexShader.endsWith(".vert"))
                throw new Error(`Vertex shader file must ends with ".vert". Received: "${vertexShader}"`);
            if (!fragmentShader.endsWith(".frag"))
                throw new Error(`Fragment shader file must ends with ".frag". Received: "${fragmentShader}"`);
        }
        const vs = vertexShader.replace(/\.vert$/, "");
        const fs = fragmentShader.replace(/\.frag$/, "");
        if (vs !== fs)
            throw new Error(`Vertex shader name should match fragment shader name. Received: "${vertexShader}", "${fragmentShader}"`);
        const name = isBuiltin ? vs : id(`${vs}.`);
        const material = (_a = assets$3.findMaterial(name)) !== null && _a !== void 0 ? _a : assets$3.createMaterial(name, vs);
        material.setState(new bnb.State(bnb.BlendingMode[(_b = state.blending) !== null && _b !== void 0 ? _b : "ALPHA"], (_c = state.zWrite) !== null && _c !== void 0 ? _c : false, (_d = state.zTest) !== null && _d !== void 0 ? _d : false, (_e = state.colorWrite) !== null && _e !== void 0 ? _e : true, (_f = state.backFaces) !== null && _f !== void 0 ? _f : false));
        for (let name in uniforms) {
            const uniform = uniforms[name];
            if (uniform instanceof Attribute) {
                if (!(uniform instanceof Vector4))
                    throw new Error(`Unsupported attribute type: "${typeof uniform}"`);
                const vec4 = uniform;
                if (ShaderMaterial.parameters.has(name)) {
                    console.warn(`The parameter name "${name}" is already in use.`, `This might produce undesired behavior, consider using another name.`);
                    const parameter = ShaderMaterial.parameters.get(name);
                    vec4.subscribe((value) => parameter.setVector4(new bnb.Vec4(...value)));
                    continue;
                }
                let parameter = material.findParameter(name);
                if (parameter) {
                    const { x, y, z, w } = parameter.getVector4();
                    vec4.value(x, y, z, w);
                }
                else {
                    parameter = bnb.Parameter.create(name);
                    material.addParameter(parameter);
                }
                vec4.subscribe((value) => parameter.setVector4(new bnb.Vec4(...value)));
                ShaderMaterial.parameters.set(name, parameter);
            }
            else {
                material.addImage(name, uniform.$$);
            }
        }
        for (const builtIn of builtIns)
            material.addImage(builtIn, null);
        this.$$ = material;
        this.uniforms = uniforms;
    }
}
Object.defineProperty(ShaderMaterial, "parameters", {
    enumerable: true,
    configurable: true,
    writable: true,
    value: new Map()
});
class BlitMaterial extends ShaderMaterial {
    constructor(texture, state) {
        const shader = id("$builtin$materials/copy_pixels.99"); // FIXME: `9999` - fixes name collision only for a while
        super({
            vertexShader: shader,
            fragmentShader: shader,
            uniforms: { tex_src: texture },
            state,
        });
    }
}

class Mesh {
    constructor(geometry, material) {
        Object.defineProperty(this, "_parent", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: null
        });
        Object.defineProperty(this, "_visible", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: true
        });
        Object.defineProperty(this, "_emitter", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: createNanoEvents()
        });
        Object.defineProperty(this, "geometry", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: void 0
        });
        Object.defineProperty(this, "material", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: void 0
        });
        this.geometry = geometry;
        this.material = material;
    }
    add(...children) {
        for (const child of children)
            child._parent = this;
    }
    visible(value) {
        if (typeof value !== "undefined") {
            this._visible = value;
            this._emitter.emit("visible", this._visible);
        }
        return this._visible;
    }
    onVisibilityChange(listener) {
        this._emitter.on("visible", listener);
    }
}
const isFaceMesh = (mesh) => (mesh === null || mesh === void 0 ? void 0 : mesh.geometry) instanceof FaceGeometry;
const getFace = (mesh) => {
    if (!mesh)
        return null;
    if (isFaceMesh(mesh))
        return mesh;
    return getFace(mesh["_parent"]);
};

const assets$2 = bnb.scene.getAssetManager();
class Attachment {
    constructor({ type, filtering, info = {}, } = {}) {
        Object.defineProperty(this, "$$", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: void 0
        });
        const name = id("_scene_attachment");
        const image = assets$2.findImage(name) || assets$2.createImage(name, bnb.ImageType.ATTACHMENT);
        const attachment = image.asAttachment();
        if (typeof type !== "undefined")
            attachment.setType(bnb.AttachmentType[type]);
        if (type === "DEPTH") {
            const _info = attachment.getInfo();
            _info.format = bnb.PixelFormatType.DEPTH24;
            attachment.setInfo(_info);
            attachment.setClearColor(new bnb.Vec3(1, 1, 1));
        }
        if (typeof filtering !== "undefined")
            attachment.setFilteringMode(bnb.TextureFilteringMode[filtering]);
        if (typeof info.load !== "undefined") {
            const _info = attachment.getInfo();
            _info.loadBehaviour = bnb.AttachmentLoadOp[info.load];
            attachment.setInfo(_info);
        }
        if (typeof info.store !== "undefined") {
            const _info = attachment.getInfo();
            _info.storedBehaviour = bnb.AttachmentStoreOp[info.store];
            attachment.setInfo(_info);
        }
        this.$$ = image;
    }
    get width() {
        return this.$$.asAttachment().getWidth();
    }
    get height() {
        return this.$$.asAttachment().getHeight();
    }
}
class RenderTarget {
    constructor({ target, width, height, scale, filtering, info, offscreen = false } = {}) {
        Object.defineProperty(this, "$$", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: void 0
        });
        if (!target) {
            const targetName = offscreen
                ? id("_scene_offscreen_render_target")
                : id("_scene_render_target");
            target = assets$2.findRenderTarget(targetName);
            if (!target) {
                target = assets$2.createRenderTarget(targetName);
                const color = new Attachment({ filtering, info });
                target.addAttachment(color.$$);
                const isDepthAttachmentSupported = typeof color.$$.asAttachment().setType !== "undefined";
                // Backward compatibility with SDK v1.2.1 that has no `Attachment.setType` binding
                if (isDepthAttachmentSupported) {
                    const depth = new Attachment({ type: "DEPTH" });
                    target.addAttachment(depth.$$);
                }
            }
        }
        if (typeof width !== "undefined" && typeof height !== "undefined")
            target.setExtent(width, height);
        if (typeof scale !== "undefined")
            target.setScale(scale);
        this.$$ = target;
    }
    get texture() {
        const [color] = this.$$.getAttachments();
        return { $$: color };
    }
    add(...meshes) {
        var _a, _b;
        const layerName = id("_scene_layer");
        let layer = bnb.scene.getLayer(layerName);
        if (!layer) {
            layer = bnb.Layer.create(layerName);
            const target = this.$$;
            const list = bnb.scene.getRenderList();
            const tasks = [];
            // copy the old tasks
            for (let i = 0, size = list.getTasksCount(); i < size; ++i) {
                tasks.push({
                    layer: list.getTaskLayer(i),
                    target: list.getTaskTarget(i),
                    subgeoms: list.getTaskSubGeometries(i),
                });
            }
            const idx = (() => {
                if (target.getName().includes("_offscreen_")) {
                    for (let i = 0; i < tasks.length; ++i) {
                        const task = tasks[i];
                        if (task.target.getName().includes("_offscreen_"))
                            continue;
                        else
                            return i;
                    }
                }
                return tasks.length;
            })();
            tasks.splice(idx, 0, { layer, target });
            // recreate render list
            list.clear();
            for (const task of tasks) {
                if ((_b = (_a = task.subgeoms) === null || _a === void 0 ? void 0 : _a.length) !== null && _b !== void 0 ? _b : 0 > 0)
                    list.addTask(task.layer, task.target, task.subgeoms);
                else
                    list.addTask(task.layer, task.target);
            }
        }
        for (const mesh of meshes) {
            const face = getFace(mesh);
            let root = face ? FaceTracker.for(face) : bnb.scene.getRoot();
            const entityName = id("_scene_entity");
            let entity = root.findChildByName(entityName);
            if (!entity) {
                entity = bnb.scene.createEntity(entityName);
                entity.addIntoLayer(layer);
                root.addChild(entity);
            }
            const component = entity.getComponent(bnb.ComponentType.MESH_INSTANCE);
            let instance = component && component.asMeshInstance();
            if (!instance) {
                instance = bnb.MeshInstance.create();
                instance.setMesh(mesh.geometry.$$);
                const materials = castArray(mesh.material);
                const subgeometries = instance.getMesh().getSubGeometries();
                for (let i = 0; i < materials.length; ++i) {
                    const material = materials[i];
                    const subgeometry = subgeometries[i];
                    if (!subgeometry)
                        break;
                    instance.setSubGeometryMaterial(subgeometry, material.$$);
                }
                instance.setVisible(mesh.visible());
                entity.addComponent(instance.asComponent());
            }
            mesh.onVisibilityChange((isVisible) => instance.setVisible(isVisible));
            if (isFaceMesh(mesh)) {
                for (const m of mesh.geometry.morphings) {
                    const layerName = id("_scene_face_morphings_layer");
                    let layer = bnb.scene.getLayer(layerName);
                    if (!layer) {
                        layer = bnb.Layer.create(layerName);
                        bnb.scene.getRenderList().addTask(layer, this.$$);
                    }
                    const morphName = m.$$.getName();
                    let morph = assets$2.findMorph(morphName);
                    if (!morph) {
                        let type = m instanceof BeautyMorphing ? bnb.MorphingType.BEAUTY : bnb.MorphingType.MESH;
                        if (morphName.startsWith("_scene_lips_morphing"))
                            type = bnb.MorphingType.LIPS;
                        morph = assets$2.createMorph(morphName, type);
                        morph.setWarpMesh(m.$$);
                    }
                    const entityName = `${morphName}_face${mesh.geometry.index}`;
                    let entity = root.findChildByName(entityName);
                    if (!entity) {
                        entity = bnb.scene.createEntity(entityName);
                        entity.addIntoLayer(layer);
                        root.addChild(entity);
                    }
                    const component = entity.getComponent(bnb.ComponentType.FACE_MORPHING);
                    let morphing = component && component.asFaceMorphing();
                    if (morphing) {
                        if (m instanceof BeautyMorphing) {
                            const beauty = morphing.asBeautyMorphing();
                            m.weight("eyes", beauty.getEyesWeight());
                            m.weight("nose", beauty.getNoseWeight());
                            m.weight("face", beauty.getFaceWeight());
                        }
                        else {
                            m.weight(morphing.getWeight());
                        }
                    }
                    else {
                        const type = m instanceof BeautyMorphing ? bnb.MorphingType.BEAUTY : bnb.MorphingType.MESH;
                        morphing = bnb.FaceMorphing.create(type);
                        morphing.setMorphing(morph);
                        morphing.setVisible(true);
                        entity.addComponent(morphing.asComponent());
                    }
                    if (m instanceof BeautyMorphing) {
                        const beauty = morphing.asBeautyMorphing();
                        m.subscribe((weights) => {
                            beauty.setEyesWeight(weights.eyes);
                            beauty.setNoseWeight(weights.nose);
                            beauty.setFaceWeight(weights.face);
                            morphing.setVisible(Object.values(weights).some((w) => w !== 0));
                        });
                    }
                    else {
                        m.subscribe((value) => {
                            morphing.setWeight(value);
                            morphing.setVisible(value !== 0);
                        });
                    }
                }
            }
        }
        return this;
    }
}
class FaceTracker {
    static for(mesh) {
        const root = bnb.scene.getRoot();
        const index = mesh.geometry.index;
        const entityName = `face_tracker${index}`;
        let entity = root.findChildByName(entityName);
        if (!entity) {
            entity = bnb.scene.createEntity(entityName);
            root.addChild(entity);
        }
        const component = entity.getComponent(bnb.ComponentType.FACE_TRACKER);
        let tracker = component && component.asFaceTracker();
        if (!tracker) {
            tracker = bnb.FaceTracker.create();
            const faceName = `face${index}`;
            let face = assets$2.findFace(faceName);
            if (!face) {
                face = assets$2.createFace(faceName);
                face.setFaceMesh(mesh.geometry.$$);
                face.setIndex(index);
            }
            tracker.setFace(face);
            entity.addComponent(tracker.asComponent());
        }
        return entity;
    }
}

class Pass {
    constructor(material, geometry, options) {
        Object.defineProperty(this, "_target", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: void 0
        });
        if (!isGeometry(geometry)) {
            options = geometry !== null && geometry !== void 0 ? geometry : {};
            geometry = new PlaneGeometry();
        }
        this._target = new RenderTarget({ offscreen: true, ...options });
        this._target.add(new Mesh(geometry, material));
    }
    get $$() {
        return this._target.texture.$$;
    }
}

const NullLut = "modules/scene/_null_lut_.png";

const NullImage = "modules/scene/_null_image_.png";

const assets$1 = bnb.scene.getAssetManager();
// built in
class Camera {
    constructor() {
        Object.defineProperty(this, "$$", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: void 0
        });
        const camera = assets$1.findImage("camera") ||
            assets$1.findImage("camera_color") || // compatibility with GLTF converter
            assets$1.findImage("ComposerRT_color"); // backward compatibility with old-converted effects
        if (!camera)
            throw new Error("Unable to find 'camera' image which is mandatory");
        this.$$ = camera;
    }
}
// custom
class LUT {
    constructor(filename, onLoad) {
        Object.defineProperty(this, "$$", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: void 0
        });
        Object.defineProperty(this, "filename", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: ""
        });
        const name = id("_scene_lut");
        let lut = assets$1.findImage(name);
        if (!lut) {
            lut = assets$1.createImage(name, bnb.ImageType.LUT);
            if (!filename)
                lut.asWeightedLut().load(NullLut);
        }
        this.$$ = lut;
        if (filename)
            this.load(filename, onLoad);
    }
    load(filename, onLoad) {
        this.filename = filename;
        this.$$.asWeightedLut().load(filename || NullLut);
        if (onLoad)
            onLoad();
        return this;
    }
}
class Image {
    constructor(filename, onLoad) {
        Object.defineProperty(this, "$$", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: void 0
        });
        Object.defineProperty(this, "filename", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: ""
        });
        const name = id("_scene_image");
        let image = assets$1.findImage(name);
        if (!image) {
            image = assets$1.createImage(name, bnb.ImageType.TEXTURE);
            if (!filename)
                image.asTexture().load(NullImage);
        }
        this.$$ = image;
        if (filename)
            this.load(filename, onLoad);
    }
    get width() {
        return this.$$.asTexture().getWidth();
    }
    get height() {
        return this.$$.asTexture().getHeight();
    }
    load(filename, onLoad) {
        this.filename = filename;
        this.$$.asTexture().load(filename || NullImage);
        if (onLoad)
            onLoad();
        return this;
    }
}
class SegmentationMask {
    constructor(type) {
        Object.defineProperty(this, "type", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: type
        });
        Object.defineProperty(this, "$$", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: void 0
        });
        const name = `_scene_seg_mask_${type}`;
        let mask = assets$1.findImage(name);
        // compatibility with converted legacy effects
        if (!mask) {
            const query = type === "L_EYE" ? "left_eye" : type === "R_EYE" ? "right_eye" : type;
            mask = assets$1.findImage(query.toLocaleLowerCase());
        }
        if (!mask) {
            mask = assets$1.createSegmentationMask(name, bnb.SegmentationMaskType[type]);
        }
        this.$$ = mask;
    }
    enable() {
        this.$$.asSegmentationMask().setActive(true);
    }
    disable() {
        this.$$.asSegmentationMask().setActive(false);
    }
}

const assets = bnb.scene.getAssetManager();
// compatibility with converted legacy effects
const target = assets.findRenderTarget("finalColorFilterRT") ||
    assets.findRenderTarget("EffectRT") ||
    assets.findRenderTarget("EffectRT0");
let screen = new RenderTarget({ target });
if (!target) {
    const CameraBackground = new Mesh(new PlaneGeometry(), new BlitMaterial(new Camera(), { blending: "OFF" }));
    screen.add(CameraBackground);
}
const add = (...meshes) => {
    for (const mesh of meshes) {
        screen.add(mesh);
    }
};
class Scene {
    constructor() {
        Object.defineProperty(this, "_target", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: void 0
        });
        this._target = screen;
        const scene = new Mesh(new PlaneGeometry(), new BlitMaterial(this._target.texture, { blending: "OFF" }));
        screen = new RenderTarget();
        screen.add(scene);
    }
    get $$() {
        return this._target.texture.$$;
    }
}

const refs = new Map();
const enable = (feature, consumer) => {
    if (!refs.has(feature))
        refs.set(feature, new Set());
    const consumers = refs.get(feature);
    if (consumers.has(consumer))
        return;
    if (consumer)
        consumers.add(consumer);
    bnb.scene.enableRecognizerFeature(bnb.FeatureID[feature]);
};
const disable = (feature, consumer) => {
    if (!refs.has(feature))
        return;
    const consumers = refs.get(feature);
    consumers.delete(consumer);
    if (consumers.size > 0)
        return;
    bnb.scene.disableRecognizerFeature(bnb.FeatureID[feature]);
};

exports.Camera = Camera;
exports.FaceGeometry = FaceGeometry;
exports.Geometry = Geometry;
exports.Image = Image;
exports.LUT = LUT;
exports.Mesh = Mesh;
exports.Pass = Pass;
exports.PlaneGeometry = PlaneGeometry;
exports.QuadGeometry = QuadGeometry;
exports.Scene = Scene;
exports.SegmentationMask = SegmentationMask;
exports.ShaderMaterial = ShaderMaterial;
exports.Vector4 = Vector4;
exports.add = add;
exports.disable = disable;
exports.enable = enable;
