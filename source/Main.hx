package;

import system.GameDimensions;
import meta.ButtplugUtils;
import macros.MacroUtil;
import core.ToastCore;
import meta.video.*;
import debug.FPS;

import openfl.events.UncaughtErrorEvent;
import lime.system.System as LimeSystem;
import lime.utils.Log as LimeLogger;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

import haxe.Exception;
import haxe.CallStack;
import haxe.io.Path;

#if linux
@:cppInclude('./external/gamemode_client.h')
@:cppFileCode('#define GAMEMODE_AUTO')
#end

class Main extends Sprite
{
	public static var fpsVar:FPS; // fps
	public static var toast:ToastCore; // notification thing, credits go to MAJigsaw77
	public static var gameWidth:Int; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	public static var gameHeight:Int; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).

	public static var instance:Main; // instance
	private var game:Joalor64Game; // the main game

	public final config:Dynamic = {
		gameDimensions: [GameDimensions.width, GameDimensions.height],
		initialState: InitialState,
		defaultFPS: 60,
		skipSplash: true,
		startFullscreen: false
	};

	public static var commitId(default, never):String = MacroUtil.get_commit_id();

	public static function main():Void
		Lib.current.addChild(new Main());

	public function new()
	{
		super();

		instance = this;

		#if windows
		meta.data.windows.WindowsAPI.darkMode(true);
		#end

		ButtplugUtils.set_intensity(100);
		ButtplugUtils.initialise();

		FlxG.signals.preStateSwitch.add(() ->{
			#if cpp
			cpp.NativeGc.run(true);
			cpp.NativeGc.enable(true);
			#end
			FlxG.bitmap.dumpCache();
			FlxG.bitmap.clearUnused();
			Paths.clearStoredMemory();
			System.gc();
		});

		FlxG.signals.postStateSwitch.add(() ->{
			#if cpp
			cpp.NativeGc.run(false);
			cpp.NativeGc.enable(false);
			#end
			Paths.clearUnusedMemory();
			System.gc();
		});

		ClientPrefs.loadDefaultKeys();
		game = new Joalor64Game(config.gameDimensions[0], config.gameDimensions[1], config.initialState, 
			config.defaultFPS, config.defaultFPS, config.skipSplash, config.startFullscreen);
		addChild(game);

		// joalor64game crash handlers don't quite work
		// yeah
		#if CRASH_HANDLER
		@:privateAccess
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onError);
		#end

		fpsVar = new FPS(10, 10, 0xFFFFFF);
		addChild(fpsVar);

		var ourSource:String = "assets/videos/DO NOT DELETE OR GAME WILL CRASH/dontDelete.webm";
		var str1:String = "WEBM SHIT"; 
		var webmHandle = new WebmHandler();
		webmHandle.source(ourSource);
		webmHandle.makePlayer();
		webmHandle.webm.name = str1;
		addChild(webmHandle.webm);
		GlobalVideo.setWebm(webmHandle);

		Application.current.window.onFocusOut.add(onWindowFocusOut);
		Application.current.window.onFocusIn.add(onWindowFocusIn);

		#if (linux || mac)
		Lib.current.stage.window.setIcon(lime.graphics.Image.fromFile("icon.png"));
		#end

		#if html5
		FlxG.autoPause = FlxG.mouse.visible = false;
		#end

		toast = new ToastCore();
		addChild(toast);
	}

	private static function onError(e:UncaughtErrorEvent):Void
	{
		var stack:Array<String> = [];
		stack.push(e.error);

		for (stackItem in CallStack.exceptionStack(true))
		{
			switch (stackItem)
			{
				case CFunction:
					stack.push('C Function');
				case Module(m):
					stack.push('Module ($m)');
				case FilePos(s, file, line, column):
					stack.push('$file (line $line)');
				case Method(classname, method):
					stack.push('$classname (method $method)');
				case LocalFunction(name):
					stack.push('Local Function ($name)');
			}
		}

		e.preventDefault();
		e.stopPropagation();
		e.stopImmediatePropagation();

		final msg:String = stack.join('\n');

		#if sys
		try
		{
			if (!FileSystem.exists('logs'))
				FileSystem.createDirectory('logs');

			File.saveContent('logs/'
				+ Lib.application.meta.get('file')
				+ '-'
				+ Date.now().toString().replace(' ', '-').replace(':', "'")
				+ '.txt', msg
				+ '\n');
		}
		catch (e:Dynamic)
		{
			LimeLogger.println("Error!\nClouldn't save the crash dump because:\n" + e);
		}
		#end

		LimeLogger.println(msg);

		FlxG.bitmap.dumpCache();
		FlxG.bitmap.clearCache();

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		FlxG.sound.play(Paths.sound('crash'));

		DiscordClient.shutdown();

		Lib.application.window.alert('Uncaught Error: \n' + msg + '\n\nIf you think this shouldn\'t have happened, report this error to GitHub repository! Please? Thanks :)\nhttps://github.com/Joalor64GH/Joalor64-Engine-Rewrite/issues', 'Error!');
		LimeSystem.exit(1);
	}

	var oldVol:Float = 1.0;
	var newVol:Float = 0.3;

	var focused:Bool = true;
	var focusMusicTween:FlxTween;

	function onWindowFocusOut()
	{
		focused = false;

		if (Type.getClass(FlxG.state) != PlayState)
		{
			oldVol = FlxG.sound.volume;
			newVol = (oldVol > 0.3) ? 0.3 : (oldVol > 0.1) ? 0.1 : 0;

			trace("Game unfocused");

			if (focusMusicTween != null)
				focusMusicTween.cancel();
			focusMusicTween = FlxTween.tween(FlxG.sound, {volume: newVol}, 0.5);

			FlxG.drawFramerate = 30;
		}
	}

	function onWindowFocusIn()
	{
		new FlxTimer().start(0.2, (timer) ->
		{
			focused = true;
		});

		if (Type.getClass(FlxG.state) != PlayState)
		{
			trace("Game focused");

			if (focusMusicTween != null)
				focusMusicTween.cancel();

			focusMusicTween = FlxTween.tween(FlxG.sound, {volume: oldVol}, 0.5);

			FlxG.drawFramerate = config.defaultFPS;
		}
	}
}

