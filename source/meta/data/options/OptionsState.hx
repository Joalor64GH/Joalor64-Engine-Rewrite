package meta.data.options;

#if desktop
import meta.data.dependency.Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.util.FlxColor;
import lime.app.Application;

import core.ToastCore;

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
		'Offsets',
		'Visuals',
		'Gameplay', 
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
					Main.toast.create('No mod options exist!', 0xFFFFFF00, 'Please add your custom options to access this menu!');
			#end
			case 'Note Colors':
				openSubState(new NotesSubState());
			case 'Controls':
				openSubState(new ControlsSubState());
			case 'Offsets':
				MusicBeatState.switchState(new NoteOffsetState());
			case 'Visuals':
				openSubState(new VisualsSubState());
			case 'Gameplay':
				openSubState(new GameplaySubState());
			case 'Miscellaneous':
				openSubState(new MiscSubState());
		}
	}

	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;

	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var camMain:FlxCamera;
	var camSub:FlxCamera;

	var bg:FlxSprite;

	override function create() {
		#if desktop
		DiscordClient.changePresence("Options Menu", null);
		#end

		Application.current.window.title = Application.current.meta.get('name');

		FlxG.sound.playMusic(Paths.music('configurator'));

		camMain = new FlxCamera();
		camSub = new FlxCamera();
		camSub.bgColor.alpha = 0;

		FlxG.cameras.reset(camMain);
		FlxG.cameras.add(camSub, false);

		FlxG.cameras.setDefaultDrawTarget(camMain, true);
		CustomFadeTransition.nextCamera = camSub;

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);
		FlxG.camera.follow(camFollowPos, null, 1);

		var yScroll:Float = Math.max(0.25 - (0.05 * (options.length - 4)), 0.1);
		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xFFea71fd;
		bg.updateHitbox();
		bg.screenCenter();
		bg.scrollFactor.set(0, yScroll / 3);
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Press D for save data settings.", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		
		initOptions();

		selectorLeft = new Alphabet(0, 0, '>', true);
		selectorLeft.scrollFactor.set(0, yScroll);
		add(selectorLeft);
		selectorRight = new Alphabet(0, 0, '<', true);
		selectorRight.scrollFactor.set(0, yScroll);
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
			optionText.scrollFactor.set(0, Math.max(0.25 - (0.05 * (options.length - 4)), 0.1));
			grpOptions.add(optionText);
		}
	}

	override function openSubState(subState:FlxSubState) {
		super.openSubState(subState);
		if (!(subState is CustomFadeTransition)) {
			persistentDraw = persistentUpdate = false;
		}
	}

	override function closeSubState() {
		super.closeSubState();
		ClientPrefs.saveSettings();
		persistentDraw = persistentUpdate = true;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
	
		var mult:Float = FlxMath.lerp(1.07, bg.scale.x, CoolUtil.clamp(1 - (elapsed * 9), 0, 1));
		bg.scale.set(mult, mult);
		bg.updateHitbox();
		bg.offset.set();

		if (FlxG.keys.justPressed.D) {
			MusicBeatState.switchState(new SaveDataState());
		}

		if (controls.UI_UP_P || controls.UI_DOWN_P) {
			changeSelection(controls.UI_UP_P ? -1 : 1);
		}

		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			if (PauseSubState.fromPlayState) {
				StageData.loadDirectory(PlayState.SONG);
				LoadingState.loadAndSwitchState(new PlayState());
			} else {
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
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
				var add:Float = (grpOptions.members.length > 4 ? grpOptions.members.length * 8 : 0);
				camFollow.setPosition(item.getGraphicMidpoint().x, item.getGraphicMidpoint().y - add);
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}