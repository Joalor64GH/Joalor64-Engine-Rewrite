package meta.state.exception;

import haxe.CallStack;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;

import meta.*;
import meta.data.*;
import meta.state.TitleState;
import meta.state.OutdatedState;
import meta.state.exception.ScrollableText;

/**
 * Cool In-Game Crash Handler
 * @author Sword352
 * @see https://github.com/FunknecionCubeFNF/Forever-Engine-Eternal
 */
class ExceptionState extends FlxState 
{
	var errorText:FlxText;

	public function new(exception:String, errorMsg:String, shouldGithubReport:Bool, ?callStack:CallStack) 
        {
		super();

		var errorScrollable:ScrollableText = new ScrollableText(0, FlxG.height * 0.05, FlxG.width, FlxG.height * 0.75);

		errorText = new FlxText(0, 200, 0, "Joalor64 Engine Rewritten - Exception Report\n").setFormat(Paths.font('vcr.ttf'), 25, FlxColor.WHITE, CENTER);
		errorText.text += 'Exception: ${exception}\n${errorMsg}\n';
		if (callStack != null)
			errorText.text += '\nCallStack: ${try CallStack.toString(callStack) catch(e) "Unknown (Failed parsing CallStack)"}\n';
		if (shouldGithubReport)
			errorText.text += '\nTake a screenshot of this error and report it to the GitHub page!';
        	errorText.text += '\nPress G to go to the GitHub page.\nPress Q to quit the game.\nPress R to restart the game.';
		errorText.screenCenter(X);
		errorScrollable.add(errorText);

		add(errorScrollable);

		FlxG.mouse.visible = true;

		errorText.antialiasing = ClientPrefs.globalAntialiasing;
	}

    	override public function create()
    	{
        	FlxG.sound.play(Paths.sound('crash'));
        	super.create();
    	}

	override function update(elapsed:Float) 
    	{
		super.update(elapsed);

        	if (FlxG.keys.justPressed.G)
			CoolUtil.browserLoad('https://github.com/Joalor64GH/Joalor64-Engine-Rewrite/issues');

        	if (FlxG.keys.justPressed.Q)
	        	FlxG.camera.fade(FlxColor.BLACK, 0.5, false, function() {Sys.exit(0);}, false);

		if (FlxG.keys.justPressed.R) 
        	{
			TitleState.initialized = false;
			TitleState.closedState = false;
			OutdatedState.leftState = false;
			FlxG.camera.fade(FlxColor.BLACK, 0.5, false, FlxG.resetGame, false);
        	}
	}
}