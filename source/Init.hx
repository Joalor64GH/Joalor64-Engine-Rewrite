package;

#if desktop
import meta.data.dependency.Discord.DiscordClient;
#end
import meta.*;
import meta.state.*
import meta.data.*;
import flixel.FlxG;
import flixel.FlxState;

#if FUTURE_POLYMOD
import core.ModCore;
#end

import haxe.Http;
import lime.app.Application;

// this loads everything in
class Init extends FlxState
{
	public static var updateVersion:String = '';

    	var mustUpdate:Bool = false;

	override function create()
    	{
        	#if html5
		Paths.initPaths();
		#end

        	#if LUA_ALLOWED
		Paths.pushGlobalMods();
		#end
		// Just to load a mod on start up if ya got one. For mods that change the menu music and bg
		WeekData.loadTheFirstEnabledMod();

		#if FUTURE_POLYMOD
		ModCore.reload();
		#end

		FlxG.game.focusLostFramerate = 60;

		FlxG.sound.muteKeys = [FlxKey.ZERO];
		FlxG.sound.volumeDownKeys = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
		FlxG.sound.volumeUpKeys = [FlxKey.NUMPADPLUS, FlxKey.PLUS];
		FlxG.keys.preventDefaultKeys = [TAB];

		ClientPrefs.loadPrefs();
        	PlayerSettings.init();
        	Highscore.load();

        	if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

        	#if desktop
		if (!DiscordClient.isInitialized)
		{
			DiscordClient.initialize();
			Application.current.onExit.add (function (exitCode) {
				DiscordClient.shutdown();
			});
		}
		#end
        	FlxG.mouse.visible = false;

        	FlxG.save.bind('j64enginerewrite', 'joalor64gh');
        	if(FlxG.save.data != null && FlxG.save.data.fullscreen)
		{
			FlxG.fullscreen = FlxG.save.data.fullscreen;
		}
			
        	persistentUpdate = true;
		persistentDraw = true;

        	#if CHECK_FOR_UPDATES
		if(ClientPrefs.checkForUpdates) {
			trace('checking for update');
			var http = new Http("https://raw.githubusercontent.com/Joalor64GH/Joalor64-Engine-Rewrite/main/gitVersion.txt");

			http.onData = function (data:String)
			{
				updateVersion = data.split('\n')[0].trim();
				var curVersion:String = MainMenuState.joalor64EngineVersion.trim();
				trace('version online: ' + updateVersion + ', your version: ' + curVersion);
				if(updateVersion != curVersion) {
					trace('versions arent matching!');
					mustUpdate = true;
				}
			}

			http.onError = function (error) {
				trace('error: $error');
			}

			http.request();
		}
		#end

        	if (mustUpdate) {
            		FlxG.switchState(new OutdatedState());
        	} else {
            		FlxG.switchState(new TitleState());
        	}

        	super.create();
    	}
}
