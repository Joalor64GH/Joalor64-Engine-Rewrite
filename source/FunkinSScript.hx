package;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

import lime.app.Application;

final class FunkinSScript extends SScript
{
    override public function new(?scriptFile:String = "")
    {
        super(scriptFile);

        traces = false;
    }

    override function preset():Void
    {
        super.preset();

        set('Alphabet', Alphabet);
        set('Application', Application);
        set('Conductor', Conductor);
        set('FlxBasic', FlxBasic);
        set('FlxEase', FlxEase);
        set('FlxTween', FlxTween);
        set('FlxG', FlxG);
        set('FlxMath', FlxMath);
        set('FlxObject', FlxObject);
        set('FlxSprite', FlxSprite);
        set('FlxText', FlxText);
        set('FlxTimer', FlxTimer);
        set('Paths', Paths);
        set('PlayState', PlayState);
        set('GameOverSubstate', GameOverSubstate);
        
        set('add', function(FlxBasic:FlxBasic)
        {
            return PlayState.instance.add(FlxBasic);
        });

        set('get', function(id:String)
        {
            var dotList:Array<String> = id.split('.');
			if (dotList.length > 1)
			{
				var property:Dynamic = Reflect.getProperty(PlayState.instance, dotList[0]);
				for (i in 1...dotList.length - 1)
				{
					property = Reflect.getProperty(property, dotList[i]);
				}

				return Reflect.getProperty(property, dotList[dotList.length - 1]);
			}
			return Reflect.getProperty(PlayState.instance, id);
        });

        set('set', function(id:String, value:Dynamic)
        {
            var dotList:Array<String> = id.split('.');
			if (dotList.length > 1)
			{
				var property:Dynamic = Reflect.getProperty(PlayState.instance, dotList[0]);
				for (i in 1...dotList.length - 1)
				{
					property = Reflect.getProperty(property, dotList[i]);
				}

                return Reflect.setProperty(property, dotList[dotList.length - 1], value);
			}
			return Reflect.setProperty(PlayState.instance, id, value);
        });

        set('getColorFromRGB', function(r:Int, g:Int, b:Int)
        {
            return FlxColor.fromRGB(r, b, g);
        });
    }
}