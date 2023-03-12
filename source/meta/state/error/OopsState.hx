package meta.state.error;

import haxe.Log;
import flixel.FlxG;
import flixel.FlxState;
import flixel.util.FlxColor;
import lime.app.Application;
import meta.state.error.Menu;
import meta.state.TitleState;

class OopsState extends FlxState
{
	var substateColor:FlxColor;

	override public function create()
	{
		// openfl.system.System.gc();
		
		substateColor = new FlxColor();

		// Create menu
		Menu.title = "Oops! You had an error!";
		Menu.options = [
			'Go to TitleState',
			'Close Game'
		];
		Menu.includeExitBtn = false;
		Menu.callback = (option:MenuSelection) ->
		{
			trace('Epic menu option ${option}');
			// Option check
			switch (option.id)
			{
				case 0:
					trace('Go to TitleState');
					FlxG.switchState(new TitleState());
				case 1:
					trace('Exit');
					#if sys
					Sys.exit(0);
					#else
					openfl.system.System.exit(0);
					#end
				default:
					trace('something is fucked');
			}
		}
		// Open menu
		FlxG.switchState(new Menu(substateColor.setRGB(0, 0, 0, 125)));

		super.create();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}