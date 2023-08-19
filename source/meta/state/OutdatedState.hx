package meta.state;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;

import haxe.Json;
import haxe.Http;

import meta.*;
import meta.data.*;
import meta.state.*;

class OutdatedState extends MusicBeatState
{
	public static var leftState:Bool = false;
	public static var mustUpdate:Bool = false;

	public static var daJson:Dynamic;

	var warnText:FlxText;
	
	override function create()
	{
		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		warnText = new FlxText(0, 0, FlxG.width,
			"Oh teh noes! You're running an outdated version of Joalor64 Engine Rewritten!\n
			Your current version is v" + MainMenuState.joalor64EngineVersion + ", while the most recent version is v" + daJson.version + "!\n
			What's New:\n"
			+ daJson.description +
			"\nPress ENTER to go to GitHub. Otherwise, press ESCAPE to proceed anyways.\n
 			Thank you for using the Engine! :)",
			32);
		warnText.setFormat("VCR OSD Mono", 25, FlxColor.WHITE, CENTER);
		warnText.screenCenter(XY);
		add(warnText);

		FlxG.camera.fade(FlxColor.BLACK, 0.33, true);
	}

	public static function updateCheck()
	{
		trace('checking for updates...');
		var http:Http = new Http('https://raw.githubusercontent.com/Joalor64GH/Joalor64-Engine-Rewrite/main/gitVersion.json');
		http.onData = function(data:String)
		{
			var daRawJson:Dynamic = Json.parse(data);
			if (daRawJson.version != MainMenuState.joalor64EngineVersion)
			{
				trace('oh noo outdated!!');
				daJson = daRawJson;
				mustUpdate = true;
			}
			else
				mustUpdate = false;
		}

		http.onError = function(error)
		{
			trace('error: $error');
		}

		http.request();
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