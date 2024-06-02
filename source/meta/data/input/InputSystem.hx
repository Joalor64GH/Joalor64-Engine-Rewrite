package meta.data.input;

import haxe.macro.Type.AbstractType;
import objects.userinterface.note.*;

class InputSystem {
    public var holdArray:Array<Bool> = [];
    public var pressArray:Array<Bool> = [];
    public var releaseArray:Array<Bool> = [];

    public function new() {}

    public function goodNoteHit(note) {
        Reflect.field(PlayState.instance, "goodNoteHit")(note);
    }

    public function noteMissPress(key) {
        Reflect.field(PlayState.instance, "noteMissPress")(key);
    }

    public function callOnScripts(script, args) {
        Reflect.field(PlayState.instance, "callOnScripts")(script,args);
    }

    public function noteMissed(note:Note) {}
    public function updateNote(note:Note, elapsed:Float) {}

    public function keyPressed(key:Int) {}
    public function keysCheck():Void {}
} 