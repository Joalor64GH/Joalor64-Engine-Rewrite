package meta.data.options;

#if desktop
import meta.data.dependency.Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import lime.app.Application;

import meta.*;
import meta.data.*;
import meta.data.alphabet.*;
import meta.data.options.*;

import meta.state.*;
import meta.state.error.*;
import meta.substate.*;

using StringTools;

class OptionsState extends MusicBeatState
{
	var options:Array<String> = [
		#if (MODS_ALLOWED && FUTURE_POLYMOD) 'Mod Options', #end
		'Note Colors', 
		'Controls', 
		'Visuals',
		'Gameplay',
		'Offsets', 
		'Miscellaneous'
	];

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private static var curSelected:Int = 0;

	function openSelectedSubstate(label:String) {
		switch(label) {
			#if (MODS_ALLOWED && FUTURE_POLYMOD)
			case 'Mod Options':
			    	if (Paths.optionsExist())
					FlxG.switchState(new ModOptionSelectState());
				else
					FlxG.switchState(new OopsState());
			#end
			case 'Note Colors':
				if(ClientPrefs.arrowMode == 'RGB')
					openSubState(new NotesRGBSubState());
				else
					openSubState(new NotesHSVSubState());
			case 'Controls':
				openSubState(new ControlsSubState());
			case 'Visuals':
				openSubState(new VisualsSubState());
			case 'Gameplay':
				openSubState(new GameplaySubState());
			case 'Offsets':
				LoadingState.loadAndSwitchState(new NoteOffsetState());
			case 'Miscellaneous':
				openSubState(new MiscSubState());
		}
	}

	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;

	override function create() {
		#if desktop
		DiscordClient.changePresence("Options Menu", null);
		#end

		Application.current.window.title = Application.current.meta.get('name');

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xFFea71fd;
		bg.updateHitbox();

		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);
		
		initOptions();

		selectorLeft = new Alphabet(0, 0, '>', true);
		add(selectorLeft);
		selectorRight = new Alphabet(0, 0, '<', true);
		add(selectorRight);

		changeSelection();
		ClientPrefs.saveSettings();

		super.create();
	}

	function initOptions() {
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

	override function closeSubState() {
		super.closeSubState();
		ClientPrefs.saveSettings();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (controls.UI_UP_P || controls.UI_DOWN_P) {
			changeSelection(controls.UI_UP_P ? -1 : 1);
		}

		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			if (PauseSubState.fromPlayState) {
				StageData.loadDirectory(PlayState.SONG);
				LoadingState.loadAndSwitchState(new PlayState());
			} else {
				if (ClientPrefs.simpleMain)
					MusicBeatState.switchState(new SimpleMainMenuState());
				else
					MusicBeatState.switchState(new MainMenuState());
			}
		}

		if (controls.ACCEPT) {
			openSelectedSubstate(options[curSelected]);
		}
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