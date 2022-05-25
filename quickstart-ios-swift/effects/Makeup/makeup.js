'use strict';

require('bnb_js/global');
require('./modules/scene/index.js');
const modules_faceMorph_index = require('./modules/face-morph/index.js');
const modules_hair_index = require('./modules/hair/index.js');
const modules_brows_index = require('./modules/brows/index.js');
const modules_eyeBags_index = require('./modules/eye-bags/index.js');
const modules_eyelashes_index = require('./modules/eyelashes/index.js');
const modules_eyes_index = require('./modules/eyes/index.js');
const modules_lips_index = require('./modules/lips/index.js');
const modules_lutFilter_index = require('./modules/lut-filter/index.js');
const modules_makeup_index = require('./modules/makeup/index.js');
const modules_skin_index = require('./modules/skin/index.js');
const modules_softlight_index = require('./modules/softlight/index.js');
const modules_teeth_index = require('./modules/teeth/index.js');
const background = require('bnb_js/background');

function _interopDefaultLegacy (e) { return e && typeof e === 'object' && 'default' in e ? e : { 'default': e }; }

const background__default = /*#__PURE__*/_interopDefaultLegacy(background);

bnb.log(`\n\nMakeup API version: ${"1.4.0-5e706b97549d1886bb2dd56c0c17945d49cd5d99"}\n`);
const Skin = new modules_skin_index.Skin();
const Eyes = new modules_eyes_index.Eyes();
const Teeth = new modules_teeth_index.Teeth();
const Lips = new modules_lips_index.Lips();
const Makeup = new modules_makeup_index.Makeup();
const Eyelashes = new modules_eyelashes_index.Eyelashes();
const Brows = new modules_brows_index.Brows();
const Softlight = new modules_softlight_index.Softlight();
const Hair = new modules_hair_index.Hair();
const Filter = new modules_lutFilter_index.LutFilter();
const FaceMorph = new modules_faceMorph_index.FaceMorph();
const EyeBagsRemoval = new modules_eyeBags_index.EyeBagsRemoval();

const m = /*#__PURE__*/Object.freeze({
	__proto__: null,
	Background: background__default['default'],
	Skin: Skin,
	Eyes: Eyes,
	Teeth: Teeth,
	Lips: Lips,
	Makeup: Makeup,
	Eyelashes: Eyelashes,
	Brows: Brows,
	Softlight: Softlight,
	Hair: Hair,
	Filter: Filter,
	FaceMorph: FaceMorph,
	EyeBagsRemoval: EyeBagsRemoval
});

exports.m = m;
