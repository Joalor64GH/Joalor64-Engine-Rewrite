package meta.data.scripts;

#if HSCRIPT_ALLOWED
#if LUA_ALLOWED
import meta.data.scripts.FunkinLua;
#end
#if VIDEOS_ALLOWED
#if (hxCodec >= "3.0.0") import hxcodec.flixel.FlxVideo as MP4Handler;
#elseif (hxCodec >= "2.6.1") import hxcodec.VideoHandler as MP4Handler;
#elseif (hxCodec == "2.6.0") import VideoHandler as MP4Handler;
#elseif (hxCodec) import vlc.MP4Handler; 
#elseif (hxvlc) import hxvlc.flixel.FlxVideo as MP4Handler;
#end
#end
import flixel.system.macros.FlxMacroUtil;
import openfl.text.TextFormat;
import flixel.system.FlxAssets.FlxShader;
import flixel.addons.text.FlxTypeText;
import openfl.media.Sound;
import openfl.text.TextField;
import haxe.io.Bytes;
import lime.media.AudioBuffer;
import flixel.addons.display.FlxGridOverlay;
import openfl.events.IOErrorEvent;
import openfl.events.Event;
import lime.system.Clipboard;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUI;
import flixel.graphics.frames.FlxFrame;
import lime.media.openal.AL;
#if sys
import sys.FileSystem;
import sys.io.File;
#end
import lime.utils.Assets as LimeAssets;
import openfl.Assets as OpenFlAssets;
import animateatlas.*;
import hscript.InterpEx;

import meta.data.Achievements;

import meta.video.*;
import meta.data.alphabet.*;
import objects.userinterface.*;
import objects.userinterface.note.*;
import objects.userinterface.menu.*;
import objects.background.*;
import objects.shaders.*;

import objects.shaders.PhillyGlow;
import objects.Character;

import objects.userinterface.DialogueBoxPsych;
import objects.userinterface.DialogueBoxPsych.DialogueFile;

class FunkinHscript extends InterpEx {
    public var scriptName:String = '';
    public var closed:Bool = false;
	public var lastCalledFunction:String = '';

