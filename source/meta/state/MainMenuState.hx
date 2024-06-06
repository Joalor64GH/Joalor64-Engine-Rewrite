package meta.state;

import meta.data.Achievements;

#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end

#if (flixel >= "5.0.0")
import flixel.input.mouse.FlxMouseEvent;
#end

typedef MenuData =
{
	enableReloadKey:Bool,
	alignToCenter:Bool,
	centerOptions:Bool,
	optionX:Float,
	optionY:Float,
	scaleX:Float,
	scaleY:Float,
	angle:Float,
	bgX:Float,
	bgY:Float,
	backgroundStatic:String,
	backgroundConfirm:String,
	colorOnConfirm:Array<FlxColor>,
	options:Array<String>,
	links:Array<Array<String>>
}

class MainMenuState extends MusicBeatState
{
	public static var nightly:String = #if nightly '-nightly' #else '' #end;
	public static var joalor64EngineVersion:String = '1.4.0-rc1'; // Used for Discord RPC
	public static var psychEngineVersion:String = '0.6.3';
	public static var psychGitBuild:String = 'eb79a80';  

	public static var curSelected:Int = 0;
	public static var firstStart:Bool = true;
	public static var finishedFunnyMove:Bool = false;

	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var menuItems:FlxTypedGroup<FlxSprite>;
	var optionShit:Array<String> = [];
	var linkArray:Array<Array<String>> = [];

	var bg:FlxSprite;
	var magenta:FlxSprite;
	var camFollow:FlxObject;

	var debugKeys:Array<FlxKey>;
	var modShortcutKeys:Array<FlxKey>;

	var tipTextMargin:Float = 10;
	var tipTextScrolling:Bool = false;
	var tipBackground:FlxSprite;
	var tipText:FlxText;

	var invalidPosition:Null<Int> = null;
	var menuJSON:MenuData;

	private var selectedSomethinAnal:Bool = true; // don't ask plz

