package meta.state;

#if desktop
import meta.data.dependency.Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.effects.FlxFlicker;
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
		'Minigames',
		#if (MODS_ALLOWED && FUTURE_POLYMOD) 'Mods', #end
		#if ACHIEVEMENTS_ALLOWED 'Awards', #end
		'Credits',
		'Options'
	];

	var debugKeys:Array<FlxKey>;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private static var curSelected:Int = 0;

	private var camAchievement:FlxCamera;

	function openSelectedSubstate(label:String) {
		switch(label) {
			case 'Story Mode':
				MusicBeatState.switchState(new StoryMenuState());
			case 'Freeplay':
				MusicBeatState.switchState(new FreeplayState());
			case 'Minigames':
				MusicBeatState.switchState(new MinigamesState());
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

	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var camMain:FlxCamera;

	var bg:FlxSprite;

	override function create() 
	{
		#if desktop
		DiscordClient.changePresence("Simple Main Menu", null);
		#end

		#if (MODS_ALLOWED && FUTURE_POLYMOD)
		Mods.pushGlobalMods();
		#end

		Mods.loadTheFirstEnabledMod();

		Application.current.window.title = "Friday Night Funkin': Joalor64 Engine Rewritten";

		camMain = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camMain);
		FlxG.cameras.add(camAchievement, false);
		FlxG.cameras.setDefaultDrawTarget(camMain, true);

		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, null, 1);

		var yScroll:Float = Math.max(0.25 - (0.05 * (options.length - 4)), 0.1);
		bg = new FlxSprite().loadGraphic(Paths.image('menuBG'));
		bg.updateHitbox();
		bg.screenCenter();
		bg.scrollFactor.set(0, yScroll / 3);
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		initOptions();

		var versionShit:FlxText = new FlxText(12, FlxG.height - 64, 0, "Joalor64 Engine Rewritten v" + MainMenuState.joalor64EngineVersion #if nightly + MainMenuState.nightly #end, 12);
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
		selectorLeft.scrollFactor.set(0, yScroll);
		add(selectorLeft);
		selectorRight = new Alphabet(0, 0, '<', true);
		selectorRight.scrollFactor.set(0, yScroll);
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

	function initOptions() {
		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			var optionText:Alphabet = new Alphabet(0, 0, options[i], true);
			optionText.screenCenter();
			optionText.y += (100 * (i - (options.length / 2))) + 50;
			optionText.scrollFactor.set(0, Math.max(0.25 - (0.05 * (options.length - 4)), 0.1));
			grpOptions.add(optionText);
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		var lerpVal:Float = CoolUtil.clamp(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
	
		var mult:Float = FlxMath.lerp(1.07, bg.scale.x, CoolUtil.clamp(1 - (elapsed * 9), 0, 1));
		bg.scale.set(mult, mult);
		bg.updateHitbox();
		bg.offset.set();

		if (FlxG.keys.justPressed.E)
			MusicBeatState.switchState(new EpicState());

		if (controls.UI_UP_P || controls.UI_DOWN_P) {
			changeSelection(controls.UI_UP_P ? -1 : 1);
		}

		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new TitleState());
		}

		if (controls.ACCEPT)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			if (ClientPrefs.flashing) {
				grpOptions.forEach(function(grpOptions:Alphabet)
				{
					FlxFlicker.flicker(grpOptions, 1, 0.06, false, false, function(flick:FlxFlicker)
					{
						openSelectedSubstate(options[curSelected]);
					});
				});
			} else {
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					openSelectedSubstate(options[curSelected]);
				});
			}
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
				var add:Float = (grpOptions.members.length > 4 ? grpOptions.members.length * 8 : 0);
				camFollow.setPosition(item.getGraphicMidpoint().x, item.getGraphicMidpoint().y - add);
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}