    public function new(path:String) {
        super();
	scriptName = path.split('/')[path.split('/').length - 1];
        super();
        //CLASSES
        //THIS IS PROBABLY MORE THAN ANYONE EVER NEEDS AND YOU CAN IMPORT CLASSES MANUALLY ANYWAYS BUT WHATEVER
        variables.set('AL', AL);
        variables.set('Application', Application);
        variables.set('AudioBuffer', AudioBuffer);
        variables.set('BitmapData', BitmapData);
        variables.set('Bytes', Bytes);
        variables.set('Clipboard', Clipboard);
        variables.set('Event', Event);
        variables.set('FlxAngle', FlxAngle);
        variables.set('FlxAtlasFrames', FlxAtlasFrames);
        variables.set('FlxBackdrop', FlxBackdrop);
        variables.set('FlxBar', FlxBar);
        variables.set('FlxBasic', FlxBasic);
        variables.set('FlxButton', FlxButton);
        variables.set('FlxCamera', FlxCamera);
        variables.set('FlxColor', FlxColorCustom);
        variables.set('FlxDestroyUtil', FlxDestroyUtil);
        variables.set('FlxEase', FlxEase);
        variables.set('FlxFlicker', FlxFlicker);
        variables.set('FlxFrame', FlxFrame);
        variables.set('FlxG', FlxG);
        variables.set('FlxGradient', FlxGradient);
        variables.set('FlxGraphic', FlxGraphic);
        variables.set('FlxGridOverlay', FlxGridOverlay);
        variables.set('FlxGroup', FlxGroup);
        variables.set('FlxKey', FlxKeyCustom);
        variables.set('FlxMath', FlxMath);
        variables.set('FlxObject', FlxObject);
        variables.set('FlxRect', FlxRect);
        variables.set('FlxSave', FlxSave);
        variables.set('FlxShader', FlxShader);
        variables.set('FlxSort', FlxSort);
        variables.set('FlxSound', FlxSound);
        variables.set('FlxSprite', FlxSprite);
        variables.set('FlxSpriteGroup', FlxSpriteGroup);
        variables.set('FlxState', FlxState);
        variables.set('FlxStringUtil', FlxStringUtil);
        variables.set('FlxSubState', FlxSubState);
        variables.set('FlxText', FlxText);
        variables.set('FlxTimer', FlxTimer);
        variables.set('FlxTrail', FlxTrail);
        variables.set('FlxTransitionableState', FlxTransitionableState);
        variables.set('FlxTween', FlxTween);
        variables.set('FlxTypedGroup', FlxTypedGroup);
        variables.set('FlxTypedSpriteGroup', FlxTypedSpriteGroup);
        variables.set('FlxUI', FlxUI);
        variables.set('FlxUICheckBox', FlxUICheckBox);
        variables.set('FlxUIDropDownMenu', FlxUIDropDownMenu);
        variables.set('FlxUIInputText', FlxUIInputText);
        variables.set('FlxUINumericStepper', FlxUINumericStepper);
        variables.set('FlxUITabMenu', FlxUITabMenu);
        variables.set('FlxTypeText', FlxTypeText);
        variables.set('IOErrorEvent', IOErrorEvent);
        variables.set('Json', Json);
        variables.set('Lib', Lib);
        variables.set('LimeAssets', LimeAssets);
        variables.set('OpenFlAssets', OpenFlAssets);
        variables.set('Path', Path);
        variables.set('Reflect', Reflect);
        variables.set('Sound', Sound);
        variables.set('StringTools', StringTools);
        variables.set('TextField', TextField);
        variables.set('TextFormat', TextFormat);
        #if sys
		variables.set('Sys', SysCustom);
        variables.set('File', File);
        variables.set('FileSystem', FileSystem);
        #end
        variables.set('AchievementObject', AchievementObject);
        variables.set('Achievements', Achievements);
        variables.set('AchievementsMenuState', AchievementsMenuState);
        variables.set('Alphabet', Alphabet);
        variables.set('AtlasFrameMaker', AtlasFrameMaker);
        variables.set('AttachedSprite', AttachedSprite);
        variables.set('AttachedText', AttachedText);
        variables.set('BaseOptionsMenu', BaseOptionsMenu);
        variables.set('BGSprite', BGSprite);
        variables.set('Boyfriend', Boyfriend);
        variables.set('Character', Character);
        variables.set('CharacterEditorState', CharacterEditorState);
        variables.set('ChartingState', ChartingState);
        variables.set('CheckboxThingie', CheckboxThingie);
        variables.set('ClientPrefs', ClientPrefs);
        variables.set('ColorSwap', ColorSwap);
        variables.set('Conductor', Conductor);
        variables.set('CoolUtil', CoolUtil);
        variables.set('CreditsState', CreditsState);
        variables.set('CustomFadeTransition', CustomFadeTransition);
        variables.set('DialogueBox', DialogueBox);
        variables.set('DialogueBoxPsych', DialogueBoxPsych);
        variables.set('FreeplayState', FreeplayState);
        variables.set('FunkinHscript', FunkinHscript);
        variables.set('FunkinLua', FunkinLua);
		variables.set('FunkinSScript', FunkinSScript);
		variables.set('Game', PlayState.instance);
        variables.set('GameOverSubstate', GameOverSubstate);
        variables.set('HealthIcon', HealthIcon);
        variables.set('Highscore', Highscore);
        variables.set('InputFormatter', InputFormatter);
        variables.set('MainMenuState', MainMenuState);
        variables.set('MasterEditorMenu', MasterEditorMenu);
        variables.set('MusicBeatState', MusicBeatState);
        variables.set('MusicBeatSubstate', MusicBeatSubstate);
        variables.set('Note', Note);
        variables.set('NoteSplash', NoteSplash);
        variables.set('OptionsState', OptionsState);
        variables.set('Paths', Paths);
        variables.set('PauseSubState', PauseSubState);
		variables.set('PhillyGlowParticle', PhillyGlowParticle);
		variables.set('PhillyGlowGradient', PhillyGlowGradient);
        variables.set('PlayState', PlayState);
        variables.set('Prompt', Prompt);
        variables.set('Song', Song);
        variables.set('StageData', StageData);
        variables.set('StoryMenuState', StoryMenuState);
        variables.set('StrumNote', StrumNote);
		variables.set('TankmenBG', TankmenBG);
        variables.set('TitleState', TitleState);
        variables.set('WeekData', WeekData);
        variables.set('WiggleEffect', WiggleEffect);
		#if desktop
        variables.set('DiscordClient', DiscordClient);
        #end
		#if LUA_ALLOWED
		variables.set('DebugLuaText', DebugLuaText);
		variables.set('ModchartSprite', ModchartSprite);
		variables.set('ModchartText', ModchartText);
		#end
        #if VIDEOS_ALLOWED
        variables.set('MP4Handler', MP4Handler);
        #end

        //VARIABLES
        variables.set('Function_Stop', FunkinLua.Function_Stop);
		variables.set('Function_Continue', FunkinLua.Function_Continue);
		variables.set('curBpm', Conductor.bpm);
		variables.set('bpm', Conductor.bpm);
		variables.set('crochet', Conductor.crochet);
		variables.set('stepCrochet', Conductor.stepCrochet);
		variables.set('scrollSpeed', PlayState.SONG.speed);
		variables.set('songLength', 0);
		variables.set('songName', PlayState.SONG.song);
		variables.set('startedCountdown', false);
		variables.set('isStoryMode', PlayState.isStoryMode);
		variables.set('difficulty', PlayState.storyDifficulty);
		variables.set('difficultyName', CoolUtil.difficulties[PlayState.storyDifficulty]);
		variables.set('weekRaw', PlayState.storyWeek);
		variables.set('week', WeekData.weeksLoaded.get(WeekData.weeksList[PlayState.storyWeek]).fileName);
		variables.set('seenCutscene', PlayState.seenCutscene);

		// Camera poo
		variables.set('cameraX', 0);
		variables.set('cameraY', 0);
		
		// Screen stuff
		variables.set('screenWidth', FlxG.width);
		variables.set('screenHeight', FlxG.height);

		// PlayState cringe ass nae nae bullcrap
		variables.set('curBeat', 0);
		variables.set('curStep', 0);

		variables.set('score', 0);
		variables.set('misses', 0);
		variables.set('hits', 0);

		variables.set('rating', 0);
		variables.set('ratingName', '');
		variables.set('ratingFC', '');
		variables.set('versionJoalor', MainMenuState.joalor64EngineVersion.trim());
		variables.set('versionPsych', MainMenuState.psychEngineVersion.trim());
			
		variables.set('inGameOver', false);
		variables.set('curSection', 0);
		variables.set('mustHitSection', false);
		variables.set('altAnim', false);
		variables.set('gfSection', false);
		variables.set('lengthInSteps', 16);
		variables.set('changeBPM', false);

		// Gameplay settings
		variables.set('healthGainMult', PlayState.instance.healthGain);
		variables.set('healthLossMult', PlayState.instance.healthLoss);
		variables.set('instakillOnMiss', PlayState.instance.instakillOnMiss);
		variables.set('botPlay', PlayState.instance.cpuControlled);
		variables.set('practice', PlayState.instance.practiceMode);

		for (i in 0...4) {
			variables.set('defaultPlayerStrumX' + i, 0);
			variables.set('defaultPlayerStrumY' + i, 0);
			variables.set('defaultOpponentStrumX' + i, 0);
			variables.set('defaultOpponentStrumY' + i, 0);
		}

		// Default character positions woooo
		variables.set('defaultBoyfriendX', PlayState.instance.BF_X);
		variables.set('defaultBoyfriendY', PlayState.instance.BF_Y);
		variables.set('defaultOpponentX', PlayState.instance.DAD_X);
		variables.set('defaultOpponentY', PlayState.instance.DAD_Y);
		variables.set('defaultGirlfriendX', PlayState.instance.GF_X);
		variables.set('defaultGirlfriendY', PlayState.instance.GF_Y);

		// Character shit
		variables.set('boyfriendName', PlayState.SONG.player1);
		variables.set('dadName', PlayState.SONG.player2);
		variables.set('gfName', PlayState.SONG.gfVersion);

			// Some settings, no jokes
		variables.set('downscroll', ClientPrefs.downScroll);
		variables.set('middlescroll', ClientPrefs.middleScroll);
		variables.set('framerate', ClientPrefs.framerate);
		variables.set('ghostTapping', ClientPrefs.ghostTapping);
		variables.set('hideHud', ClientPrefs.hideHud);
		variables.set('timeBarType', ClientPrefs.timeBarType);
		variables.set('scoreZoom', ClientPrefs.scoreZoom);
		variables.set('cameraZoomOnBeat', ClientPrefs.camZooms);
		variables.set('flashingLights', ClientPrefs.flashing);
		variables.set('noteOffset', ClientPrefs.noteOffset);
		variables.set('noResetButton', ClientPrefs.noReset);
		variables.set('lowQuality', ClientPrefs.lowQuality);

		variables.set("scriptName", scriptName);

		#if windows
		variables.set('buildTarget', 'windows');
		#elseif linux
		variables.set('buildTarget', 'linux');
		#elseif mac
		variables.set('buildTarget', 'mac');
		#elseif html5
		variables.set('buildTarget', 'browser');
		#elseif android
		variables.set('buildTarget', 'android');
		#else
		variables.set('buildTarget', 'unknown');
		#end

        variables.set('controls', PlayerSettings.player1.controls);
        variables.set('instance', PlayState.instance);
        variables.set('window', Application.current.window);

        variables.set("addHaxeLibrary", function(libName:String, ?libFolder:String = '') {
			try {
				var str:String = '';
				if(libFolder.length > 0)
					str = libFolder + '.';

				variables.set(libName, Type.resolveClass(str + libName));
			}
			catch (e:Dynamic) {
				PlayState.instance.addTextToDebug(scriptName + ":" + lastCalledFunction + " - " + e, FlxColor.RED);
			}
		});
		variables.set('addBehindChars', function(obj:FlxBasic) {
			var index = PlayState.instance.members.indexOf(PlayState.instance.gfGroup);
			if (PlayState.instance.members.indexOf(PlayState.instance.dadGroup) < index) {
				index = PlayState.instance.members.indexOf(PlayState.instance.dadGroup);
			}
			if (PlayState.instance.members.indexOf(PlayState.instance.boyfriendGroup) < index) {
				index = PlayState.instance.members.indexOf(PlayState.instance.boyfriendGroup);
			}
			PlayState.instance.insert(index, obj);
		});
		variables.set('addOverChars', function(obj:FlxBasic) {
			var index = PlayState.instance.members.indexOf(PlayState.instance.boyfriendGroup);
			if (PlayState.instance.members.indexOf(PlayState.instance.dadGroup) > index) {
				index = PlayState.instance.members.indexOf(PlayState.instance.dadGroup);
			}
			if (PlayState.instance.members.indexOf(PlayState.instance.gfGroup) > index) {
				index = PlayState.instance.members.indexOf(PlayState.instance.gfGroup);
			}
			PlayState.instance.insert(index + 1, obj);
		});
		variables.set('getObjectOrder', function(obj:Dynamic) {
			if ((obj is String)) {
				var basic:FlxBasic = Reflect.getProperty(PlayState.instance, obj);
				if (basic != null) {
					return PlayState.instance.members.indexOf(basic);
				}
				return -1;
			} else {
				return PlayState.instance.members.indexOf(obj);
			}
		});
		variables.set('setObjectOrder', function(obj:Dynamic, pos:Int = 0) {
			if ((obj is String)) {
				var basic:FlxBasic = Reflect.getProperty(PlayState.instance, obj);
				if (basic != null) {
					if (PlayState.instance.members.indexOf(basic) > -1) {
						PlayState.instance.remove(basic);
					}
					PlayState.instance.insert(pos, basic);
				}
			} else {
				if (PlayState.instance.members.indexOf(obj) > -1) {
					PlayState.instance.remove(obj);
				}
				PlayState.instance.insert(pos, obj);
			}
		});
		variables.set('getProperty', function(variable:String) {
			return Reflect.getProperty(PlayState.instance, variable);
		});
		variables.set('setProperty', function(variable:String, value:Dynamic) {
			Reflect.setProperty(PlayState.instance, variable, value);
		});
		variables.set('getPropertyFromClass', function(classVar:String, variable:String) {
			return Reflect.getProperty(Type.resolveClass(classVar), variable);
		});
		variables.set('setPropertyFromClass', function(classVar:String, variable:String, value:Dynamic) {
			Reflect.setProperty(Type.resolveClass(classVar), variable, value);
		});
		variables.set('loadSong', function(name:String = null, ?difficultyNum:Int = -1, ?skipTransition:Bool = false) {
			if (name == null) name = PlayState.SONG.song;
			if (difficultyNum < 0) difficultyNum = PlayState.storyDifficulty;
			FlxG.timeScale = 1;

			if (skipTransition)
			{
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
			}

			if (PlayState.isStoryMode && !PlayState.instance.transitioning) {
				PlayState.campaignScore += PlayState.instance.songScore;
				PlayState.campaignMisses += PlayState.instance.songMisses;
				PlayState.storyPlaylist.remove(PlayState.storyPlaylist[0]);
				PlayState.storyPlaylist.insert(0, name);
			}

			if (difficultyNum >= CoolUtil.difficulties.length) {
				difficultyNum = CoolUtil.difficulties.length - 1;
			}
			var poop = Highscore.formatSong(name, difficultyNum);
			PlayState.SONG = Song.loadFromJson(poop, name);
			PlayState.storyDifficulty = difficultyNum;
			PlayState.instance.persistentUpdate = false;
			PlayState.cancelMusicFadeTween();
			PlayState.deathCounter = 0;
			FlxG.sound.music.pause();
			FlxG.sound.music.volume = 0;
			if(PlayState.instance.vocals != null)
			{
				PlayState.instance.vocals.pause();
				PlayState.instance.vocals.volume = 0;
			}
			LoadingState.loadAndResetState();
		});
		variables.set("endSong", function() {
			PlayState.instance.KillNotes();
			PlayState.instance.finishSong(true);
		});
		variables.set("restartSong", function(skipTransition:Bool = false) {
			PlayState.instance.persistentUpdate = false;
			PauseSubState.restartSong(skipTransition);
		});
		variables.set("exitSong", function(skipTransition:Bool = false) {
			if (skipTransition)
			{
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
			}
			FlxG.timeScale = 1;

			PlayState.cancelMusicFadeTween();
			CustomFadeTransition.nextCamera = PlayState.instance.camOther;
			if (FlxTransitionableState.skipNextTransIn)
				CustomFadeTransition.nextCamera = null;

			if (PlayState.isStoryMode)
				MusicBeatState.switchState(new StoryMenuState());
			else
				MusicBeatState.switchState(new FreeplayState());

			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			PlayState.changedDifficulty = false;
			PlayState.chartingMode = false;
			PlayState.instance.transitioning = true;
			PlayState.deathCounter = 0;
		});
		variables.set('openCredits', function() {
			FlxG.timeScale = 1;
			PlayState.cancelMusicFadeTween();
			CustomFadeTransition.nextCamera = PlayState.instance.camOther;
			if (FlxTransitionableState.skipNextTransIn)
				CustomFadeTransition.nextCamera = null;

			MusicBeatState.switchState(new CreditsState());

			FlxG.sound.music.stop();
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			PlayState.changedDifficulty = false;
			PlayState.chartingMode = false;
			PlayState.instance.transitioning = true;
			PlayState.deathCounter = 0;
		});
		variables.set("startDialogue", function(dialogueFile:String, music:String = null) {
			var path:String = Paths.json('${Paths.formatToSongPath(PlayState.SONG.song)}/$dialogueFile');
			PlayState.instance.addTextToDebug('Trying to load dialogue: $path');

			if (Paths.exists(path)) {
				var shit:DialogueFile = DialogueBoxPsych.parseDialogue(path);
				if (shit.dialogue.length > 0) {
					PlayState.instance.startDialogue(shit, music);
					PlayState.instance.addTextToDebug('Successfully loaded dialogue');
				} else {
					PlayState.instance.addTextToDebug('Your dialogue file is badly formatted!');
				}
			} 
			else
			@:privateAccess 
			{
				PlayState.instance.addTextToDebug('Dialogue file not found');
				PlayState.instance.startAndEnd();
			}
		});
		variables.set("setWeekCompleted", function(name:String = '') {
			if(name.length > 0)
			{
				StoryMenuState.weekCompleted.set(name, true);
				FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
				FlxG.save.flush(); 
			}
		});
		variables.set("close", function() {
			closed = true;
			return closed;
		});
		variables.set('addScript', function(name:String, ?ignoreAlreadyRunning:Bool = false) {
			var cervix = '$name.hscript';
			var doPush = false;
			cervix = Paths.getPath(cervix);
			if (Paths.exists(cervix)) {
				doPush = true;
			}

			if (doPush)
			{
				if (!ignoreAlreadyRunning && PlayState.instance.hscriptMap.exists(cervix))
				{
					PlayState.instance.addTextToDebug('The script "$cervix" is already running!');
					return;
				}
				PlayState.instance.addHscript(cervix);
				return;
			}
			PlayState.instance.addTextToDebug("Script doesn't exist!");
		});
		variables.set('removeScript', function(name:String) {
			var cervix = '$name.hscript';
			var doPush = false;
			cervix = Paths.getPath(cervix);
			if (Paths.exists(cervix)) {
				doPush = true;
			}

			if (doPush)
			{
				if (PlayState.instance.hscriptMap.exists(cervix))
				{
					var hscript = PlayState.instance.hscriptMap.get(cervix);
					PlayState.instance.hscriptMap.remove(cervix);
					hscript = null;
					return;
				}
				return;
			}
			PlayState.instance.addTextToDebug("Script doesn't exist!");
		});
		variables.set('debugPrint', function(text:Dynamic) {
			PlayState.instance.addTextToDebug('$text');
			trace(text);
		});

		//EVENTS
		var funcs = [
			'onCreate',
			'onCreatePost',
			'onDestroy',
			'onStepHit',
			'onBeatHit',
			'onStartCountdown',
			'onSongStart',
			'onEndSong',
			'onSkipCutscene',
			'onBPMChange',
			'onSignatureChange',
			'onOpenChartEditor',
			'onOpenCharacterEditor',
			'onPause',
			'onResume',
			'onGameOver',
			'onRecalculateRating'
		];
		for (i in funcs)
			variables.set(i, function() {});
		variables.set('onUpdate', function(elapsed) {});
		variables.set('onUpdatePost', function(elapsed) {});
		variables.set('onCountdownTick', function(counter) {});
		variables.set('onGameOverConfirm', function(retry) {});
		variables.set('onNextDialogue', function(line) {});
		variables.set('onSkipDialogue', function(line) {});
		variables.set('onNoteHit', function(index, direction, noteType, isSustainNote, characters, strumID, isPlayer) {});
		variables.set('noteMissPress', function(direction) {});
		variables.set('noteMiss', function(index, direction, noteType, isSustainNote, characters) {});
		variables.set('onMoveCamera', function(focus) {});
		variables.set('onEvent', function(name, value1, value2) {});
		variables.set('eventPushed', function(name, strumTime, value1, value2) {});
		variables.set('eventEarlyTrigger', function(name) {});
		variables.set('onTweenCompleted', function(tag) {});
		variables.set('onTimerCompleted', function(tag, loops, loopsLeft) {});
		variables.set('onSpawnNote', function(index, direction, noteType, isSustainNote, characters) {});
		variables.set('onGhostTap', function(direction) {});
		variables.set('onKeyChange', function(strumID, keyAmount) {});

		trace('hscript file loaded succesfully: $path');
	}

