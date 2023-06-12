package;

#if desktop
import meta.data.dependency.epicSpriteord.epicSpriteordClient;
#end
import meta.*;
import meta.state.*;
import meta.data.*;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.input.keyboard.FlxKey;
import lime.app.Application;
import haxe.Http;
#if FUTURE_POLYMOD
import core.ModCore;
#end

// this loads everything in
class Init extends FlxState
{
	public static var updateVersion:String = '';

    	var mustUpdate:Bool = false;

	var epicSprite:FlxSprite;

	public function new() 
	{
		super();
		persistentUpdate = true;
		persistentDraw = true;
	}

	override function create()
    	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
        	bg.scale.set(10, 10);
		bg.screenCenter();
        	add(bg);
        
        	epicSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('credits/joalor'));
        	epicSprite.antialiasing = ClientPrefs.globalAntialiasing;
        	epicSprite.angularVelocity = 30;
        	add(epicSprite);

		load();

        	super.create();
    	}

	function load()	
	{
		#if html5
		Paths.initPaths();
		#end

        	#if LUA_ALLOWED
		Mods.pushGlobalMods();
		#end
		// Just to load a mod on start up if ya got one. For mods that change the menu music and bg
		Mods.loadTheFirstEnabledMod();
		#if FUTURE_POLYMOD
		ModCore.reload();
		#end

		FlxG.game.focusLostFramerate = 60;

		FlxG.sound.muteKeys = [FlxKey.ZERO];
		FlxG.sound.volumeDownKeys = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
		FlxG.sound.volumeUpKeys = [FlxKey.NUMPADPLUS, FlxKey.PLUS];
		FlxG.keys.preventDefaultKeys = [TAB];

		PlayerSettings.init();

		if(FlxG.save.data != null && FlxG.save.data.fullscreen)
		{
			FlxG.fullscreen = FlxG.save.data.fullscreen;
		}

        	if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		FlxG.mouse.visible = false;
        	#if desktop
		if (!DiscordClient.isInitialized)
		{
			DiscordClient.initialize();
			Application.current.onExit.add (function (exitCode) {
				DiscordClient.shutdown();
			});
		}
		#end

		FlxG.save.bind('j64enginerewrite', 'joalor64gh');

		ClientPrefs.loadPrefs();

        	#if CHECK_FOR_UPDATES
		if(ClientPrefs.checkForUpdates) {
			trace('checking for updates...');
			var http = new Http("https://raw.githubusercontent.com/Joalor64GH/Joalor64-Engine-Rewrite/main/gitVersion.txt");

			http.onData = function (data:String)
			{
				updateVersion = data.split('\n')[0].trim();
				var curVersion:String = MainMenuState.joalor64EngineVersion.trim();
				trace('version online: ' + updateVersion + ', your version: ' + curVersion);
				if(updateVersion != curVersion) {
					trace('oh noo outdated!!');
					mustUpdate = true;
				}
			}

			http.onError = function (error) {
				trace('error: $error');
			}

			http.request();
		}
		#end

		Highscore.load();
	}

	override function update(elapsed) 
	{
		if (mustUpdate) 
		{
            		FlxG.camera.fade(FlxColor.BLACK, 0.33, false, function() 
            		{
				FlxG.switchState(new OutdatedStateState());
	    		});
        	} 
		else 
		{
            		FlxG.camera.fade(FlxColor.BLACK, 0.33, false, function() 
            		{
				FlxG.switchState(new TitleState());
	    		});
        	}
		
		super.update(elapsed);
	}
}
