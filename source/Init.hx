package;

#if desktop
import meta.data.dependency.Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.input.keyboard.FlxKey;
import lime.app.Application;

import meta.*;
import meta.state.*;
import meta.data.*;
#if FUTURE_POLYMOD
import core.ModCore;
#end

// this loads everything in
class Init extends FlxState
{
	public static var coolColors:Array<FlxColor> = [
		0x00000000, // Transparent
		0xFFFFFFFF, // White
		0xFF808080, // Gray
		0xFF000000, // Black
		0xFF008000, // Green
		0xFF00FF00, // Lime
		0xFFFFFF00, // Yellow
		0xFFFFA500, // Orange
		0xFFFF0000, // Red
		0xFF800080, // Purple
		0xFF0000FF, // Blue
		0xFF8B4513, // Brown
		0xFFFFC0CB, // Pink
		0xFFFF00FF, // Magenta
		0xFF00FFFF // Cyan
	];

	var loadingSpeen:FlxSprite;
	var epicLogo:FlxSprite;

	var coolText:FlxText;
    	
	var isTweening:Bool = false;

	var lastString:String = '';

	public function new() 
	{
		super();
		persistentUpdate = persistentDraw = true;
	}

	override function create()
    	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image("loader/bgDesat"));
		bg.color = randomizeColor();
		bg.screenCenter();
        	add(bg);
        
        	epicLogo = new FlxSprite().loadGraphic(Paths.image('loader/startupLogo'));
        	epicLogo.antialiasing = ClientPrefs.globalAntialiasing;
		epicLogo.screenCenter();
        	add(epicLogo);

		logoTween();

		var bottomPanel:FlxSprite = new FlxSprite(0, FlxG.height - 100).makeGraphic(FlxG.width, 100, 0xFF000000);
		bottomPanel.alpha = 0.5;
		add(bottomPanel);

		coolText = new FlxText(20, FlxG.height - 80, 1000, "", 22);
		coolText.scrollFactor.set();
		coolText.setFormat("VCR OSD Mono", 26, 0xFFffffff, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(coolText);

		loadingSpeen = new FlxSprite(FlxG.width - 91, FlxG.height - 91).loadGraphic(Paths.image("loader/loader"));
		loadingSpeen.angularVelocity = 180;
		loadingSpeen.antialiasing = ClientPrefs.globalAntialiasing;
		add(loadingSpeen);

		FlxG.sound.play(Paths.sound('startup'));

		loadEverything();

		new FlxTimer().start(10, function(timer) 
		{
			startGame();
		});

		FlxG.camera.fade(FlxColor.BLACK, 0.33, true);

        	super.create();
    	}

	var selectedSomethin:Bool = false;
	var timer:Float = 0;

	override function update(elapsed)
	{
		if (!selectedSomethin) {
			if (isTweening) {
				coolText.screenCenter(X);
				timer = 0;
			} else {
				coolText.screenCenter(X);
				timer += elapsed;
				if (timer >= 3)
				{
					changeText();
				}
			}
		}

		if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE) {
			startGame(); // in case you wanna skip
		}

		super.update(elapsed);
	}

	function loadEverything()	
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
		if (ClientPrefs.checkForUpdates && !OutdatedState.leftState)
			OutdatedState.updateCheck();
		#end

		Highscore.load();
	}

	function changeText()
	{
		var selectedText:String = '';
		var textArray:Array<String> = CoolUtil.coolTextFile(Paths.txt('tipText')); // basically introText.txt

		coolText.alpha = 1;
		isTweening = true;
		selectedText = textArray[FlxG.random.int(0, (textArray.length - 1))].replace('--', '\n');
		FlxTween.tween(coolText, {alpha: 0}, 1, {
			ease: FlxEase.linear,
			onComplete: function(shit:FlxTween)
			{
				if (selectedText != lastString)
				{
					coolText.text = selectedText;
					lastString = selectedText;
				}
				else
				{
					selectedText = textArray[FlxG.random.int(0, (textArray.length - 1))].replace('--', '\n');
					coolText.text = selectedText;
				}

				coolText.alpha = 0;

				FlxTween.tween(coolText, {alpha: 1}, 1, {
					ease: FlxEase.linear,
					onComplete: function(shit:FlxTween)
					{
						isTweening = false;
					}
				});
			}
		});
	}

	function startGame() 
	{
        	FlxG.camera.fade(FlxColor.BLACK, 0.33, false, function() 
        	{
			if (OutdatedState.mustUpdate && !OutdatedState.leftState)
			{
				FlxG.switchState(new OutdatedState());
			} 
			else 
			{
				if (FlxG.save.data.flashing == null && !FlashingState.leftState)
					FlxG.switchState(new FlashingState());
				else
					FlxG.switchState(new TitleState());
			}
	    	});
	}

	function logoTween()
	{
		epicLogo.angle = -4;

		new FlxTimer().start(0.01, function(tmr:FlxTimer)
		{
			if (epicLogo.angle == -4)
				FlxTween.angle(epicLogo, epicLogo.angle, 4, 4, {ease: FlxEase.quartInOut});
			if (epicLogo.angle == 4)
				FlxTween.angle(epicLogo, epicLogo.angle, -4, 4, {ease: FlxEase.quartInOut});
		}, 0);
	}

	public static function randomizeColor()
    	{
		var chance:Int = FlxG.random.int(0, coolColors.length - 1);
		var color:FlxColor = coolColors[chance];
		return color;
   	}
}