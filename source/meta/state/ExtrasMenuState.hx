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
import flixel.input.keyboard.FlxKey;
import openfl.Assets;
import haxe.Json;

import meta.*;
import meta.data.*;
import meta.state.*;
import meta.data.alphabet.*;

import core.ToastCore;

#if (MODS_ALLOWED && FUTURE_POLYMOD)
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

typedef MenuDataExtra =
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

	var menuJSONExtra:MenuDataExtra;

	override function create()
	{
		menuJSONExtra = Json.parse(Paths.getTextFromFile('images/mainmenu/menu_preferences_extra.json'));

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

		if (menuJSONExtra.options != null && menuJSONExtra.options.length > 0 && menuJSONExtra.options.length < 13)
		{
			optionShit = menuJSONExtra.options;
		}
		else
		{
			optionShit = 
			[
				'mini',
				#if !switch 
				'manual',
				'kickstarter',
				#end
			];
		}

		for (i in menuJSONExtra.links)
		{
			linkArray.push(i);
		}

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);

		bg = new FlxSprite();
		bg.loadGraphic(Paths.image('menuBG'));

		if (menuJSONExtra.backgroundStatic != null && menuJSONExtra.backgroundStatic.length > 0 && menuJSONExtra.backgroundStatic != "none")
			bg.loadGraphic(Paths.image(menuJSONExtra.backgroundStatic));
		else
			bg.loadGraphic(Paths.image('menuBG'));

		if (menuJSONExtra.bgX != invalidPosition)
			bg.x = menuJSONExtra.bgX;
		if (menuJSONExtra.bgY != invalidPosition)
			bg.y = menuJSONExtra.bgY;
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

		if (menuJSONExtra.backgroundConfirm != null && menuJSONExtra.backgroundConfirm.length > 0 && menuJSONExtra.backgroundConfirm != "none")
			magenta.loadGraphic(Paths.image(menuJSONExtra.backgroundConfirm));
		else
			magenta.loadGraphic(Paths.image('menuDesat'));

		if (menuJSONExtra.bgX != invalidPosition)
			magenta.x = menuJSONExtra.bgX;
		if (menuJSONExtra.bgY != invalidPosition)
			magenta.y = menuJSONExtra.bgY;
		else
			magenta.y = -80;

		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.2));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		if (menuJSONExtra.colorOnConfirm != null && menuJSONExtra.colorOnConfirm.length > 0)
			magenta.color = FlxColor.fromRGB(menuJSONExtra.colorOnConfirm[0], menuJSONExtra.colorOnConfirm[1], menuJSONExtra.colorOnConfirm[2]);
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

			if (menuJSONExtra.optionX != invalidPosition)
				menuItem.x = menuJSONExtra.optionX;
			if (menuJSONExtra.optionY != invalidPosition)
				menuItem.y = menuJSONExtra.optionY;

			if (menuJSONExtra.angle != invalidPosition)
				menuItem.angle = menuJSONExtra.angle;

			if (menuJSONExtra.scaleX != invalidPosition)
				menuItem.scale.x = menuJSONExtra.scaleX;
			else
				menuItem.scale.x = scale;

			if (menuJSONExtra.scaleY != invalidPosition)
				menuItem.scale.y = menuJSONExtra.scaleY;
			else
				menuItem.scale.y = scale;

			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			if (menuJSONExtra.alignToCenter)
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

		if (FlxG.keys.justPressed.E)
			MusicBeatState.switchState(new EpicState());
		
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
				if (optionShit[curSelected] == '${menuJSONExtra.links[0]}') 
				{
					CoolUtil.browserLoad('${menuJSONExtra.links[1]}');
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
										MusicBeatState.switchState(new MinigamesState());
								}
							});
						}
					});
				}
			}

			if (controls.RESET && menuJSONExtra.enableReloadKey)
				FlxG.resetState();
		}

		super.update(elapsed);

		menuItems.forEach((spr:FlxSprite) -> 
		{
			if (menuJSONExtra.centerOptions) 
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