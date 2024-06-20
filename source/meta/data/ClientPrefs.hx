package meta.data;

class ClientPrefs {
	public static var downScroll:Bool = false;
	public static var middleScroll:Bool = false;
	public static var opponentStrums:Bool = true;
	public static var showFPS:Bool = true;
	public static var flashing:Bool = true;
	public static var globalAntialiasing:Bool = true;
	public static var noteSplashes:Bool = true;
	public static var lowQuality:Bool = false;
	public static var shaders:Bool = true;
	public static var framerate:Int = 60;
	public static var camZooms:Bool = true;
	public static var hideHud:Bool = false;
	public static var noteOffset:Int = 0;
	public static var arrowRGB:Array<Array<Int>> = [[194, 75, 153], [0, 255, 255], [18, 250, 5], [249, 57, 63]];
	public static var ghostTapping:Bool = true;
	public static var timeBarType:String = 'Time Left';
	public static var scoreTxtType:String = 'Default';
	public static var scoreZoom:Bool = true;
	public static var noReset:Bool = false;
	public static var healthBarAlpha:Float = 1;
	public static var enableArtemis:Bool = true;
	public static var screenRes:String = "1280 x 720";
	public static var screenResTemp:String = "1280 x 720"; // dummy value that isn't saved, used so that if the player cancels instead of hitting space the resolution isn't applied
	public static var screenScaleMode:String = "Letterbox";
	public static var screenScaleModeTemp:String = "Letterbox";
	public static var hitsoundVolume:Float = 0;
	public static var pauseMusic:String = 'Tea Time';
	public static var saveReplay:Bool = true;
	public static var checkForUpdates:Bool = true;
	public static var uiSkin:String = 'Default';
	public static var comboStacking = true;
	public static var colorBlindFilter:String = 'None';
	public static var simpleMain:Bool = false;
	public static var longBar:Bool = false;
	public static var floatyLetters:Bool = false;
	public static var songDisplay:String = 'Classic';
	public static var language:String = 'en';
	public static var displayMilliseconds:Bool = true;
	public static var weekendScore:Bool = false;
	public static var resultsScreen:Bool = true;
	public static var autoPause:Bool = true;
	public static var ghostTapAnim:Bool = true;
	public static var cameraPanning:Bool = true;
	public static var panIntensity:Float = 1;
	public static var noteSkin:String = 'Default'; // defualt :skull:
	public static var gameplaySettings:Map<String, Dynamic> = [
		'scrollspeed' => 1.0,
		'scrolltype' => 'multiplicative', 
		// anyone reading this, amod is multiplicative speed mod, cmod is constant speed mod, and xmod is bpm based speed mod.
		// an amod example would be chartSpeed * multiplier
		// cmod would just be constantSpeed = chartSpeed
		// and xmod basically works by basing the speed on the bpm.
		// iirc (beatsPerSecond * (conductorToNoteDifference / 1000)) * noteSize (110 or something like that depending on it, prolly just use note.height)
		// bps is calculated by bpm / 60
		// oh yeah and you'd have to actually convert the difference to seconds which I already do, because this is based on beats and stuff. but it should work
		// just fine. but I wont implement it because I don't know how you handle sustains and other stuff like that.
		// oh yeah when you calculate the bps divide it by the songSpeed or rate because it wont scroll correctly when speeds exist.
		'songspeed' => 1.0,
		'healthgain' => 1.0,
		'healthloss' => 1.0,
		'instakill' => false,
		'practice' => false,
		'botplay' => false,
		'opponentplay' => false,
		'randommode' => false,
		'flip' => false,
		'stairmode' => false,
		'wavemode' => false,
		'onekey' => false
	];

	public static var comboOffset:Array<Int> = [0, 0, 0, 0, 0, 0];
	public static var ratingOffset:Int = 0;
	public static var sickWindow:Int = 45;
	public static var goodWindow:Int = 90;
	public static var badWindow:Int = 135;
	public static var safeFrames:Float = 10;

