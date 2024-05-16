package meta.state;

#if desktop
import meta.data.dependency.Discord.DiscordClient;
#end

import flixel.effects.FlxFlicker;
import flixel.input.keyboard.FlxKey;

import system.CoolSystemStuff;
import meta.data.Achievements;

#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end

enum MainMenuColumn {
	LEFT;
	CENTER;
	RIGHT;
}

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
	public static var joalor64EngineVersion:String = '1.4.0b'; // Used for Discord RPC
	public static var psychEngineVersion:String = '0.6.3';
	public static var psychGitBuild:String = 'eb79a80';  

	public static var curSelected:Int = 0;
	public static var firstStart:Bool = true;
	public static var finishedFunnyMove:Bool = false;
	public static var curColumn:MainMenuColumn = CENTER;

	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var menuItems:FlxTypedGroup<FlxSprite>;
	var optionShit:Array<String> = [];
	var linkArray:Array<Array<String>> = [];

	var leftItem:FlxSprite;
	var rightItem:FlxSprite;
	var leftOption:String = #if ACHIEVEMENTS_ALLOWED 'achievements' #else null #end;
	var rightOption:String = 'options';

	var bg:FlxSprite;
	var magenta:FlxSprite;

	var camFollow:FlxObject;
	var camFollowPos:FlxObject;

	var debugKeys:Array<FlxKey>;
	var modShortcutKeys:Array<FlxKey>;

	var tipTextMargin:Float = 10;
	var tipTextScrolling:Bool = false;
	var tipBackground:FlxSprite;
	var tipText:FlxText;

	var invalidPosition:Null<Int> = null;
	var menuJSON:MenuData;

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
		{
			optionShit = menuJSON.options;
		}
		else
		{
			optionShit = 
			[
				'play',
				#if MODS_ALLOWED 'mods',
				#end
				'credits',
				#if !switch 
				'manual',
				'donate'
				#end
			];
		}

		for (i in menuJSON.links)
			linkArray.push(i);

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);

		bg = new FlxSprite();
		bg.loadGraphic(Paths.image('menuBG'));

		if (menuJSON.backgroundStatic != null && menuJSON.backgroundStatic.length > 0 && menuJSON.backgroundStatic != "none")
			bg.loadGraphic(Paths.image(menuJSON.backgroundStatic));
		else
			bg.loadGraphic(Paths.image('menuBG'));

		if (menuJSON.bgX != invalidPosition)
			bg.x = menuJSON.bgX;
		if (menuJSON.bgY != invalidPosition)
			bg.y = menuJSON.bgY;
		else
			bg.y = -80;

		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.2));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		magenta = new FlxSprite();

		if (menuJSON.backgroundConfirm != null && menuJSON.backgroundConfirm.length > 0 && menuJSON.backgroundConfirm != "none")
			magenta.loadGraphic(Paths.image(menuJSON.backgroundConfirm));
		else
			magenta.loadGraphic(Paths.image('menuDesat'));

		if (menuJSON.bgX != invalidPosition)
			magenta.x = menuJSON.bgX;
		if (menuJSON.bgY != invalidPosition)
			magenta.y = menuJSON.bgY;
		else
			magenta.y = -80;

		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.2));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		if (menuJSON.colorOnConfirm != null && menuJSON.colorOnConfirm.length > 0)
			magenta.color = FlxColor.fromRGB(menuJSON.colorOnConfirm[0], menuJSON.colorOnConfirm[1], menuJSON.colorOnConfirm[2]);
		else
			magenta.color = 0xFFfd719b;

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

			if (menuJSON.scaleX != invalidPosition)
				menuItem.scale.x = menuJSON.scaleX;
			else
				menuItem.scale.x = scale;

			if (menuJSON.scaleY != invalidPosition)
				menuItem.scale.y = menuJSON.scaleY;
			else
				menuItem.scale.y = scale;

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
		}

		if (leftOption != null)
			leftItem = createMenuItem(leftOption, 60, 490);
		if (rightOption != null)
		{
			rightItem = createMenuItem(rightOption, FlxG.width - 60, 490);
			rightItem.x -= rightItem.width;
		}

		firstStart = false;

		FlxG.camera.follow(camFollowPos, null, 0.2);

		// The system says hi :)
		#if debug
		var versionShit:FlxText = new FlxText(12, FlxG.height - 104, 0, 'Hello ${CoolSystemStuff.getUsername()} having a good day? im proud of you! :)', 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		#end

		// Watermarks
		var versionShitArray:Array<String> = [
			'Joalor64 Engine Rewritten v$joalor64EngineVersion' + nightly,
			'Psych Engine v$psychEngineVersion [$psychGitBuild]',
			"Friday Night Funkin' v" + Application.current.meta.get('version')
		];
		versionShitArray.reverse();
		for (i in 0...versionShitArray.length) {
			var versionShit:FlxText = new FlxText(12, (FlxG.height - 24) - (18 * i), 0, versionShitArray[i], 12);
			versionShit.scrollFactor.set();
			versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			add(versionShit);
		}

		tipBackground = new FlxSprite();
		tipBackground.scrollFactor.set();
		tipBackground.alpha = 0.7;
		add(tipBackground);

		tipText = new FlxText(0, 0, 0,
			"Welcome to Joalor64 Engine Rewritten! This is a complete remake of the original that changes a lot of stuff, but still retains the \"vibe\" of the original. Credits go to ShadowMario for Psych Engine. Thanks for playing!");
		tipText.scrollFactor.set();
		tipText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, LEFT);
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
	}

	function createMenuItem(name:String, x:Float, y:Float):FlxSprite
	{
		var menuItem:FlxSprite = new FlxSprite(x, y);
		menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_$name');
		menuItem.animation.addByPrefix('idle', '$name idle', 24, true);
		menuItem.animation.addByPrefix('selected', '$name selected', 24, true);
		menuItem.animation.play('idle');
		menuItem.updateHitbox();
		
		menuItem.antialiasing = ClientPrefs.globalAntialiasing;
		menuItem.scrollFactor.set();
		if (firstStart)
			FlxTween.tween(menuItem, {alpha: 1}, 1, {ease: FlxEase.quadOut});
		menuItems.add(menuItem);
		return menuItem;
	}

	#if ACHIEVEMENTS_ALLOWED
	function giveAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
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

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (FlxG.keys.justPressed.E)
			FlxG.switchState(() -> new EpicState());
		
		if (!selectedSomethin)
		{
			if (controls.UI_UP_P || controls.UI_DOWN_P) {
				changeItem(controls.UI_UP_P ? -1 : 1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if (FlxG.mouse.deltaScreenX != 0 && FlxG.mouse.deltaScreenY != 0)
			{
				FlxG.mouse.visible = true;
				timeNotMoving = 0;

				var selectedItem:FlxSprite;
				switch(curColumn)
				{
					case CENTER:
						selectedItem = menuItems.members[curSelected];
					case LEFT:
						selectedItem = leftItem;
					case RIGHT:
						selectedItem = rightItem;
				}

				if(leftItem != null && FlxG.mouse.overlaps(leftItem))
				{
					if(selectedItem != leftItem)
					{
						curColumn = LEFT;
						changeItem();
					}
				}
				else if(rightItem != null && FlxG.mouse.overlaps(rightItem))
				{
					if(selectedItem != rightItem)
					{
						curColumn = RIGHT;
						changeItem();
					}
				}
				else
				{
					var dist:Float = -1;
					var distItem:Int = -1;
					for (i in 0...optionShit.length)
					{
						var memb:FlxSprite = menuItems.members[i];
						if(FlxG.mouse.overlaps(memb))
						{
							var distance:Float = Math.sqrt(Math.pow(memb.getGraphicMidpoint().x - FlxG.mouse.screenX, 2) + Math.pow(memb.getGraphicMidpoint().y - FlxG.mouse.screenY, 2));
							if (dist < 0 || distance < dist)
							{
								dist = distance;
								distItem = i;
							}
						}
					}

					if(distItem != -1 && curSelected != distItem)
					{
						curColumn = CENTER;
						curSelected = distItem;
						changeItem();
					}
				}
			}
			else
			{
				timeNotMoving += elapsed;
				if(timeNotMoving > 1) FlxG.mouse.visible = false;
			}

			switch (curColumn)
			{
				case CENTER:
					if(controls.UI_LEFT_P && leftOption != null)
					{
						curColumn = LEFT;
						changeItem();
					}
					else if(controls.UI_RIGHT_P && rightOption != null)
					{
						curColumn = RIGHT;
						changeItem();
					}

				case LEFT:
					if(controls.UI_RIGHT_P)
					{
						curColumn = CENTER;
						changeItem();
					}

				case RIGHT:
					if(controls.UI_LEFT_P)
					{
						curColumn = CENTER;
						changeItem();
					}
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.mouse.visible = false;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.switchState(() -> new TitleState());
			}

			if (controls.ACCEPT || FlxG.mouse.justPressed)
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

					if (ClientPrefs.flashing)
						FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					var item:FlxSprite;
					var option:String;
					switch(curColumn)
					{
						case CENTER:
							option = optionShit[curSelected];
							item = menuItems.members[curSelected];

						case LEFT:
							option = leftOption;
							item = leftItem;

						case RIGHT:
							option = rightOption;
							item = rightItem;
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
									case 'play':
										FlxG.switchState(() -> new PlayMenuState());
									#if MODS_ALLOWED
									case 'mods':
										FlxG.switchState(() -> new ModsMenuState());
									#end
									#if ACHIEVEMENTS_ALLOWED
									case 'achievements':
										FlxG.switchState(() -> new AchievementsMenuState());
									#end
									case 'credits':
										FlxG.switchState(() -> new CreditsState());
									case 'donate':
										FlxG.switchState(() -> new DonateScreenState());
									case 'options':
										LoadingState.loadAndSwitchState(() -> new OptionsState());
								}
							});
						}
					});
				}
			}
			#if MODS_ALLOWED
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				FlxG.switchState(() -> new MasterEditorMenu());
			}
			else if (FlxG.keys.anyJustPressed(modShortcutKeys))
			{
				selectedSomethin = true;
				FlxG.switchState(() -> new ModsMenuState());
			}
			#end

			#if debug
			if (FlxG.keys.justPressed.FOUR)
				FlxG.switchState(() -> new VideoState("assets/videos/cutscenetest/video.webm", () -> new MainMenuState()));
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
		{
			if(change != 0) curColumn = CENTER;
			curSelected = FlxMath.wrap(curSelected + change, 0, optionShit.length - 1);
		}

		for (item in menuItems)
		{
			item.animation.play('idle');
			item.centerOffsets();
		}

		var selectedItem:FlxSprite;
		switch(curColumn)
		{
			case CENTER:
				selectedItem = menuItems.members[curSelected];
			case LEFT:
				selectedItem = leftItem;
			case RIGHT:
				selectedItem = rightItem;
		}
		selectedItem.animation.play('selected');
		selectedItem.centerOffsets();
		camFollow.y = selectedItem.getGraphicMidpoint().y;
	}
}