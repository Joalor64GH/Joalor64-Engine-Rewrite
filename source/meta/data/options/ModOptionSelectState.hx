package meta.data.options;

#if desktop
import meta.data.dependency.Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.transition.FlxTransitionableState;
import flixel.util.FlxColor;

import meta.*;
import meta.data.*;
import meta.data.alphabet.*;
import meta.data.options.*;

using StringTools;

class ModOptionSelectState extends MusicBeatState
{
	private var mods:Array<String>;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;

	function openSelectedSubstate(label:String) {
		switch(label) {
			case 'Global':
                		openSubState(new ModOptions());
            		default:
                		openSubState(new ModOptions(label));
		}
	}

	override function create() {
		#if desktop
		DiscordClient.changePresence("Mod Menu", null);
		#end

        	mods = Mods.getModDirectories();
        	mods.insert(0, 'Global');

		for (mod in mods) {
			if (!Paths.optionsExist(mod == 'Global' ? '' : mod)) {
				mods.remove(mod);
			}
		}

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xFFea71fd;
		bg.updateHitbox();

		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...mods.length)
		{
			var optionText:Alphabet = new Alphabet(0, 0, mods[i], true);
			optionText.screenCenter();
			optionText.y += (80 * i) + 50;

			optionText.isMenuItem = true;
			optionText.targetY = i;
			optionText.alignment = CENTERED;
			optionText.distancePerItem.x = 0;
			optionText.startPosition.x = FlxG.width / 2;
			optionText.startPosition.y = 100;

			grpOptions.add(optionText);
		}

		changeSelection();

		super.create();
	}

	override function closeSubState() {
		super.closeSubState();
		ClientPrefs.saveSettings();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (controls.UI_UP_P || controls.UI_DOWN_P)
			changeSelection(controls.UI_UP_P ? -1 : 1);

		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
            		FlxTransitionableState.skipNextTransIn = true;
           		FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new OptionsState());		
        	}

		if (controls.ACCEPT) {
			openSelectedSubstate(mods[curSelected]);
		}
	}

	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = mods.length - 1;
		if (curSelected >= mods.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0) {
				item.alpha = 1;
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}