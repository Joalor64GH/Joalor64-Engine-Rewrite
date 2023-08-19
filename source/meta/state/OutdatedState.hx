package meta.state;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;

import haxe.Json;

import meta.*;
import meta.data.*;
import meta.state.*;

import Init;

class OutdatedState extends MusicBeatState
{
	public static var leftState:Bool = false;
	public static var newVer:EngineVersion = null;

	var warnText:FlxText;
	
	override function create()
	{
		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		var ver = MainMenuState.joalor64EngineVersion;
		var patchNotes:String = "";

		for (i in newVer.patchNotes)
			patchNotes += '$i\n';

		warnText = new FlxText(0, 0, FlxG.width,
			"Oh teh noes! You're running an outdated version of Joalor64 Engine Rewritten!\n
			Your current version is v" + ver + ", while the most recent version is v" + newVer.version + "!\n
			What's Changed:\n"
			+ patchNotes +
			"\nPress ENTER to go to GitHub. Otherwise, press ESCAPE to proceed anyways.\n
 			Thank you for using the Engine! :)",
			32);
		warnText.setFormat("VCR OSD Mono", 25, FlxColor.WHITE, CENTER);
		warnText.screenCenter(XY);
		add(warnText);

		FlxG.camera.fade(FlxColor.BLACK, 0.33, true);
	}

	override function update(elapsed:Float)
	{
		if(!leftState) {
			if (controls.ACCEPT) {
				leftState = true;
				CoolUtil.browserLoad("https://github.com/Joalor64GH/Joalor64-Engine-Rewrite/releases");
			}
			else if(controls.BACK) {
				leftState = true;
			}

			if(leftState)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxTween.tween(warnText, {alpha: 0}, 1, {
					onComplete: function (twn:FlxTween) {
						if (FlxG.save.data.flashing == null && !FlashingState.leftState)
							FlxG.switchState(new FlashingState());
						else
							FlxG.switchState(new TitleState());
					}
				});
			}
		}
		super.update(elapsed);
	}
}