	//Every key has two binds, add your key bind down here and then add your control on options/ControlsSubState.hx and Controls.hx
	public static var keyBinds:Map<String, Array<FlxKey>> = [
		//Key Bind, Name for ControlsSubState
		'note_left'		=> [A, LEFT],
		'note_down'		=> [S, DOWN],
		'note_up'		=> [W, UP],
		'note_right'	=> [D, RIGHT],
		
		'ui_left'		=> [A, LEFT],
		'ui_down'		=> [S, DOWN],
		'ui_up'			=> [W, UP],
		'ui_right'		=> [D, RIGHT],
		
		'accept'		=> [SPACE, ENTER],
		'back'			=> [BACKSPACE, ESCAPE],
		'pause'			=> [ENTER, ESCAPE],
		'reset'			=> [R, NONE],
		
		'volume_mute'	=> [ZERO, NONE],
		'volume_up'		=> [NUMPADPLUS, PLUS],
		'volume_down'	=> [NUMPADMINUS, MINUS],
		
		'debug_1'		=> [SEVEN, NONE],
		'debug_2'		=> [EIGHT, NONE]
	];
	public static var defaultKeys:Map<String, Array<FlxKey>> = null;

	inline public static function loadDefaultKeys() {
		defaultKeys = keyBinds.copy();
	}

	public static function saveSettings() {
		FlxG.save.data.downScroll = downScroll;
		FlxG.save.data.middleScroll = middleScroll;
		FlxG.save.data.opponentStrums = opponentStrums;
		FlxG.save.data.showFPS = showFPS;
		FlxG.save.data.flashing = flashing;
		FlxG.save.data.globalAntialiasing = globalAntialiasing;
		FlxG.save.data.noteSplashes = noteSplashes;
		FlxG.save.data.lowQuality = lowQuality;
		FlxG.save.data.shaders = shaders;
		FlxG.save.data.framerate = framerate;
		FlxG.save.data.camZooms = camZooms;
		FlxG.save.data.noteOffset = noteOffset;
		FlxG.save.data.hideHud = hideHud;
		FlxG.save.data.arrowRGB = arrowRGB;
		FlxG.save.data.ghostTapping = ghostTapping;
		FlxG.save.data.timeBarType = timeBarType;
		FlxG.save.data.scoreTxtType = scoreTxtType;
		FlxG.save.data.scoreZoom = scoreZoom;
		FlxG.save.data.noReset = noReset;
		FlxG.save.data.healthBarAlpha = healthBarAlpha;
		FlxG.save.data.comboOffset = comboOffset;
		FlxG.save.data.achievementsMap = Achievements.achievementsMap;
		FlxG.save.data.henchmenDeath = Achievements.henchmenDeath;

		FlxG.save.data.ratingOffset = ratingOffset;
		FlxG.save.data.sickWindow = sickWindow;
		FlxG.save.data.goodWindow = goodWindow;
		FlxG.save.data.badWindow = badWindow;
		FlxG.save.data.safeFrames = safeFrames;
		FlxG.save.data.enableArtemis = enableArtemis;
		FlxG.save.data.gameplaySettings = gameplaySettings;
		FlxG.save.data.hitsoundVolume = hitsoundVolume;
		FlxG.save.data.pauseMusic = pauseMusic;
		FlxG.save.data.saveReplay = saveReplay;
		FlxG.save.data.checkForUpdates = checkForUpdates;
		FlxG.save.data.uiSkin = uiSkin;
		FlxG.save.data.comboStacking = comboStacking;
		FlxG.save.data.colorBlindFilter = colorBlindFilter;
		FlxG.save.data.simpleMain = simpleMain;
		FlxG.save.data.longBar = longBar;
		FlxG.save.data.floatyLetters = floatyLetters;
		FlxG.save.data.songDisplay = songDisplay;
		FlxG.save.data.language = language;
		FlxG.save.data.displayMilliseconds = displayMilliseconds;
		FlxG.save.data.weekendScore = weekendScore;
		FlxG.save.data.resultsScreen = resultsScreen;
		FlxG.save.data.autoPause = autoPause;
		FlxG.save.data.ghostTapAnim = ghostTapAnim;
		FlxG.save.data.cameraPanning = cameraPanning;
		FlxG.save.data.panIntensity = panIntensity;
		FlxG.save.data.noteSkin = noteSkin;
	
		FlxG.save.flush();

		var save:FlxSave = new FlxSave();
		save.bind('controls_v2', 'ninjamuffin99'); //Placing this in a separate save so that it can be manually deleted without removing your Score and stuff
		save.data.customControls = keyBinds;
		save.flush();
		FlxG.log.add("Settings saved!");
	}

