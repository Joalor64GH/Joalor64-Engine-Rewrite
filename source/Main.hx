package;

import webm.WebmPlayer;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.FlxGame;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.StageScaleMode;
import meta.data.ClientPrefs;
import meta.ButtplugUtils;
import core.ToastCore;
import meta.video.*;

import meta.CoolUtil;

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

#if linux
import lime.graphics.Image;
#end

using StringTools;

#if linux
@:cppInclude('./external/gamemode_client.h')
@:cppFileCode('
	#define GAMEMODE_AUTO
')
#end

class Main extends Sprite
{
	var gameWidth:Int; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions. (Removed from Flixel 5.0.0)
	
	public static var fpsVar:FPS;
	public static var game:Joalor64Game; // the main game
	public static var toast:ToastCore; // credits go to MAJigsaw77

	public static function main():Void
	{
		Lib.current.addChild(new Main());

		#if CRASH_HANDLER
		@:privateAccess
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, function(e) game.exceptionCaughtOpenFL(e));
		#end
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
		game = new Joalor64Game(gameWidth, gameHeight, Init, #if (flixel < "5.0.0") zoom, #end 60, 60, true, false);
		addChild(game);

		fpsVar = new FPS(10, 3, 0xFFFFFF);
		addChild(fpsVar);
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		if(fpsVar != null)
			fpsVar.visible = ClientPrefs.showFPS;

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

		#if linux
		var icon = Image.fromFile("icon.png");
		Lib.current.stage.window.setIcon(icon);
		#end

		#if html5
		FlxG.autoPause = FlxG.mouse.visible = false;
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
		if (ClientPrefs.fpsRainbow) {
			if (currentColor >= array.length)
				currentColor = 0;
			currentColor = Math.round(FlxMath.lerp(0, array.length, skippedFrames / ClientPrefs.framerate));
			(cast(Lib.current.getChildAt(0), Main)).changeFPSColor(array[currentColor]);
			currentColor++;
			skippedFrames++;
			if (skippedFrames > ClientPrefs.framerate)
				skippedFrames = 0;
		}
		else 
			fpsVar.textColor = FlxColor.fromRGB(255, 255, 255);
	}
	inline public function changeFPSColor(color:FlxColor)
		fpsVar.textColor = color;

	public static var webmHandler:WebmHandler;
}

class Joalor64Game extends FlxGame {
	/**
	 * Used to instantiate the guts of the flixel game object once we have a valid reference to the root.
	 */
	override function create(_):Void {
		try super.create(_)
		catch (e:haxe.Exception)
			return exceptionCaught(e);
	}

	/**
	 * Called when the user on the game window
	 */
	override function onFocus(_):Void {
		try super.onFocus(_)
		catch (e:haxe.Exception)
			return exceptionCaught(e);
	}

	/**
	 * Called when the user clicks off the game window
	 */
	override function onFocusLost(_):Void {
		try super.onFocusLost(_)
		catch (e:haxe.Exception)
			return exceptionCaught(e);
	}

	/**
	 * Handles the `onEnterFrame` call and figures out how many updates and draw calls to do.
	 */
	override function onEnterFrame(_):Void {
		try super.onEnterFrame(_)
		catch (e:haxe.Exception)
			return exceptionCaught(e);
	}

	/**
	 * This function is called by `step()` and updates the actual game state.
	 * May be called multiple times per "frame" or draw call.
	 */
	override function update():Void {
		try super.update()
		catch (e:haxe.Exception)
			return exceptionCaught(e);
	}

	/**
	 * Goes through the game state and draws all the game objects and special effects.
	 */
	override function draw():Void {
		try super.draw()
		catch (e:haxe.Exception)
			return exceptionCaught(e);
	}

	private function exceptionCaught(e:haxe.Exception) {
		var callStack:CallStack = CallStack.exceptionStack(true);

		final formattedMessage:String = getCallStack().join("\n");

		FlxG.sound.music.volume = 0;

		DiscordClient.shutdown();

		goToExceptionState(e.message, formattedMessage, true, callStack);
	}

	private function exceptionCaughtOpenFL(e:UncaughtErrorEvent) {
		var callStack:CallStack = CallStack.exceptionStack(true);

		final formattedMessage:String = getCallStack().join("\n");

		FlxG.sound.music.volume = 0;

		DiscordClient.shutdown();

		goToExceptionState(e.error, formattedMessage, true, callStack);
	}

	private function getCallStack():Array<String> {
		var caughtErrors:Array<String> = [];

		for (stackItem in CallStack.exceptionStack(true)) {
			switch (stackItem) {
				case CFunction:
					caughtErrors.push('Non-Haxe (C) Function');
				case Module(moduleName):
					caughtErrors.push('Module (${moduleName})');
				case FilePos(s, file, line, column):
					caughtErrors.push('${file} (line ${line})');
				case Method(className, method):
					caughtErrors.push('${className} (method ${method})');
				case LocalFunction(name):
					caughtErrors.push('Local Function (${name})');
			}

			Sys.println(stackItem);
		}

		return caughtErrors;
	}

	private function goToExceptionState(exception:String, errorMsg:String, shouldGithubReport:Bool, ?callStack:CallStack) {
		var arguments:Array<Dynamic> = [exception, errorMsg, shouldGithubReport];
		if (callStack != null)
			arguments.push(callStack);

		_requestedState = Type.createInstance(meta.state.exception.ExceptionState, arguments);
		switchState();
	}

	private function writeLog(path:String, errMsg:String) {
		if (!FileSystem.exists("crash/"))
			FileSystem.createDirectory("crash/");
		File.saveContent(path, '${errMsg}\n');

		Sys.println(errMsg);
		Sys.println('Crash dump saved in ${Path.normalize(path)}');
	}

	private function getLogPath():String {
		return "crash/" + "J64E_" + formatDate() + ".txt";
	}

	private function formatDate():String {
		var dateNow:String = Date.now().toString();
		dateNow = StringTools.replace(dateNow, " ", "_");
		dateNow = StringTools.replace(dateNow, ":", "'");
		return dateNow;
	}
}