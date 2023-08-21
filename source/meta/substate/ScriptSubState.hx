package meta.substate;

import core.ScriptCore;
import flixel.FlxBasic;
import flixel.addons.ui.FlxUITooltip;
import flixel.addons.ui.interfaces.IFlxUIWidget;

class ScriptSubState extends meta.MusicBeatSubstate
{
	var daScript:ScriptCore;

	public function new(path:String, args:Array<Dynamic>)
	{
		daScript = new ScriptCore('', false);
		daScript.setVariable('this', this);
		daScript.setVariable('add', function(Object:FlxBasic)
		{
			add(Object);
		});
		daScript.setVariable('remove', function(Object:FlxBasic)
		{
			remove(Object);
		});
		daScript.setVariable('insert', function(position:Int, object:FlxBasic)
		{
			insert(position, object);
		});
		daScript.execute(path, false);

		super();

		daScript.executeFunc('new', args);
	}

	public override function onFocus()
	{
		daScript.executeFunc("onFocus", []);
		super.onFocus();
	}

	public override function onFocusLost()
	{
		daScript.executeFunc("onFocusLost", []);
		super.onFocusLost();
	}

	public override function onResize(width:Int, height:Int)
	{
		daScript.executeFunc("onResize", [width, height]);
		super.onResize(width, height);
	}

	public override function create()
	{
		daScript.executeFunc("create", []);
		super.create();
	}

	public override function beatHit()
	{
		daScript.executeFunc("beatHit", [curBeat]);
		super.beatHit();
	}

	public override function stepHit()
	{
		daScript.executeFunc("stepHit", [curStep]);
		super.stepHit();
	}

	public override function update(elapsed:Float)
	{
		daScript.executeFunc("update", [elapsed]);
		super.update(elapsed);
	}

	public override function destroy()
	{
		daScript.executeFunc("destroy", []);
		super.destroy();
	}
}