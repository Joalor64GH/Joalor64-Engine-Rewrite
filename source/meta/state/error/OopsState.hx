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
					TitleState.initialized = false;
					TitleState.closedState = false;
					FlxG.sound.music.fadeOut(0.3);
					FlxG.camera.fade(FlxColor.BLACK, 0.5, false, FlxG.resetGame, false);
				case 1:
					trace('Close Game');
					FlxG.sound.music.fadeOut(0.3);
	            	FlxG.camera.fade(FlxColor.BLACK, 0.5, false, function()
	            	{
						#if sys
		        		Sys.exit(0);
						#else
						openfl.system.System.exit(0);
						#end
	            	}, false);
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