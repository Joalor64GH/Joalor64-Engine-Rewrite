package;

import webm.WebmPlayer;
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

using StringTools;

#if linux
@:cppInclude('./external/gamemode_client.h')
@:cppFileCode('
	#define GAMEMODE_AUTO
')
#end

class Main extends Sprite
{
	public static var fpsVar:FPS; // fps
	public static var game:Joalor64Game; // the main game
	public static var toast:ToastCore; // notification thing, credits go to MAJigsaw77
	public static var gameWidth:Int; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	public static var gameHeight:Int; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).

	public final config:Dynamic = {
		gameDimensions: [GameDimensions.width, GameDimensions.height],
		initialState: Init,
		defaultFPS: 60,
		skipSplash: true,
		startFullscreen: false
	};

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

		meta.data.windows.WindowsAPI.darkMode(true);

		ButtplugUtils.set_intensity(100);
		ButtplugUtils.initialise();

		var timer = new haxe.Timer(1);
		timer.run = function() {
			coloring();
			if (fpsVar.textColor == 0) 
				fpsVar.textColor = -4775566; // needs to be done because textcolor becomes black for a frame
		}

		FlxG.signals.preStateSwitch.add(() ->{
			#if cpp
			cpp.NativeGc.run(true);
			cpp.NativeGc.enable(true);
			#end
			FlxG.bitmap.dumpCache();
			FlxG.bitmap.clearUnused();
			Paths.clearStoredMemory();
			openfl.system.System.gc();
		});

		FlxG.signals.postStateSwitch.add(() ->{
			#if cpp
			cpp.NativeGc.run(false);
			cpp.NativeGc.enable(false);
			#end
			Paths.clearUnusedMemory();
			openfl.system.System.gc();
		});

		ClientPrefs.loadDefaultKeys();
		game = new Joalor64Game(config.gameDimensions[0], config.gameDimensions[1], config.initialState, 
			config.defaultFPS, config.defaultFPS, config.skipSplash, config.startFullscreen);
		addChild(game);

		fpsVar = new FPS(10, 10, 0xFFFFFF);
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

		#if (linux || mac)
		Lib.current.stage.window.setIcon(lime.graphics.Image.fromFile("icon.png"));
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
	override function create(_):Void {
		try super.create(_)
		catch (e:haxe.Exception)
			return exceptionCaught(e);
	}

	override function onFocus(_):Void {
		try super.onFocus(_)
		catch (e:haxe.Exception)
			return exceptionCaught(e);
	}

	override function onFocusLost(_):Void {
		try super.onFocusLost(_)
		catch (e:haxe.Exception)
			return exceptionCaught(e);
	}

	override function onEnterFrame(_):Void {
		try super.onEnterFrame(_)
		catch (e:haxe.Exception)
			return exceptionCaught(e);
	}

	override function update():Void {
		try super.update()
		catch (e:haxe.Exception)
			return exceptionCaught(e);
	}

	override function draw():Void {
		try super.draw()
		catch (e:haxe.Exception)
			return exceptionCaught(e);
	}

	private function exceptionCaught(e:haxe.Exception) {
		#if CRASH_HANDLER
		var callStack:CallStack = CallStack.exceptionStack(true);

		final formattedMessage:String = getCallStack().join("\n");

		FlxG.sound.music.volume = 0;

		DiscordClient.shutdown();

		goToExceptionState(e.message, formattedMessage, true, callStack);
		#else
		throw e;
		#end
	}

	#if CRASH_HANDLER
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
	#end

	private function getLogPath():String
		return "crash/" + "J64E_" + formatDate() + ".txt";

	private function formatDate():String {
		var dateNow:String = Date.now().toString();
		dateNow = StringTools.replace(dateNow, " ", "_");
		dateNow = StringTools.replace(dateNow, ":", "'");
		return dateNow;
	}
}