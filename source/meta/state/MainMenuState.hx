package meta.state;

#if desktop
import meta.data.dependency.Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import flixel.input.keyboard.FlxKey;
import openfl.Assets;
import meta.data.Achievements;
import openfl.media.Video;
import haxe.Json;

import meta.*;
import meta.data.*;
import meta.state.*;
import meta.video.*;
import meta.data.alphabet.*;
import meta.data.options.*;
import meta.state.editors.*;
import system.*;

import core.ToastCore;

#if (MODS_ALLOWED && FUTURE_POLYMOD)
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

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
	public static var joalor64EngineVersion:String = '1.3.0'; //This is also used for Discord RPC
	public static var psychEngineVersion:String = '0.6.3';
	public static var psychGitBuild:String = 'eb79a80';  
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	public static var firstStart:Bool = true;
	public static var finishedFunnyMove:Bool = false;
	
	var optionShit:Array<String> = [];
	var linkArray:Array<Array<String>> = [];

	var tipTextMargin:Float = 10;
	var tipTextScrolling:Bool = false;

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;

	var debugKeys:Array<FlxKey>;
	var modShortcutKeys:Array<FlxKey>;

	var tipBackground:FlxSprite;
	var tipText:FlxText;

	var invalidPosition:Null<Int> = null;

	var menuJSON:MenuData;

	#if !mac
	var name:String = Sys.environment()["USERNAME"];
	#else
	var name:String = Sys.environment()["USER"];
	#end

	override function create()
	{
		#if (MODS_ALLOWED && FUTURE_POLYMOD)
		Paths.pushGlobalMods();
		#end
		WeekData.loadTheFirstEnabledMod();
		menuJSON = Json.parse(Paths.getTextFromFile('images/mainmenu/menu_preferences.json'));

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));
		modShortcutKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_2'));

		#if desktop
		trace(Sys.environment()["COMPUTERNAME"]); // sussy test for a next menu x1
		#end

		trace(name);

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
			optionShit = [
				'story_mode',
				'freeplay',
				#if (MODS_ALLOWED && FUTURE_POLYMOD) 'mods',
				#end
				#if ACHIEVEMENTS_ALLOWED
				'awards',
				#end
				'credits',
				#if !switch 'donate',
				#end
				'options'
			];
		}

		for (i in menuJSON.links)
		{
			linkArray.push(i);
		}

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite();
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
		bg.setGraphicSize(Std.int(bg.width * 1.175));
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
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
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
			if (firstStart)
				FlxTween.tween(menuItem,{y: 60 + (i * 160)},1 + (i * 0.25) ,{ease: FlxEase.expoInOut, onComplete: function(flxTween:FlxTween) 
					{
						finishedFunnyMove = true; 
						changeItem();
					}
				});
			else
				menuItem.y = 60 + (i * 160);
		}

		FlxG.camera.follow(camFollowPos, null, 1);

		// The system says hi :)
		#if debug
		var versionShit:FlxText = new FlxText(12, FlxG.height - 104, 0, 'Hello ${CoolSystemStuff.getUsername()} having a good day? im proud of you! :)', 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		#end

		// Joalor64 Engine
		var versionShit:FlxText = new FlxText(12, FlxG.height - 64, 0, 'Joalor64 Engine Rewritten v$joalor64EngineVersion', 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// Psych Engine
		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, 'Psych Engine v$psychEngineVersion [$psychGitBuild]', 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// FNF
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		tipBackground = new FlxSprite();
		tipBackground.scrollFactor.set();
		tipBackground.alpha = 0.7;
		add(tipBackground);

		tipText = new FlxText(0, 0, 0,
			"Welcome to Joalor64 Engine Rewritten! This is a complete remake of the original that changes a lot of stuff, but still retains the \"vibe\" of the original. Credits go to ShadowMario for Psych Engine. Thank you!");
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
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var selectedSomethin:Bool = false;

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

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == '${menuJSON.links[0]}') {
					CoolUtil.browserLoad('${menuJSON.links[1]}');
				}
				else if (optionShit[curSelected] == 'donate') {
					CoolUtil.browserLoad(Assets.getText(Paths.txt('donate_button_link')));
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					if (ClientPrefs.flashing)
						FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
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
									#if (MODS_ALLOWED && FUTURE_POLYMOD)
									case 'mods':
										MusicBeatState.switchState(new ModsMenuState());
									#end
									case 'awards':
										MusicBeatState.switchState(new AchievementsMenuState());
									case 'credits':
										MusicBeatState.switchState(new CreditsState());
									case 'options':
										LoadingState.loadAndSwitchState(new OptionsState());
									default:
										Main.toast.create('Oops!', 0xFFFFFF00, 'State not found!');
								}
							});
						}
					});
				}
			}
			#if (MODS_ALLOWED && FUTURE_POLYMOD)
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			else if (FlxG.keys.anyJustPressed(modShortcutKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new ModsMenuState());
			}
			#end

            		#if debug
			if (FlxG.keys.justPressed.FOUR)
			{
				MusicBeatState.switchState(new VideoState("assets/videos/cutscenetest/video.webm", new MainMenuState()));
			}
			#end

			if (controls.RESET && menuJSON.enableReloadKey)
				FlxG.resetState();
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
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

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				var add:Float = 0;
				if(menuItems.length > 4) {
					add = menuItems.length * 8;
				}
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
				spr.centerOffsets();
			}
		});
	}
}