package;

import webm.WebmPlayer;
import openfl.display.FPS;
import openfl.events.Event;
import openfl.display.StageScaleMode;
import meta.ButtplugUtils;
import core.ToastCore;
import meta.video.*;

// crash handler stuff
import haxe.Exception;
import haxe.CallStack;
import haxe.io.Path;

#if linux
@:cppInclude('./external/gamemode_client.h')
@:cppFileCode('
	#define GAMEMODE_AUTO
')
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
		initialState: () -> new Init(),
		defaultFPS: 60,
		skipSplash: true,
		startFullscreen: false
	};

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
	var _viewingCrash:Bool = false;

	public function new(gameWidth:Int = 0, gameHeight:Int = 0, initialState:Class<FlxState>, updateFramerate:Int = 60, drawFramerate:Int = 60, skipSplash:Bool = false, startFullscreen:Bool = false) 
	{
		super(gameWidth, gameHeight, initialState, updateFramerate, drawFramerate, skipSplash, startFullscreen);
		_customSoundTray = Joalor64SoundTray;
	}

	override function create(_):Void {
		try {
			super.create(_);
			
			removeChild(soundTray);
			addChild(soundTray);
		}
		catch (e:Exception)
			return exceptionCaught(e, 'create');
	}

	override function onFocus(_):Void {
		try super.onFocus(_) catch (e:Exception)
			return exceptionCaught(e, 'onFocus');
	}

	override function onFocusLost(_):Void {
		try super.onFocusLost(_) catch (e:Exception)
			return exceptionCaught(e, 'onFocusLost');
	}

	override function onEnterFrame(_):Void {
		try super.onEnterFrame(_) catch (e:Exception)
			return exceptionCaught(e, 'onEnterFrame');
	}

	override function update():Void {
		if (_viewingCrash) return;
		try super.update() catch (e:Exception)
			return exceptionCaught(e, 'update');
	}

	override function draw():Void {
		try super.draw() catch (e:Exception)
			return exceptionCaught(e, 'draw');
	}

	@:allow(flixel.FlxG)
	override function onResize(_):Void {
		if (_viewingCrash) return;
		super.onResize(_);
	}

	private function exceptionCaught(e:Exception, ?func:String = null)
	{
		#if CRASH_HANDLER
		if (_viewingCrash) return;

		var path:String;
		var fileStack:Array<String> = [];
		var dateNow:String = Date.now().toString();
		var println = #if sys Sys.println #else trace #end;

		dateNow = StringTools.replace(dateNow, " ", "_");
		dateNow = StringTools.replace(dateNow, ":", "'");

		path = 'crash/J64E_${dateNow}.txt';

		for (stackItem in CallStack.exceptionStack(true)) {
			switch (stackItem) {
				case CFunction:
					fileStack.push('Non-Haxe (C) Function');
				case Module(moduleName):
					fileStack.push('Module (${moduleName})');
				case FilePos(s, file, line, col):
					fileStack.push('${file} (line ${line})');
				case Method(className, method):
					fileStack.push('${className} (method ${method})');
				case LocalFunction(name):
					fileStack.push('Local Function (${name})');
			}

			println(stackItem);
		}

		fileStack.insert(0, "Exception: " + e.message);

		final msg:String = fileStack.join('\n');

		try 
		{
			if (!FileSystem.exists("crash/")) 
				FileSystem.createDirectory("crash/");
			File.saveContent(path, '${msg}\n');
		} 
		catch (e:Exception)
			trace('Couldn\'t save error message "${e.message}"');

		final funcThrew:String = '${func != null ? ' thrown at "${func}" function' : ""}';

		println(msg + funcThrew);
		println(e.message);
		println('Crash dump saved in ${Path.normalize(path)}');

		FlxG.bitmap.dumpCache();
		FlxG.bitmap.clearCache();

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		DiscordClient.shutdown();

		Main.instance.addChild(new backend.CrashHandler(e.details()));
		_viewingCrash = true;
		#else
		throw e;
		#end
	}
}

class Joalor64SoundTray extends flixel.system.ui.FlxSoundTray 
{
	var _bar:Bitmap;

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
	}

	override function update(elapsed:Float) {
		super.update(elapsed * 4);
	}

	override function show(up:Bool = false) 
	{
		if (!silent)
		{
			final sound = flixel.system.FlxAssets.getSound("assets/sounds/scrollMenu");
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