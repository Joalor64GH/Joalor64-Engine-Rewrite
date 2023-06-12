package;

#if desktop
import meta.data.dependency.Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;

import lime.app.Application;
import haxe.Http;

import meta.*;
import meta.state.*;
import meta.data.*;
#if FUTURE_POLYMOD
import core.ModCore;
#end

// this loads everything in
class Init extends FlxState
{
	public static var randomIcon:Array<String> = [
		'joalor',
		'meme',
		'bot'
	];
	var epicSprite:FlxSprite;

	public static var updateVersion:String = '';
    	var mustUpdate:Bool = false;

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
        
        	epicSprite = new FlxSprite().loadGraphic(randomizeIcon());
        	epicSprite.antialiasing = ClientPrefs.globalAntialiasing;
        	epicSprite.angularVelocity = 30;
		epicSprite.screenCenter();
        	add(epicSprite);

		FlxG.sound.play(Paths.sound('credits/goofyahhphone'));

		load();

		new FlxTimer().start(4, function(timer) 
		{
			startGame();
		});

        	super.create();
    	}

	override function update(elapsed)
	{
		if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE)
			skip();

		super.update(elapsed);
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

	function skip() 
	{
		startGame();
	}

	function startGame() 
	{
		if (mustUpdate) {
            		FlxG.camera.fade(FlxColor.BLACK, 0.33, false, function() 
            		{
				FlxG.switchState(new OutdatedState());
	    		});
        	} else {
            		FlxG.camera.fade(FlxColor.BLACK, 0.33, false, function() 
            		{
				FlxG.switchState(new TitleState());
	    		});
        	}
	}

	public static function randomizeIcon():flixel.system.FlxAssets.FlxGraphicAsset
	{
		var chance:Int = FlxG.random.int(0, randomIcon.length - 1);
		return Paths.image('credits/${randomIcon[chance]}');
	}
}