	override function create()
	{
		FlxG.mouse.visible = true;

		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end

		Mods.loadTheFirstEnabledMod();

		menuJSON = Json.parse(Paths.getTextFromFile('images/mainmenu/menu_preferences.json'));

		Application.current.window.title = Application.current.meta.get('name');

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		#if sys
		ArtemisIntegration.setGameState ("menu");
		ArtemisIntegration.resetModName ();
		#end
		
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));
		modShortcutKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_2'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		if (menuJSON.options != null && menuJSON.options.length > 0 && menuJSON.options.length < 13)
			optionShit = menuJSON.options;
		else
		{
			optionShit = [
				'story_mode',
				'freeplay',
				'mini',
				#if ACHIEVEMENTS_ALLOWED 'awards',
				#end
				#if MODS_ALLOWED 'mods',
				#end
				'credits',
				'manual',
				'options'
			];
		}

		#if !desktop
		optionShit.remove("manual");
		#end

		for (i in menuJSON.links)
			linkArray.push(i);

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		bg = new FlxSprite();
		bg.loadGraphic(Paths.image(
			(menuJSON.backgroundStatic != null && menuJSON.backgroundStatic.length > 0 && menuJSON.backgroundStatic != "none") 
				? menuJSON.backgroundStatic : 'menuBG'));
		if (menuJSON.bgX != invalidPosition) bg.x = menuJSON.bgX;
		bg.y = (menuJSON.bgY != invalidPosition) ? menuJSON.bgY : -80;
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.2));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		#if sys
		ArtemisIntegration.setBackgroundColor ("#FFFDE871");
		#end

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite();
		magenta.loadGraphic(Paths.image(
			(menuJSON.backgroundConfirm != null && menuJSON.backgroundConfirm.length > 0 && menuJSON.backgroundConfirm != "none") 
				? menuJSON.backgroundConfirm : 'menuDesat'));
		if (menuJSON.bgX != invalidPosition) magenta.x = menuJSON.bgX;
		magenta.y = (menuJSON.bgY != invalidPosition) ? menuJSON.bgY : -80;
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.2));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = (menuJSON.colorOnConfirm != null && menuJSON.colorOnConfirm.length > 0) 
			? FlxColor.fromRGB(menuJSON.colorOnConfirm[0], menuJSON.colorOnConfirm[1], menuJSON.colorOnConfirm[2]) : 0xFFfd719b;
		add(magenta);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var invalidPosition:Null<Int> = null;
		var scale = 1;

		for (i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, (i * 140) + offset);
			if (menuJSON.optionX != invalidPosition)
				menuItem.x = menuJSON.optionX;
			if (menuJSON.optionY != invalidPosition)
				menuItem.y = menuJSON.optionY;
			if (menuJSON.angle != invalidPosition)
				menuItem.angle = menuJSON.angle;
			menuItem.scale.x = (menuJSON.scaleX != invalidPosition) ? menuJSON.scaleX : scale;
			menuItem.scale.y = (menuJSON.scaleY != invalidPosition) ? menuJSON.scaleY : scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			if (menuJSON.alignToCenter)
				menuItem.screenCenter(X);
			menuItems.add(menuItem);
			menuItem.scrollFactor.set(0, 1);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			menuItem.updateHitbox();
			if (optionShit[i] == '') menuItem.visible = false;
			FlxTween.tween(menuItem, {x: menuItem.width / 4 + (i * 60) - 55}, 1.3, {ease: FlxEase.expoInOut});
			if (firstStart)
				FlxTween.tween(menuItem, {y: 60 + (i * 160)}, 1 + (i * 0.25), {
					ease: FlxEase.expoInOut, onComplete: function(flxTween:FlxTween) 
					{
						finishedFunnyMove = true; 
						changeItem();
					}
				});
			else
				menuItem.y = 60 + (i * 160);
			#if (flixel >= "5.0.0") // update your fucking flixel
			FlxMouseEvent.add(menuItem, null, function(e) switchTheStatePlease(), function(e)
			{
				new FlxTimer().start(0.01, function (tmr:FlxTimer) {
					selectedSomethinAnal = true;
				});

				if (!selectedSomethin && selectedSomethinAnal)
				{
					curSelected = i;
					changeItem();
					FlxG.sound.play(backend.utils.Paths.sound('scrollMenu'));
				}
			});
			#end
		}

		firstStart = false;

		// The system says hi :)
		#if debug
		var versionShit:FlxText = new FlxText(12, FlxG.height - 104, 0, 'Hello ${system.CoolSystemStuff.getUsername()} having a good day? im proud of you! :)', 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat(Paths.font('vcr.ttf'), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		#end

		// Watermarks
		var versionShitArray:Array<String> = [
			'Joalor64 Engine Rewritten v$joalor64EngineVersion' + '$nightly' + ' [${Main.commitId}]',
			'Psych Engine v$psychEngineVersion [$psychGitBuild]',
			"Friday Night Funkin' v" + Application.current.meta.get('version')
		];
		versionShitArray.reverse();
		for (i in 0...versionShitArray.length) {
			var versionShit:FlxText = new FlxText(12, (FlxG.height - 24) - (18 * i), 0, versionShitArray[i], 12);
			versionShit.scrollFactor.set();
			versionShit.setFormat(Paths.font('vcr.ttf'), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			add(versionShit);
		}

		tipBackground = new FlxSprite();
		tipBackground.scrollFactor.set();
		tipBackground.alpha = 0.7;
		add(tipBackground);

		tipText = new FlxText(0, 0, 0,
			"Welcome to Joalor64 Engine Rewritten! This is a complete remake of the original that changes a lot of stuff, but still retains the \"vibe\" of the original. Credits go to ShadowMario for Psych Engine. Thanks for playing!");
		tipText.scrollFactor.set();
		tipText.setFormat(Paths.font('vcr.ttf'), 24, FlxColor.WHITE, LEFT);
		tipText.updateHitbox();
		add(tipText);

		tipBackground.makeGraphic(FlxG.width, Std.int((tipTextMargin * 2) + tipText.height), FlxColor.BLACK);

		changeItem();
		tipTextStartScrolling();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) {
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

		super.create();

		FlxG.camera.follow(camFollow, null, 0.15);
	}

	#if ACHIEVEMENTS_ALLOWED
	function giveAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
	}
	#end

	var selectedSomethin:Bool = false;
	var timeNotMoving:Float = 0;

	override function update(elapsed:Float)
	{
		if (tipTextScrolling)
		{
			tipText.x -= elapsed * 130;
			if (tipText.x < -tipText.width)
			{
				tipTextScrolling = false;
				tipTextStartScrolling();
			}
		}
		
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		if (FlxG.keys.justPressed.E)
			MusicBeatState.switchState(new EpicState());
		
		if (!selectedSomethin)
		{
			if (controls.UI_UP_P || controls.UI_DOWN_P) {
				susOWO();
				changeItem(controls.UI_UP_P ? -1 : 1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if (FlxG.mouse.wheel == 1 || FlxG.mouse.wheel == -1) {
				susOWO();
				changeItem(FlxG.mouse.wheel == 1 ? -1 : 1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.mouse.visible = false;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT || FlxG.mouse.justPressed)
			{
				switchTheStatePlease();
			}
			#if MODS_ALLOWED
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				FlxG.mouse.visible = false;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			else if (FlxG.keys.anyJustPressed(modShortcutKeys))
			{
				selectedSomethin = true;
				FlxG.mouse.visible = false;
				MusicBeatState.switchState(new ModsMenuState());
			}
			#end

			if (controls.RESET && menuJSON.enableReloadKey)
				FlxG.resetState();
		}

		super.update(elapsed);

		menuItems.forEach((spr:FlxSprite) -> 
		{
			if (menuJSON.centerOptions) 
				spr.screenCenter(X);
		});
	}

	function susOWO() {
		selectedSomethinAnal = false;
	}

	function tipTextStartScrolling()
	{
		tipText.x = tipTextMargin;
		tipText.y = -tipText.height;

		new FlxTimer().start(1.0, function(timer:FlxTimer)
		{
			FlxTween.tween(tipText, {y: tipTextMargin}, 0.3);
			new FlxTimer().start(2.25, function(timer:FlxTimer)
			{
				tipTextScrolling = true;
			});
		});
	}

	function changeItem(change:Int = 0)
	{
		if (finishedFunnyMove) 
			curSelected = FlxMath.wrap(curSelected + change, 0, optionShit.length - 1);

		menuItems.forEach((spr:FlxSprite) ->
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				var add:Float = 0;
				if (menuItems.length > 4) 
					add = menuItems.length * 8;
				
				camFollow.y = spr.getGraphicMidpoint().y;
				spr.centerOffsets();
			}
		});
	}

	function switchTheStatePlease()
	{
		if (optionShit[curSelected] == '')
			return;

		if (optionShit[curSelected] == '${menuJSON.links[0]}') 
			CoolUtil.browserLoad('${menuJSON.links[1]}');
		else if (optionShit[curSelected] == 'manual') 
			CoolUtil.browserLoad('https://github.com/Joalor64GH/Joalor64-Engine-Rewrite/wiki');
		else
		{
			selectedSomethin = true;
			FlxG.mouse.visible = false;
			FlxG.sound.play(Paths.sound('confirmMenu'));

			if (ClientPrefs.flashing) {
				FlxFlicker.flicker(magenta, 1.1, 0.15, false);
				#if sys
				ArtemisIntegration.triggerFlash (StringTools.hex (magenta.color));
				#end
			}

			menuItems.forEach((spr:FlxSprite) ->
			{
				if (curSelected != spr.ID)
				{
					FlxTween.tween(FlxG.camera, {zoom: 5}, 0.8, {ease: FlxEase.expoIn});
					FlxTween.tween(bg, {angle: 45}, 0.8, {ease: FlxEase.expoIn});
					FlxTween.tween(magenta, {angle: 45}, 0.8, {ease: FlxEase.expoIn});
					FlxTween.tween(bg, {alpha: 0}, 0.8, {ease: FlxEase.expoIn});
					FlxTween.tween(magenta, {alpha: 0}, 0.8, {ease: FlxEase.expoIn});
					FlxTween.tween(spr, {alpha: 0}, 0.4, {
						ease: FlxEase.quadOut,
						onComplete: function(twn:FlxTween) 
						{ 
							spr.kill(); 
						}
					});
				}
				else
				{
					FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
					{
						var daChoice:String = optionShit[curSelected];

						switch (daChoice)
						{
							case 'story_mode':
								MusicBeatState.switchState(new StoryMenuState());
							case 'freeplay':
								MusicBeatState.switchState(new FreeplayState());
							case 'mini':
								MusicBeatState.switchState(new MinigamesState());
							#if MODS_ALLOWED
							case 'mods':
								MusicBeatState.switchState(new ModsMenuState());
							#end
							#if ACHIEVEMENTS_ALLOWED
							case 'awards':
								MusicBeatState.switchState(new AchievementsMenuState());
							#end
							case 'credits':
								MusicBeatState.switchState(new CreditsState());
							case 'options':
								LoadingState.loadAndSwitchState(new OptionsState());
						}
					});
				}
			});
		}
	}
}