package;

import webm.WebmPlayer;
import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.StageScaleMode;
import core.ToastCore;

//crash handler stuff
#if CRASH_HANDLER
import lime.app.Application;
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
import meta.data.dependency.Discord.DiscordClient;
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;
#end

import meta.video.*;

#if (hxCodec > "2.5.1")
#error "hxCodec is the git version, please use the haxelib version instead"
#end

using StringTools;

class Main extends Sprite
{
	var gameWidth:Int; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions. (Removed from Flixel 5.0.0)
	var framerate:Int = 60; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets
	public static var fpsVar:FPS;
	
	public static var toast:ToastCore; // credits go to MAJigsaw77

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}

		toast = new ToastCore();
		addChild(toast);
	}

	public static var webmHandler:WebmHandler;

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		gameWidth = GameDimensions.width;
		gameHeight = GameDimensions.height;
		
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			final ratioX:Float = stageWidth / gameWidth;
			final ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}
	
		ClientPrefs.loadDefaultKeys();
		addChild(new FlxGame(gameWidth, gameHeight, initialState, #if (flixel < "5.0.0") zoom, #end framerate, framerate, skipSplash, startFullscreen));

		fpsVar = new FPS(10, 3, 0xFFFFFF);
		addChild(fpsVar);
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		if(fpsVar != null) {
			fpsVar.visible = ClientPrefs.showFPS;
		}

		var ourSource:String = "assets/videos/DO NOT DELETE OR GAME WILL CRASH/dontDelete.webm";

		#if web
		var str1:String = "HTML CRAP";
		var vHandler = new VideoHandler();
		vHandler.init1();
		vHandler.video.name = str1;
		addChild(vHandler.video);
		vHandler.init2();
		GlobalVideo.setVid(vHandler);
		vHandler.source(ourSource);
		#elseif WEBM_ALLOWED
		var str1:String = "WEBM SHIT";
		var webmHandle = new WebmHandler();
		webmHandle.source(ourSource);
		webmHandle.makePlayer();
		webmHandle.webm.name = str1;
		addChild(webmHandle.webm);
		GlobalVideo.setWebm(webmHandle);
		#end

		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end
		
		#if CRASH_HANDLER
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end
	}

	// Code was entirely made by sqirra-rng for their fnf engine named "Izzy Engine", big props to them!!!
	// very cool person for real they don't get enough credit for their work
	#if CRASH_HANDLER
	function onCrash(e:UncaughtErrorEvent):Void
	{
		var errMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = dateNow.replace(" ", "_");
		dateNow = dateNow.replace(":", "'");

		path = "./crash/" + "Joalor64Engine_" + dateNow + ".txt";

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += "\nUncaught Error: " + e.error + "\nPlease report this error to the GitHub page: https://github.com/Joalor64GH/Joalor64-Engine-Rewrite/issues\n\n> Crash Handler written by: sqirra-rng";

		if (!FileSystem.exists("./crash/"))
			FileSystem.createDirectory("./crash/");

		File.saveContent(path, errMsg + "\n");

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));

		Application.current.window.alert(errMsg, "Error!");
		DiscordClient.shutdown();
		Sys.exit(1);
	}
	#end
}
