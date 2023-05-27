package meta.state;

#if desktop
import meta.data.dependency.Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.addons.transition.FlxTransitionableState;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.effects.FlxFlicker;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import lime.app.Application;
import meta.*;
import meta.data.*;
import meta.data.alphabet.*;
import meta.data.options.*;
import meta.state.editors.*;
import meta.state.*;

import meta.data.Achievements;

using StringTools;

class SimpleMainMenuState extends MusicBeatState
{
	var options:Array<String> = [
		'Story Mode',
		'Freeplay',
        	#if (MODS_ALLOWED && FUTURE_POLYMOD) 'Mods', #end
        	#if ACHIEVEMENTS_ALLOWED 'Awards', #end
		'Credits',
		'Options'
	];

    	var debugKeys:Array<FlxKey>;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;

	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;

	var camFollow:FlxObject;
	var camFollowPos:FlxObject;

	function openSelectedSubstate(label:String) {
		switch(label) {
			case 'Story Mode':
				MusicBeatState.switchState(new StoryMenuState());
			case 'Freeplay':
				MusicBeatState.switchState(new FreeplayState());
            		#if (MODS_ALLOWED && FUTURE_POLYMOD)
			case 'Mods':
				MusicBeatState.switchState(new ModsMenuState());
            		#end
			case 'Awards':
				MusicBeatState.switchState(new AchievementsMenuState());
			case 'Credits':
				MusicBeatState.switchState(new CreditsState());
			case 'Options':
				MusicBeatState.switchState(new OptionsState());
		}
	}

	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;

	override function create() 
	{
		#if (MODS_ALLOWED && FUTURE_POLYMOD)
		Paths.pushGlobalMods();
		#end
		
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		DiscordClient.changePresence("Simple Main Menu Menu", null);
		#end

		Application.current.window.title = "Friday Night Funkin': Joalor64 Engine Rewritten";

		camGame = new FlxCamera();
        	camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
        	FlxG.cameras.add(camAchievement, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

        	debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBG'));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);
		FlxG.camera.follow(camFollowPos, null, 1);

        	initOptions();

        	var versionShit:FlxText = new FlxText(12, FlxG.height - 64, 0, "Joalor64 Engine Rewritten v" + MainMenuState.joalor64EngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + MainMenuState.psychEngineVersion + " [" + MainMenuState.psychGitBuild + "]", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		selectorLeft = new Alphabet(0, 0, '>', true);
		add(selectorLeft);
		selectorRight = new Alphabet(0, 0, '<', true);
		add(selectorRight);

		changeSelection();

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

    	override function closeSubState()
	{
		super.closeSubState();
	}

    	function initOptions() 
		{
        	grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			var optionText:Alphabet = new Alphabet(0, 0, options[i], true);
			optionText.screenCenter();
			optionText.y += (100 * (i - (options.length / 2))) + 50;
			grpOptions.add(optionText);
		}
    	}

	override function update(elapsed:Float) 
	{
		super.update(elapsed);

		if (controls.UI_UP_P) {
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P) {
			changeSelection(1);
		}

		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new TitleState());
		}

		if (controls.ACCEPT && ClientPrefs.flashing)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			grpOptions.forEach(function(grpOptions:Alphabet)
			{
				FlxFlicker.flicker(grpOptions, 1, 0.06, false, false, function(flick:FlxFlicker)
				{
					openSelectedSubstate(options[curSelected]);
				});
			});
		}

		if (controls.ACCEPT && !ClientPrefs.flashing)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				openSelectedSubstate(options[curSelected]);
			});
		}

        	#if desktop
		else if (FlxG.keys.anyJustPressed(debugKeys))
		{
			MusicBeatState.switchState(new MasterEditorMenu());
		}
		#end
	}
	
	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0) {
				item.alpha = 1;
				selectorLeft.x = item.x - 63;
				selectorLeft.y = item.y;
				selectorRight.x = item.x + item.width + 15;
				selectorRight.y = item.y;
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}