		inline function getInstance()
			return PlayState.instance.isDead ? GameOverSubstate.instance : PlayState.instance;
}

//cant use an abstract as a value so made one with just the static functions
class FlxColorCustom
{
	public static inline var TRANSPARENT:FlxColor = 0x00000000;
	public static inline var WHITE:FlxColor = 0xFFFFFFFF;
	public static inline var GRAY:FlxColor = 0xFF808080;
	public static inline var BLACK:FlxColor = 0xFF000000;

	public static inline var GREEN:FlxColor = 0xFF008000;
	public static inline var LIME:FlxColor = 0xFF00FF00;
	public static inline var YELLOW:FlxColor = 0xFFFFFF00;
	public static inline var ORANGE:FlxColor = 0xFFFFA500;
	public static inline var RED:FlxColor = 0xFFFF0000;
	public static inline var PURPLE:FlxColor = 0xFF800080;
	public static inline var BLUE:FlxColor = 0xFF0000FF;
	public static inline var BROWN:FlxColor = 0xFF8B4513;
	public static inline var PINK:FlxColor = 0xFFFFC0CB;
	public static inline var MAGENTA:FlxColor = 0xFFFF00FF;
	public static inline var CYAN:FlxColor = 0xFF00FFFF;

	/**
	 * A `Map<String, Int>` whose values are the static colors of `FlxColor`.
	 * You can add more colors for `FlxColor.fromString(String)` if you need.
	 */
	public static var colorLookup(default, null):Map<String, Int> = FlxMacroUtil.buildMap("flixel.util.FlxColor");

