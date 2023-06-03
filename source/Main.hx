package;

import webm.WebmPlayer;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
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
import meta.data.ClientPrefs;
import meta.state.TitleState;
import meta.ButtplugUtils;
import core.ToastCore;
import meta.video.*;

//crash handler stuff
#if CRASH_HANDLER
import lime.app.Application;
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
import meta.data.dependency.Discord.DiscordClient;
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class Main extends Sprite
{
	var gameWidth:Int; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions. (Removed from Flixel 5.0.0)
	
	public static var fpsVar:FPS;
	public static var toast:ToastCore; // credits go to MAJigsaw77

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		meta.data.windows.WindowsAPI.setDarkMode(true);

		ButtplugUtils.set_intensity(100);
		ButtplugUtils.initialise();

		var timer = new haxe.Timer(1);
		timer.run = function() {
			coloring();
			if (fpsVar.textColor == 0) 
				fpsVar.textColor = -4775566; // needs to be done because textcolor becomes black for a frame
		}
		
		gameWidth = GameDimensions.width;
		gameHeight = GameDimensions.height;
		
		final stageWidth:Int = Lib.current.stage.stageWidth;
		final stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			final ratioX:Float = stageWidth / gameWidth;
			final ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		FlxG.signals.preStateSwitch.add(() ->{
			#if cpp
			cpp.NativeGc.run(true);
			cpp.NativeGc.enable(true);
			#end
			FlxG.bitmap.dumpCache();
			FlxG.bitmap.clearUnused();

			openfl.system.System.gc();
		});

		FlxG.signals.postStateSwitch.add(() ->{
			#if cpp
			cpp.NativeGc.run(false);
			cpp.NativeGc.enable(false);
			#end
			openfl.system.System.gc();
		});

		ClientPrefs.loadDefaultKeys();
		addChild(new FlxGame(gameWidth, gameHeight, TitleState, #if (flixel < "5.0.0") zoom, #end 60, 60, true, false));

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
		FlxG.autoPause = FlxG.mouse.visible = false;
		#end
		
		// Code was entirely made by sqirra-rng for their fnf engine named "Izzy Engine", big props to them!!!
		// very cool person for real they don't get enough credit for their work
		#if CRASH_HANDLER
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, (e) -> {
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
		});
		#end

		toast = new ToastCore();
		addChild(toast);
	}

	// Chroma Effect (12 Colors)
	var array:Array<FlxColor> = [
		FlxColor.fromRGB(216, 34, 83),
		FlxColor.fromRGB(255, 38, 0),
		FlxColor.fromRGB(255, 80, 0),
		FlxColor.fromRGB(255, 147, 0),
		FlxColor.fromRGB(255, 199, 0),
		FlxColor.fromRGB(255, 255, 0),
		FlxColor.fromRGB(202, 255, 0),
		FlxColor.fromRGB(0, 255, 0),
		FlxColor.fromRGB(0, 146, 146),
		FlxColor.fromRGB(0, 0, 255),
		FlxColor.fromRGB(82, 40, 204),
		FlxColor.fromRGB(150, 33, 146)
	];
	var skippedFrames = 0;
	var currentColor = 0;

	// Event Handlers
	public function coloring():Void
	{
		// Hippity, Hoppity, your code is now my property (from KadeEngine)
		if (FlxG.save.data.fpsRainbow) {
			if (currentColor >= array.length)
				currentColor = 0;
			currentColor = Math.round(FlxMath.lerp(0, array.length, skippedFrames / ClientPrefs.framerate));
			(cast(Lib.current.getChildAt(0), Main)).changeFPSColor(array[currentColor]);
			currentColor++;
			skippedFrames++;
			if (skippedFrames > ClientPrefs.framerate)
				skippedFrames = 0;
		}
		else fpsVar.textColor = FlxColor.fromRGB(255, 255, 255);
	}
	public function changeFPSColor(color:FlxColor)
	{
		fpsVar.textColor = color;
	}

	public static var webmHandler:WebmHandler;
}