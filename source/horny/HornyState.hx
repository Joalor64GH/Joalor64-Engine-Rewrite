package horny;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxState;
import horny.*;

class HornyState extends FlxState {
    public var script:HornyScript;

    public override function new(path:String, args:Array<Any>) {
        super();
        script = new HornyScript(path);
        script.setVariable("add", function(obj:FlxBasic) {add(obj);});
        script.setVariable("remove", function(obj:FlxBasic) {remove(obj);});
        script.setVariable("insert", function(i:Int, obj:FlxBasic) {insert(i, obj);});
        script.setVariable("state", this);
        script.run();
        script.executeFunc("new", args);
    }

    public override function onFocus() {
        script.executeFunc("onFocus");
        super.onFocus();
    }

    public override function onFocusLost() {
        script.executeFunc("onFocusLost");
        super.onFocusLost();
    }

    public override function onResize(width:Int, height:Int) {
        script.executeFunc("onResize", [width, height]);
        super.onResize(width, height);
    }

    public override function draw() {
        script.executeFunc("draw");
        super.draw();
        script.executeFunc("drawPost");
    }

    public override function create() {
        super.create();
        script.executeFunc("create");
    }

    public override function update(elapsed:Float) {
        script.executeFunc("update", [elapsed]);
        super.update(elapsed);
        script.executeFunc("updatePost", [elapsed]);
    }

    public override function destroy() {
        script.executeFunc("destroy");
        super.destroy();
    }
}