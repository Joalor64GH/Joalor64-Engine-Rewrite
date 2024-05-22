package meta.data.options;

class OptionsState extends MusicBeatState
{
	var options:Array<String> = [
		'Note Colors', 
		'Controls', 
		'Offsets',
		'Visuals',
		'Gameplay', 
		'Language',
		'Miscellaneous'
	];

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private static var curSelected:Int = 0;

	function openSelectedSubstate(label:String) {
		switch(label) {
			case 'Note Colors':
				openSubState(new OptionsSubState.NotesSubState());
			case 'Controls':
				openSubState(new OptionsSubState.ControlsSubState());
			case 'Offsets':
				FlxG.switchState(() -> new NoteOffsetState());
			case 'Visuals':
				openSubState(new OptionsSubState.VisualsSubState());
			case 'Gameplay':
				openSubState(new OptionsSubState.GameplaySubState());
			case 'Language':
				openSubState(new OptionsSubState.LanguageSubState());
			case 'Miscellaneous':
				openSubState(new OptionsSubState.MiscSubState());
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

		#if sys
		ArtemisIntegration.setBackgroundFlxColor (bg.color);
		#end
		
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

		selectorLeft = new Alphabet(0, 0, '>', true);
		selectorLeft.scrollFactor.set(0, yScroll);
		add(selectorLeft);
		selectorRight = new Alphabet(0, 0, '<', true);
		selectorRight.scrollFactor.set(0, yScroll);
		add(selectorRight);

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		textBG.scrollFactor.set();
		add(textBG);

		var versionShit:FlxText = new FlxText(textBG.x, textBG.y + 4, 0, "Press D for save data settings.", 12);
		versionShit.setFormat("VCR OSD Mono", 18, FlxColor.WHITE, LEFT);
		versionShit.scrollFactor.set();
		add(versionShit);

		#if MODS_ALLOWED
		var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, "Press RESET to access the Modpacks Options saves Reset menu.", 18);
		text.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, RIGHT);
		text.scrollFactor.set();
		add(text);
		#end

		changeSelection();
		ClientPrefs.saveSettings();

		super.create();
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

		if (FlxG.keys.justPressed.D)
			FlxG.switchState(() -> new SaveDataState());

		if (controls.UI_UP_P || controls.UI_DOWN_P)
			changeSelection(controls.UI_UP_P ? -1 : 1);

		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			if (PauseSubState.fromPlayState) {
				StageData.loadDirectory(PlayState.SONG);
				LoadingState.loadAndSwitchState(() -> new PlayState());
			} else {
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				FlxG.switchState((ClientPrefs.simpleMain) ? () -> new SimpleMainMenuState() : () -> new MainMenuState());
			}
		}

		if (controls.ACCEPT)
			openSelectedSubstate(options[curSelected]);

		#if MODS_ALLOWED
		if (controls.RESET)
			openSubState(new DeleteSavesSubState());
		#end
	}
	
	function changeSelection(change:Int = 0) {
		curSelected = FlxMath.wrap(curSelected + change, 0, options.length - 1);

		for (num => item in grpOptions.members) {
			item.targetY = num - curSelected;

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