	static var COLOR_REGEX = ~/^(0x|#)(([A-F0-9]{2}){3,4})$/i;

	/**
	 * Create a color from the least significant four bytes of an Int
	 *
	 * @param	Value And Int with bytes in the format 0xAARRGGBB
	 * @return	The color as a FlxColor
	 */
	public static inline function fromInt(Value:Int):FlxColor
	{
		return new FlxColor(Value);
	}

	/**
	 * Generate a color from integer RGB values (0 to 255)
	 *
	 * @param Red	The red value of the color from 0 to 255
	 * @param Green	The green value of the color from 0 to 255
	 * @param Blue	The green value of the color from 0 to 255
	 * @param Alpha	How opaque the color should be, from 0 to 255
	 * @return The color as a FlxColor
	 */
	public static inline function fromRGB(Red:Int, Green:Int, Blue:Int, Alpha:Int = 255):FlxColor
	{
		var color = new FlxColor();
		return color.setRGB(Red, Green, Blue, Alpha);
	}

	/**
	 * Generate a color from float RGB values (0 to 1)
	 *
	 * @param Red	The red value of the color from 0 to 1
	 * @param Green	The green value of the color from 0 to 1
	 * @param Blue	The green value of the color from 0 to 1
	 * @param Alpha	How opaque the color should be, from 0 to 1
	 * @return The color as a FlxColor
	 */
	public static inline function fromRGBFloat(Red:Float, Green:Float, Blue:Float, Alpha:Float = 1):FlxColor
	{
		var color = new FlxColor();
		return color.setRGBFloat(Red, Green, Blue, Alpha);
	}

	/**
	 * Generate a color from CMYK values (0 to 1)
	 *
	 * @param Cyan		The cyan value of the color from 0 to 1
	 * @param Magenta	The magenta value of the color from 0 to 1
	 * @param Yellow	The yellow value of the color from 0 to 1
	 * @param Black		The black value of the color from 0 to 1
	 * @param Alpha		How opaque the color should be, from 0 to 1
	 * @return The color as a FlxColor
	 */
	public static inline function fromCMYK(Cyan:Float, Magenta:Float, Yellow:Float, Black:Float, Alpha:Float = 1):FlxColor
	{
		var color = new FlxColor();
		return color.setCMYK(Cyan, Magenta, Yellow, Black, Alpha);
	}

	/**
	 * Generate a color from HSB (aka HSV) components.
	 *
	 * @param	Hue			A number between 0 and 360, indicating position on a color strip or wheel.
	 * @param	Saturation	A number between 0 and 1, indicating how colorful or gray the color should be.  0 is gray, 1 is vibrant.
	 * @param	Brightness	(aka Value) A number between 0 and 1, indicating how bright the color should be.  0 is black, 1 is full bright.
	 * @param	Alpha		How opaque the color should be, either between 0 and 1 or 0 and 255.
	 * @return	The color as a FlxColor
	 */
	public static function fromHSB(Hue:Float, Saturation:Float, Brightness:Float, Alpha:Float = 1):FlxColor
	{
		var color = new FlxColor();
		return color.setHSB(Hue, Saturation, Brightness, Alpha);
	}

	/**
	 * Generate a color from HSL components.
	 *
	 * @param	Hue			A number between 0 and 360, indicating position on a color strip or wheel.
	 * @param	Saturation	A number between 0 and 1, indicating how colorful or gray the color should be.  0 is gray, 1 is vibrant.
	 * @param	Lightness	A number between 0 and 1, indicating the lightness of the color
	 * @param	Alpha		How opaque the color should be, either between 0 and 1 or 0 and 255.
	 * @return	The color as a FlxColor
	 */
	public static inline function fromHSL(Hue:Float, Saturation:Float, Lightness:Float, Alpha:Float = 1):FlxColor
	{
		var color = new FlxColor();
		return color.setHSL(Hue, Saturation, Lightness, Alpha);
	}

	/**
	 * Parses a `String` and returns a `FlxColor` or `null` if the `String` couldn't be parsed.
	 *
	 * Examples (input -> output in hex):
	 *
	 * - `0x00FF00`    -> `0xFF00FF00`
	 * - `0xAA4578C2`  -> `0xAA4578C2`
	 * - `#0000FF`     -> `0xFF0000FF`
	 * - `#3F000011`   -> `0x3F000011`
	 * - `GRAY`        -> `0xFF808080`
	 * - `blue`        -> `0xFF0000FF`
	 *
	 * @param	str 	The string to be parsed
	 * @return	A `FlxColor` or `null` if the `String` couldn't be parsed
	 */
	public static function fromString(str:String):Null<FlxColor>
	{
		var result:Null<FlxColor> = null;
		str = StringTools.trim(str);

		if (COLOR_REGEX.match(str))
		{
			var hexColor:String = "0x" + COLOR_REGEX.matched(2);
			result = new FlxColor(Std.parseInt(hexColor));
			if (hexColor.length == 8)
			{
				result.alphaFloat = 1;
			}
		}
		else
		{
			str = str.toUpperCase();
			for (key in colorLookup.keys())
			{
				if (key.toUpperCase() == str)
				{
					result = new FlxColor(colorLookup.get(key));
					break;
				}
			}
		}

		return result;
	}

	/**
	 * Get HSB color wheel values in an array which will be 360 elements in size
	 *
	 * @param	Alpha Alpha value for each color of the color wheel, between 0 (transparent) and 255 (opaque)
	 * @return	HSB color wheel as Array of FlxColors
	 */
	public static function getHSBColorWheel(Alpha:Int = 255):Array<FlxColor>
	{
		return [for (c in 0...360) fromHSB(c, 1.0, 1.0, Alpha)];
	}

	/**
	 * Get an interpolated color based on two different colors.
	 *
	 * @param 	Color1 The first color
	 * @param 	Color2 The second color
	 * @param 	Factor Value from 0 to 1 representing how much to shift Color1 toward Color2
	 * @return	The interpolated color
	 */
	public static inline function interpolate(Color1:FlxColor, Color2:FlxColor, Factor:Float = 0.5):FlxColor
	{
		var r:Int = Std.int((Color2.red - Color1.red) * Factor + Color1.red);
		var g:Int = Std.int((Color2.green - Color1.green) * Factor + Color1.green);
		var b:Int = Std.int((Color2.blue - Color1.blue) * Factor + Color1.blue);
		var a:Int = Std.int((Color2.alpha - Color1.alpha) * Factor + Color1.alpha);

		return fromRGB(r, g, b, a);
	}

	/**
	 * Create a gradient from one color to another
	 *
	 * @param Color1 The color to shift from
	 * @param Color2 The color to shift to
	 * @param Steps How many colors the gradient should have
	 * @param Ease An optional easing function, such as those provided in FlxEase
	 * @return An array of colors of length Steps, shifting from Color1 to Color2
	 */
	public static function gradient(Color1:FlxColor, Color2:FlxColor, Steps:Int, ?Ease:Float->Float):Array<FlxColor>
	{
		var output = new Array<FlxColor>();

		if (Ease == null)
		{
			Ease = function(t:Float):Float
			{
				return t;
			}
		}

		for (step in 0...Steps)
		{
			output[step] = interpolate(Color1, Color2, Ease(step / (Steps - 1)));
		}

		return output;
	}

	/**
	 * Multiply the RGB channels of two FlxColors
	 */
	@:op(A * B)
	public static inline function multiply(lhs:FlxColor, rhs:FlxColor):FlxColor
	{
		return FlxColor.fromRGBFloat(lhs.redFloat * rhs.redFloat, lhs.greenFloat * rhs.greenFloat, lhs.blueFloat * rhs.blueFloat);
	}

	/**
	 * Add the RGB channels of two FlxColors
	 */
	@:op(A + B)
	public static inline function add(lhs:FlxColor, rhs:FlxColor):FlxColor
	{
		return FlxColor.fromRGB(lhs.red + rhs.red, lhs.green + rhs.green, lhs.blue + rhs.blue);
	}

	/**
	 * Subtract the RGB channels of one FlxColor from another
	 */
	@:op(A - B)
	public static inline function subtract(lhs:FlxColor, rhs:FlxColor):FlxColor
	{
		return FlxColor.fromRGB(lhs.red - rhs.red, lhs.green - rhs.green, lhs.blue - rhs.blue);
	}
}

class FlxKeyCustom
{
	public static var fromStringMap(default, null):Map<String, FlxKey> = FlxMacroUtil.buildMap("flixel.input.keyboard.FlxKey");
	public static var toStringMap(default, null):Map<FlxKey, String> = FlxMacroUtil.buildMap("flixel.input.keyboard.FlxKey", true);
	// Key Indicies
	static var NONE = -1;

