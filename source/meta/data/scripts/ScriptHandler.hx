package meta.data.scripts;

import flixel.*;
import flixel.math.*;
import flixel.system.*;
import flixel.tweens.*;
import flixel.util.*;

class ScriptHandler extends SScript
{
    public function new(file:String, ?preset:Bool = true)
    {
        super(file, preset);
    }

    override public function preset():Void
    {
        super.preset();

	interp.variables.set('FlxG', FlxG);
	interp.variables.set('FlxBasic', FlxBasic);
	interp.variables.set('FlxObject', FlxObject);
	interp.variables.set('FlxCamera', FlxCamera);
	interp.variables.set('FlxSprite', FlxSprite);
	interp.variables.set('FlxTimer', FlxTimer);
	interp.variables.set('FlxTween', FlxTween);
	interp.variables.set('FlxEase', FlxEase);
	interp.variables.set('FlxMath', FlxMath);
	interp.variables.set('FlxSound', FlxSound);
    }
}