class Joalor64Game extends FlxGame
{
	public function new(gameWidth:Int = 0, gameHeight:Int = 0, initialState:Class<FlxState>, updateFramerate:Int = 60, drawFramerate:Int = 60, skipSplash:Bool = false, startFullscreen:Bool = false) 
	{
		super(gameWidth, gameHeight, initialState, updateFramerate, drawFramerate, skipSplash, startFullscreen);
		_customSoundTray = Joalor64SoundTray;
	}
}

class Joalor64SoundTray extends flixel.system.ui.FlxSoundTray 
{
	var _bar:Bitmap;
	var volumeMaxSound:String;

	public function new()
	{
		super();
		removeChildren();

		final bg = new Bitmap(new BitmapData(80, 25, false, 0xff3f3f3f));
		addChild(bg);

		_bar = new Bitmap(new BitmapData(75, 25, false, 0xffffffff));
		_bar.x = 2.5;
		addChild(_bar);

		final tmp:Bitmap = new Bitmap(Assets.getBitmapData("assets/images/soundtray.png", false), null, true);
		addChild(tmp);

		screenCenter();

		tmp.scaleX = 0.5;
		tmp.scaleY = 0.5;
		tmp.x -= tmp.width * 0.2;
		tmp.y -= 5;

		y = -height;
		visible = false;

		var soundExt:String = #if !web "ogg" #else "mp3" #end;
		volumeUpSound = 'assets/sounds/soundtray/Volup.$soundExt';
		volumeDownSound = 'assets/sounds/soundtray/Voldown.$soundExt';
		volumeMaxSound = 'assets/sounds/soundtray/VolMAX.$soundExt';
	}

	override function update(elapsed:Float) {
		super.update(elapsed * 4);
	}

	override function show(up:Bool = false) 
	{
		var globalVolume:Int = Math.round(FlxG.sound.volume * 10);
    	if (FlxG.sound.muted) globalVolume = 0;

		if (!silent)
		{
			var sound = up ? volumeUpSound : volumeDownSound;
			if (globalVolume == 10) sound = volumeMaxSound;
			if (sound != null) FlxG.sound.load(sound).play();
		}

		_timer = 4;
		y = 0;
		visible = active = true;
		_bar.scaleX = FlxG.sound.muted ? 0 : FlxG.sound.volume;
	}

	override function screenCenter()
	{
		_defaultScale = Math.min(FlxG.stage.stageWidth / FlxG.width, FlxG.stage.stageHeight / FlxG.height) * 2;
		super.screenCenter();
	}
}