	public static inline function fromString(s:String)
	{
		s = s.toUpperCase();
		return fromStringMap.exists(s) ? fromStringMap.get(s) : NONE;
	}
}

#if sys
class SysCustom
{
	public static function print(v:Dynamic) {
		Sys.print(v);
	}
	public static function println(v:Dynamic) {
		Sys.println(v);
	}
	public static function args() {
		return Sys.args();
	}
	public static function getEnv(s:String) {
		return Sys.getEnv(s);
	}
	public static function environment() {
		return Sys.environment();
	}
	public static function sleep(seconds:Float) {
		Sys.sleep(seconds);
	}
	public static function getCwd() {
		return Sys.getCwd();
	}
	public static function systemName() {
		return Sys.systemName();
	}
	public static function exit(code:Int) {
		Sys.exit(code);
	}
	public static function time() {
		return Sys.time();
	}
	public static function cpuTime() {
		return Sys.cpuTime();
	}
	public static function programPath() {
		return Sys.programPath();
	}
	public static function getChar(echo:Bool) {
		return Sys.getChar(echo);
	}
	public static function stdin() {
		return Sys.stdin();
	}
	public static function stdout() {
		return Sys.stdout();
	}
	public static function stderr() {
		return Sys.stderr();
	}
}
#end
#end