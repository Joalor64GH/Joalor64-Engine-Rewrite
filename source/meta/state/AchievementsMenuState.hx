package meta.state;

import meta.data.Achievements;

class AchievementsMenuState extends MusicBeatState
{
	#if ACHIEVEMENTS_ALLOWED
	var options:Array<String> = [];
	private var grpOptions:FlxTypedGroup<Alphabet>;
	private static var curSelected:Int = 0;
	private var achievementArray:Array<AttachedAchievement> = [];
	private var achievementIndex:Array<Int> = [];
	private var descText:FlxText;

	override function create() {
		#if desktop
		DiscordClient.changePresence("Achievements Menu", null);
		#end

		#if sys
		ArtemisIntegration.setBackgroundColor ("#FF9271FD");
		ArtemisIntegration.setGameState ("menu");
		ArtemisIntegration.resetModName ();
		#end

		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = ClientPrefs.globalAntialiasing;
		add(menuBG);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		Achievements.loadAchievements();
		for (i in 0...Achievements.achievementsStuff.length) {
			if(!Achievements.achievementsStuff[i][3] || Achievements.achievementsMap.exists(Achievements.achievementsStuff[i][2])) {
				options.push(Achievements.achievementsStuff[i]);
				achievementIndex.push(i);
			}
		}

		for (i in 0...options.length) {
			var achieveName:String = Achievements.achievementsStuff[achievementIndex[i]][2];
			var optionText:Alphabet = new Alphabet(280, 300, Achievements.isAchievementUnlocked(achieveName) ? Achievements.achievementsStuff[achievementIndex[i]][0] : '?', false);
			optionText.isMenuItem = true;
			optionText.targetY = i - curSelected;
			optionText.snapToPosition();
			grpOptions.add(optionText);

			var icon:AttachedAchievement = new AttachedAchievement(optionText.x - 105, optionText.y, achieveName);
			icon.sprTracker = optionText;
			achievementArray.push(icon);
			add(icon);
		}

		descText = new FlxText(150, 600, 980, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);

		var resetText:FlxText = new FlxText(12, FlxG.height - 24, 0, "Press R to reset the currently selected achievement. Press ALT + R to reset all achievements.", 12);
		resetText.borderSize = 5;
		resetText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		resetText.scrollFactor.set();
		add(resetText);

		FlxG.mouse.visible = true;

		changeSelection();

		super.create();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (controls.UI_UP_P || controls.UI_DOWN_P)
			changeSelection(controls.UI_UP_P ? -1: 1);
		
		if (controls.RESET) {
			if(FlxG.keys.pressed.ALT) {
				openSubState(new Prompt('This action will reset ALL of the achievements.\nProceed?', 0, function() {
					FlxG.sound.play(Paths.sound('confirmMenu'));
					for (i in 0...achievementArray.length) {
						achievementArray[i].forget();
						grpOptions.members[i].text = '?';
					}
				}, function() {
					FlxG.sound.play(Paths.sound('cancelMenu'));
				}, false));
			} else {
				openSubState(new Prompt('This action will reset the selected achievement.\nProceed?', 0, function() {
					FlxG.sound.play(Paths.sound('confirmMenu'));
					achievementArray[curSelected].forget();
					grpOptions.members[curSelected].text = '?';
				}, function() {
					FlxG.sound.play(Paths.sound('cancelMenu'));
				}, false));
			}
 		}

		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			if (ClientPrefs.simpleMain)
				MusicBeatState.switchState(new SimpleMainMenuState());
			else
				MusicBeatState.switchState(new MainMenuState());
		}

		for (num => item in grpOptions.members) {
			item.targetY = num - curSelected;
			item.alpha = (item.targetY == 0) ? 1 : 0.6;
		}
	}

	function changeSelection(change:Int = 0) {
		curSelected = FlxMath.wrap(curSelected + change, 0, options.length - 1);

		for (i in 0...achievementArray.length)
			achievementArray[i].alpha = (i == curSelected) ? 1 : 0.6;
		
		descText.text = Achievements.achievementsStuff[achievementIndex[curSelected]][1];
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
	}
	#end
}