	public static function loadPrefs() {
		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		#end
		
		if(FlxG.save.data.downScroll != null) {
			downScroll = FlxG.save.data.downScroll;
		}
		if(FlxG.save.data.middleScroll != null) {
			middleScroll = FlxG.save.data.middleScroll;
		}
		if(FlxG.save.data.opponentStrums != null) {
			opponentStrums = FlxG.save.data.opponentStrums;
		}
		if(FlxG.save.data.showFPS != null) {
			showFPS = FlxG.save.data.showFPS;
			if(Main.fpsVar != null) {
				Main.fpsVar.visible = showFPS;
			}
		}
		if(FlxG.save.data.flashing != null) {
			flashing = FlxG.save.data.flashing;
		}
		if(FlxG.save.data.globalAntialiasing != null) {
			globalAntialiasing = FlxG.save.data.globalAntialiasing;
		}
		if(FlxG.save.data.noteSplashes != null) {
			noteSplashes = FlxG.save.data.noteSplashes;
		}
		if(FlxG.save.data.lowQuality != null) {
			lowQuality = FlxG.save.data.lowQuality;
		}
		if(FlxG.save.data.shaders != null) {
			shaders = FlxG.save.data.shaders;
		}

		if(FlxG.save.data.autoPause != null) {
			autoPause = FlxG.save.data.autoPause;
		}

		#if (!html5 && !switch)
		FlxG.autoPause = autoPause;

		if (FlxG.save.data.framerate == null) {
			final refreshRate:Int = FlxG.stage.application.window.displayMode.refreshRate;
			framerate = Std.int(FlxMath.bound(refreshRate, 60, 240));
		}
		#end

		if(FlxG.save.data.framerate != null) {
			framerate = FlxG.save.data.framerate;
			if(framerate > FlxG.drawFramerate) {
				FlxG.updateFramerate = framerate;
				FlxG.drawFramerate = framerate;
			} else {
				FlxG.drawFramerate = framerate;
				FlxG.updateFramerate = framerate;
			}
		}
		if(FlxG.save.data.camZooms != null) {
			camZooms = FlxG.save.data.camZooms;
		}
		if(FlxG.save.data.hideHud != null) {
			hideHud = FlxG.save.data.hideHud;
		}
		if(FlxG.save.data.noteOffset != null) {
			noteOffset = FlxG.save.data.noteOffset;
		}
		if(FlxG.save.data.arrowRGB != null) {
			arrowRGB = FlxG.save.data.arrowRGB;
		}
		if(FlxG.save.data.ghostTapping != null) {
			ghostTapping = FlxG.save.data.ghostTapping;
		}
		if(FlxG.save.data.timeBarType != null) {
			timeBarType = FlxG.save.data.timeBarType;
		}
		if(FlxG.save.data.scoreTxtType != null) {
			scoreTxtType = FlxG.save.data.scoreTxtType;
		}
		if(FlxG.save.data.scoreZoom != null) {
			scoreZoom = FlxG.save.data.scoreZoom;
		}
		if(FlxG.save.data.noReset != null) {
			noReset = FlxG.save.data.noReset;
		}
		if(FlxG.save.data.healthBarAlpha != null) {
			healthBarAlpha = FlxG.save.data.healthBarAlpha;
		}
		if(FlxG.save.data.comboOffset != null) {
			comboOffset = FlxG.save.data.comboOffset;
		}
		if(FlxG.save.data.ratingOffset != null) {
			ratingOffset = FlxG.save.data.ratingOffset;
		}
		if(FlxG.save.data.sickWindow != null) {
			sickWindow = FlxG.save.data.sickWindow;
		}
		if(FlxG.save.data.goodWindow != null) {
			goodWindow = FlxG.save.data.goodWindow;
		}
		if(FlxG.save.data.badWindow != null) {
			badWindow = FlxG.save.data.badWindow;
		}
		if(FlxG.save.data.safeFrames != null) {
			safeFrames = FlxG.save.data.safeFrames;
		}
		if(FlxG.save.data.hitsoundVolume != null) {
			hitsoundVolume = FlxG.save.data.hitsoundVolume;
		}
		if(FlxG.save.data.pauseMusic != null) {
			pauseMusic = FlxG.save.data.pauseMusic;
		}
		if(FlxG.save.data.saveReplay != null) {
			saveReplay = FlxG.save.data.saveReplay;
		}
		if (FlxG.save.data.enableArtemis != null) {
			enableArtemis = FlxG.save.data.enableArtemis;
		}
		if(FlxG.save.data.screenRes != null) {
			screenRes = FlxG.save.data.screenRes;
		}
		if(FlxG.save.data.screenScaleMode != null) {
			screenScaleMode = FlxG.save.data.screenScaleMode;
		}

		if(FlxG.save.data.gameplaySettings != null)
		{
			var savedMap:Map<String, Dynamic> = FlxG.save.data.gameplaySettings;
			for (name => value in savedMap)
			{
				gameplaySettings.set(name, value);
			}
		}
		
		// flixel automatically saves your volume!
		if(FlxG.save.data.volume != null)
		{
			FlxG.sound.volume = FlxG.save.data.volume;
		}
		if (FlxG.save.data.mute != null)
		{
			FlxG.sound.muted = FlxG.save.data.mute;
		}
		
		if (FlxG.save.data.checkForUpdates != null)
		{
			checkForUpdates = FlxG.save.data.checkForUpdates;
		}
		if(FlxG.save.data.uiSkin != null) {
			uiSkin = FlxG.save.data.uiSkin;
		}
		if (FlxG.save.data.comboStacking != null)
			comboStacking = FlxG.save.data.comboStacking;
		if (FlxG.save.data.colorBlindFilter != null)
			colorBlindFilter = FlxG.save.data.colorBlindFilter;
		if(FlxG.save.data.simpleMain != null)
			simpleMain = FlxG.save.data.simpleMain;
		if(FlxG.save.data.longBar != null)
			longBar = FlxG.save.data.longBar;
		if(FlxG.save.data.floatyLetters != null)
			floatyLetters = FlxG.save.data.floatyLetters;
		if(FlxG.save.data.songDisplay != null)
			songDisplay = FlxG.save.data.songDisplay;
		if(FlxG.save.data.language != null)
			language = FlxG.save.data.language;
		if(FlxG.save.data.displayMilliseconds != null)
			displayMilliseconds = FlxG.save.data.displayMilliseconds;
		if(FlxG.save.data.weekendScore != null)
			weekendScore = FlxG.save.data.weekendScore;
		if(FlxG.save.data.resultsScreen != null)
			resultsScreen = FlxG.save.data.resultsScreen;
		if(FlxG.save.data.ghostTapAnim != null)
			ghostTapAnim = FlxG.save.data.ghostTapAnim;
		if(FlxG.save.data.cameraPanning != null)
			cameraPanning = FlxG.save.data.cameraPanning;
		if(FlxG.save.data.panIntensity != null)
			panIntensity = FlxG.save.data.panIntensity;
		if(FlxG.save.data.noteSkin != null)
			noteSkin = FlxG.save.data.noteSkin;

		var save:FlxSave = new FlxSave();
		save.bind('controls_v2', 'ninjamuffin99');
		if(save != null && save.data.customControls != null) {
			var loadedControls:Map<String, Array<FlxKey>> = save.data.customControls;
			for (control => keys in loadedControls) {
				keyBinds.set(control, keys);
			}
			reloadControls();
		}
	}

	// idk where to put this ok
	#if MODS_ALLOWED
	public static var modsOptsSaves:Map<String, Map<String, Dynamic>> = [];
	#end

	inline public static function getGameplaySetting(name:String, defaultValue:Dynamic):Dynamic {
		return (gameplaySettings.exists(name) ? gameplaySettings.get(name) : defaultValue);
	}

	public static function reloadControls() {
		PlayerSettings.player1.controls.setKeyboardScheme(KeyboardScheme.Solo);

		FlxG.sound.muteKeys = [FlxKey.ZERO];
		FlxG.sound.volumeDownKeys = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
		FlxG.sound.volumeUpKeys = [FlxKey.NUMPADPLUS, FlxKey.PLUS];
	}
	public static function copyKey(arrayToCopy:Array<FlxKey>):Array<FlxKey> {
		var copiedArray:Array<FlxKey> = arrayToCopy.copy();
		var i:Int = 0;
		var len:Int = copiedArray.length;

		while (i < len) {
			if(copiedArray[i] == NONE) {
				copiedArray.remove(NONE);
				--i;
			}
			i++;
			len = copiedArray.length;
		}
		return copiedArray;
	}
}