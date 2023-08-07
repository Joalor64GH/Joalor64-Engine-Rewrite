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
import haxe.Json;

import meta.*;
import meta.data.*;
import meta.state.*;
import meta.data.alphabet.*;
import meta.data.options.*;

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

class ExtrasMenuState extends MusicBeatState
{
	public static var curSelected:Int = 0;

	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;

	public static var firstStart:Bool = true;
	public static var finishedFunnyMove:Bool = false;
	
	var menuItems:FlxTypedGroup<FlxSprite>;

	var optionShit:Array<String> = [];
	var linkArray:Array<Array<String>> = [];

	var bg:FlxSprite;
	var magenta:FlxSprite;

	var camFollow:FlxObject;
	var camFollowPos:FlxObject;

	var invalidPosition:Null<Int> = null;

	var menuJSON:MenuData;

	override function create()
	{
		menuJSON = Json.parse(Paths.getTextFromFile('images/mainmenu/menu_preferences_extra.json'));

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

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
				'mini',
				#if !switch 
				'kickstarter',
				'discord',
				'manual',
				#end
				'more'
			];
		}

		for (i in menuJSON.links)
		{
			linkArray.push(i);
		}

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
			FlxTween.tween(menuItem, {x: menuItem.width / 4 + (i * 60) - 55}, 1.3, {ease: FlxEase.expoInOut});
			menuItems.add(menuItem);
			menuItem.scrollFactor.set(0, 1);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			menuItem.updateHitbox();
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

		FlxG.camera.follow(camFollowPos, null, 1);

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P || controls.UI_DOWN_P) {
				changeItem(controls.UI_UP_P ? -1 : 1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == '${menuJSON.links[0]}') 
				{
					CoolUtil.browserLoad('${menuJSON.links[1]}');
				} 
				else if (optionShit[curSelected] == 'discord') 
				{
					CoolUtil.browserLoad('https://discord.gg/GnXqAVMFbA');
				}
				else if (optionShit[curSelected] == 'manual') 
				{
					CoolUtil.browserLoad('https://github.com/Joalor64GH/Joalor64-Engine-Rewrite/wiki');
				}
				else if (optionShit[curSelected] == 'kickstarter')
				{
					CoolUtil.browserLoad('https://www.kickstarter.com/projects/funkin/friday-night-funkin-the-full-ass-game');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					if (ClientPrefs.flashing)
						FlxFlicker.flicker(magenta, 1.1, 0.15, false);

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
									case 'mini':
										Main.toast.create('WIP', 0xFFFFFF00, 'This menu is a wip!');
									case 'more':
										MusicBeatState.switchState(new EpicState());
								}
							});
						}
					});
				}
			}

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

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach((spr:FlxSprite) ->
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				var add:Float = 0;
				if(menuItems.length > 4) 
					add = menuItems.length * 8;
				
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
				spr.centerOffsets();
			}
		});
	}
}