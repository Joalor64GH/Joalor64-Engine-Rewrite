// How to use the cool new HScript system

/* IMPORT CLASS */

// how to import classes
import('package.Class');

/* CLASSES */

// current instance of HClass
var class:HClass = new HClass("path/to/hscript/file.hx", [arguments, or, functions]);

// runs when creating HClass
function new(/*add arguments here, if needed*/) {}

// runs after the new function is completed
function create(/*add arguments here, if needed*/) {}

/* OBJECT */

// IMPORTANT: HObject is just a child class of flixel.FlxSprite.
// That means you can do the same things with FlxSprite with HObject.

// current instance of HObject
var object:HObject = new HObject(x, y, "path/to/hscript/file.hx");

// runs when creating HObject
function new(x, y) {}

// runs after the new function is completed
function create(x, y) {}

// runs during each frame
function update(elapsed) {}

// same as update, but this runs after update and super
function updatePost(elapsed) {}

// sets offsets of an animation for an object
setOffset(animName, x, y);

// applys offsets to current animation
updateOffset();

// destroys object
function destroy() {}

// return "true" to call super, or return "false" to not call super
function draw() {}

function getGraphicMidpoint(?point:FlxPoint) {}

function getRotatedBounds(?newRect:FlxRect) {}

function getScreenBounds(?newRect:FlxRect, ?camera:FlxCamera) {}

function pixelsOverlapPoint(point:FlxPoint, Mask:Int = 0xFF, ?Camera:FlxCamera) {}

function loadGraphic(graphic:FlxGraphicAsset, animated:Bool = false, width:Int = 0, height:Int = 0, unique:Bool = false, ?Key:String) {}

function getScreenBounds(?newRect:FlxRect, ?camera:FlxCamera) {}

/* HSCRIPT */

// current instance of script
var script:HScript = new HScript("path/to/hscript/file.hx");

// parses your script
function run() {}

// sets a variable
function setVariable(name:String, val:Dynamic) {}

// returns a variable
function getVariable(name:String) {}

// executes a function
function executeFunc(funcName:String, ?args:Array<Any>) {}

/* SCRIPTED STATE */

// IMPORTANT: HState is just a child class of flixel.FlxState.
// That means you can do the same things with FlxState with HState.

// current instance of HState
var state:HState = new HState("path/to/hscript/file.hx", [arguements, or, functions]);

// adds an object to layer "i"
function insert(i:Int, obj:FlxBasic) {}

// destroys object
function destroy() {}

// runs when creating HState
function new(/*add arguments here, if needed*/) {}

// runs after the new function is completed
function create(/*add arguments here, if needed*/) {}

// runs during each frame
function update(elapsed) {}

// same as update, but this runs after update and super
function updatePost(elapsed) {}

// these don't need any explanation
function add(obj:FlxBasic) {}

function remove(obj:FlxBasic) {}

function onFocus() {}

function onFocusLost() {}

function onResize(width:Int, height:Int) {}

function draw() {}

/* SCRIPTED SUBSTATE */

// IMPORTANT: This is literally the same as HState, but it's a child class of flixel.FlxSubState.
// Also, "state" is unavailable in HSubState.

// current instance of HSubState
var substate:HSubState = new HSubState("path/to/hscript/file.hx", [arguements, or, functions]);

// closes substate
function close() {}
