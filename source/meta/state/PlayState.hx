package meta.state;

import haxe.ds.Vector as HaxeVector;

#if MODS_ALLOWED
import meta.state.ModsMenuState.ModMetadata;
#end

#if !flash 
import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;
#end

import openfl.events.KeyboardEvent;
import openfl.display.BlendMode;

import flixel.util.FlxTimer.FlxTimerManager;

import modcharting.ModchartFuncs;
import modcharting.NoteMovement;
import modcharting.PlayfieldRenderer;

#if VIDEOS_ALLOWED
#if (hxCodec >= "3.0.0") import hxcodec.flixel.FlxVideo as MP4Handler;
#elseif (hxCodec >= "2.6.1") import hxcodec.VideoHandler as MP4Handler;
#elseif (hxCodec == "2.6.0") import VideoHandler as MP4Handler;
#elseif (hxCodec) import vlc.MP4Handler; 
#elseif (hxvlc) import hxvlc.flixel.FlxVideo as MP4Handler; 
#end
#end

#if WEBM_ALLOWED
import meta.video.BackgroundVideo;
import meta.video.VideoSubState;
import meta.video.WebmHandler;
#end

import meta.video.*;
import meta.data.scripts.*;
import meta.data.scripts.FunkinLua;
import meta.data.Achievements;
import meta.data.StageData;
import meta.data.WeekData;

import meta.state.ReplayState.ReplayPauseSubstate;

import objects.Character;
import objects.shaders.*;
import objects.background.*;
import objects.userinterface.note.*;
import objects.userinterface.note.Note;
import objects.userinterface.DialogueBoxPsych;

import flixel_5_3_1.ParallaxSprite;

class PlayState extends MusicBeatState
{
	public static var STRUM_X = 48.5;
	public static var STRUM_X_MIDDLESCROLL = -278;
	public static var ratingStuff:Array<Dynamic> = []; 

	public var stateTimers:FlxTimerManager = new FlxTimerManager();

	//event variables
	private var isCameraOnForcedPos:Bool = false;

	public var boyfriendMap:Map<String, Boyfriend> = new Map();
	public var dadMap:Map<String, Character> = new Map();
	public var gfMap:Map<String, Character> = new Map();
	public var variables:Map<String, Dynamic> = new Map();
	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartSprites:Map<String, ModchartSprite> = new Map<String, ModchartSprite>();
	public var modchartParallax:Map<String, ParallaxSprite> = new Map<String, ParallaxSprite>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	public var modchartTexts:Map<String, ModchartText> = new Map<String, ModchartText>();
	public var modchartSaves:Map<String, FlxSave> = new Map<String, FlxSave>();
	public var elapsedtime:Float = 0;

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var songSpeedTween:FlxTween;
	public var songSpeed(default, set):Float = 1;
	public var songSpeedType:String = "multiplicative";
	public var noteKillOffset:Float = 350;

	public var playbackRate(default, set):Float = 1;

	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;

	public static var curStage:String = '';
	public static var isPixelStage:Bool = false;
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	public var spawnTime:Float = 2000;

	public var vocals:FlxSound;
	var vocalsFinished:Bool = false;

	public var dad:Character = null;
	public var gf:Character = null;
	public var boyfriend:Boyfriend = null;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<EventNote> = [];

	private var strumLine:FlxSprite;

	// Precision
	public var precisions:Array<FlxText> = [];

	//Handles the new epic mega sexy cam code that i've done
	public var camFollow:FlxPoint;
	public var camFollowPos:FlxObject;
	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public var camZooming:Bool = false;
	public var camZoomingMult:Float = 1;
	public var camZoomingDecay:Float = 1;

	public var gfSpeed:Int = 1;
	public var health(default, set):Float = 1;
	public var combo:Int = 0;

	public var healthBar:Bar;
	public var timeBar:Bar;

	var songPercent:Float = 0;

	public var ratingsArray:Array<Dynamic> = [
		// name, hit window, score, notesplash
		["sick", 1, 350, true],
		["good", 0.75, 200, false],
		["bad", 0.5, 100, false],
		["shit", 0, 50, false]
	];
	public var ratingsData:Array<Rating> = [];
	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;

	private var generatedMusic:Bool = false;
	public var endingSong:Bool = false;
	public var startingSong:Bool = false;
	private var updateTime:Bool = true;
	public static var changedDifficulty:Bool = false;
	public static var chartingMode:Bool = false;

	//Gameplay settings
	public var healthGain:Float = 1;
	public var healthLoss:Float = 1;
	public var instakillOnMiss:Bool = false;
	public var cpuControlled:Bool = false;
	public var practiceMode:Bool = false;
	public var botplaySine:Float = 0;
	public var botplayTxt:FlxText;

	var randomMode:Bool = false;
	var flip:Bool = false;
	var stairs:Bool = false;
	var waves:Bool = false;
	var oneK:Bool = false;
	var randomSpeedThing:Bool = false;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;
	public var camTint:FlxCamera;
	public var cameraSpeed:Float = 1;

	var dialogue:Array<String> = null;
	var dialogueJson:DialogueFile = null;

	var dadbattleBlack:BGSprite;
	var dadbattleLight:BGSprite;
	var dadbattleSmokes:FlxSpriteGroup;

	var halloweenBG:BGSprite;
	var halloweenWhite:BGSprite;

	var phillyLightsColors:Array<FlxColor>;
	var phillyWindow:BGSprite;
	var phillyStreet:BGSprite;
	var phillyTrain:BGSprite;
	var blammedLightsBlack:FlxSprite;
	var phillyWindowEvent:BGSprite;
	var trainSound:FlxSound;
	var phillyGlowGradient:PhillyGlow.PhillyGlowGradient;
	var phillyGlowParticles:FlxTypedGroup<PhillyGlow.PhillyGlowParticle>;

	var limoKillingState:Int = 0;
	var limo:BGSprite;
	var limoMetalPole:BGSprite;
	var limoLight:BGSprite;
	var limoCorpse:BGSprite;
	var limoCorpseTwo:BGSprite;
	var bgLimo:BGSprite;
	var grpLimoParticles:FlxTypedGroup<BGSprite>;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:BGSprite;
	var billBoard:FlxSprite;

	var upperBoppers:BGSprite;
	var bottomBoppers:BGSprite;
	var santa:BGSprite;
	var heyTimer:Float;

	var bgGirls:FlxTypedGroup<BackgroundGirls>;
	var rosesLightningGrp:FlxTypedGroup<BGSprite>;
	var schoolCloudsGrp:FlxTypedGroup<BGSprite>;
	var schoolRain:FlxSprite;
	var rainSound:FlxSound = null;
	var bgGhouls:BGSprite;

	var tintMap:Map<String, FlxSprite> = new Map<String, FlxSprite>();

	var tankWatchtower:BGSprite;
	var tankGround:BGSprite;
	var tankmanRun:FlxTypedGroup<TankmenBG>;
	var foregroundSprites:FlxTypedGroup<BGSprite>;
	var gunsThing:FlxSprite;
	var gunsExtraClouds:FlxBackdrop;

	public var tankmanRainbow:Bool = false;
	final gunsColors:Array<FlxColor> = [0xBFFF0000, 0xBFFF5E00, 0xBFFFFB00, 0xBF00FF0D, 0xBF0011FF, 0xBFD400FF];
	var gunsTween:FlxTween = null;
	var stageGraphicArray:Array<FlxSprite> = [];
	var gunsNoteTweens:Array<FlxTween> = [];

	public var smoothScore:Float = 0;
	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var scoreTxt:FlxText;
	public var judgementCounter:FlxText;

	var timeTxt:FlxText;
	var scoreTxtTween:FlxTween;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var campaignSicks:Int = 0;
	public static var campaignGoods:Int = 0;
	public static var campaignBads:Int = 0;
	public static var campaignShits:Int = 0;

	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;

	public var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;
	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public var inCutscene:Bool = false;
	public var skipCountdown:Bool = false;
	
	var songLength:Float = 0;

	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	var inReplay:Bool;

	//Achievement shit
	var keysPressed:Array<Bool> = [];
	var boyfriendIdleTime:Float = 0.0;
	var boyfriendIdled:Bool = false;
	var achievementsArray:Array<FunkinLua> = [];
	public static var achievementWeeks:Array<String> = [];

	// Lua shit
	public static var instance:PlayState = null;
	#if LUA_ALLOWED
	public var luaArray:Array<FunkinLua> = [];
	private var luaDebugGroup:FlxTypedGroup<DebugLuaText>;
	#end
	public var introSoundsSuffix:String = '';

	#if HSCRIPT_ALLOWED
	public var scriptArray:Array<FunkinHScript> = [];
	#end

	// Debug buttons
	private var debugKeysChart:Array<FlxKey>;
	private var debugKeysCharacter:Array<FlxKey>;

	// Less laggy controls
	private var keysArray:Array<Dynamic>;
	private var controlArray:Array<String>;

	var precacheList:Map<String, String> = new Map<String, String>();
	
	// stores the last judgement object
	public static var lastRating:RatingSprite;
	// stores the last combo sprite object
	public static var lastCombo:FlxSprite;
	// stores the last combo score objects in an array
	public static var lastScore:Array<FlxSprite> = [];

	var moveCamTo:HaxeVector<Float> = new HaxeVector(2);

	var nps:Int = 0;
	var npsArray:Array<Date> = [];
	var maxNPS:Int = 0;

	//the payload for beat-based buttplug support
	public var bpPayload:String = ""; // why was this added again??

	public var comboFunction:Void->Void = null;
	public static var inMini:Bool = false;

	public static var gainedCredit:Int = 0;

	public static function truncateFloat(number:Float, precision:Int):Float
	{
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round(num) / Math.pow(10, precision);
		return num;
	}

	override public function create()
	{
		PauseSubState.fromPlayState = false;

		if (curStage != 'schoolEvil')
			Application.current.window.title = 'Friday Night Funkin\': Joalor64 Engine Rewritten - NOW PLAYING: ${SONG.song}';

		#if cpp
		cpp.vm.Gc.enable(true);
		#end
		System.gc();

		Paths.clearStoredMemory();

		// for lua
		instance = this;

		if (!inReplay)
		{
			ReplayState.hits = [];
			ReplayState.miss = [];
			ReplayState.judgements = [];
			ReplayState.sustainHits = [];
		}

		#if WEBM_ALLOWED
		var ourVideo:Dynamic = BackgroundVideo.get();

		if (useVideo && ourVideo != null)
		{
			ourVideo.stop();
			remove(videoSprite);
		}

		removedVideo = true;
		#end

		debugKeysChart = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));
		debugKeysCharacter = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_2'));
		PauseSubState.songName = null; //Reset to default
		playbackRate = ClientPrefs.getGameplaySetting('songspeed', 1);

		controlArray = [
			'NOTE_LEFT',
			'NOTE_DOWN',
			'NOTE_UP',
			'NOTE_RIGHT'
		];

		keysArray = [];

		// real question, how do switch statements make everything so easy??
		ratingStuff = switch (ClientPrefs.scoreTxtType) {
			case 'Default': [
				['F-', 0.2],
				['F', 0.5],
				['D', 0.6],
				['C', 0.7],
				['B', 0.8],
				['A-', 0.89],
				['A', 0.90],
				['A+', 0.93],
				['S-', 0.96],
				['S', 0.99],
				['S+', 0.997],
				['SS-', 0.998],
				['SS', 0.999],
				['SS+', 0.9995],
				['X-', 0.9997],
				['X', 0.9998],
				['X+', 0.999935],
				['P', 1.0]
			];

			case 'Psych': [
				['You Suck!', 0.2],
				['Shit', 0.4],
				['Bad', 0.5],
				['Bruh', 0.6],
				['Meh', 0.69],
				['Nice', 0.7],
				['Good', 0.8],
				['Great', 0.9],
				['Sick!', 1],
				['Perfect!!', 1]
			];

			case 'Kade': [
				['D', 0.59],
				['C', 0.6],
				['B', 0.7],
				['A', 0.8],
				['A.', 0.85],
				['A:', 0.90],
				['AA', 0.93],
				['AA.', 0.965],
				['AA:', 0.99],
				['AAA', 0.997],
				['AAA.', 0.998],
				['AAA:', 0.999],
				['AAAA', 0.99955],
				['AAAA.', 0.9997],
				['AAAA:', 0.9998],
				['AAAAA', 0.999935]
			];

			default: [
				['?', 0.2],
				['??', 0.4],
				['???', 0.5],
				['????', 0.6],
				['?????', 0.69],
				['??????', 0.7], 
				['???????', 0.8], 
				['????????', 0.9],
				['?????????', 1], 
				['??????????', 1] 
			];	
		}

		for (ass in controlArray)
			keysArray.push(ClientPrefs.copyKey(ClientPrefs.keyBinds.get(ass.toLowerCase())));

		comboFunction = () -> {
			// Rating FC
			switch (ClientPrefs.scoreTxtType)
			{
				case 'Default':
					ratingFC = "CB";
					if (songMisses < 1){
						if (shits > 0)
							ratingFC = "FC";
						else if (bads > 0)
							ratingFC = "GFC";
						else if (goods > 0)
							ratingFC = "MFC";
						else if (sicks > 0)
							ratingFC = "SFC";
					}
					else if (songMisses < 10){
						ratingFC = "SDCB";
					}
					else if (songMisses > 100){
						ratingFC = "WTF";
					}
					else if (cpuControlled){
						ratingFC = "Botplay";
					}
				
				case 'Psych':
					ratingFC = "";
					if (sicks > 0) ratingFC = "SFC";
					if (goods > 0) ratingFC = "GFC";
					if (bads > 0 || shits > 0) ratingFC = "FC";
					if (songMisses > 0 && songMisses < 10) ratingFC = "SDCB";
					else if (songMisses >= 10) ratingFC = "Clear";

				case 'Kade':
					ratingFC = "N/A";
					if (cpuControlled)
						ratingFC = "BotPlay";

					else if (songMisses == 0 && sicks >= 0 && goods == 0 && bads == 0 && shits == 0)
						ratingFC = "MFC";
					else if (songMisses == 0 && goods >= 0 && bads == 0 && shits == 0)
						ratingFC = "GFC";
					else if (songMisses == 0)
						ratingFC = "FC";
					else if (songMisses <= 10)
						ratingFC = "SDCB";
					else
						ratingFC = "Clear";
			}		
		}

		for (i in ratingsArray) {
			var rating:Rating = new Rating(i[0]);
			rating.ratingMod = i[1];
			rating.score = i[2];
			rating.noteSplash = i[3];
			ratingsData.push(rating);
		}

		// For the "Just the Two of Us" achievement
		for (i in 0...keysArray.length)
			keysPressed.push(false);

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// Gameplay settings
		healthGain = ClientPrefs.getGameplaySetting('healthgain', 1);
		healthLoss = ClientPrefs.getGameplaySetting('healthloss', 1);
		instakillOnMiss = ClientPrefs.getGameplaySetting('instakill', false);
		practiceMode = ClientPrefs.getGameplaySetting('practice', false);
		cpuControlled = ClientPrefs.getGameplaySetting('botplay', false);
		randomMode = ClientPrefs.getGameplaySetting('randommode', false);
		flip = ClientPrefs.getGameplaySetting('flip', false);
		stairs = ClientPrefs.getGameplaySetting('stairmode', false);
		waves = ClientPrefs.getGameplaySetting('wavemode', false);
		oneK = ClientPrefs.getGameplaySetting('onekey', false);
		randomSpeedThing = ClientPrefs.getGameplaySetting('randomspeed', false);

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camTint = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;
		camTint.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camTint, false);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camOther, false);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>(8);

		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		persistentUpdate = persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.bpm = SONG.bpm;

		#if desktop
		storyDifficultyText = CoolUtil.difficulties[storyDifficulty];

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		detailsText = (isStoryMode) ? "Story Mode: " + WeekData.getCurrentWeek().weekName : "Freeplay";

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end

		GameOverSubstate.resetVariables();
		var songName:String = Paths.formatToSongPath(SONG.song);

		curStage = SONG.stage;
		if(SONG.stage == null || SONG.stage.length < 1) {
			switch (songName)
			{
				case 'spookeez' | 'south' | 'monster': curStage = 'spooky';
				case 'pico' | 'blammed' | 'philly' | 'philly-nice': curStage = 'philly';
				case 'milf' | 'satin-panties' | 'high': curStage = 'limo';
				case 'cocoa' | 'eggnog': curStage = 'mall';
				case 'winter-horrorland': curStage = 'mallEvil';
				case 'senpai' | 'roses': curStage = 'school';
				case 'thorns': curStage = 'schoolEvil';
				case 'ugh' | 'guns' | 'stress': curStage = 'tank';
				default: curStage = 'stage';
			}
		}
		SONG.stage = curStage;

		var stageData:StageFile = StageData.getStageFile(curStage);
		if(stageData == null) { //Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = {
				directory: "",
				defaultZoom: 0.9,
				isPixelStage: false,

				boyfriend: [770, 100],
				girlfriend: [400, 130],
				opponent: [100, 100],
				hide_girlfriend: false,

				camera_boyfriend: [0, 0],
				camera_opponent: [0, 0],
				camera_girlfriend: [0, 0],
				camera_speed: 1
			};

			#if sys
			ArtemisIntegration.setBackgroundColor ("#00000000");
			#end
		}

		defaultCamZoom = stageData.defaultZoom;
		isPixelStage = stageData.isPixelStage;
		
		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];

		if(stageData.camera_speed != null)
			cameraSpeed = stageData.camera_speed;

		boyfriendCameraOffset = stageData.camera_boyfriend;
		if(boyfriendCameraOffset == null) //Fucks sake should have done it since the start :rolling_eyes:
			boyfriendCameraOffset = [0, 0];

		opponentCameraOffset = stageData.camera_opponent;
		if(opponentCameraOffset == null)
			opponentCameraOffset = [0, 0];

		girlfriendCameraOffset = stageData.camera_girlfriend;
		if(girlfriendCameraOffset == null)
			girlfriendCameraOffset = [0, 0];

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);

		// tell artemis all the things it needs to know
		#if sys
		ArtemisIntegration.setStageName (curStage);
		if (isStoryMode) ArtemisIntegration.setGameState ("in-game story");
		else ArtemisIntegration.setGameState ("in-game freeplay");
		ArtemisIntegration.sendBoyfriendHealth (health);
		ArtemisIntegration.setIsPixelStage (isPixelStage);
		ArtemisIntegration.autoUpdateControlColors (isPixelStage);
		ArtemisIntegration.setBackgroundColor ("#00000000"); // in case there's no set background in the artemis profile, hide the background and just show the overlays over the user's default artemis layout
		ArtemisIntegration.resetAllFlags ();

		#if MODS_ALLOWED
		if (Mods.currentModDirectory != null && Mods.currentModDirectory.length > 0) {
			var currentMod:ModMetadata = new ModMetadata (Mods.currentModDirectory);
			if (currentMod.id == "name") ArtemisIntegration.resetModName ();
			else ArtemisIntegration.setModName (currentMod.id);

			var possibleArtemisProfilePathHahaLongVariableName:String = haxe.io.Path.join (["mods/", Mods.currentModDirectory, "/artemis/default.json"]);
			if (sys.FileSystem.exists (possibleArtemisProfilePathHahaLongVariableName)) {
				ArtemisIntegration.sendProfileRelativePath (possibleArtemisProfilePathHahaLongVariableName);
			}
		} else {
			ArtemisIntegration.resetModName ();
		}
		#end

		ArtemisIntegration.startSong ();
		#end

		switch (curStage)
		{
			case 'stage': //Week 1
				var bg:BGSprite = new BGSprite('stages/stage/stageback', -600, -200, 0.9, 0.9);
				add(bg);

				var stageFront:BGSprite = new BGSprite('stages/stage/stagefront', -650, 600, 0.9, 0.9);
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				add(stageFront);
				if(!ClientPrefs.lowQuality) {
					var stageLight:BGSprite = new BGSprite('stages/stage/stage_light', -125, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					add(stageLight);
					var stageLight:BGSprite = new BGSprite('stages/stage/stage_light', 1225, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					stageLight.flipX = true;
					add(stageLight);

					var stageCurtains:BGSprite = new BGSprite('stages/stage/stagecurtains', -500, -300, 1.3, 1.3);
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					add(stageCurtains);
				}
				dadbattleSmokes = new FlxSpriteGroup(); //troll'd

			case 'spooky': //Week 2
				if(!ClientPrefs.lowQuality) {
					halloweenBG = new BGSprite('stages/spooky/halloween_bg', -200, -100, ['halloweem bg0', 'halloweem bg lightning strike']);
				} else {
					halloweenBG = new BGSprite('stages/spooky/halloween_bg_low', -200, -100);
				}
				add(halloweenBG);

				halloweenWhite = new BGSprite(null, -800, -400, 0, 0);
				halloweenWhite.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
				halloweenWhite.alpha = 0;
				halloweenWhite.blend = ADD;

				//PRECACHE SOUNDS
				precacheList.set('thunder_1', 'sound');
				precacheList.set('thunder_2', 'sound');

			case 'philly': //Week 3
				if(!ClientPrefs.lowQuality) {
					var bg:BGSprite = new BGSprite('stages/philly/sky', -100, 0, 0.1, 0.1);
					add(bg);
				}

				var city:BGSprite = new BGSprite('stages/philly/city', -10, 0, 0.3, 0.3);
				city.setGraphicSize(Std.int(city.width * 0.85));
				city.updateHitbox();
				add(city);

				phillyLightsColors = [0xFF31A2FD, 0xFF31FD8C, 0xFFFB33F5, 0xFFFD4531, 0xFFFBA633];
				phillyWindow = new BGSprite('stages/philly/window', city.x, city.y, 0.3, 0.3);
				phillyWindow.setGraphicSize(Std.int(phillyWindow.width * 0.85));
				phillyWindow.updateHitbox();
				add(phillyWindow);
				phillyWindow.alpha = 0;

				if(!ClientPrefs.lowQuality) {
					var streetBehind:BGSprite = new BGSprite('stages/philly/behindTrain', -40, 50);
					add(streetBehind);
				}

				phillyTrain = new BGSprite('stages/philly/train', 2000, 360);
				add(phillyTrain);

				trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
				FlxG.sound.list.add(trainSound);

				phillyStreet = new BGSprite('stages/philly/street', -40, 50);
				add(phillyStreet);

			case 'limo': //Week 4
				var skyBG:BGSprite = new BGSprite('stages/limo/limoSunset', -120, -50, 0.1, 0.1);
				add(skyBG);

				billBoard = new FlxSprite(1000, -500).loadGraphic(Paths.image('stages/limo/fastBfLol'));
				billBoard.scrollFactor.set(0.36,0.36);
				billBoard.scale.set(1.9,1.9);
				billBoard.updateHitbox();
				add(billBoard);
				billBoard.active = true;

				if(!ClientPrefs.lowQuality) {
					limoMetalPole = new BGSprite('stages/limo/gore/metalPole', -500, 220, 0.4, 0.4);
					add(limoMetalPole);

					bgLimo = new BGSprite('stages/limo/bgLimo', -150, 480, 0.4, 0.4, ['background limo pink'], true);
					add(bgLimo);

					limoCorpse = new BGSprite('stages/limo/gore/noooooo', -500, limoMetalPole.y - 130, 0.4, 0.4, ['Henchmen on rail'], true);
					add(limoCorpse);

					limoCorpseTwo = new BGSprite('stages/limo/gore/noooooo', -500, limoMetalPole.y, 0.4, 0.4, ['henchmen death'], true);
					add(limoCorpseTwo);

					grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
					add(grpLimoDancers);

					for (i in 0...5)
					{
						var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 170, bgLimo.y - 400);
						dancer.scrollFactor.set(0.4, 0.4);
						grpLimoDancers.add(dancer);
					}

					limoLight = new BGSprite('stages/limo/gore/coldHeartKiller', limoMetalPole.x - 180, limoMetalPole.y - 80, 0.4, 0.4);
					add(limoLight);

					grpLimoParticles = new FlxTypedGroup<BGSprite>();
					add(grpLimoParticles);

					//PRECACHE BLOOD
					var particle:BGSprite = new BGSprite('stages/limo/gore/stupidBlood', -400, -400, 0.4, 0.4, ['blood'], false);
					particle.alpha = 0.01;
					grpLimoParticles.add(particle);
					resetLimoKill();

					//PRECACHE SOUND
					precacheList.set('dancerdeath', 'sound');
				}

				limo = new BGSprite('stages/limo/limoDrive', -120, 550, 1, 1, ['Limo stage'], true);

				fastCar = new BGSprite('stages/limo/fastCarLol', -300, 160);
				fastCar.active = true;
				limoKillingState = 0;

			case 'mall': //Week 5 - Cocoa, Eggnog
				var bg:BGSprite = new BGSprite('stages/mall/christmas/bgWalls', -1000, -500, 0.2, 0.2);
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				if(!ClientPrefs.lowQuality) {
					upperBoppers = new BGSprite('stages/mall/christmas/upperBop', -240, -90, 0.33, 0.33, ['Upper Crowd Bob']);
					upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
					upperBoppers.updateHitbox();
					add(upperBoppers);

					var bgEscalator:BGSprite = new BGSprite('stages/mall/christmas/bgEscalator', -1100, -600, 0.3, 0.3);
					bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
					bgEscalator.updateHitbox();
					add(bgEscalator);
				}

				var tree:BGSprite = new BGSprite('stages/mall/christmas/christmasTree', 370, -250, 0.40, 0.40);
				add(tree);

				bottomBoppers = new BGSprite('stages/mall/christmas/bottomBop', -300, 140, 0.9, 0.9, ['Bottom Level Boppers Idle']);
				bottomBoppers.animation.addByPrefix('hey', 'Bottom Level Boppers HEY', 24, false);
				bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
				bottomBoppers.updateHitbox();
				add(bottomBoppers);

				var fgSnow:BGSprite = new BGSprite('stages/mall/christmas/fgSnow', -600, 700);
				add(fgSnow);

				santa = new BGSprite('stages/mall/christmas/santa', -840, 150, 1, 1, ['santa idle in fear']);
				add(santa);
				precacheList.set('Lights_Shut_off', 'sound');

			case 'mallEvil': //Week 5 - Winter Horrorland
				var bg:BGSprite = new BGSprite('stages/mall/christmas/evilBG', -400, -500, 0.2, 0.2);
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				var evilTree:BGSprite = new BGSprite('stages/mall/christmas/evilTree', 300, -300, 0.2, 0.2);
				add(evilTree);

				var evilSnow:BGSprite = new BGSprite('stages/mall/christmas/evilSnow', -200, 700);
				add(evilSnow);

			case 'school': //Week 6 - Senpai, Roses
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
				GameOverSubstate.loopSoundName = 'gameOver-pixel';
				GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
				GameOverSubstate.characterName = 'bf-pixel-dead';

				final path = 'stages/school';
				final isRoses = SONG.song.toLowerCase() == 'roses';
				var layerArray:Array<FlxBasic> = [];
	
				var bgSky:BGSprite = new BGSprite('$path/weeb/weebSky', 0, 0, 0.1, 0.1);
				if (isRoses) bgSky.color = 0xffcecece;
	
				final repositionShit = -198;
	
				var bgSchool:BGSprite = new BGSprite('$path/weeb/weebSchool', repositionShit, 0, 0.6, 0.90); //0.6, 0.9
				var bgStreet:BGSprite = new BGSprite('$path/weeb/weebStreet', repositionShit, 0, 1, 1);
	
				var widShit = Std.int(bgSky.width * 6);
	
				var bgTrees:FlxSprite = new FlxSprite(repositionShit - 378, -798);
				bgTrees.frames = Paths.getPackerAtlas('$path/weeb/weebTrees');
				bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
				bgTrees.animation.play('treeLoop');
				bgTrees.scrollFactor.set(0.85, 0.85);

				halloweenWhite = new BGSprite(null, 0, 0, 0, 0);
				halloweenWhite.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
				halloweenWhite.alpha = 0.001;
				halloweenWhite.blend = ADD;
				halloweenWhite.screenCenter();
				halloweenWhite.visible = false;
	
				if (!ClientPrefs.lowQuality) {
					var howMany:Int = (isRoses ? 3 : 1);
					schoolCloudsGrp = new FlxTypedGroup<BGSprite>();
					for (i in 0...howMany) {
						var schoolClouds = new BGSprite('$path/weeb/weebClouds', FlxG.random.int(isRoses ? -120 : -60, 60), FlxG.random.int(isRoses ? -120 : -24, 6), 0.15+0.05*i, 0.2+0.01*i);
						schoolClouds.ID = i;
						schoolClouds.active = true;
						schoolClouds.velocity.x = FlxG.random.float(-6, isRoses ? 12 : 6);
						schoolClouds.antialiasing = false;
						schoolClouds.setGraphicSize(widShit);
						schoolClouds.updateHitbox();
						if (isRoses) schoolClouds.color = 0xffdadada;
						schoolCloudsGrp.add(schoolClouds);
					}

					if (isRoses) {
						rosesLightningGrp = new FlxTypedGroup<BGSprite>();
						for (i in 0...howMany) {
							var rosesLightning = new BGSprite('$path/weeb/weebLightning', schoolCloudsGrp.members[i].x, schoolCloudsGrp.members[i].y, 0.15+0.05*i, 0.2+0.01*i);
							rosesLightning.ID = i;
							rosesLightning.active = true;
							rosesLightning.velocity.x = schoolCloudsGrp.members[i].velocity.x;
							rosesLightning.antialiasing = false;
							rosesLightning.setGraphicSize(widShit);
							rosesLightning.updateHitbox();
							rosesLightning.alpha = 0.001;
							rosesLightning.visible = false;
							rosesLightningGrp.add(rosesLightning);
						}
					}

					var fgTrees:BGSprite = new BGSprite('$path/weeb/weebTreesBack', repositionShit + 174, 132, 0.9, 0.9);
					fgTrees.setGraphicSize(Std.int(widShit * 0.8));
					fgTrees.updateHitbox();
					fgTrees.antialiasing = false;
	
					var treeLeaves:BGSprite = new BGSprite('$path/weeb/petals', repositionShit, -42, 0.85, 0.85, ['PETALS ALL'], true);
					treeLeaves.setGraphicSize(widShit);
					treeLeaves.updateHitbox();
					treeLeaves.antialiasing = false;
	
					bgGirls = new FlxTypedGroup<BackgroundGirls>(3);
						for (i in 0...3) {
							var bgGirl = new BackgroundGirls(-114 + (498 * i) + 48, 192);
							bgGirl.scrollFactor.set(1, 1);
		
							bgGirl.setGraphicSize(Std.int(bgGirl.width * daPixelZoom));
							bgGirl.updateHitbox();
							bgGirls.add(bgGirl);
						}
	
					if (isRoses)
						layerArray = [bgSky, rosesLightningGrp, schoolCloudsGrp, bgSchool, bgStreet, fgTrees, bgTrees, treeLeaves, bgGirls];
					else
						layerArray = [bgSky, schoolCloudsGrp, bgSchool, bgStreet, fgTrees, bgTrees, treeLeaves, bgGirls];
				}
				else
					layerArray = [bgSky, bgSchool, bgStreet, bgTrees];

					switch(SONG.song.toLowerCase()) {
						case 'roses':
							precacheList.set('weeb/thunder_1', 'sound');
							precacheList.set('weeb/thunder_2', 'sound');
							precacheList.set('rainSnd', 'sound');
							Paths.getSparrowAtlas('$path/weeb/rain'); //directly precaching the sparrow atlas like a boss
					}
					autoLayer(layerArray);
	
					bgSky.antialiasing = false;
					bgSchool.antialiasing = false;
					bgStreet.antialiasing = false;
					bgTrees.antialiasing = false;
	
					bgSky.setGraphicSize(widShit);
					bgSchool.setGraphicSize(widShit);
					bgStreet.setGraphicSize(widShit);
					bgTrees.setGraphicSize(Std.int(widShit * 1.4));
	
					bgSky.updateHitbox();
					bgSchool.updateHitbox();
					bgStreet.updateHitbox();
					bgTrees.updateHitbox();

			case 'schoolEvil': //Week 6 - Thorns
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
				GameOverSubstate.loopSoundName = 'gameOver-pixel';
				GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
				GameOverSubstate.characterName = 'bf-pixel-dead';

				var posX = 400;
				var posY = 200;
				if(!ClientPrefs.lowQuality) {
					var bg:BGSprite = new BGSprite('stages/school/weeb/animatedEvilSchool', posX, posY, 0.8, 0.9, ['background 2'], true);
					bg.scale.set(6, 6);
					bg.antialiasing = false;
					add(bg);

					bgGhouls = new BGSprite('stages/school/weeb/bgGhouls', -100, 190, 0.9, 0.9, ['BG freaks glitch instance'], false);
					bgGhouls.setGraphicSize(Std.int(bgGhouls.width * daPixelZoom));
					bgGhouls.updateHitbox();
					bgGhouls.visible = false;
					bgGhouls.antialiasing = false;
					add(bgGhouls);
				} else {
					var bg:BGSprite = new BGSprite('stages/school/weeb/animatedEvilSchool_low', posX, posY, 0.8, 0.9);
					bg.scale.set(6, 6);
					bg.antialiasing = false;
					add(bg);
				}

			case 'tank': //Week 7 - Ugh, Guns, Stress
				final path = 'stages/tank';
				tankmanRainbow = false;
				var layerArray:Array<FlxBasic> = [];
					
				var sky:BGSprite = new BGSprite('$path/tankSky', -400, -400, 0, 0);
				sky.scale.set(1.5,1.5);
				sky.updateHitbox();
	
				var ruins:BGSprite = new BGSprite('$path/tankRuins',-200,0,.35,.35);
				ruins.setGraphicSize(Std.int(1.1 * ruins.width));
				ruins.updateHitbox();
	
				tankGround = new BGSprite('$path/tankRolling', 300, 300, 0.5, 0.5,['BG tank w lighting'], true);
				tankmanRun = new FlxTypedGroup<TankmenBG>();
	
				var ground:BGSprite = new BGSprite('$path/tankGround', -420, -150);
				ground.setGraphicSize(Std.int(1.15 * ground.width));
				ground.updateHitbox();
				moveTank();
	
				if(!ClientPrefs.lowQuality)
				{
					var clouds:BGSprite = new BGSprite('$path/tankClouds', FlxG.random.int(-700, -100), FlxG.random.int(-20, 20), 0.1, 0.1);
					clouds.active = true;
					clouds.velocity.x = FlxG.random.float(5, 15);
	
					var mountains:BGSprite = new BGSprite('$path/tankMountains', -300, -20, 0.2, 0.2);
					mountains.setGraphicSize(Std.int(1.2 * mountains.width));
					mountains.updateHitbox();
	
					var buildings:BGSprite = new BGSprite('$path/tankBuildings', -200, 0, 0.3, 0.3);
					buildings.setGraphicSize(Std.int(1.1 * buildings.width));
					buildings.updateHitbox();
	
					var smokeLeft:BGSprite = new BGSprite('$path/smokeLeft', -200, -100, 0.4, 0.4, ['SmokeBlurLeft'], true);
					var smokeRight:BGSprite = new BGSprite('$path/smokeRight', 1100, -100, 0.4, 0.4, ['SmokeRight'], true);
	
					tankWatchtower = new BGSprite('$path/tankWatchtower', 100, 50, 0.5, 0.5, ['watchtower gradient color']);
	
					layerArray = [sky, clouds, mountains, buildings, ruins, smokeLeft, smokeRight, tankWatchtower, tankGround, tankmanRun, ground];
				} 
				else
					layerArray = [sky, ruins, tankGround, tankmanRun, ground];
	
				autoLayer(layerArray);

				layerArray.remove(sky);
				layerArray.remove(tankmanRun);
				stageGraphicArray = cast layerArray;

				if (SONG.song.toLowerCase() == 'guns') {
					gunsThing = new FlxSprite(-100,-100).makeGraphic(Std.int(FlxG.width * 1.5), Std.int(FlxG.height * 1.5),FlxColor.WHITE);
					gunsThing.color = 0xBFFF0000;
					gunsThing.alpha = 0.001;
					gunsThing.visible = false;
					gunsThing.scrollFactor.set();
					gunsThing.screenCenter();

					gunsExtraClouds = new FlxBackdrop(Paths.image('$path/tankClouds'), XY, 64, 128);
					gunsExtraClouds.velocity.set(12, 168);
					gunsExtraClouds.alpha = 0.001;
					gunsExtraClouds.visible = false;
					gunsExtraClouds.scrollFactor.set(0.1, 0.2);
					add(gunsExtraClouds);
				}

				foregroundSprites = new FlxTypedGroup<BGSprite>();
				foregroundSprites.add(new BGSprite('$path/tank0', -500, 650, 1.7, 1.5, ['fg']));
				if(!ClientPrefs.lowQuality) foregroundSprites.add(new BGSprite('$path/tank1', -300, 750, 2, 0.2, ['fg']));
				foregroundSprites.add(new BGSprite('$path/tank2', 450, 940, 1.5, 1.5, ['foreground']));
				if(!ClientPrefs.lowQuality) foregroundSprites.add(new BGSprite('$path/tank4', 1250, 900, 1.5, 1.5, ['fg']));
				foregroundSprites.add(new BGSprite('$path/tank5', 1620, 700, 1.5, 1.5, ['fg']));
				if(!ClientPrefs.lowQuality) foregroundSprites.add(new BGSprite('$path/tank3', 1300, 1200, 3.5, 2.5, ['fg']));
		}

		switch(Paths.formatToSongPath(SONG.song))
		{
			case 'stress':
				GameOverSubstate.characterName = 'bf-holding-gf-dead';
		}

		if(isPixelStage) {
			introSoundsSuffix = '-pixel';
		}

		add(gfGroup); //Needed for blammed lights

		// Shitty layering but whatev it works LOL
		switch (curStage) {
			case 'limo': add(limo);
			case 'tank': if (SONG.song.toLowerCase() == 'guns') add(gunsThing);
		}

		add(dadGroup);
		add(boyfriendGroup);

		switch(curStage) {
			case 'spooky' | 'school': add(halloweenWhite);
			case 'tank': add(foregroundSprites);
		}

		#if LUA_ALLOWED
		luaDebugGroup = new FlxTypedGroup<DebugLuaText>();
		luaDebugGroup.cameras = [camOther];
		add(luaDebugGroup);
		#end

		function addAbilityToUnlockAchievements(funkinLua:FunkinLua)
		{
			var lua = funkinLua.lua;
			if (lua != null){
				Lua_helper.add_callback(lua, "giveAchievement", function(name:String){
					if (luaArray.contains(funkinLua))
						throw 'Illegal attempt to unlock ' + name;
					@:privateAccess
					if (Achievements.isAchievementUnlocked(name))
						return "Achievement " + name + " is already unlocked!";
					if (!Achievements.exists(name))
						return "Achievement " + name + " does not exist."; 
					if(instance != null) { 
						Achievements.unlockAchievement(name);
						instance.startAchievement(name);
						ClientPrefs.saveSettings();
						return "Unlocked achievement " + name + "!";
					}
					else return "Instance is null.";
				});
			}
		}

		//CUSTOM ACHIVEMENTS
		#if (MODS_ALLOWED && LUA_ALLOWED && ACHIEVEMENTS_ALLOWED)
		var luaFiles:Array<String> = Achievements.getModAchievements().copy();
		if(luaFiles.length > 0)
		{
			for(luaFile in luaFiles)
			{
				var meta:Achievements.AchievementMeta = try Json.parse(File.getContent(luaFile.substring(0, luaFile.length - 4) + '.json')) catch(e) throw e;
				if (meta != null)
				{
					if ((meta.global == null || meta.global.length < 1) && meta.song != null && meta.song.length > 0 && SONG.song.toLowerCase().replace(' ', '-') != meta.song.toLowerCase().replace(' ', '-'))
						continue;

					var lua = new FunkinLua(luaFile);
					addAbilityToUnlockAchievements(lua);
					achievementsArray.push(lua);
				}
			}
		}

		var achievementMetas = Achievements.getModAchievementMetas().copy();
		for (i in achievementMetas) { 
			if (i.global == null || i.global.length < 1)
			{
				if(i.song != null)
				{
					if(i.song.length > 0 && SONG.song.toLowerCase().replace(' ', '-') != i.song.toLowerCase().replace(' ', '-'))
						continue;
				}
				if(i.lua_code != null) {
					var lua = new FunkinLua(null, i.lua_code);
					addAbilityToUnlockAchievements(lua);
					achievementsArray.push(lua);
				}
				if(i.week_nomiss != null) {
					achievementWeeks.push(i.week_nomiss + '_nomiss');
				}
			}
		}
		#end

		// "GLOBAL" SCRIPTS
		var foldersToCheck:Array<String> = Mods.directoriesWithFile(Paths.getPreloadPath(), 'scripts/');
		for (folder in foldersToCheck)
		{
			for (file in FileSystem.readDirectory(folder))
			{
				#if LUA_ALLOWED
				if(file.toLowerCase().endsWith('.lua'))
					luaArray.push(new FunkinLua(folder + file));
				#end

				#if HSCRIPT_ALLOWED
				if (Paths.validScriptType(file))
					scriptArray.push(new FunkinHScript(folder + file));
				#end
			}
		}

		// STAGE SCRIPTS
		#if MODS_ALLOWED
		var doPush:Bool = false;
		#if LUA_ALLOWED
		var luaFile:String = 'stages/' + curStage + '.lua';
		if(FileSystem.exists(Paths.modFolders(luaFile))) {
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		} else {
			luaFile = Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}

		if(doPush)
			luaArray.push(new FunkinLua(luaFile));
		#end

		/*#if HSCRIPT_ALLOWED
		var hscriptFile:String = 'stages/' + curStage + '.hscript';
		if(FileSystem.exists(Paths.modFolders(hscriptFile))) {
			hscriptFile = Paths.modFolders(hscriptFile);
			doPush = true;
		} else {
			hscriptFile = Paths.getPreloadPath(hscriptFile);
			if(FileSystem.exists(hscriptFile)) {
				doPush = true;
			}
		}

		if(doPush)
			addHscript(hscriptFile);
		#end*/
		#end

		var gfVersion:String = SONG.gfVersion;
		if(gfVersion == null || gfVersion.length < 1)
		{
			switch (curStage)
			{
				case 'limo': gfVersion = 'gf-car';
				case 'mall' | 'mallEvil': gfVersion = 'gf-christmas';
				case 'school' | 'schoolEvil': gfVersion = 'gf-pixel';
				case 'tank': gfVersion = 'gf-tankmen';
				default: gfVersion = 'gf';
			}

			switch(Paths.formatToSongPath(SONG.song))
			{
				case 'stress':
					gfVersion = 'pico-speaker';
			}
			SONG.gfVersion = gfVersion; //Fix for the Chart Editor
		}

		if (!stageData.hide_girlfriend)
		{
			gf = new Character(0, 0, gfVersion);
			startCharacterPos(gf);
			gf.scrollFactor.set(0.95, 0.95);
			gfGroup.add(gf);
			startCharacterLua(gf.curCharacter);

			if(gfVersion == 'pico-speaker')
			{
				if(!ClientPrefs.lowQuality)
				{
					var firstTank:TankmenBG = new TankmenBG(20, 500, true);
					firstTank.resetShit(20, 600, true);
					firstTank.strumTime = 10;
					tankmanRun.add(firstTank);

					for (i in 0...TankmenBG.animationNotes.length)
					{
						if(FlxG.random.bool(16)) {
							var tankBih = tankmanRun.recycle(TankmenBG);
							tankBih.strumTime = TankmenBG.animationNotes[i][0];
							tankBih.resetShit(500, 200 + FlxG.random.int(50, 100), TankmenBG.animationNotes[i][1] < 2);
							tankmanRun.add(tankBih);
						}
					}
				}
			}
		}

		dad = new Character(0, 0, SONG.player2);
		startCharacterPos(dad, true);
		dadGroup.add(dad);
		startCharacterLua(dad.curCharacter);

		boyfriend = new Boyfriend(0, 0, SONG.player1);
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);
		startCharacterLua(boyfriend.curCharacter);

		var camPos:FlxPoint = FlxPoint.get(girlfriendCameraOffset[0], girlfriendCameraOffset[1]);
		if(gf != null)
		{
			camPos.x += gf.getGraphicMidpoint().x + gf.cameraPosition[0];
			camPos.y += gf.getGraphicMidpoint().y + gf.cameraPosition[1];
		}

		if(dad.curCharacter.startsWith('gf')) {
			dad.setPosition(GF_X, GF_Y);
			if(gf != null)
				gf.visible = false;
		}

		switch(curStage)
		{
			case 'limo':
				resetFastCar();
				resetBillBoard();
				addBehindGF(fastCar);

			case 'schoolEvil':
				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069); //nice
				addBehindDad(evilTrail);
		}

		switch (SONG.song.toLowerCase()) {
			case 'roses':
				defaultCamZoom += 0.05;
				tintMap.set('roses', addATint(0.15, FlxColor.fromRGB(90, 20, 10))); 
		}

		var file:String = Paths.json(songName + '/dialogue'); //Checks for json/Psych Engine dialogue
		if (Assets.exists(file))
			dialogueJson = DialogueBoxPsych.parseDialogue(file);

		var file:String = Paths.txt(songName + '/' + songName + 'Dialogue'); //Checks for vanilla/Senpai dialogue
		if (Assets.exists(file))
			dialogue = CoolUtil.coolTextFile(file);

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;
		doof.nextDialogueThing = startNextDialogue;
		doof.skipDialogueThing = skipDialogue;

		Conductor.songPosition = -5000 / Conductor.songPosition;

		strumLine = new FlxSprite(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);
		if(ClientPrefs.downScroll) strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();

		var showTime:Bool = (ClientPrefs.timeBarType != 'Disabled');
		timeTxt = new FlxText(0, 19, 400, "", 32);
		timeTxt.screenCenter(X);
		timeTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = updateTime = showTime;
		if(ClientPrefs.downScroll) timeTxt.y = FlxG.height - 44;
		if(ClientPrefs.timeBarType == 'Song Name') timeTxt.text = SONG.song;

		timeBar = new Bar(0, timeTxt.y + (timeTxt.height / 4), 'timeBar', () -> return songPercent, 0, 1);
		timeBar.scrollFactor.set();
		timeBar.screenCenter(X);
		timeBar.alpha = 0;
		timeBar.visible = showTime;
		add(timeBar);
		add(timeTxt);

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);

		if(ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.size = 24;
			timeTxt.y += 3;
		}

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0;

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

		generateSong();

		playfieldRenderer = new PlayfieldRenderer(strumLineNotes, notes, this);
		playfieldRenderer.cameras = [camHUD];
		add(playfieldRenderer);
		add(grpNoteSplashes);

		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);

		snapCamFollowToPos(camPos.x, camPos.y);
		if (prevCamFollow != null && prevCamFollowPos != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;

			camFollowPos = prevCamFollowPos;
			prevCamFollowPos = null;			
		}
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);
		moveCameraSection();

		var healthBarStr:String = (ClientPrefs.longBar) ? 'healthBarLong' : 'healthBar';
		healthBar = new Bar(0, FlxG.height * (!ClientPrefs.downScroll ? 0.89 : 0.11), healthBarStr, () -> return health, 0, 2);
		healthBar.screenCenter(X);
		healthBar.leftToRight = false;
		healthBar.scrollFactor.set();
		healthBar.visible = !ClientPrefs.hideHud;
		healthBar.alpha = ClientPrefs.healthBarAlpha;
		reloadHealthBarColors();
		add(healthBar);

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - 75;
		iconP1.visible = !ClientPrefs.hideHud;
		iconP1.alpha = ClientPrefs.healthBarAlpha;
		iconP1.canBounce = true;
		add(iconP1);

		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.y = healthBar.y - 75;
		iconP2.visible = !ClientPrefs.hideHud;
		iconP2.alpha = ClientPrefs.healthBarAlpha;
		iconP2.canBounce = true;
		add(iconP2);

		scoreTxt = new FlxText(0, healthBar.y + 36, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.visible = !ClientPrefs.hideHud;
		updateScore(false);
		add(scoreTxt);

		// thanks kade
		judgementCounter = new FlxText(20, 0, 0, "", 20);
		judgementCounter.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		judgementCounter.borderSize = 2;
		judgementCounter.borderQuality = 2;
		judgementCounter.scrollFactor.set();
		judgementCounter.cameras = [camHUD];
		judgementCounter.screenCenter(Y);
		judgementCounter.text = 'Sicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}\nMisses: ${songMisses}';
		add(judgementCounter);

		botplayTxt = new FlxText(400, timeBar.y + 55, FlxG.width - 800, "BOTPLAY", 32);
		botplayTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled;
		add(botplayTxt);
		if (ClientPrefs.downScroll)
			botplayTxt.y = timeBar.y - 78;

		var texty:String = (inMini) ? '${SONG.song} - Joalor64 Engine Rewrite v${MainMenuState.joalor64EngineVersion}'
			: '${SONG.song} ${CoolUtil.difficultyString()} - Joalor64 Engine Rewrite v${MainMenuState.joalor64EngineVersion}';
		var versionTxt:FlxText = new FlxText(4, FlxG.height - 24, 0, texty, 12);
		versionTxt.scrollFactor.set();
		versionTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionTxt);

		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		botplayTxt.cameras = [camHUD];
		timeBar.cameras = [camHUD];
		timeTxt.cameras = [camHUD];
		doof.cameras = [camHUD];
		versionTxt.cameras = [camHUD];

		startingSong = true;

		#if LUA_ALLOWED
		for (notetype in noteTypes)
		{
			#if MODS_ALLOWED
			var luaToLoad:String = Paths.modFolders('notetypes/' + notetype + '.lua');
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			else
			{
				luaToLoad = Paths.getPreloadPath('notetypes/' + notetype + '.lua');
				if(FileSystem.exists(luaToLoad))
				{
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
			#elseif sys
			var luaToLoad:String = Paths.getPreloadPath('notetypes/' + notetype + '.lua');
			if(Assets.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			#end
		}
		for (event in eventsPushed)
		{
			#if MODS_ALLOWED
			var luaToLoad:String = Paths.modFolders('events/' + event + '.lua');
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			else
			{
				luaToLoad = Paths.getPreloadPath('events/' + event + '.lua');
				if(FileSystem.exists(luaToLoad))
				{
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
			#elseif sys
			var luaToLoad:String = Paths.getPreloadPath('events/' + event + '.lua');
			if(Assets.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			#end
		}
		#end

		/*#if HSCRIPT_ALLOWED
		for (notetype in noteTypes)
		{
			#if MODS_ALLOWED
			var hscriptToLoad:String = Paths.modFolders('notetypes/' + notetype + '.hscript');
			if(FileSystem.exists(hscriptToLoad))
			{
				addHscript(hscriptToLoad);
			}
			else
			{
				hscriptToLoad = Paths.getPreloadPath('notetypes/' + notetype + '.hscript');
				if(FileSystem.exists(hscriptToLoad))
				{
					addHscript(hscriptToLoad);
				}
			}
			#elseif sys
			var hscriptToLoad:String = Paths.getPreloadPath('notetypes/' + notetype + '.hscript');
			if(Assets.exists(hscriptToLoad))
			{
				addHscript(hscriptToLoad);
			}
			#end
		}
		for (event in eventsPushed)
		{
			#if MODS_ALLOWED
			var hscriptToLoad:String = Paths.modFolders('events/' + event + '.hscript');
			if(FileSystem.exists(hscriptToLoad))
			{
				addHscript(hscriptToLoad);
			}
			else
			{
				hscriptToLoad = Paths.getPreloadPath('events/' + event + '.hscript');
				if(FileSystem.exists(hscriptToLoad))
				{
					addHscript(hscriptToLoad);
				}
			}
			#elseif sys
			var hscriptToLoad:String = Paths.getPreloadPath('events/' + event + '.hscript');
			if(Assets.exists(hscriptToLoad))
			{
				addHscript(hscriptToLoad);
			}
			#end
		}
		#end*/
		noteTypes = null;
		eventsPushed = null;

		// SONG SPECIFIC SCRIPTS
		var foldersToCheck:Array<String> = Mods.directoriesWithFile(Paths.getPreloadPath(), 'data/' + songName + '/');
		for (folder in foldersToCheck)
		{
			for (file in FileSystem.readDirectory(folder))
			{
				#if LUA_ALLOWED
				if(file.toLowerCase().endsWith('.lua'))
					luaArray.push(new FunkinLua(folder + file));
				#end

				#if HSCRIPT_ALLOWED
				if (Paths.validScriptType(file))
					scriptArray.push(new FunkinHScript(folder + file));
				#end
			}
		}

		for (script in scriptArray) {
			script?.setVariable('addScript', function(path:String) {
				scriptArray.push(new FunkinHScript(Paths.script(path)));
			});
		}

		switch (SONG.song.toLowerCase()) {
			case 'roses':
				defaultCamZoom += 0.05;
		}

		if (isStoryMode && !seenCutscene)
		{
			switch (SONG.song.toLowerCase())
			{
				case "monster":
					var whiteScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
					add(whiteScreen);
					whiteScreen.scrollFactor.set();
					whiteScreen.blend = ADD;
					camHUD.visible = false;
					snapCamFollowToPos(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
					inCutscene = true;

					FlxTween.tween(whiteScreen, {alpha: 0}, 1, {
						startDelay: 0.1,
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween)
						{
							camHUD.visible = true;
							remove(whiteScreen);
							startCountdown();
						}
					});
					FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
					if(gf != null) gf.playAnim('scared', true);
					boyfriend.playAnim('scared', true);

				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite().makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;
					inCutscene = true;

					FlxTween.tween(blackScreen, {alpha: 0}, 0.7, {
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween) {
							remove(blackScreen);
						}
					});
					FlxG.sound.play(Paths.sound('Lights_Turn_On'));
					snapCamFollowToPos(400, -2050);
					FlxG.camera.focusOn(camFollow);
					FlxG.camera.zoom = 1.5;

					new FlxTimer().start(0.8, function(tmr:FlxTimer)
					{
						camHUD.visible = true;
						remove(blackScreen);
						FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
							ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween)
							{
								startCountdown();
							}
						});
					});
				case 'senpai' | 'roses' | 'thorns':
					if(SONG.song.toLowerCase() == 'roses') FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);

				case 'ugh' | 'guns' | 'stress':
					tankIntro();

				default:
					startCountdown();
			}
			seenCutscene = true;
		}
		else
			startCountdown();

		RecalculateRating();

		#if sys
		if (SONG.song.toLowerCase() == "monster") ArtemisIntegration.setCustomFlag (1, true);
		#end

		//PRECACHING MISS SOUNDS BECAUSE I THINK THEY CAN LAG PEOPLE AND FUCK THEM UP IDK HOW HAXE WORKS
		if(ClientPrefs.hitsoundVolume > 0) 
			precacheList.set('hitsound', 'sound');
		precacheList.set('missnote1', 'sound');
		precacheList.set('missnote2', 'sound');
		precacheList.set('missnote3', 'sound');

		if (PauseSubState.songName != null)
			precacheList.set(PauseSubState.songName, 'music');
		else if(ClientPrefs.pauseMusic != 'None')
			precacheList.set(Paths.formatToSongPath(ClientPrefs.pauseMusic), 'music');

		precacheList.set('alphabet', 'image');
	
		#if desktop
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		#end

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);

		ModchartFuncs.loadLuaFunctions();
		callOnLuas('onCreatePost', []);

		// no point in these if antialiasing is off
		if (boyfriend.antialiasing == true)
			boyfriend.antialiasing = ClientPrefs.globalAntialiasing;
		if (dad.antialiasing == true)
			dad.antialiasing = ClientPrefs.globalAntialiasing;
		if (gf.antialiasing == true)
			gf.antialiasing = ClientPrefs.globalAntialiasing;

		super.create();

		cacheCountdown();
		cachePopUpScore();
		for (key => type in precacheList)
		{
			switch(type)
			{
				case 'image':
					Paths.image(key);
				case 'sound':
					Paths.sound(key);
				case 'music':
					Paths.music(key);
				case 'video':
					Paths.video(key);
			}
		}
		Paths.clearUnusedMemory();
	}

	#if (!flash && sys)
	public var runtimeShaders:Map<String, Array<String>> = new Map<String, Array<String>>();
	public function createRuntimeShader(name:String):FlxRuntimeShader
	{
		if(!ClientPrefs.shaders) return new FlxRuntimeShader();

		#if (!flash && MODS_ALLOWED && sys)
		if(!runtimeShaders.exists(name) && !initLuaShader(name))
		{
			FlxG.log.warn('Shader $name is missing!');
			return new FlxRuntimeShader();
		}

		var arr:Array<String> = runtimeShaders.get(name);
		return new FlxRuntimeShader(arr[0], arr[1]);
		#else
		FlxG.log.warn("Platform unsupported for Runtime Shaders!");
		return null;
		#end
	}

	public function initLuaShader(name:String, ?glslVersion:Int = 120)
	{
		if(!ClientPrefs.shaders) return false;

		if(runtimeShaders.exists(name))
		{
			FlxG.log.warn('Shader $name was already initialized!');
			return true;
		}

		var foldersToCheck:Array<String> = [Paths.mods('shaders/')];
		if(Mods.currentModDirectory != null && Mods.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Mods.currentModDirectory + '/shaders/'));

		for(mod in Mods.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/shaders/'));
		
		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				var frag:String = folder + name + '.frag';
				var vert:String = folder + name + '.vert';
				var found:Bool = false;
				if(FileSystem.exists(frag))
				{
					frag = File.getContent(frag);
					found = true;
				}
				else frag = null;

				if (FileSystem.exists(vert))
				{
					vert = File.getContent(vert);
					found = true;
				}
				else vert = null;

				if(found)
				{
					runtimeShaders.set(name, [frag, vert]);
					return true;
				}
			}
		}
		FlxG.log.warn('Missing shader $name .frag AND .vert files!');
		return false;
	}
	#end

	inline function set_songSpeed(value:Float):Float
	{
		if(generatedMusic)
		{
			var ratio:Float = value / songSpeed; //funny word huh
			for (note in notes) note.resizeByRatio(ratio);
			for (note in unspawnNotes) note.resizeByRatio(ratio);
		}
		songSpeed = value;
		noteKillOffset = 350 / songSpeed;
		return value;
	}

	inline function set_playbackRate(value:Float):Float
	{
		#if FLX_PITCH
		if(generatedMusic)
		{
			if(vocals != null) vocals.pitch = value;
			FlxG.sound.music.pitch = value;
		}
		playbackRate = value;
		FlxG.timeScale = value;
		trace('Anim speed: ' + FlxG.timeScale);
		Conductor.safeZoneOffset = (ClientPrefs.safeFrames / 60) * 1000 * value;
		setOnLuas('playbackRate', playbackRate);
		#else
		playbackRate = 1.0;
		#end
		return playbackRate;
	}

	public function addTextToDebug(text:String, color:FlxColor = FlxColor.WHITE) {
		#if LUA_ALLOWED
		luaDebugGroup.forEachAlive(function(spr:DebugLuaText) {
			spr.y += 20;
		});

		if(luaDebugGroup.members.length > 34) {
			var blah = luaDebugGroup.members[34];
			blah.destroy();
			luaDebugGroup.remove(blah);
		}
		luaDebugGroup.insert(0, new DebugLuaText(text, luaDebugGroup, color));
		#end
	}

	public function reloadHealthBarColors() {
		var dadColor:FlxColor = CoolUtil.getColor(dad.healthColorArray);
		var bfColor:FlxColor = CoolUtil.getColor(boyfriend.healthColorArray);
		healthBar.setColors(dadColor, bfColor);
		#if sys
		ArtemisIntegration.setHealthbarFlxColors (dadColor, bfColor);
		#end

		timeBar.setColors(CoolUtil.getColor(dad.healthColorArray), 0xFF404040);
	}

	public function addCharacterToList(newCharacter:String, type:Int) {
		switch(type) {
			case 0:
				if(!boyfriendMap.exists(newCharacter)) {
					var newBoyfriend:Boyfriend = new Boyfriend(0, 0, newCharacter);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
					startCharacterLua(newBoyfriend.curCharacter);
				}

			case 1:
				if(!dadMap.exists(newCharacter)) {
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
					startCharacterLua(newDad.curCharacter);
				}

			case 2:
				if(gf != null && !gfMap.exists(newCharacter)) {
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
					startCharacterLua(newGf.curCharacter);
				}
		}
	}

	function startCharacterLua(name:String)
	{
		#if LUA_ALLOWED
		var doPush:Bool = false;
		var luaFile:String = 'characters/' + name + '.lua';
		#if MODS_ALLOWED
		if(FileSystem.exists(Paths.modFolders(luaFile))) {
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		} else {
			luaFile = Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}
		#else
		luaFile = Paths.getPreloadPath(luaFile);
		if(Assets.exists(luaFile)) {
			doPush = true;
		}
		#end

		if(doPush)
		{
			for (script in luaArray)
			{
				if(script.scriptName == luaFile) return;
			}
			luaArray.push(new FunkinLua(luaFile));
		}
		#end

		/*#if HSCRIPT_ALLOWED
		var doPush:Bool = false;
		var hscriptFile:String = 'characters/$name.hscript';
		#if MODS_ALLOWED
		if (FileSystem.exists(Paths.modFolders(hscriptFile))) {
			hscriptFile = Paths.modFolders(hscriptFile);
			doPush = true;
		} else {
		#end
			hscriptFile = Paths.getPreloadPath(hscriptFile);
			if (Assets.exists(hscriptFile)) {
				doPush = true;
			}
		#if MODS_ALLOWED
		}
		#end
		
		if (doPush && !hscriptMap.exists(hscriptFile))
		{
			addHscript(hscriptFile);
		}
		#end*/
	}

	public function getLuaObject(tag:String, text:Bool=true):FlxSprite {
		if(modchartSprites.exists(tag)) return modchartSprites.get(tag);
		if(modchartParallax.exists(tag)) return modchartParallax.get(tag);
		if(text && modchartTexts.exists(tag)) return modchartTexts.get(tag);
		if(variables.exists(tag)) return variables.get(tag);
		return null;
	}

	function startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		if(gfCheck && char.curCharacter.startsWith('gf')) { //IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
			char.danceEveryNumBeats = 2;
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	public function startVideo(name:String, type:String = 'mp4'):Void
	{
		inCutscene = true;

		switch (type)
		{
			case 'webm':
				#if WEBM_ALLOWED
				if (Paths.fileExists(Paths.webm(name))) {
					openSubState(new VideoSubState(name, () -> {
						if (endingSong)
							endSong();
						else 
							startCountdown();
					}));
					return;
				}

				FlxG.log.warn('Couldnt find video file: ' + name);
				#else
				FlxG.log.warn('Platform not supported!');
				#end
			default:
				#if VIDEOS_ALLOWED
				if (Paths.fileExists(Paths.video(name))) 
				{
					var video:MP4Handler = new MP4Handler();
					#if (hxvlc)
					video.load(Paths.video(name));
					video.onEndReached.add(() -> {
						video.dispose();
						if (FlxG.game.contains(video))
							FlxG.game.removeChild(video);
						startAndEnd();
					});
					video.play();
					#elseif (hxCodec >= "3.0.0")
					// Recent versions
					video.play(Paths.video(name));
					video.onEndReached.add(function()
					{
						video.dispose();
						startAndEnd();
						return;
					}, true);
					#else
					// Older versions
					video.playVideo(Paths.video(name));
					video.finishCallback = function()
					{
						startAndEnd();
						return;
					}
					#end
				}
				FlxG.log.warn('Couldnt find video file: ' + name);
				#else
				FlxG.log.warn('Platform not supported!');
				#end
		}

		startAndEnd();
	}

	inline function startAndEnd(){
		(endingSong) ? endSong() : startCountdown();
	}

	var dialogueCount:Int = 0;
	public var psychDialogue:DialogueBoxPsych;
	//You don't have to add a song, just saying. You can just do "startDialogue(dialogueJson);" and it should work
	public function startDialogue(dialogueFile:DialogueFile, ?song:String = null):Void
	{
		// TO DO: Make this more flexible, maybe?
		if(psychDialogue != null) return;

		if(dialogueFile.dialogue.length > 0) {
			inCutscene = true;
			precacheList.set('dialogue', 'sound');
			precacheList.set('dialogueClose', 'sound');
			psychDialogue = new DialogueBoxPsych(dialogueFile, song);
			psychDialogue.scrollFactor.set();
			if(endingSong) {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					endSong();
				}
			} else {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					startCountdown();
				}
			}
			psychDialogue.nextDialogueThing = startNextDialogue;
			psychDialogue.skipDialogueThing = skipDialogue;
			psychDialogue.cameras = [camHUD];
			add(psychDialogue);
		} else {
			FlxG.log.warn('Your dialogue file is badly formatted!');
			if(endingSong)
				endSong();
			else 
				startCountdown();
		}
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		inCutscene = true;
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('stages/school/weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();
		senpaiEvil.x += 300;

		var songName:String = Paths.formatToSongPath(SONG.song);
		if (songName == 'roses' || songName == 'thorns')
		{
			remove(black);

			if (songName == 'thorns')
			{
				add(red);
				camHUD.visible = false;
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					if (Paths.formatToSongPath(SONG.song) == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
										camHUD.visible = true;
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
						add(dialogueBox);
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	function tankIntro()
	{
		var cutsceneHandler:CutsceneHandler = new CutsceneHandler();

		var songName:String = Paths.formatToSongPath(SONG.song);
		dadGroup.alpha = 0.00001;
		camHUD.visible = false;

		var tankman:FlxSprite = new FlxSprite(-20, 320);
		tankman.frames = Paths.getSparrowAtlas('cutscenes/' + songName);
		tankman.antialiasing = ClientPrefs.globalAntialiasing;
		addBehindDad(tankman);
		cutsceneHandler.push(tankman);

		var tankman2:FlxSprite = new FlxSprite(16, 312);
		tankman2.antialiasing = ClientPrefs.globalAntialiasing;
		tankman2.alpha = 0.000001;
		cutsceneHandler.push(tankman2);
		var gfDance:FlxSprite = new FlxSprite(gf.x - 107, gf.y + 140);
		gfDance.antialiasing = ClientPrefs.globalAntialiasing;
		cutsceneHandler.push(gfDance);
		var gfCutscene:FlxSprite = new FlxSprite(gf.x - 104, gf.y + 122);
		gfCutscene.antialiasing = ClientPrefs.globalAntialiasing;
		cutsceneHandler.push(gfCutscene);
		var picoCutscene:FlxSprite = new FlxSprite(gf.x - 849, gf.y - 264);
		picoCutscene.antialiasing = ClientPrefs.globalAntialiasing;
		cutsceneHandler.push(picoCutscene);
		var boyfriendCutscene:FlxSprite = new FlxSprite(boyfriend.x + 5, boyfriend.y + 20);
		boyfriendCutscene.antialiasing = ClientPrefs.globalAntialiasing;
		cutsceneHandler.push(boyfriendCutscene);

		cutsceneHandler.finishCallback = function()
		{
			var timeForStuff:Float = Conductor.crochet / 1000 * 4.5;
			FlxG.sound.music.fadeOut(timeForStuff);
			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, timeForStuff, {ease: FlxEase.quadInOut});
			moveCamera(true);
			startCountdown();

			dadGroup.alpha = 1;
			camHUD.visible = true;
			boyfriend.animation.finishCallback = null;
			gf.animation.finishCallback = null;
			gf.dance();
		};

		camFollow.set(dad.x + 280, dad.y + 170);
		switch(songName)
		{
			case 'ugh':
				cutsceneHandler.endTime = 12;
				cutsceneHandler.music = 'DISTORTO';
				precacheList.set('wellWellWell', 'sound');
				precacheList.set('killYou', 'sound');
				precacheList.set('bfBeep', 'sound');

				var wellWellWell:FlxSound = new FlxSound().loadEmbedded(Paths.sound('wellWellWell'));
				FlxG.sound.list.add(wellWellWell);

				tankman.animation.addByPrefix('wellWell', 'TANK TALK 1 P1', 24, false);
				tankman.animation.addByPrefix('killYou', 'TANK TALK 1 P2', 24, false);
				tankman.animation.play('wellWell', true);
				FlxG.camera.zoom *= 1.2;

				// Well well well, what do we got here?
				// EDUARDO???
				cutsceneHandler.timer(0.1, function()
				{
					wellWellWell.play(true);
				});

				// Move camera to BF
				cutsceneHandler.timer(3, function()
				{
					camFollow.x += 750;
					camFollow.y += 100;
				});

				// Beep!
				cutsceneHandler.timer(4.5, function()
				{
					boyfriend.playAnim('singUP', true);
					boyfriend.specialAnim = true;
					FlxG.sound.play(Paths.sound('bfBeep'));
				});

				// Move camera to Tankman
				cutsceneHandler.timer(6, function()
				{
					camFollow.x -= 750;
					camFollow.y -= 100;

					// We should just kill you but... what the hell, it's been a boring day... let's see what you've got!
					tankman.animation.play('killYou', true);
					FlxG.sound.play(Paths.sound('killYou'));
				});

			case 'guns':
				cutsceneHandler.endTime = 11.5;
				cutsceneHandler.music = 'DISTORTO';
				tankman.x += 40;
				tankman.y += 10;
				precacheList.set('tankSong2', 'sound');

				var tightBars:FlxSound = new FlxSound().loadEmbedded(Paths.sound('tankSong2'));
				FlxG.sound.list.add(tightBars);

				tankman.animation.addByPrefix('tightBars', 'TANK TALK 2', 24, false);
				tankman.animation.play('tightBars', true);
				boyfriend.animation.curAnim.finish();

				cutsceneHandler.onStart = function()
				{
					tightBars.play(true);
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2}, 4, {ease: FlxEase.quadInOut});
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2 * 1.2}, 0.5, {ease: FlxEase.quadInOut, startDelay: 4});
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2}, 1, {ease: FlxEase.quadInOut, startDelay: 4.5});
				};

				cutsceneHandler.timer(4, function()
				{
					gf.playAnim('sad', true);
					gf.animation.finishCallback = function(name:String)
					{
						gf.playAnim('sad', true);
					};
				});

			case 'stress':
				cutsceneHandler.endTime = 35.5;
				tankman.x -= 54;
				tankman.y -= 14;
				gfGroup.alpha = 0.00001;
				boyfriendGroup.alpha = 0.00001;
				camFollow.set(dad.x + 400, dad.y + 170);
				FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2}, 1, {ease: FlxEase.quadInOut});
				foregroundSprites.forEach(function(spr:BGSprite)
				{
					spr.y += 100;
				});
				precacheList.set('stressCutscene', 'sound');

				tankman2.frames = Paths.getSparrowAtlas('cutscenes/stress2');
				addBehindDad(tankman2);

				if (!ClientPrefs.lowQuality)
				{
					gfDance.frames = Paths.getSparrowAtlas('characters/gfTankmen');
					gfDance.animation.addByPrefix('dance', 'GF Dancing at Gunpoint', 24, true);
					gfDance.animation.play('dance', true);
					addBehindGF(gfDance);
				}

				gfCutscene.frames = Paths.getSparrowAtlas('cutscenes/stressGF');
				gfCutscene.animation.addByPrefix('dieBitch', 'GF STARTS TO TURN PART 1', 24, false);
				gfCutscene.animation.addByPrefix('getRektLmao', 'GF STARTS TO TURN PART 2', 24, false);
				gfCutscene.animation.play('dieBitch', true);
				gfCutscene.animation.pause();
				addBehindGF(gfCutscene);
				if (!ClientPrefs.lowQuality)
				{
					gfCutscene.alpha = 0.00001;
				}

				picoCutscene.frames = AtlasFrameMaker.construct('cutscenes/stressPico');
				picoCutscene.animation.addByPrefix('anim', 'Pico Badass', 24, false);
				addBehindGF(picoCutscene);
				picoCutscene.alpha = 0.00001;

				boyfriendCutscene.frames = Paths.getSparrowAtlas('characters/BOYFRIEND');
				boyfriendCutscene.animation.addByPrefix('idle', 'BF idle dance', 24, false);
				boyfriendCutscene.animation.play('idle', true);
				boyfriendCutscene.animation.curAnim.finish();
				addBehindBF(boyfriendCutscene);

				var cutsceneSnd:FlxSound = new FlxSound().loadEmbedded(Paths.sound('stressCutscene'));
				FlxG.sound.list.add(cutsceneSnd);

				tankman.animation.addByPrefix('godEffingDamnIt', 'TANK TALK 3', 24, false);
				tankman.animation.play('godEffingDamnIt', true);

				var calledTimes:Int = 0;
				var zoomBack:Void->Void = function()
				{
					var camPosX:Float = 630;
					var camPosY:Float = 425;
					camFollow.set(camPosX, camPosY);
					camFollowPos.setPosition(camPosX, camPosY);
					FlxG.camera.zoom = 0.8;
					cameraSpeed = 1;

					calledTimes++;
					if (calledTimes > 1)
					{
						foregroundSprites.forEach(function(spr:BGSprite)
						{
							spr.y -= 100;
						});
					}
				}

				cutsceneHandler.onStart = function()
				{
					cutsceneSnd.play(true);
				};

				cutsceneHandler.timer(15.2, function()
				{
					FlxTween.tween(camFollow, {x: 650, y: 300}, 1, {ease: FlxEase.sineOut});
					FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2 * 1.2}, 2.25, {ease: FlxEase.quadInOut});

					gfDance.visible = false;
					gfCutscene.alpha = 1;
					gfCutscene.animation.play('dieBitch', true);
					gfCutscene.animation.finishCallback = function(name:String)
					{
						if(name == 'dieBitch') //Next part
						{
							gfCutscene.animation.play('getRektLmao', true);
							gfCutscene.offset.set(224, 445);
						}
						else
						{
							gfCutscene.visible = false;
							picoCutscene.alpha = 1;
							picoCutscene.animation.play('anim', true);

							boyfriendGroup.alpha = 1;
							boyfriendCutscene.visible = false;
							boyfriend.playAnim('bfCatch', true);
							boyfriend.animation.finishCallback = function(name:String)
							{
								if(name != 'idle')
								{
									boyfriend.playAnim('idle', true);
									boyfriend.animation.curAnim.finish(); //Instantly goes to last frame
								}
							};

							picoCutscene.animation.finishCallback = function(name:String)
							{
								picoCutscene.visible = false;
								gfGroup.alpha = 1;
								picoCutscene.animation.finishCallback = null;
							};
							gfCutscene.animation.finishCallback = null;
						}
					};
				});

				cutsceneHandler.timer(17.5, function()
				{
					zoomBack();
				});

				cutsceneHandler.timer(19.5, function()
				{
					tankman2.animation.addByPrefix('lookWhoItIs', 'TANK TALK 3', 24, false);
					tankman2.animation.play('lookWhoItIs', true);
					tankman2.alpha = 1;
					tankman.visible = false;
				});

				cutsceneHandler.timer(20, function()
				{
					camFollow.set(dad.x + 500, dad.y + 170);
				});

				cutsceneHandler.timer(31.2, function()
				{
					boyfriend.playAnim('singUPmiss', true);
					boyfriend.animation.finishCallback = function(name:String)
					{
						if (name == 'singUPmiss')
						{
							boyfriend.playAnim('idle', true);
							boyfriend.animation.curAnim.finish(); //Instantly goes to last frame
						}
					};

					camFollow.set(boyfriend.x + 280, boyfriend.y + 200);
					cameraSpeed = 12;
					FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2 * 1.2}, 0.25, {ease: FlxEase.elasticOut});
				});

				cutsceneHandler.timer(32.2, function()
				{
					zoomBack();
				});
		}
	}

	function camPanRoutine(anim:String = 'singUP', who:String = 'bf'):Void {
		if (SONG.notes[curSection] != null)
		{
			var fps:Float = FlxG.updateFramerate;
			final bfCanPan:Bool = SONG.notes[curSection].mustHitSection;
			final dadCanPan:Bool = !SONG.notes[curSection].mustHitSection;
			var clear:Bool = false;
			switch (who) {
				case 'bf' | 'boyfriend': clear = bfCanPan;
				case 'oppt' | 'dad': clear = dadCanPan;
			}
			if (clear) {
				if (fps == 0) fps = 1;
				switch (anim.split('-')[0])
				{
					case 'singUP': moveCamTo[1] = -40 * ClientPrefs.panIntensity * 240 * playbackRate / fps;
					case 'singDOWN': moveCamTo[1] = 40 * ClientPrefs.panIntensity * 240 * playbackRate / fps;
					case 'singLEFT': moveCamTo[0] = -40 * ClientPrefs.panIntensity * 240 * playbackRate / fps;
					case 'singRIGHT': moveCamTo[0] = 40 * ClientPrefs.panIntensity * 240 * playbackRate / fps;
				}
			}
		}
	}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	// For being able to mess with the sprites on Lua
	public var countdownThree:FlxSprite;
	public var countdownTwo:FlxSprite;
	public var countdownOne:FlxSprite;
	public var countdownGo:FlxSprite;
	
	public static var startOnTime:Float = 0;

	function cacheCountdown()
	{
		var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
		introAssets.set('default', [
			'three',
			'two', 
			'one', 
			'go'
		]);
		introAssets.set('pixel', [
			'pixelUI/three-pixel',
			'pixelUI/two-pixel', 
			'pixelUI/one-pixel', 
			'pixelUI/date-pixel'
		]);

		var introAlts:Array<String> = introAssets.get('default');
		if (isPixelStage) introAlts = introAssets.get('pixel');
		
		for (asset in introAlts)
			Paths.image(asset);
		
		Paths.sound('intro3' + introSoundsSuffix);
		Paths.sound('intro2' + introSoundsSuffix);
		Paths.sound('intro1' + introSoundsSuffix);
		Paths.sound('introGo' + introSoundsSuffix);
	}

	public function startCountdown():Void
	{
		if(startedCountdown) {
			callOnLuas('onStartCountdown', []);
			return;
		}

		inCutscene = false;
		var ret:Dynamic = callOnLuas('onStartCountdown', [], false);
		if(ret != FunkinLua.Function_Stop) {
			if (skipCountdown || startOnTime > 0) skipArrowStartTween = true;

			generateStaticArrows(0);
			generateStaticArrows(1);
			NoteMovement.getDefaultStrumPos(this);
			for (i in 0...playerStrums.length) {
				setOnLuas('defaultPlayerStrumX' + i, playerStrums.members[i].x);
				setOnLuas('defaultPlayerStrumY' + i, playerStrums.members[i].y);
				// setOnHscripts('playerStrums', playerStrums);
			}
			for (i in 0...opponentStrums.length) {
				setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
				setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
				// setOnHscripts('opponentStrums', opponentStrums);
				// setOnHscripts('opponentStrums', opponentStrums);
			}

			startedCountdown = true;
			Conductor.songPosition = -Conductor.crochet * 5;
			setOnLuas('startedCountdown', true);
			callOnLuas('onCountdownStarted', []);

			var swagCounter:Int = 0;

			if(startOnTime < 0) startOnTime = 0;

			if (startOnTime > 0) {
				clearNotesBefore(startOnTime);
				setSongTime(startOnTime - 350);
				return;
			}
			else if (skipCountdown)
			{
				setSongTime(0);
				return;
			}

			startTimer = new FlxTimer().start(Conductor.crochet / 1000 / playbackRate, function(tmr:FlxTimer)
			{
				if (gf != null && tmr.loopsLeft % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
					gf.dance();
				if (tmr.loopsLeft % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
					boyfriend.dance();
				if (tmr.loopsLeft % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
					dad.dance();

				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				introAssets.set('default', [
					'three',
					'two', 
					'one', 
					'go'
				]);
				introAssets.set('pixel', [
					'pixelUI/three-pixel',
					'pixelUI/two-pixel', 
					'pixelUI/one-pixel', 
					'pixelUI/date-pixel'
				]);

				var introAlts:Array<String> = introAssets.get('default');
				var antialias:Bool = ClientPrefs.globalAntialiasing;
				if(isPixelStage) {
					introAlts = introAssets.get('pixel');
					antialias = false;
				}

				// head bopping for bg characters on Mall
				if(curStage == 'mall') {
					if(!ClientPrefs.lowQuality)
						upperBoppers.dance(true);

					bottomBoppers.dance(true);
					santa.dance(true);
				}

				switch (swagCounter)
				{
					case 0:
					    countdownThree = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
						countdownThree.scrollFactor.set();
						countdownThree.updateHitbox();

						if (PlayState.isPixelStage)
							countdownThree.setGraphicSize(Std.int(countdownThree.width * daPixelZoom));

						countdownThree.screenCenter();
						countdownThree.antialiasing = antialias;
						add(countdownThree);
						FlxTween.tween(countdownThree, {alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownThree);
								countdownThree.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro3' + introSoundsSuffix), 0.6);
					case 1:
						countdownTwo = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
						countdownTwo.cameras = [camHUD];
						countdownTwo.scrollFactor.set();
						countdownTwo.updateHitbox();

						if (PlayState.isPixelStage)
							countdownTwo.setGraphicSize(Std.int(countdownTwo.width * daPixelZoom));

						countdownTwo.screenCenter();
						countdownTwo.antialiasing = antialias;
						insert(members.indexOf(notes), countdownTwo);
						FlxTween.tween(countdownTwo, {alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownTwo);
								countdownTwo.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro2' + introSoundsSuffix), 0.6);
					case 2:
						countdownOne = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
						countdownOne.cameras = [camHUD];
						countdownOne.scrollFactor.set();

						if (PlayState.isPixelStage)
							countdownOne.setGraphicSize(Std.int(countdownOne.width * daPixelZoom));

						countdownOne.screenCenter();
						countdownOne.antialiasing = antialias;
						insert(members.indexOf(notes), countdownOne);
						FlxTween.tween(countdownOne, {alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownOne);
								countdownOne.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro1' + introSoundsSuffix), 0.6);
						if (boyfriend != null && !PlayState.isPixelStage || curStage != 'mall' || curStage != 'mallEvil' || curStage != 'limo' || SONG.song.toLowerCase() != 'stress') {
							boyfriend.playAnim('pre-attack', true);
							boyfriend.specialAnim = true;
						}
					case 3:
						countdownGo = new FlxSprite().loadGraphic(Paths.image(introAlts[3]));
						countdownGo.cameras = [camHUD];
						countdownGo.scrollFactor.set();

						if (PlayState.isPixelStage)
							countdownGo.setGraphicSize(Std.int(countdownGo.width * daPixelZoom));

						countdownGo.updateHitbox();

						countdownGo.screenCenter();
						countdownGo.antialiasing = antialias;
						insert(members.indexOf(notes), countdownGo);
						FlxTween.tween(countdownGo, {alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownGo);
								countdownGo.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('introGo' + introSoundsSuffix), 0.6);
						strumLineNotes.forEachAlive(function(strum:FlxSprite) {
							FlxTween.tween(strum, {angle: 360}, Conductor.crochet / 1000 * 2, {ease: FlxEase.cubeInOut});
						});
						if (curStage != 'limo' || SONG.song.toLowerCase() != 'stress') {
							if (boyfriend != null && boyfriend.animOffsets.exists('hey')) {
								boyfriend.playAnim('hey', true);
								boyfriend.specialAnim = true;
								boyfriend.heyTimer = 0.6;
							}

							if (curStage != 'tank') {
								if (gf != null && gf.animOffsets.exists('cheer')) {
									gf.playAnim('cheer', true);
									gf.specialAnim = true;
									gf.heyTimer = 0.6;
								}
							}
						}
					// case 4: trace('troll!');
				}

				notes.forEachAlive(function(note:Note) {
					if(ClientPrefs.opponentStrums || note.mustPress)
					{
						note.copyAlpha = false;
						note.alpha = note.multAlpha;
						if(ClientPrefs.middleScroll && !note.mustPress) {
							note.alpha *= 0.35;
						}
					}
				});
				callOnLuas('onCountdownTick', [swagCounter]);

				swagCounter++;
			}, 4);
		}
	}

	public function addBehindGF(obj:FlxObject)
	{
		insert(members.indexOf(gfGroup), obj);
	}
	public function addBehindBF(obj:FlxObject)
	{
		insert(members.indexOf(boyfriendGroup), obj);
	}
	public function addBehindDad(obj:FlxObject)
	{
		insert(members.indexOf(dadGroup), obj);
	}

	public function clearNotesBefore(time:Float)
	{
		var i:Int = unspawnNotes.length - 1;
		while (i >= 0) {
			var daNote:Note = unspawnNotes[i];
			if(daNote.strumTime - 350 < time)
			{
				daNote.ignoreNote = true;

				unspawnNotes.remove(daNote);
				daNote.destroy();
			}
			--i;
		}

		i = notes.length - 1;
		while (i >= 0) {
			var daNote:Note = notes.members[i];
			if(daNote.strumTime - 350 < time)
			{
				daNote.ignoreNote = true;

				notes.remove(daNote, true);
				daNote.destroy();
			}
			--i;
		}
	}

	public dynamic function updateScore(miss:Bool = false)
	{
		var scoreThing = (ClientPrefs.weekendScore) ? truncateFloat(smoothScore, 0) : songScore;
		switch (ClientPrefs.scoreTxtType)
		{
			case 'Default':
				if (ratingName == '?')
					scoreTxt.text = 'NPS: $nps/$maxNPS // Score: $scoreThing // Combo Breaks: $songMisses // Accuracy: $ratingName // Rank: N/A';
				else
					scoreTxt.text = 'NPS: $nps/$maxNPS // Score: $scoreThing // Combo Breaks: $songMisses // Accuracy: ${Highscore.floorDecimal(ratingPercent * 100, 2)}% // Rank: $ratingName ($ratingFC)';

			case 'Psych':
				scoreTxt.text = 'Score: $scoreThing | Misses: $songMisses | Rating: $ratingName'
				+ (ratingName != '?' ? ' (${Highscore.floorDecimal(ratingPercent * 100, 2)}%) - $ratingFC' : '');

			case 'Kade':
				scoreTxt.text = 'NPS: $nps (Max $maxNPS) | Score: $scoreThing | Combo Breaks: $songMisses | Accuracy: ${Highscore.floorDecimal(ratingPercent * 100, 2)}% | ($ratingFC) $ratingName';

			case 'Simple':
				scoreTxt.text = 'Score: $scoreThing | Misses: $songMisses';
		}

		if(ClientPrefs.scoreZoom && !miss && !cpuControlled)
		{
			if(scoreTxtTween != null) {
				scoreTxtTween.cancel();
			}
			scoreTxt.scale.x = 1.075;
			scoreTxt.scale.y = 1.075;
			scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
				onComplete: function(twn:FlxTween) {
					scoreTxtTween = null;
				}
			});
		}
		callOnLuas('onUpdateScore', [miss]);
	}

	public function setSongTime(time:Float)
	{
		if(time < 0) time = 0;

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.time = time;
		#if FLX_PITCH FlxG.sound.music.pitch = playbackRate; #end
		FlxG.sound.music.play();

		if (!vocalsFinished){
			if (Conductor.songPosition <= vocals.length)
			{
				vocals.time = time;
				#if FLX_PITCH vocals.pitch = playbackRate; #end
			}
			vocals.play();
		}
		else
			vocals.time = vocals.length;

		Conductor.songPosition = time;
		songTime = time;
	}

	function startNextDialogue() {
		dialogueCount++;
		callOnLuas('onNextDialogue', [dialogueCount]);
	}

	function skipDialogue() {
		callOnLuas('onSkipDialogue', [dialogueCount]);
	}

	var previousFrameTime:Int = 0;
	var songTime:Float = 0;

	public var songStarted = false;

	function startSong():Void
	{
		#if WEBM_ALLOWED
		var ourVideo:Dynamic = BackgroundVideo.get();

		if (useVideo && ourVideo != null)
			ourVideo.resume();
		#end

		startingSong = false;
		songStarted = true;

		previousFrameTime = FlxG.game.ticks;

		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		#if FLX_PITCH FlxG.sound.music.pitch = playbackRate; #end
		FlxG.sound.music.onComplete = () -> finishSong();
		vocals.play();
		vocals.onComplete = () -> vocalsFinished = true;

		if(startOnTime > 0)
			setSongTime(startOnTime - 500);

		startOnTime = 0;

		if(paused) {
			FlxG.sound.music.pause();
			vocals.pause();
		}

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});

		switch(curStage)
		{
			case 'tank':
				if(!ClientPrefs.lowQuality) tankWatchtower.dance();
				foregroundSprites.forEach(function(spr:BGSprite)
				{
					spr.dance();
				});
		}

		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength);
		#end
		setOnLuas('songLength', songLength);
		callOnLuas('onSongStart', []);
	}

	private var noteTypes:Array<String> = [];
	private var eventsPushed:Array<String> = [];
	
	public function lerpSongSpeed(num:Float, time:Float):Void
	{
		FlxTween.num(playbackRate, num, time, {onUpdate: function(tween:FlxTween){
			var ting = FlxMath.lerp(playbackRate, num, tween.percent);
			if (ting != 0) //divide by 0 is a verry bad
				playbackRate = ting; //why cant i just tween a variable

			FlxG.sound.music.time = Conductor.songPosition;
			resyncVocals();
		}});
	}
	
	var stair:Int = 0;
	private function generateSong():Void
	{
		songSpeedType = ClientPrefs.getGameplaySetting('scrolltype','multiplicative');

		switch(songSpeedType)
		{
			case "multiplicative":
				songSpeed = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1);
			case "constant":
				songSpeed = ClientPrefs.getGameplaySetting('scrollspeed', 1);
		}

		Conductor.bpm = SONG.bpm;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		#if FLX_PITCH vocals.pitch = playbackRate; #end
		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.song)));

		//generate the payload for the frontend
		bpPayload = ButtplugUtils.createPayload(Conductor.crochet);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = SONG.notes;

		var songName:String = Paths.formatToSongPath(SONG.song);
		var file:String = Paths.json(songName + '/events');
		#if MODS_ALLOWED
		if (FileSystem.exists(Paths.modsJson(songName + '/events')) || FileSystem.exists(file)) {
		#else
		if (Assets.exists(file)) {
		#end
			var eventsData:Array<Dynamic> = Song.loadFromJson('events', songName).events;
			for (event in eventsData) //Event Notes
			{
				for (i in 0...event[1].length)
				{
					var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
					var subEvent:EventNote = {
						strumTime: newEventNote[0] + ClientPrefs.noteOffset,
						event: newEventNote[1],
						value1: newEventNote[2],
						value2: newEventNote[3]
					};
					subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
					eventNotes.push(subEvent);
					eventPushed(subEvent);
				}
			}
		}

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				if (!randomMode && !flip && !stairs && !waves)
				{
					daNoteData = Std.int(songNotes[1] % 4);
				}
				if (oneK)
				{
					daNoteData = 2;
				}
				if (randomMode || randomMode && flip || randomMode && flip && stairs || randomMode && flip && stairs && waves) { //gotta specify that random mode must at least be turned on for this to work
					daNoteData = FlxG.random.int(0, 3);
				}
				if (flip && !stairs && !waves) {
					daNoteData = Std.int(Math.abs((songNotes[1] % 4) - 3));
				}
				if (stairs && !waves) {
					daNoteData = stair % 4;
					stair++;
				}
				if (waves) {
					switch (stair % 6)
					{
						case 0 | 1 | 2 | 3:
							daNoteData = stair % 6;
						case 4:
							daNoteData = 2;
						case 5:
							daNoteData = 1;
					}
					stair++;
				}

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
					gottaHitNote = !section.mustHitSection;

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.mustPress = gottaHitNote;
				// sustain length fix courtesey of Stilic
				// modified by memehoovy
				swagNote.sustainLength = Math.round(songNotes[2] / Conductor.stepCrochet) * Conductor.stepCrochet;
				swagNote.gfNote = (section.gfSection && (songNotes[1]<4));
				swagNote.noteType = songNotes[3];
				if(!Std.isOfType(songNotes[3], String)) swagNote.noteType = ChartingState.noteTypeList[songNotes[3]]; //Backward compatibility + compatibility with Week 7 charts

				swagNote.scrollFactor.set();

				unspawnNotes.push(swagNote);

				var roundSus:Int = Math.round(swagNote.sustainLength / Conductor.stepCrochet);
				if(roundSus > 0) {
					for (susNote in 0...Math.floor(Math.max(roundSus, 2)))
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(songSpeed, 2)), daNoteData, oldNote, true);
						sustainNote.mustPress = gottaHitNote;
						sustainNote.gfNote = (section.gfSection && (songNotes[1]<4));
						sustainNote.noteType = swagNote.noteType;
						sustainNote.scrollFactor.set();
						swagNote.tail.push(sustainNote);
						sustainNote.parent = swagNote;
						unspawnNotes.push(sustainNote);

						if (sustainNote.mustPress)
							sustainNote.x += FlxG.width / 2; // general offset
						else if(ClientPrefs.middleScroll)
						{
							sustainNote.x += 310;
							if(daNoteData > 1) //Up and Right
								sustainNote.x += FlxG.width / 2 + 25;
						}
					}
				}

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else if(ClientPrefs.middleScroll)
				{
					swagNote.x += 310;
					if(daNoteData > 1) //Up and Right
						swagNote.x += FlxG.width / 2 + 25;
				}

				if(!noteTypes.contains(swagNote.noteType))
					noteTypes.push(swagNote.noteType);
			}
		}
		for (event in SONG.events) //Event Notes
		{
			for (i in 0...event[1].length)
			{
				var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
				var subEvent:EventNote = {
					strumTime: newEventNote[0] + ClientPrefs.noteOffset,
					event: newEventNote[1],
					value1: newEventNote[2],
					value2: newEventNote[3]
				};
				subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
				eventNotes.push(subEvent);
				eventPushed(subEvent);
			}
		}

		unspawnNotes.sort(sortByShit);
		if(eventNotes.length > 1) //No need to sort if there's a single one or none at all
			eventNotes.sort(sortByTime);

		checkEventNote();
		generatedMusic = true;
	}

	function eventPushed(event:EventNote) {
		switch(event.event) {
			case 'Change Character':
				var charType:Int = 0;
				switch(event.value1.toLowerCase()) {
					case 'gf' | 'girlfriend' | '1':
						charType = 2;
					case 'dad' | 'opponent' | '0':
						charType = 1;
					default:
						charType = Std.parseInt(event.value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				var newCharacter:String = event.value2;
				addCharacterToList(newCharacter, charType);

				if (boyfriend.antialiasing == true)
					boyfriend.antialiasing = ClientPrefs.globalAntialiasing;
				if (dad.antialiasing == true)
					dad.antialiasing = ClientPrefs.globalAntialiasing;
				if (gf.antialiasing == true)
			    	gf.antialiasing = ClientPrefs.globalAntialiasing;

			case 'Dadbattle Spotlight':
				if (curStage != 'stage')
					return;
				dadbattleBlack = new BGSprite(null, -800, -400, 0, 0);
				dadbattleBlack.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				dadbattleBlack.alpha = 0.25;
				dadbattleBlack.visible = false;
				add(dadbattleBlack);

				dadbattleLight = new BGSprite('stages/stage/spotlight', 400, -400);
				dadbattleLight.alpha = 0.375;
				dadbattleLight.blend = ADD;
				dadbattleLight.visible = false;

				dadbattleSmokes.alpha = 0.7;
				dadbattleSmokes.blend = ADD;
				dadbattleSmokes.visible = false;
				add(dadbattleLight);
				add(dadbattleSmokes);

				var offsetX = 200;
				var smoke:BGSprite = new BGSprite('stages/stage/smoke', -1550 + offsetX, 660 + FlxG.random.float(-20, 20), 1.2, 1.05);
				smoke.setGraphicSize(Std.int(smoke.width * FlxG.random.float(1.1, 1.22)));
				smoke.updateHitbox();
				smoke.velocity.x = FlxG.random.float(15, 22);
				smoke.active = true;
				dadbattleSmokes.add(smoke);
				var smoke:BGSprite = new BGSprite('stages/stage/smoke', 1550 + offsetX, 660 + FlxG.random.float(-20, 20), 1.2, 1.05);
				smoke.setGraphicSize(Std.int(smoke.width * FlxG.random.float(1.1, 1.22)));
				smoke.updateHitbox();
				smoke.velocity.x = FlxG.random.float(-15, -22);
				smoke.active = true;
				smoke.flipX = true;
				dadbattleSmokes.add(smoke);

			case 'Philly Glow':
				if (curStage != 'philly')
					return;
				blammedLightsBlack = new FlxSprite(FlxG.width * -0.5, FlxG.height * -0.5).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				blammedLightsBlack.visible = false;
				insert(members.indexOf(phillyStreet), blammedLightsBlack);

				phillyWindowEvent = new BGSprite('philly/window', phillyWindow.x, phillyWindow.y, 0.3, 0.3);
				phillyWindowEvent.setGraphicSize(Std.int(phillyWindowEvent.width * 0.85));
				phillyWindowEvent.updateHitbox();
				phillyWindowEvent.visible = false;
				insert(members.indexOf(blammedLightsBlack) + 1, phillyWindowEvent);

				phillyGlowGradient = new PhillyGlow.PhillyGlowGradient(-400, 225); //This shit was refusing to properly load FlxGradient so fuck it
				phillyGlowGradient.visible = false;
				insert(members.indexOf(blammedLightsBlack) + 1, phillyGlowGradient);
				if(!ClientPrefs.flashing) phillyGlowGradient.intendedAlpha = 0.7;

				precacheList.set('philly/particle', 'image'); //precache particle image
				phillyGlowParticles = new FlxTypedGroup<PhillyGlow.PhillyGlowParticle>();
				phillyGlowParticles.visible = false;
				insert(members.indexOf(phillyGlowGradient) + 1, phillyGlowParticles);
			case 'Play Sound':
				Paths.sound(event.value1); // precache
		}

		if(!eventsPushed.contains(event.event)) {
			eventsPushed.push(event.event);
		}
	}

	function eventNoteEarlyTrigger(event:EventNote):Float {
		var returnedValue:Float = callOnLuas('eventEarlyTrigger', [event.event]);
		if(returnedValue != 0) {
			return returnedValue;
		}

		switch(event.event) {
			case 'Kill Henchmen': //Better timing so that the kill sound matches the beat intended
				return 280; //Plays 280ms before the actual position
		}
		return 0;
	}

	inline function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	inline function sortByTime(Obj1:EventNote, Obj2:EventNote):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	public var skipArrowStartTween:Bool = false; //for lua
	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			var targetAlpha:Float = 1;
			if (player < 1)
				targetAlpha = (!ClientPrefs.opponentStrums) ? 0 : (ClientPrefs.middleScroll) ? 0.35 : 1;

			var babyArrow:StrumNote = new StrumNote(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, strumLine.y, i, player);
			babyArrow.downScroll = ClientPrefs.downScroll;
			if (!isStoryMode && !skipArrowStartTween)
			{
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}
			else
				babyArrow.alpha = targetAlpha;

			if (player == 1)
				playerStrums.add(babyArrow);
			else
			{
				if(ClientPrefs.middleScroll)
				{
					babyArrow.x += 310;
					if(i > 1) { //Up and Right
						babyArrow.x += FlxG.width / 2 + 25;
					}
				}
				opponentStrums.add(babyArrow);
			}

			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = false;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = false;
			if (songSpeedTween != null)
				songSpeedTween.active = false;

			if(carTimer != null) carTimer.active = false;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = false;
				}
			}

			for (tween in modchartTweens)
				tween.active = false;
			for (timer in modchartTimers)
				timer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = true;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = true;
			if (songSpeedTween != null)
				songSpeedTween.active = true;

			if(carTimer != null) carTimer.active = true;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = true;
				}
			}

			for (tween in modchartTweens)
				tween.active = true;
			for (timer in modchartTimers)
				timer.active = true;

			paused = false;
			callOnScripts('resume', []);
			callOnLuas('onResume', []);

			#if desktop
			if (startTimer != null && startTimer.finished)
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			else
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			else
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		}
		#end

		callOnScripts('onFocus', []);
		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		#end

		callOnScripts('onFocusLost', []);
		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if(finishTimer != null || vocalsFinished || isDead || !SONG.needsVoices) return;

		vocals.pause();

		FlxG.sound.music.play();
		#if FLX_PITCH FlxG.sound.music.pitch = playbackRate; #end
		Conductor.songPosition = FlxG.sound.music.time;

		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = Conductor.songPosition;
			#if FLX_PITCH vocals.pitch = playbackRate; #end
		}
		vocals.play();
	}

	public var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var limoSpeed:Float = 0;

	override public function update(elapsed:Float)
	{
		callOnScripts('update', [elapsed]);

		if (SONG.song.toLowerCase() == 'guns' && tankmanRainbow)
			dad.y += (Math.sin(elapsedtime) * 0.2) * FlxG.elapsed * 244;

		// SECRET KEYS!! SHHHHHHHH
		#if debug
		final keyPressed:FlxKey = FlxG.keys.firstJustPressed();
		if (keyPressed != FlxKey.NONE){
			switch(keyPressed){
				case F1: // End Song
				if (!startingSong)
					endSong();
					KillNotes();
					FlxG.sound.music.onComplete();
				case F2 if (!startingSong): // 10 Seconds Forward
					setSongTime(Conductor.songPosition + 10000);
					clearNotesBefore(Conductor.songPosition);
					FlxG.sound.music.time = Conductor.songPosition;
					vocals.time = Conductor.songPosition;
				case F3 if (!startingSong): // 10 Seconds Back
					setSongTime(Conductor.songPosition - 10000);
					clearNotesBefore(Conductor.songPosition);
					FlxG.sound.music.time = Conductor.songPosition;
					vocals.time = Conductor.songPosition;
				case F4: // Enable/Disable Botplay
					cpuControlled = !cpuControlled;
					botplayTxt.visible = cpuControlled;
				case F5: // Camera Speeds Up
					cameraSpeed += 0.5;
				case F6: // Camera Slows Down
					cameraSpeed -= 0.5;
				case F7: // Song Speeds Up
					songSpeed += 0.1;
				case F8: // Song Slows Down
					songSpeed -= 0.1;
				case F9: // Camera Zooms In
					defaultCamZoom += 0.1;
				case F10: // Camera Zooms Out
					defaultCamZoom -= 0.1;
				default:
					// nothing
			}
		}
		#end

		if (FlxG.keys.justPressed.SPACE)
		{
			if (curStage != 'limo' || SONG.song.toLowerCase() != 'stress') {
				if (boyfriend != null && boyfriend.animOffsets.exists('hey')) {
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = 0.6;
				}

				if (curStage != 'tank') {
					if (gf != null && gf.animOffsets.exists('cheer')) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = 0.6;
					}
				}
			}
		}

		judgementCounter.text = 'Sicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}\nMisses: ${songMisses}';

		elapsedtime += elapsed;

		callOnLuas('onUpdate', [elapsed]);

		switch (curStage)
		{
			case 'tank':
				moveTank(elapsed);
			case 'schoolEvil':
				if(!ClientPrefs.lowQuality && bgGhouls.animation.curAnim.finished) {
					bgGhouls.visible = false;
				}
				Application.current.window.title = randomString();
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				phillyWindow.alpha -= (Conductor.crochet / 1000) * FlxG.elapsed * 1.5;

				if(phillyGlowParticles != null)
				{
					var i:Int = phillyGlowParticles.members.length-1;
					while (i > 0)
					{
						var particle = phillyGlowParticles.members[i];
						if(particle.alpha < 0)
						{
							particle.kill();
							phillyGlowParticles.remove(particle, true);
							particle.destroy();
						}
						--i;
					}
				}
			case 'limo':
				if(!ClientPrefs.lowQuality) {
					grpLimoParticles.forEach(function(spr:BGSprite) {
						if(spr.animation.curAnim.finished) {
							spr.kill();
							grpLimoParticles.remove(spr, true);
							spr.destroy();
						}
					});

					switch(limoKillingState) {
						case 1:
							limoMetalPole.x += 5000 * elapsed;
							limoLight.x = limoMetalPole.x - 180;
							limoCorpse.x = limoLight.x - 50;
							limoCorpseTwo.x = limoLight.x + 35;

							var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
							for (i in 0...dancers.length) {
								if(dancers[i].x < FlxG.width * 1.5 && limoLight.x > (370 * i) + 170) {
									switch(i) {
										case 0 | 3:
											if(i == 0) {
												FlxG.sound.play(Paths.sound('dancerdeath'), 0.5);
												#if sys
												ArtemisIntegration.triggerFlash ("#AFFF0000");
												#end
											}

											var diffStr:String = i == 3 ? ' 2 ' : ' ';
											var particle:BGSprite = new BGSprite('stages/limo/gore/noooooo', dancers[i].x + 200, dancers[i].y, 0.4, 0.4, ['hench leg spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);
											var particle:BGSprite = new BGSprite('stages/limo/gore/noooooo', dancers[i].x + 160, dancers[i].y + 200, 0.4, 0.4, ['hench arm spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);
											var particle:BGSprite = new BGSprite('stages/limo/gore/noooooo', dancers[i].x, dancers[i].y + 50, 0.4, 0.4, ['hench head spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);

											var particle:BGSprite = new BGSprite('stages/limo/gore/stupidBlood', dancers[i].x - 110, dancers[i].y + 20, 0.4, 0.4, ['blood'], false);
											particle.flipX = true;
											particle.angle = -57.5;
											grpLimoParticles.add(particle);
										case 1:
											limoCorpse.visible = true;
										case 2:
											limoCorpseTwo.visible = true;
									} //Note: Nobody cares about the fifth dancer because he is mostly hidden offscreen :(
									dancers[i].x += FlxG.width * 2;
								}
							}

							if(limoMetalPole.x > FlxG.width * 2) {
								resetLimoKill();
								limoSpeed = 800;
								limoKillingState = 2;
							}

						case 2:
							limoSpeed -= 4000 * elapsed;
							bgLimo.x -= limoSpeed * elapsed;
							if(bgLimo.x > FlxG.width * 1.5) {
								limoSpeed = 3000;
								limoKillingState = 3;
							}

						case 3:
							limoSpeed -= 2000 * elapsed;
							if(limoSpeed < 1000) limoSpeed = 1000;

							bgLimo.x -= limoSpeed * elapsed;
							if(bgLimo.x < -275) {
								limoKillingState = 4;
								limoSpeed = 800;
							}

						case 4:
							bgLimo.x = FlxMath.lerp(bgLimo.x, -150, CoolUtil.boundTo(elapsed * 9, 0, 1));
							if(Math.round(bgLimo.x) == -150) {
								bgLimo.x = -150;
								limoKillingState = 0;
							}
					}

					if(limoKillingState > 2) {
						var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
						for (i in 0...dancers.length) {
							dancers[i].x = (370 * i) + bgLimo.x + 280;
						}
					}
				}
			case 'mall':
				if(heyTimer > 0) {
					heyTimer -= elapsed;
					if(heyTimer <= 0) {
						bottomBoppers.dance(true);
						heyTimer = 0;
					}
				}
		}

		if(!inCutscene) {
			final lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4 * cameraSpeed * playbackRate, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x + moveCamTo[0] / 102, camFollow.x + moveCamTo[0] / 102, lerpVal), FlxMath.lerp(camFollowPos.y + moveCamTo[1] / 102, camFollow.y + moveCamTo[1] / 102, lerpVal));
			if(!startingSong && !endingSong && boyfriend.animation.curAnim != null && boyfriend.animation.curAnim.name.startsWith('idle')) {
				boyfriendIdleTime += elapsed;
				if(boyfriendIdleTime >= 0.15) { // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some playerss
					boyfriendIdled = true;
				}
			} else {
				boyfriendIdleTime = 0;
			}
			final panLerpVal:Float = CoolUtil.boundTo(elapsed * 4.4 * cameraSpeed, 0, 1);
			moveCamTo[0] = FlxMath.lerp(moveCamTo[0], 0, panLerpVal);
			moveCamTo[1] = FlxMath.lerp(moveCamTo[1], 0, panLerpVal);
		}

		var scoreMult:Float = FlxMath.lerp(smoothScore, songScore, 0.108);
		smoothScore = scoreMult;

		#if WEBM_ALLOWED
		var ourVideo:Dynamic = BackgroundVideo.get();

		if (useVideo && ourVideo != null && !stopUpdate)
		{
			if (ourVideo.ended && !removedVideo)
			{
				remove(videoSprite);

				removedVideo = true;
				useVideo = false;
			}
		}
		#end

		super.update(elapsed);

		setOnLuas('curDecStep', curDecStep);
		setOnLuas('curDecBeat', curDecBeat);

		var pooper = npsArray.length - 1;
		while (pooper >= 0) {
			var fondler:Date = npsArray[pooper];
			if (fondler != null && fondler.getTime() + 1000 < Date.now().getTime()) {
				npsArray.remove(fondler);
			}
			else
				pooper = 0;
			pooper--;
		}
		nps = npsArray.length;
		if (nps > maxNPS)
			maxNPS = nps;

		if(botplayTxt.visible) {
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}

		if (controls.PAUSE && startedCountdown && canPause)
		{
			var ret:Dynamic = callOnLuas('onPause', [], false);
			if(ret != FunkinLua.Function_Stop)
				openPauseMenu();
		}

		if (FlxG.keys.anyJustPressed(debugKeysChart) && !endingSong && !inCutscene)
			openChartEditor();

		if (healthBar.bounds != null && health > healthBar.bounds.max) health = healthBar.bounds.max;

		updateIconsPosition();

		if (FlxG.keys.anyJustPressed(debugKeysCharacter) && !endingSong && !inCutscene) {
			persistentUpdate = false;
			paused = true;
			cancelMusicFadeTween();
			MusicBeatState.switchState(new CharacterEditorState(SONG.player2));
		}
		
		if (startedCountdown && !paused)
			Conductor.songPosition += FlxG.elapsed * 1000 * playbackRate;

		if (startingSong)
		{
			if (startedCountdown && Conductor.songPosition >= 0)
				startSong();
			else if(!startedCountdown)
				Conductor.songPosition = -Conductor.crochet * 5;
		}
		else if (!paused && updateTime)
		{
			var curTime:Float = Math.max(0, Conductor.songPosition - ClientPrefs.noteOffset);
			songPercent = (curTime / songLength);

			var songCalc:Float = (songLength - curTime) / playbackRate; // time fix

			if (ClientPrefs.timeBarType == 'Time Elapsed') songCalc = curTime; // amount of time passed is ok

			var secondsTotal:Int = Math.floor(songCalc / 1000);
			if(secondsTotal < 0) secondsTotal = 0;

			if (ClientPrefs.timeBarType != 'Song Name')
				timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);
			else {
				var secondsTotal:Int = Math.floor(songCalc / 1000);
				if (secondsTotal < 0) secondsTotal = 0;
				timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);
			}
		}

		FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay * playbackRate), 0, 1));
		camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay * playbackRate), 0, 1));

		if (curBeat % 32 == 0 && randomSpeedThing)
		{
			var randomShit = FlxMath.roundDecimal(FlxG.random.float(0.4, 3), 2);
			lerpSongSpeed(randomShit, 1);
		}

		FlxG.watch.addQuick("secShit", curSection);
		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		// RESET = Quick Game Over Screen
		if (!ClientPrefs.noReset && controls.RESET && !inCutscene && !endingSong)
		{
			health = 0;
			#if sys
			ArtemisIntegration.sendBoyfriendHealth (health);
			#end
			trace("RESET = True");
		}
		doDeathCheck();

		if (unspawnNotes[0] != null)
		{
			var time:Float = spawnTime;
			if(songSpeed < 1) time /= songSpeed;
			if(unspawnNotes[0].multSpeed < 1) time /= unspawnNotes[0].multSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes.shift();
				notes.insert(0, dunceNote);
				dunceNote.spawned=true;
				callOnLuas('onSpawnNote', [notes.members.indexOf(dunceNote), dunceNote.noteData, dunceNote.noteType, dunceNote.isSustainNote]);
			}
		}

		if (generatedMusic && !inCutscene)
		{
			if(!cpuControlled)
				keyShit();
			else if(boyfriend.animation.curAnim != null && boyfriend.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * boyfriend.singDuration 
			&& boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
				boyfriend.dance();

			if(startedCountdown)
			{
				var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
				notes.forEachAlive(function(daNote:Note)
				{
					var strumGroup:FlxTypedGroup<StrumNote> = playerStrums;
					if(!daNote.mustPress) strumGroup = opponentStrums;

					var strumX:Float = strumGroup.members[daNote.noteData].x;
					var strumY:Float = strumGroup.members[daNote.noteData].y;
					var strumAngle:Float = strumGroup.members[daNote.noteData].angle;
					var strumDirection:Float = strumGroup.members[daNote.noteData].direction;
					var strumAlpha:Float = strumGroup.members[daNote.noteData].alpha;
					var strumScroll:Bool = strumGroup.members[daNote.noteData].downScroll;

					strumX += daNote.offsetX;
					strumY += daNote.offsetY;
					strumAngle += daNote.offsetAngle;
					strumAlpha *= daNote.multAlpha;

					// whether downscroll or not
					daNote.distance = ((strumScroll) ? 0.45 : -0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed * daNote.multSpeed);

					var angleDir = strumDirection * Math.PI / 180;
					if (daNote.copyAngle)
						daNote.angle = strumDirection - 90 + strumAngle;

					if(daNote.copyAlpha)
						daNote.alpha = strumAlpha;

					if(daNote.copyX)
						daNote.x = strumX + Math.cos(angleDir) * daNote.distance;

					if(daNote.copyY)
					{
						daNote.y = strumY + Math.sin(angleDir) * daNote.distance;

						//Jesus fuck this took me so much mother fucking time AAAAAAAAAA
						if(strumScroll && daNote.isSustainNote)
						{
							if (daNote.animation.curAnim.name.endsWith('end')) {
								daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * songSpeed + (46 * (songSpeed - 1));
								daNote.y -= 46 * (1 - (fakeCrochet / 600)) * songSpeed;
								if(PlayState.isPixelStage) {
									daNote.y += 8 + (6 - daNote.originalHeightForCalcs) * PlayState.daPixelZoom;
								} else {
									daNote.y -= 19;
								}
							}
							daNote.y += (Note.swagWidth / 2) - (60.5 * (songSpeed - 1));
							daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (songSpeed - 1);
						}
					}

					if (!daNote.mustPress && daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
						opponentNoteHit(daNote);

					if(!daNote.blockHit && daNote.mustPress && cpuControlled && daNote.canBeHit) {
						if(daNote.isSustainNote) {
							if(daNote.canBeHit)
								goodNoteHit(daNote);
						} 
						else if(daNote.strumTime <= Conductor.songPosition || daNote.isSustainNote)
							goodNoteHit(daNote);
					}

					var center:Float = strumY + Note.swagWidth / 2;
					if(strumGroup.members[daNote.noteData].sustainReduce && daNote.isSustainNote && (daNote.mustPress || !daNote.ignoreNote) &&
						(!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
					{
						if (strumScroll)
						{
							if(daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center)
							{
								var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
								swagRect.height = (center - daNote.y) / daNote.scale.y;
								swagRect.y = daNote.frameHeight - swagRect.height;

								daNote.clipRect = swagRect;
							}
						}
						else
						{
							if (daNote.y + daNote.offset.y * daNote.scale.y <= center)
							{
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (center - daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;

								daNote.clipRect = swagRect;
							}
						}
					}

					// Kill extremely late notes and cause misses
					if (Conductor.songPosition > noteKillOffset + daNote.strumTime)
					{
						if (daNote.mustPress && !cpuControlled &&!daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit)) {
							noteMiss(daNote);
						}
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});
			}
			else
			{
				notes.forEachAlive(function(daNote:Note)
				{
					daNote.canBeHit = false;
					daNote.wasGoodHit = false;
				});
			}
		}
		checkEventNote();

		setOnLuas('cameraX', camFollowPos.x);
		setOnLuas('cameraY', camFollowPos.y);
		setOnLuas('botPlay', cpuControlled);
		callOnLuas('onUpdatePost', [elapsed]);
	}

	public dynamic function updateIconsPosition()
	{
		final iconOffset:Int = 26;
		iconP1.x = healthBar.barCenter + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
		iconP2.x = healthBar.barCenter - (150 * iconP2.scale.x) / 2 - iconOffset * 2;
	}

	var iconsAnimations:Bool = true;
	function set_health(value:Float):Float
	{
		if (!iconsAnimations || healthBar == null || !healthBar.enabled || healthBar.valueFunction == null)
		{
			health = value;
			return health;
		}

		health = value;
		var newPercent:Null<Float> = FlxMath.remapToRange(FlxMath.bound(healthBar.valueFunction(), healthBar.bounds.min, healthBar.bounds.max), healthBar.bounds.min, healthBar.bounds.max, 0, 100);
		healthBar.percent = (newPercent != null ? newPercent : 0);

		switch (iconP1.widthThing) 
		{
			case 150:
				iconP1.animation.curAnim.curFrame = 0;
			case 300:
				if (healthBar.percent < 20)
					iconP1.animation.curAnim.curFrame = 1;
				else
					iconP1.animation.curAnim.curFrame = 0;
			case 450:
				if (healthBar.percent < 20)
					iconP1.animation.curAnim.curFrame = 1; // Losing
				else if (healthBar.percent > 80)
					iconP1.animation.curAnim.curFrame = 2; // Winning
				else
					iconP1.animation.curAnim.curFrame = 0; // Neutral
			case 750:
				if (healthBar.percent < 20 && healthBar.percent > 0)
					iconP1.animation.curAnim.curFrame = 2; // Danger
				else if (healthBar.percent < 40 && healthBar.percent > 20)
					iconP1.animation.curAnim.curFrame = 1; // Losing
				else if (healthBar.percent > 40 && healthBar.percent < 60)
					iconP1.animation.curAnim.curFrame = 0; // Neutral
				else if (healthBar.percent > 60 && healthBar.percent < 80)
					iconP1.animation.curAnim.curFrame = 3; // Winning
				else if (healthBar.percent > 80)
					iconP1.animation.curAnim.curFrame = 4; // Victorious
		}

		// Does this work??
		// the 2 icons do, but idk about 3 nor the 5 icons
		// okay 3 should work fine now, but idk about 5 icons
		switch (iconP2.widthThing) 
		{
			case 150:
				iconP2.animation.curAnim.curFrame = 0;
			case 300:
				if (healthBar.percent > 80)
					iconP2.animation.curAnim.curFrame = 1;
				else
					iconP2.animation.curAnim.curFrame = 0;
			case 450:
				if (healthBar.percent > 80)
					iconP2.animation.curAnim.curFrame = 1; // Losing
				else if (healthBar.percent < 20)
					iconP2.animation.curAnim.curFrame = 2; // Winning
				else
					iconP2.animation.curAnim.curFrame = 0; // Neutral
			case 750:
				if (healthBar.percent < 80)
					iconP2.animation.curAnim.curFrame = 4; // Victorious
				else if (healthBar.percent < 60 && healthBar.percent > 80)
					iconP2.animation.curAnim.curFrame = 3; // Winning
				else if (healthBar.percent > 40 && healthBar.percent < 60)
					iconP2.animation.curAnim.curFrame = 0; // Neutral
				else if (healthBar.percent > 40 && healthBar.percent < 20)
					iconP2.animation.curAnim.curFrame = 1; // Losing
				else if (healthBar.percent < 20 && healthBar.percent > 0)
					iconP2.animation.curAnim.curFrame = 2; // Danger
		}
		return health;
	}

	function openPauseMenu()
	{
		persistentUpdate = false;
		persistentDraw = paused = true;

		if(FlxG.sound.music != null) {
			FlxG.sound.music.pause();
			vocals.pause();
		}
		if (inReplay)
			openSubState(new ReplayPauseSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		else
			openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

		#if desktop
		DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		#end
	}

	function openChartEditor()
	{
		persistentUpdate = false;
		cancelMusicFadeTween();
		Application.current.window.title = Application.current.meta.get('name');
		MusicBeatState.switchState(new ChartingState());
		chartingMode = paused = true;

		#if desktop
		DiscordClient.changePresence("Chart Editor", null, null, true);
		#end
	}

	public var isDead:Bool = false; //Don't mess with this on Lua!!!
	function doDeathCheck(?skipHealthCheck:Bool = false) {
		if (((skipHealthCheck && instakillOnMiss) || health <= 0) && !practiceMode && !isDead)
		{
			var ret:Dynamic = callOnLuas('onGameOver', [], false);
			if(ret != FunkinLua.Function_Stop) {
				FlxG.timeScale = 1;
				boyfriend.stunned = true;
				deathCounter++;

				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				persistentUpdate = persistentDraw = false;
				for (tween in modchartTweens)
					tween.active = true;
				for (timer in modchartTimers)
					timer.active = true;

				if (SONG.song.toLowerCase() == 'tutorial')
					trace('bro how tf did you die on tutorial :skull:');
				
				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x - boyfriend.positionArray[0], boyfriend.getScreenPosition().y - boyfriend.positionArray[1], camFollowPos.x, camFollowPos.y, 
					songScore, songMisses, Highscore.floorDecimal(ratingPercent * 100, 2), ratingName, ratingFC));

				#if desktop
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
				#end
				#if sys
				ArtemisIntegration.setGameState ("dead");
				#end
				isDead = true;
				return true;
			}
		}
		return false;
	}

	public function checkEventNote() {
		while(eventNotes.length > 0) {
			if(Conductor.songPosition < eventNotes[0].strumTime) break;

			var value1:String = '';
			if(eventNotes[0].value1 != null)
				value1 = eventNotes[0].value1;

			var value2:String = '';
			if(eventNotes[0].value2 != null)
				value2 = eventNotes[0].value2;

			triggerEventNote(eventNotes[0].event, value1, value2);
			eventNotes.shift();
		}
	}

	inline public function getControl(key:String) {
		var pressed:Bool = Reflect.getProperty(controls, key);
		return pressed;
	}

	public function triggerEventNote(eventName:String, value1:String, value2:String) {
		var flValue1:Null<Float> = Std.parseFloat(value1);
		var flValue2:Null<Float> = Std.parseFloat(value2);
		if (Math.isNaN(flValue1)) flValue1 = null;
		if (Math.isNaN(flValue2)) flValue2 = null;

		switch(eventName) {
			case 'Dadbattle Spotlight':
				if (curStage != 'stage')
					return;

				var val:Null<Int> = Std.parseInt(value1);
				if(val == null) val = 0;

				switch(Std.parseInt(value1))
				{
					case 1, 2, 3: //enable and target dad
						if(val == 1) //enable
						{
							dadbattleBlack.visible = true;
							dadbattleLight.visible = true;
							dadbattleSmokes.visible = true;
							defaultCamZoom += 0.12;
						}

						var who:Character = dad;
						if(val > 2) who = boyfriend;
						//2 only targets dad
						dadbattleLight.alpha = 0;
						new FlxTimer().start(0.12, function(tmr:FlxTimer) {
							dadbattleLight.alpha = 0.375;
						});
						dadbattleLight.setPosition(who.getGraphicMidpoint().x - dadbattleLight.width / 2, who.y + who.height - dadbattleLight.height + 50);

					default:
						dadbattleBlack.visible = false;
						dadbattleLight.visible = false;
						defaultCamZoom -= 0.12;
						FlxTween.tween(dadbattleSmokes, {alpha: 0}, 1, {onComplete: function(twn:FlxTween)
						{
							dadbattleSmokes.visible = false;
						}});
				}

			case 'Hey!':
				var value:Int = 2;
				switch(value1.toLowerCase().trim()) {
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				var time:Float = Std.parseFloat(value2);
				if(Math.isNaN(time) || time <= 0) time = 0.6;

				if(value != 0) {
					if(dad.curCharacter.startsWith('gf')) { //Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = time;
					} else if (gf != null) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = time;
					}

					if(curStage == 'mall') {
						bottomBoppers.animation.play('hey', true);
						heyTimer = time;
					}
				}
				if(value != 1) {
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = time;
				}

			case 'Set GF Speed':
				var value:Int = Std.parseInt(value1);
				if(Math.isNaN(value) || value < 1) value = 1;
				gfSpeed = value;

			case 'Philly Glow':
				if (curStage != 'philly')
					return;

				var lightId:Int = Std.parseInt(value1);
				if(Math.isNaN(lightId)) lightId = 0;

				var doFlash:Void->Void = function() {
					var color:FlxColor = FlxColor.WHITE;
					if(!ClientPrefs.flashing) color.alphaFloat = 0.5;

					#if sys
					ArtemisIntegration.setBlammedLights (StringTools.hex (color));
					#end

					FlxG.camera.flash(color, 0.15, null, true);
				};

				var chars:Array<Character> = [boyfriend, gf, dad];
				switch(lightId)
				{
					case 0:
						if(phillyGlowGradient.visible)
						{
							doFlash();
							if(ClientPrefs.camZooms)
							{
								FlxG.camera.zoom += 0.5;
								camHUD.zoom += 0.1;
							}

							blammedLightsBlack.visible = false;
							phillyWindowEvent.visible = false;
							phillyGlowGradient.visible = false;
							phillyGlowParticles.visible = false;
							curLightEvent = -1;

							for (who in chars)
							{
								who.color = FlxColor.WHITE;
							}
							phillyStreet.color = FlxColor.WHITE;
						}

					case 1: //turn on
						curLightEvent = FlxG.random.int(0, phillyLightsColors.length-1, [curLightEvent]);
						var color:FlxColor = phillyLightsColors[curLightEvent];

						if(!phillyGlowGradient.visible)
						{
							doFlash();
							if(ClientPrefs.camZooms)
							{
								FlxG.camera.zoom += 0.5;
								camHUD.zoom += 0.1;
							}

							blammedLightsBlack.visible = true;
							blammedLightsBlack.alpha = 1;
							phillyWindowEvent.visible = true;
							phillyGlowGradient.visible = true;
							phillyGlowParticles.visible = true;
						}
						else if(ClientPrefs.flashing)
						{
							var colorButLower:FlxColor = color;
							colorButLower.alphaFloat = 0.25;
							FlxG.camera.flash(colorButLower, 0.5, null, true);
						}

						var charColor:FlxColor = color;
						if(!ClientPrefs.flashing) charColor.saturation *= 0.5;
						else charColor.saturation *= 0.75;

						for (who in chars)
						{
							who.color = charColor;
						}
						phillyGlowParticles.forEachAlive(function(particle:PhillyGlow.PhillyGlowParticle)
						{
							particle.color = color;
						});
						phillyGlowGradient.color = color;
						phillyWindowEvent.color = color;

						color.brightness *= 0.5;
						phillyStreet.color = color;

					case 2: // spawn particles
						if(!ClientPrefs.lowQuality)
						{
							var particlesNum:Int = FlxG.random.int(8, 12);
							var width:Float = (2000 / particlesNum);
							var color:FlxColor = phillyLightsColors[curLightEvent];
							for (j in 0...3)
							{
								for (i in 0...particlesNum)
								{
									var particle:PhillyGlow.PhillyGlowParticle = new PhillyGlow.PhillyGlowParticle(-400 + width * i + FlxG.random.float(-width / 5, width / 5), phillyGlowGradient.originalY + 200 + (FlxG.random.float(0, 125) + j * 40), color);
									phillyGlowParticles.add(particle);
								}
							}
						}
						phillyGlowGradient.bop();
				}

			case 'Kill Henchmen':
				killHenchmen();

			case 'Add Camera Zoom':
				if(ClientPrefs.camZooms && FlxG.camera.zoom < 1.35) {
					var camZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);
					if(Math.isNaN(camZoom)) camZoom = 0.015;
					if(Math.isNaN(hudZoom)) hudZoom = 0.03;

					FlxG.camera.zoom += camZoom;
					camHUD.zoom += hudZoom;
				}

			case 'Trigger BG Ghouls':
				if(curStage == 'schoolEvil' && !ClientPrefs.lowQuality) {
					bgGhouls.dance(true);
					bgGhouls.visible = true;
					#if sys
					ArtemisIntegration.triggerCustomEvent ("bgGhouls", "#00000000", 0);
					#end
				}

			case 'Play Animation':
				var char:Character = dad;
				switch(value2.toLowerCase().trim()) {
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						var val2:Int = Std.parseInt(value2);
						if(Math.isNaN(val2)) val2 = 0;

						switch(val2) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.playAnim(value1, true);
					char.specialAnim = true;
				}

			case 'Camera Follow Pos':
				if(camFollow != null)
				{
					var val1:Float = Std.parseFloat(value1);
					var val2:Float = Std.parseFloat(value2);
					if(Math.isNaN(val1)) val1 = 0;
					if(Math.isNaN(val2)) val2 = 0;

					isCameraOnForcedPos = false;
					if(!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2))) {
						camFollow.x = val1;
						camFollow.y = val2;
						isCameraOnForcedPos = true;
					}
				}

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);
						if(Math.isNaN(val)) val = 0;

						switch(val) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.idleSuffix = value2;
					char.recalculateDanceIdle();
				}

			case 'Screen Shake':
				var valuesArray:Array<String> = [value1, value2];
				var targetsArray:Array<FlxCamera> = [camGame, camHUD];
				for (i in 0...targetsArray.length) {
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = 0;
					var intensity:Float = 0;
					if(split[0] != null) duration = Std.parseFloat(split[0].trim());
					if(split[1] != null) intensity = Std.parseFloat(split[1].trim());
					if(Math.isNaN(duration)) duration = 0;
					if(Math.isNaN(intensity)) intensity = 0;

					if(duration > 0 && intensity != 0) {
						targetsArray[i].shake(intensity, duration);
					}
				}

			case 'Change Character':
				var charType:Int = 0;
				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				switch(charType) {
					case 0:
						if(boyfriend.curCharacter != value2) {
							if(!boyfriendMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = boyfriend.alpha;
							boyfriend.alpha = 0.00001;
							boyfriend = boyfriendMap.get(value2);
							boyfriend.alpha = lastAlpha;
							iconP1.changeIcon(boyfriend.healthIcon);
						}
						setOnLuas('boyfriendName', boyfriend.curCharacter);
						// setOnHscripts('boyfriend', boyfriend);

					case 1:
						if(dad.curCharacter != value2) {
							if(!dadMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf');
							var lastAlpha:Float = dad.alpha;
							dad.alpha = 0.00001;
							dad = dadMap.get(value2);
							if(!dad.curCharacter.startsWith('gf')) {
								if(wasGf && gf != null) {
									gf.visible = true;
								}
							} else if(gf != null) {
								gf.visible = false;
							}
							dad.alpha = lastAlpha;
							iconP2.changeIcon(dad.healthIcon);
						}
						setOnLuas('dadName', dad.curCharacter);
						// setOnHscripts('dad', dad);

					case 2:
						if(gf != null)
						{
							if(gf.curCharacter != value2)
							{
								if(!gfMap.exists(value2))
								{
									addCharacterToList(value2, charType);
								}

								var lastAlpha:Float = gf.alpha;
								gf.alpha = 0.00001;
								gf = gfMap.get(value2);
								gf.alpha = lastAlpha;
							}
							setOnLuas('gfName', gf.curCharacter);
							// setOnHscripts('gf', gf);
						}
				}
				reloadHealthBarColors();

			case 'BG Freaks Expression':
				if(bgGirls != null) bgGirls.forEach(bgGirl -> bgGirl.swapDanceType());

			case 'Change Scroll Speed':
				if (songSpeedType == "constant")
					return;
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 1;
				if(Math.isNaN(val2)) val2 = 0;

				var newValue:Float = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1) * val1;

				if(val2 <= 0)
					songSpeed = newValue;
				else
					songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, val2 / playbackRate, {ease: FlxEase.linear, onComplete: _ -> songSpeedTween = null});

			case 'Popup':
				FlxG.sound.music.pause();
				vocals.pause();

				lime.app.Application.current.window.alert(value2, value1);
				FlxG.sound.music.resume();
				vocals.resume();

			case 'Popup (No Pause)':
				lime.app.Application.current.window.alert(value2, value1);

			case 'Set Property':
				try {
					var killMe:Array<String> = value1.split('.');
					if(killMe.length > 1)
						FunkinLua.setVarInArray(FunkinLua.getPropertyLoopThingWhatever(killMe, true, true), killMe[killMe.length - 1], value2);
					else
						FunkinLua.setVarInArray(this, value1, value2);
				} catch(e:Dynamic) {
					var len:Int = e.message.indexOf('\n') + 1;
					if (len <= 0) len = e.message.length;
					#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
					addTextToDebug('ERROR ("Set Property" Event) - ' + e.message.substr(0, len), FlxColor.RED);
					#else
					FlxG.log.warn('ERROR ("Set Property" Event) - ' + e.message.substr(0, len));
					#end
				}
			case 'Play Sound':
				if (flValue2 == null) flValue2 = 1;
				FlxG.sound.play(Paths.sound(value1), flValue2);
			case 'Add Subtitle':
				var split:Array<String> = value2.split(',');
				var val2:Null<Int> = Std.parseInt(split[0]);
				var funnyColor:FlxColor = FlxColor.WHITE;
				var useIco:Bool = false;
				switch (split[0].toLowerCase()) {
					case 'dadicon' | 'dad' | 'oppt' | 'oppticon' | 'opponent':
						funnyColor = CoolUtil.getColor(dad.healthColorArray);
						useIco = true;
					case 'bficon' | 'bf' | 'boyfriend' | 'boyfriendicon':
						funnyColor = CoolUtil.getColor(boyfriend.healthColorArray);
						useIco = true;
					case 'gficon' | 'gf' | 'girlfriend' | 'girlfriendicon':
						funnyColor = CoolUtil.getColor(gf.healthColorArray);
						useIco = true;
				}
				var val3:Null<Float> = Std.parseFloat(split[1]);
				var sub:FlxText = new FlxText(0, ClientPrefs.downScroll ? healthBar.y + 90 : healthBar.y - 90, 0, value1, 32);
				sub.scrollFactor.set();
				sub.cameras = [camHUD];
				sub.setFormat(Paths.font("vcr.ttf"), 32, useIco ? funnyColor : val2, CENTER, FlxTextBorderStyle.SHADOW, FlxColor.BLACK);
				var subBG:FlxSprite = new FlxSprite(0, ClientPrefs.downScroll ? healthBar.y + 90 : healthBar.y - 90).makeGraphic(Std.int(sub.width + 10), Std.int(sub.height + 10), FlxColor.BLACK);
				subBG.scrollFactor.set();
				subBG.cameras = [camHUD];
				subBG.alpha = 0.5;
				subBG.screenCenter(X);
				sub.screenCenter(X);
				sub.y += 5;
				add(subBG);
				add(sub);
				var tmr:FlxTimer = new FlxTimer().start(val3 / playbackRate, function(timer:FlxTimer) {
					FlxTween.tween(sub, {alpha: 0}, 0.25 / playbackRate, {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween) {
						sub.kill();
						sub.destroy();
					}});
					FlxTween.tween(subBG, {alpha: 0}, 0.25 / playbackRate, {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween) {
						subBG.kill();
						subBG.destroy();
					}});
				});
		}
		callOnLuas('onEvent', [eventName, value1, value2]);
	}

	function moveCameraSection():Void {
		if(SONG.notes[curSection] == null) return;

		if (gf != null && SONG.notes[curSection].gfSection)
		{
			camFollow.set(gf.getMidpoint().x, gf.getMidpoint().y);
			camFollow.x += gf.cameraPosition[0] + girlfriendCameraOffset[0];
			camFollow.y += gf.cameraPosition[1] + girlfriendCameraOffset[1];
			tweenCamIn();
			callOnLuas('onMoveCamera', ['gf']);
			return;
		}

		moveCamera(!SONG.notes[curSection].mustHitSection);
		callOnLuas('onMoveCamera', !SONG.notes[curSection].mustHitSection ? ['dad'] : ['boyfriend']);
	}

	var cameraTwn:FlxTween;
	public function moveCamera(isDad:Bool)
	{
		if(isDad)
		{
			camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			camFollow.x += dad.cameraPosition[0] + opponentCameraOffset[0];
			camFollow.y += dad.cameraPosition[1] + opponentCameraOffset[1];
			tweenCamIn();
		}
		else
		{
			camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
			camFollow.x -= boyfriend.cameraPosition[0] - boyfriendCameraOffset[0];
			camFollow.y += boyfriend.cameraPosition[1] + boyfriendCameraOffset[1];

			if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1)
				cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete: _ -> cameraTwn = null});
		}
	}

	inline function tweenCamIn() {
		if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1.3)
			cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete: _ -> cameraTwn = null});
	}

	inline function snapCamFollowToPos(x:Float, y:Float) {
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	public function finishSong(?ignoreNoteOffset:Bool = false):Void
	{
		var finishCallback:Void->Void = endSong; //In case you want to change it in a specific song.

		#if WEBM_ALLOWED
		endBGVideo();
		#end

		updateTime = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		vocals.pause();
		if(ClientPrefs.noteOffset <= 0 || ignoreNoteOffset) {
			finishCallback();
		} else {
			finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer) {
				finishCallback();
			});
		}
	}

	public var transitioning = false;

	public function endSong():Void
	{
		Application.current.window.title = Application.current.meta.get('name');
		
		System.gc();
		ButtplugUtils.stop();

		gainedCredit = FlxG.random.int(1, 100);
		FlxG.save.data.socialCredit += gainedCredit;
		SocialCreditState.wentUp = true;

		#if sys
		if (!inReplay)
		{
			final files:Array<String> = CoolUtil.coolPathArray(Paths.getPreloadPath('replays/'));
			final song:String = SONG.song.coolSongFormatter().toLowerCase();
			var length:Null<Int> = null;

			length = (files == null) ? 0 : files.length;

			if (ClientPrefs.saveReplay)
				File.saveContent(Paths.getPreloadPath('replays/$song ${length}.json'), ReplayState.stringify());
		}
		#end

		timeBar.visible = timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		updateTime = false;
		deathCounter = 0;
		seenCutscene = false;

		#if ACHIEVEMENTS_ALLOWED
		if (achievementObj != null)
			return;
		else {
			var weekNoMiss:String = WeekData.getWeekFileName() + '_nomiss';
			var achieve:String = checkForAchievement([weekNoMiss, 'ur_bad', 'ur_good', 'hype', 'two_keys', 'toastie', 'debugger']);
			var customAchieve:String = checkForAchievement(achievementWeeks);
			
			if(achieve != null || customAchieve != null) {
				startAchievement(customAchieve != null ? customAchieve : achieve);
				return;
			}
		}
		#end

		var ret:Dynamic = callOnLuas('onEndSong', [], false);
		if(ret != FunkinLua.Function_Stop && !transitioning) {
			var percent:Float = ratingPercent;
			if(Math.isNaN(percent)) percent = 0;
			Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent);
			playbackRate = 1;

			if (inReplay)
			{
				MusicBeatState.switchState(new FreeplayState());
				return;
			}
			else if (chartingMode)
			{
				openChartEditor();
				return;
			}
			else if (isStoryMode)
			{
				campaignScore += songScore;
				campaignMisses += songMisses;
				campaignSicks += sicks;
				campaignGoods += goods;
				campaignBads += bads;
				campaignShits += shits;

				storyPlaylist.remove(storyPlaylist[0]);
				if (storyPlaylist.length <= 0)
				{
					Mods.loadTheFirstEnabledMod();

					cancelMusicFadeTween();

					if (ClientPrefs.resultsScreen) {
						new FlxTimer().start(0.5, function(tmr:FlxTimer) {
							persistentUpdate = true;
							openSubState(new ResultsSubState(campaignSicks, campaignGoods, campaignBads, campaignShits, campaignScore, campaignMisses, 
								Highscore.floorDecimal(ratingPercent * 100, 2), ratingName, ratingFC)); 
						});
					} else {
						Application.current.window.title = Application.current.meta.get('name');
						MusicBeatState.switchState(new StoryMenuState());
					}

					if(!ClientPrefs.getGameplaySetting('practice', false) && !ClientPrefs.getGameplaySetting('botplay', false)) {
						StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);

						Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);

						FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
						FlxG.save.flush();
					}
					changedDifficulty = false;
				}
				else
				{
					var difficulty:String = CoolUtil.getDifficultyFilePath();

					trace('LOADING NEXT SONG');
					trace(Paths.formatToSongPath(PlayState.storyPlaylist[0]) + difficulty);

					var winterHorrorlandNext = (Paths.formatToSongPath(SONG.song) == "eggnog");
					if (winterHorrorlandNext)
					{
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;

						FlxG.sound.play(Paths.sound('Lights_Shut_off'));
					}

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;

					prevCamFollow = camFollow;
					prevCamFollowPos = camFollowPos;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					if(winterHorrorlandNext) {
						new FlxTimer().start(1.5, function(tmr:FlxTimer) {
							cancelMusicFadeTween();
							LoadingState.loadAndSwitchState(new PlayState());
						});
					} else {
						cancelMusicFadeTween();
						LoadingState.loadAndSwitchState(new PlayState());
					}
				}
			}
			else
			{
				Mods.loadTheFirstEnabledMod();

				cancelMusicFadeTween();

				if (ClientPrefs.resultsScreen) {
					new FlxTimer().start(0.5, function(tmr:FlxTimer) {
						persistentUpdate = true;
						openSubState(new ResultsSubState(sicks, goods, bads, shits, songScore, songMisses,
				 			Highscore.floorDecimal(ratingPercent * 100, 2), ratingName, ratingFC)); 
					});
				} else {
					Application.current.window.title = Application.current.meta.get('name');
					MusicBeatState.switchState(new FreeplayState());
				}
				
				changedDifficulty = false;
			}
			transitioning = true;
		}
	}

	#if ACHIEVEMENTS_ALLOWED
	var achievementObj:AchievementObject = null;
	function startAchievement(achieve:String) {
		achievementObj = new AchievementObject(achieve, camOther);
		achievementObj.onFinish = achievementEnd;
		add(achievementObj);
		trace('Giving achievement ' + achieve);
	}
	function achievementEnd():Void
	{
		achievementObj = null;
		if(endingSong && !inCutscene) {
			endSong();
		}
	}
	#end

	public function KillNotes() {
		while(notes.length > 0) {
			var daNote:Note = notes.members[0];
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	public var totalPlayed:Int = 0;
	public var totalNotesHit:Float = 0.0;

	public var showCombo:Bool = true;
	public var showComboNum:Bool = true;
	public var showRating:Bool = true;

	private function cachePopUpScore()
	{
		var pixelShitPart1:String = '';
		var pixelShitPart2:String = '';

		switch (ClientPrefs.uiSkin) 
		{
			case 'Default':
				pixelShitPart1 = (isPixelStage) ? 'pixelUI/' : '';
				pixelShitPart2 = (isPixelStage) ? '-pixel' : '';

			case 'Vanilla':
				pixelShitPart1 = 'skins/vanillaUI/';
				pixelShitPart2 = (isPixelStage) ? '-pixel' : '';

			case 'Forever':
				pixelShitPart1 = 'skins/foreverUI/';
				pixelShitPart2 = (isPixelStage) ? '-pixel' : '';

			case 'Kade':
				pixelShitPart1 = 'skins/kadeUI/';
				pixelShitPart2 = (!isPixelStage) ? '' : '-pixel';

			// no pixel assets for simplylove oops
			// it isn't even meant for pixel stages anyways
			case 'Simplylove':
				pixelShitPart1 = 'skins/simplylove/';
				pixelShitPart2 = ''; 
		}

		if (isPixelStage && ClientPrefs.uiSkin == 'Simplylove'){
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		Paths.image(pixelShitPart1 + "sick" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "good" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "bad" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "shit" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "combo" + pixelShitPart2);
		
		for (i in 0...10)
			Paths.image(pixelShitPart1 + 'num' + i + pixelShitPart2);
	}

	private function popUpScore(?note:Note, ?optionalRating:Float):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + ClientPrefs.ratingOffset);
		vocals.volume = vocalsFinished ? 0 : 1;

		var rating:RatingSprite = new RatingSprite();
		var score:Int = 350;

		var isSimplyLove:Bool = false;

		if (!inReplay)
		{
			ReplayState.hits.push(note.strumTime);
			ReplayState.judgements.push(noteDiff);
		}

		if (optionalRating != null)
			noteDiff = optionalRating;

		//tryna do MS based judgment due to popular demand
		var daRating:Rating = Conductor.judgeNote(note, noteDiff / playbackRate);

		totalNotesHit += daRating.ratingMod;
		note.ratingMod = daRating.ratingMod;
		if(!note.ratingDisabled) daRating.increase();
		note.rating = daRating.name;
		score = daRating.score;

		if(daRating.noteSplash && !note.noteSplashDisabled)
			spawnNoteSplashOnNote(note);

		if(!practiceMode && !cpuControlled) {
			songScore += score;
			if(!note.ratingDisabled)
			{
				songHits++;
				totalPlayed++;
				RecalculateRating(false);
			}
		}

		var pixelShitPart1:String = '';
		var pixelShitPart2:String = '';

		switch (ClientPrefs.uiSkin) 
		{
			case 'Default':
				pixelShitPart1 = (isPixelStage) ? 'pixelUI/' : '';
				pixelShitPart2 = (isPixelStage) ? '-pixel' : '';

			case 'Vanilla':
				pixelShitPart1 = 'skins/vanillaUI/';
				pixelShitPart2 = (isPixelStage) ? '-pixel' : '';

			case 'Forever':
				pixelShitPart1 = 'skins/foreverUI/';
				pixelShitPart2 = (isPixelStage) ? '-pixel' : '';

			case 'Kade':
				pixelShitPart1 = 'skins/kadeUI/';
				pixelShitPart2 = (!isPixelStage) ? '' : '-pixel';

			case 'Simplylove':
				pixelShitPart1 = 'skins/simplylove/';
				pixelShitPart2 = '';
				isSimplyLove = true;
		}
		// just simply don't use the skin
		if (isSimplyLove && isPixelStage){
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}
		
		final ratingsX:Float = FlxG.width * 0.35 - 40;
		final ratingsY:Float = 60;

		rating = new RatingSprite();
		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating.image + pixelShitPart2));
		rating.cameras = [camHUD];
		rating.screenCenter();
		rating.isSimply = isSimplyLove;
		rating.x = ratingsX;
		rating.y -= ratingsY;
		rating.acceleration.y = 550 * playbackRate * playbackRate;
		rating.velocity.y -= FlxG.random.int(140, 175) * playbackRate;
		rating.velocity.x -= FlxG.random.int(0, 10) * playbackRate;
		rating.visible = (!ClientPrefs.hideHud && showRating);
		rating.x += ClientPrefs.comboOffset[0];
		rating.y -= ClientPrefs.comboOffset[1];

		if (isSimplyLove)
		{
			rating = lastRating;
			if (rating != null){
				rating.isSimply = true;
				rating.revive();

				if (rating.tween != null)
				{
					rating.tween.cancel();
					rating.tween.destroy();
				}

				rating.scale.set(0.7 * 1.1, 0.7 * 1.1);

				rating.tween = FlxTween.tween(rating.scale, {x: 0.7, y: 0.7}, 0.1, {
					ease: FlxEase.quadOut,
					onComplete: function(tween:FlxTween)
					{
						if (!rating.alive)
							return;

						final time:Float = (Conductor.stepCrochet * 0.001);
						rating.tween = FlxTween.tween(rating.scale, {x: 0, y: 0}, time, {
							startDelay: time * 8,
							ease: FlxEase.quadIn,
							onComplete: function(tween:FlxTween)
							{
								rating.kill();
							}
						});
					}
				});
			}
		}

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		final comboX:Float = FlxG.width * 0.35;
		final comboY:Float = 60;
		comboSpr.cameras = [camHUD];
		comboSpr.screenCenter();
		comboSpr.x = comboX;
		if (!isSimplyLove){
			comboSpr.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
			comboSpr.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
		}
		else{
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7) * 1.5, Std.int(comboSpr.height * 0.7) * 1.5);
			var scaleTween:FlxTween = null;
			if (scaleTween != null)
				scaleTween.cancel();
			scaleTween = FlxTween.tween(comboSpr, {'scale.x': comboSpr.width - 100, 'scale.y': comboSpr.height - 100}, {onComplete: _ -> scaleTween = null});
		}
		comboSpr.visible = (!ClientPrefs.hideHud && showCombo);
		comboSpr.x += ClientPrefs.comboOffset[4];
		comboSpr.y -= ClientPrefs.comboOffset[5];
		comboSpr.velocity.x += FlxG.random.int(1, 10) * playbackRate;

		for (i in precisions) remove(i);

		var precision:FlxText = new FlxText(0, (ClientPrefs.downScroll ? playerStrums.members[0].y + 110 : playerStrums.members[0].y - 40), '' + Math.round(Conductor.songPosition - note.strumTime) + ' ms');
		precision.cameras = [camOther];
		if (ClientPrefs.downScroll) precision.y -= 3; else precision.y += 3;
		precision.x = (playerStrums.members[1].x + playerStrums.members[1].width / 2) - precision.width / 2;
		precision.setFormat(Paths.font("vcr.ttf"), 21, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		FlxTween.tween(precision, {y: (ClientPrefs.downScroll ? precision.y + 3 : precision.y - 3)}, 0.01, {ease: FlxEase.bounceOut});
		precisions.push(precision);
		
		if (!ClientPrefs.comboStacking || isSimplyLove)
		{
			if (lastRating != null) 
				lastRating.kill();
			lastRating = rating;
		}

		if (!PlayState.isPixelStage)
		{
			if (!isSimplyLove){
				rating.setGraphicSize(Std.int(rating.width * 0.7));
				comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			}
			if (rating != null)
				rating.antialiasing = ClientPrefs.globalAntialiasing;
			comboSpr.antialiasing = ClientPrefs.globalAntialiasing;
		}
		else
		{
			if (rating != null)
				rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.85));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.85));
		}

		comboSpr.updateHitbox();
		if (rating != null)
			rating.updateHitbox();

		// forever engine combo
		var seperatedScore:Array<String> = (combo + "").split("");
		var daLoop:Int = 0;

		if (!ClientPrefs.comboStacking || isSimplyLove)
		{
			if (lastCombo != null) lastCombo.kill();
			lastCombo = comboSpr;
		}
		if (lastScore != null)
		{
			while (lastScore.length > 0)
			{
				lastScore[0].kill();
				lastScore.remove(lastScore[0]);
			}
		}
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + i + pixelShitPart2));
			final numScoreX:Float = FlxG.width * 0.35 + (43 * daLoop) - 90;
			final numScoreY:Float = 80;
			numScore.cameras = [camHUD];
			numScore.screenCenter();
			numScore.x = numScoreX;
			numScore.y += numScoreY;

			numScore.x += ClientPrefs.comboOffset[2];
			numScore.y -= ClientPrefs.comboOffset[3];
			
			if (!ClientPrefs.comboStacking || isSimplyLove)
				lastScore.push(numScore);

			if (!PlayState.isPixelStage)
			{
				numScore.antialiasing = ClientPrefs.globalAntialiasing;
				if (!isSimplyLove)
					numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));

			numScore.updateHitbox();

			if (!isSimplyLove){
				numScore.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
				numScore.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
				numScore.velocity.x = FlxG.random.float(-5, 5) * playbackRate;
			}
			else{
				numScore.setGraphicSize(Std.int(numScore.width * 0.7) * 1.5, Std.int(numScore.height * 0.7) * 1.5);
				var scaleTween:FlxTween = null;
				if (scaleTween != null)
					scaleTween.cancel();
				scaleTween = FlxTween.tween(numScore, {'scale.x': numScore.width - 100, 'scale.y': numScore.height - 100}, {onComplete: _ -> scaleTween = null});
			}
			numScore.visible = (!ClientPrefs.hideHud && showComboNum);

			if (curStage == 'limo' && !isSimplyLove) 
			{
				new FlxTimer().start(0.3, (tmr:FlxTimer) -> 
				{
					comboSpr.acceleration.x = 1250;
					rating.acceleration.x = 1250;
					numScore.acceleration.x = 1250;
				});
			}

			if (curStage == 'philly' && trainMoving && !trainFinishing && !isSimplyLove) 
			{
				new FlxTimer().start(0.3, (tmr:FlxTimer) -> 
				{
					comboSpr.acceleration.x = -1250;
					rating.acceleration.x = -1250;
					numScore.acceleration.x = -1250;
				});
			}

			if (combo >= 0)
				insert(members.indexOf(strumLineNotes), numScore);
			
			if (combo >= 10)
				insert(members.indexOf(strumLineNotes), comboSpr);

			insert(members.indexOf(strumLineNotes), rating);
			if (ClientPrefs.displayMilliseconds) add(precision);

			FlxTween.tween(numScore, {alpha: 0}, 0.2 / playbackRate, {onComplete: _ -> {
					numScore.kill();
					numScore.alpha = 1;
				},
				startDelay: Conductor.crochet * 0.002 / playbackRate
			});

			daLoop++;
		}

		if (!isSimplyLove){
			FlxTween.tween(rating, {alpha: 0}, 0.2 / playbackRate, {onComplete: _ -> {
					rating.kill();
					rating.alpha = 1;
				},
				startDelay: Conductor.crochet * 0.001 / playbackRate
			});
		}

		if (ClientPrefs.displayMilliseconds) {
			FlxTween.tween(precision, {alpha: 0}, 0.2 / playbackRate, {
				startDelay: Conductor.crochet * 0.001 / playbackRate
			});
		}

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2 / playbackRate, {onComplete: _ -> {
				comboSpr.kill();
				comboSpr.alpha = 1;
			},
			startDelay: Conductor.crochet * 0.002 / playbackRate
		});
	}

	public var strumsBlocked:Array<Bool> = [];
	private function onKeyPress(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);

		if (!cpuControlled && startedCountdown && !paused && key > -1 && (FlxG.keys.checkStatus(eventKey, JUST_PRESSED)))
		{
			if(!boyfriend.stunned && generatedMusic && !endingSong)
			{
				//more accurate hit time for the ratings?
				var lastTime:Float = Conductor.songPosition;
				Conductor.songPosition = FlxG.sound.music.time;

				var canMiss:Bool = !ClientPrefs.ghostTapping;

				// heavily based on my own code LOL if it aint broke dont fix it
				var pressNotes:Array<Note> = [];
				var notesStopped:Bool = false;

				var sortedNotesList:Array<Note> = [];
				notes.forEachAlive(function(daNote:Note)
				{
					if (strumsBlocked[daNote.noteData] != true && daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote && !daNote.blockHit)
					{
						if(daNote.noteData == key)
						{
							sortedNotesList.push(daNote);
						}
						canMiss = true;
					}
				});
				sortedNotesList.sort(sortHitNotes);

				if (sortedNotesList.length > 0) {
					for (epicNote in sortedNotesList)
					{
						for (doubleNote in pressNotes) {
							if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 1) {
								notes.remove(doubleNote, true);
								doubleNote.destroy();
							} else
								notesStopped = true;
						}

						// eee jack detection before was not super good
						if (!notesStopped) {
							goodNoteHit(epicNote);
							pressNotes.push(epicNote);
						}

					}
				}else{
					callOnLuas('onGhostTap', [key]);

					if (ClientPrefs.ghostTapAnim)
					{
						boyfriend.playAnim(singAnimations[Std.int(Math.abs(key))], true);
						if (ClientPrefs.cameraPanning) camPanRoutine(singAnimations[Std.int(Math.abs(key))], 'bf');
						boyfriend.holdTimer = 0;
					}

					if (ClientPrefs.cameraPanning) camPanRoutine(singAnimations[Std.int(Math.abs(key))], 'dad');

					if (canMiss && !ClientPrefs.ghostTapping) {
						noteMissPress(key);
					}
				}

				// for the "Just the Two of Us" achievement
				keysPressed[key] = true;

				//more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
				Conductor.songPosition = lastTime;
			}

			var spr:StrumNote = playerStrums.members[key];
			if(strumsBlocked[key] != true && spr != null && spr.animation.curAnim.name != 'confirm')
			{
				spr.playAnim('pressed');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyPress', [key]);
		}
	}

	function sortHitNotes(a:Note, b:Note):Int
	{
		if (a.lowPriority && !b.lowPriority)
			return 1;
		else if (!a.lowPriority && b.lowPriority)
			return -1;

		return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
	}

	private function onKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		if(!cpuControlled && startedCountdown && !paused && key > -1)
		{
			var spr:StrumNote = playerStrums.members[key];
			if(spr != null)
			{
				spr.playAnim('static');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyRelease', [key]);
		}
	}

	private function getKeyFromEvent(key:FlxKey):Int
	{
		if(key != NONE)
		{
			for (i in 0...keysArray.length)
			{
				for (j in 0...keysArray[i].length)
				{
					if(key == keysArray[i][j])
					{
						return i;
					}
				}
			}
		}
		return -1;
	}

	// Hold notes
	private function keyShit():Void
	{
		// HOLDING
		var parsedHoldArray:Array<Bool> = parseKeys();

		if (startedCountdown && !boyfriend.stunned && generatedMusic)
		{
			// rewritten inputs???
			notes.forEachAlive(function(daNote:Note)
			{
				// hold note functions
				if (strumsBlocked[daNote.noteData] != true && daNote.isSustainNote && parsedHoldArray[daNote.noteData] && daNote.canBeHit
				&& daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.blockHit) {
					goodNoteHit(daNote);
				}
			});

			if (parsedHoldArray.contains(true) && !endingSong) {
				#if ACHIEVEMENTS_ALLOWED
				var achieve:String = checkForAchievement(['oversinging']);
				if (achieve != null) {
					startAchievement(achieve);
				}
				#end
			}
			else if (boyfriend.animation.curAnim != null && boyfriend.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.dance();
			}
		}

		if(strumsBlocked.contains(true))
		{
			var parsedArray:Array<Bool> = parseKeys('_R');
			if(parsedArray.contains(true))
			{
				for (i in 0...parsedArray.length)
				{
					if(parsedArray[i] || strumsBlocked[i] == true)
						onKeyRelease(new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, -1, keysArray[i][0]));
				}
			}
		}
	}

	inline private function parseKeys(?suffix:String = ''):Array<Bool>
	{
		return [for (i in 0...controlArray.length) Reflect.getProperty(controls, controlArray[i] + suffix)];
	}

	public var useVideo:Bool = false;
	public var stopUpdate:Bool = false;
	public var removedVideo:Bool = false;

	#if WEBM_ALLOWED
	public static var webmHandler:WebmHandler;
	#end
	public var videoSprite:FlxSprite;

	public function backgroundVideo(source:String):Void // for background videos
	{
		#if WEBM_ALLOWED
		useVideo = true;

		var ourSource:String = "assets/videos/DO NOT DELETE OR GAME WILL CRASH/dontDelete.webm";

		webmHandler = new WebmHandler();
		webmHandler.source(ourSource);
		webmHandler.makePlayer();
		webmHandler.webm.name = "WEBM SHIT";

		BackgroundVideo.setWebm(webmHandler);
		var ourVideo:Dynamic = BackgroundVideo.get();

		ourVideo.source(Paths.video(source));
		ourVideo.clearPause();

		if (BackgroundVideo.isWebm)
			ourVideo.updatePlayer();

		ourVideo.show();

		if (BackgroundVideo.isWebm) ourVideo.restart();
		else ourVideo.play();

		var data = webmHandler.webm.bitmapData;

		videoSprite = new FlxSprite(0, 0);
		videoSprite.loadGraphic(data);
		videoSprite.scrollFactor.set();
		videoSprite.cameras = [camHUD];
		add(videoSprite);

		if (startingSong)
			webmHandler.pause();
		else
			webmHandler.resume();
		#end
	}

	public function makeBackgroundTheVideo(source:String, with:Dynamic):Void // for background videos
	{
		#if WEBM_ALLOWED
		useVideo = true;

		var ourSource:String = "assets/videos/DO NOT DELETE OR GAME WILL CRASH/dontDelete.webm";

		webmHandler = new WebmHandler();
		webmHandler.source(ourSource);
		webmHandler.makePlayer();
		webmHandler.webm.name = "WEBM SHIT";

		BackgroundVideo.setWebm(webmHandler);
		var ourVideo:Dynamic = BackgroundVideo.get();

		ourVideo.source(Paths.video(source));
		ourVideo.clearPause();

		if (BackgroundVideo.isWebm)
			ourVideo.updatePlayer();

		ourVideo.show();

		if (BackgroundVideo.isWebm) ourVideo.restart();
		else ourVideo.play();

		var data = webmHandler.webm.bitmapData;

		videoSprite = new FlxSprite(0, 0);
		videoSprite.loadGraphic(data);
		videoSprite.setGraphicSize(Std.int(videoSprite.width * 1.4));
		videoSprite.scrollFactor.set();

		switch (with)
		{
			case 'before' | 'in front of' | 'afore' | 'ere' | 'front' | 'head' | true | 'true':
				add(videoSprite);
			case 'dad' | 'opponent':
				addBehindDad(videoSprite);
			case 'bf' | 'boyfriend':
				addBehindBF(videoSprite);
			default:
				addBehindGF(videoSprite);
		}

		if (startingSong)
			webmHandler.pause();
		else
			webmHandler.resume();
		#end
	}

	public function endBGVideo():Void
	{
		#if WEBM_ALLOWED
		var video:Dynamic = BackgroundVideo.get();

		if (useVideo && video != null)
		{
			video.stop();
			remove(videoSprite);
		}
		#end
	}

	function noteMiss(daNote:Note):Void { //You didn't hit the key and let it go offscreen, also used by Hurt Notes
		//Dupe note remove
		notes.forEachAlive(function(note:Note) {
			if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 1) {
				notes.remove(note, true);
				note.destroy();
			}
		});
		combo = 0;
		health -= daNote.missHealth * healthLoss;

		#if sys
		ArtemisIntegration.breakCombo ();
		ArtemisIntegration.sendBoyfriendHealth (health);
		#end
		
		if(instakillOnMiss)
		{
			vocals.volume = 0;
			doDeathCheck(true);
		}

		songMisses++;
		vocals.volume = 0;
		if(!practiceMode) songScore -= 10;

		totalPlayed++;
		RecalculateRating(true);

		var char:Character = boyfriend;
		if(daNote.gfNote) {
			char = gf;
		}

		if(char != null && !daNote.noMissAnimation && char.hasMissAnimations)
		{
			var animToPlay:String = singAnimations[Std.int(Math.abs(daNote.noteData))] + 'miss' + daNote.animSuffix;
			char.playAnim(animToPlay, true);
		}

		callOnLuas('noteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
	}

	function noteMissPress(direction:Int = 1):Void //You pressed a key when there was no notes to press for this key
	{
		if (!boyfriend.stunned)
		{
			if (!inReplay)
			{
				ReplayState.miss.push([Std.int(Conductor.songPosition), direction]);
			}
			
			health -= 0.05 * healthLoss;
			if(instakillOnMiss)
			{
				vocals.volume = 0;
				doDeathCheck(true);
			}

			if (combo > 5 && gf != null && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			#if sys
			ArtemisIntegration.sendBoyfriendHealth (health);
			ArtemisIntegration.breakCombo ();
			#end

			if(!practiceMode) songScore -= 10;
			if(!endingSong) {
				songMisses++;
			}
			totalPlayed++;
			RecalculateRating(true);

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));

			if(boyfriend.hasMissAnimations) {
				boyfriend.playAnim(singAnimations[Std.int(Math.abs(direction))] + 'miss', true);
			}
			vocals.volume = 0;
		}
		callOnLuas('noteMissPress', [direction]);
	}

	function opponentNoteHit(note:Note):Void
	{
		if (Paths.formatToSongPath(SONG.song) != 'tutorial')
			camZooming = true;

		if(note.noteType == 'Hey!' && dad.animOffsets.exists('hey')) {
			dad.playAnim('hey', true);
			dad.specialAnim = true;
			dad.heyTimer = 0.6;
		} else if(!note.noAnimation) {
			var altAnim:String = note.animSuffix;

			if (SONG.notes[curSection] != null)
			{
				if (SONG.notes[curSection].altAnim && !SONG.notes[curSection].gfSection) {
					altAnim = '-alt';
				}
			}

			var char:Character = dad;
			var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))] + altAnim;
			if(note.gfNote) {
				char = gf;
			}

			if(char != null)
			{
				if (ClientPrefs.cameraPanning) inline camPanRoutine(animToPlay, 'dad');
				char.playAnim(animToPlay, true);
				char.holdTimer = 0;
			}
		}

		if (SONG.needsVoices)
			vocals.volume = vocalsFinished ? 0 : 1;

		var time:Float = 0.15;
		if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
			time += 0.15;
		}
		StrumPlayAnim(true, Std.int(Math.abs(note.noteData)), time);
		note.hitByOpponent = true;

		callOnLuas('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);

		if (!note.isSustainNote)
		{
			notes.remove(note, true);
			note.destroy();
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if(cpuControlled && (note.ignoreNote || note.hitCausesMiss)) return;

			if (!note.isSustainNote)
				npsArray.unshift(Date.now());

			if (ClientPrefs.hitsoundVolume > 0 && !note.hitsoundDisabled)
				FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.hitsoundVolume);

			if(note.hitCausesMiss) {
				noteMiss(note);
				if(!note.noteSplashDisabled && !note.isSustainNote) {
					spawnNoteSplashOnNote(note);
				}

				if(!note.noMissAnimation)
				{
					switch(note.noteType) {
						case 'Hurt Note': //Hurt note
							if(boyfriend.animation.getByName('hurt') != null) {
								boyfriend.playAnim('hurt', true);
								boyfriend.specialAnim = true;
							}
					}
				}

				note.wasGoodHit = true;
				if (!note.isSustainNote)
				{
					notes.remove(note, true);
					note.destroy();
				}
				return;
			}

			if (!note.isSustainNote)
			{
				combo++;
				if(combo > 9999) combo = 9999;
				#if sys
				ArtemisIntegration.setCombo (combo);
				#end
				popUpScore(note);
			}
			else if (!inReplay && note.isSustainNote)
			{
				ReplayState.sustainHits.push(Std.int(note.strumTime));
			}
			health += note.hitHealth * healthGain;
			#if sys
			ArtemisIntegration.sendBoyfriendHealth (health);
			#end

			if(!note.noAnimation) {
				var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))];

				if(note.gfNote)
				{
					if(gf != null)
					{
						gf.playAnim(animToPlay + note.animSuffix, true);
						gf.holdTimer = 0;
					}
				}
				else
				{
					if (ClientPrefs.cameraPanning) inline camPanRoutine(animToPlay, 'bf');
					boyfriend.playAnim(animToPlay + note.animSuffix, true);
					boyfriend.holdTimer = 0;
				}

				if(note.noteType == 'Hey!') {
					if(boyfriend.animOffsets.exists('hey')) {
						boyfriend.playAnim('hey', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = 0.6;
					}

					if(gf != null && gf.animOffsets.exists('cheer')) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = 0.6;
					}
				}
			}

			if(cpuControlled) {
				var time:Float = 0.15;
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
					time += 0.15;
				}
				StrumPlayAnim(false, Std.int(Math.abs(note.noteData)), time);
			} else {
				var spr = playerStrums.members[note.noteData];
				if(spr != null)
				{
					spr.playAnim('confirm', true);
				}
			}
			note.wasGoodHit = true;
			vocals.volume = vocalsFinished ? 0 : 1;

			var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
			var leData:Int = Math.round(Math.abs(note.noteData));
			var leType:String = note.noteType;
			callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);

			if (!note.isSustainNote)
			{
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	public function spawnNoteSplashOnNote(note:Note) {
		if(ClientPrefs.noteSplashes && note != null) {
			var strum:StrumNote = playerStrums.members[note.noteData];
			if(strum != null) {
				spawnNoteSplash(strum.x, strum.y, note.noteData, note);
			}
		}
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null) {
		var skin:String = 'noteSplashes';
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;

		var col:FlxColor = FlxColor.WHITE;
		if (data > -1 && data < ClientPrefs.arrowRGB.length)
		{
			col = ClientPrefs.arrowRGB[data][0];
			if(note != null) {
				col = note.noteSplashColor;
			}
		}

		if(note != null) {
			skin = note.noteSplashTexture;
		}

		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data, skin, col);
		grpNoteSplashes.add(splash);
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	var carTimer:FlxTimer;
	function fastCarDrive()
	{
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		carTimer = new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
			carTimer = null;
		});
	}

	var billBoardCanBill:Bool = true;

	public function resetBillBoard():Void
	{
		billBoard.x = -12600;
		billBoard.y = FlxG.random.int(-840, -1050);
		billBoard.velocity.x = 0;
		billBoardCanBill = true;
		var billBoardWho:String = '';
		switch (FlxG.random.int(0, 2)) {
			case 0:
				billBoardWho = 'stages/limo/fastMomLol';
			case 1:
				billBoardWho = 'stages/limo/fastBfLol';
			case 2:
				billBoardWho = 'stages/limo/fastPicoLol';
		}
		billBoard.loadGraphic(Paths.image(billBoardWho));
	}

	var billTimer:FlxTimer;
	inline public function billBoardBill()
	{
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		billBoard.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		billBoardCanBill = false;
		billTimer = new FlxTimer(stateTimers).start(FlxG.random.int(4, 8), function(tmr:FlxTimer)
		{
			resetBillBoard();
			billTimer = null;
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			if (gf != null)
			{
				gf.playAnim('hairBlow');
				gf.specialAnim = true;
			}
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		if(gf != null)
		{
			gf.danced = false; //Sets head to the correct position once the animation ends
			gf.playAnim('hairFall');
			gf.specialAnim = true;
		}
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		if(!ClientPrefs.lowQuality) halloweenBG.animation.play('halloweem bg lightning strike');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		if(boyfriend.animOffsets.exists('scared')) {
			boyfriend.playAnim('scared', true);
		}

		if(gf != null && gf.animOffsets.exists('scared')) {
			gf.playAnim('scared', true);
		}

		if(ClientPrefs.camZooms) {
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;

			if(!camZooming) { //Just a way for preventing it to be permanently zoomed until Skid & Pump hits a note
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.5);
				FlxTween.tween(camHUD, {zoom: 1}, 0.5);
			}
		}

		if(ClientPrefs.flashing) {
			#if sys
			ArtemisIntegration.triggerFlash ("#FFFFFFEF");
			#end
			halloweenWhite.alpha = 0.4;
			FlxTween.tween(halloweenWhite, {alpha: 0.5}, 0.075);
			FlxTween.tween(halloweenWhite, {alpha: 0}, 0.25, {startDelay: 0.15});
		}
	}

	function killHenchmen():Void
	{
		if(!ClientPrefs.lowQuality && curStage == 'limo') {
			if(limoKillingState < 1) {
				limoMetalPole.x = -400;
				limoMetalPole.visible = true;
				limoLight.visible = true;
				limoCorpse.visible = false;
				limoCorpseTwo.visible = false;
				limoKillingState = 1;

				#if ACHIEVEMENTS_ALLOWED
				Achievements.henchmenDeath++;
				FlxG.save.data.henchmenDeath = Achievements.henchmenDeath;
				var achieve:String = checkForAchievement(['roadkill_enthusiast']);
				if (achieve != null) {
					startAchievement(achieve);
				} else {
					FlxG.save.flush();
				}
				FlxG.log.add('Deaths: ' + Achievements.henchmenDeath);
				#end
			}
		}
	}

	function resetLimoKill():Void
	{
		if(curStage == 'limo') {
			limoMetalPole.x = -500;
			limoMetalPole.visible = false;
			limoLight.x = -500;
			limoLight.visible = false;
			limoCorpse.x = -500;
			limoCorpse.visible = false;
			limoCorpseTwo.x = -500;
			limoCorpseTwo.visible = false;
		}
	}

	public function rosesLightningStrike():Void
	{
		FlxG.sound.play(Paths.soundRandom('weeb/thunder_', 1, 2), FlxG.random.float(0.25, 0.35));
		if(!ClientPrefs.lowQuality) {
			var fuck:Int = FlxG.random.int(0,2);
			for (rosesLightning in rosesLightningGrp) {
				if (rosesLightning.ID == fuck) {
					rosesLightning.visible = true;
					rosesLightning.alpha = 0.7;
					FlxTween.tween(rosesLightning, {alpha: 1}, 0.075 / playbackRate);
					FlxTween.tween(rosesLightning, {alpha: 0.001}, 0.75 / playbackRate, {startDelay: 0.15 / playbackRate, onComplete: _ -> rosesLightning.visible = false});
				}
			}
			for (schoolClouds in schoolCloudsGrp) {
				if (schoolClouds.ID == fuck) {
					schoolClouds.color = 0xffffffff;
					FlxTween.color(schoolClouds, 0.95 / playbackRate, schoolClouds.color, 0xffdadada, {startDelay: 0.15 / playbackRate});
				} else {
					schoolClouds.color = 0xffebebeb;
					FlxTween.color(schoolClouds, 0.95 / playbackRate, schoolClouds.color, 0xffdadada, {startDelay: 0.15 / playbackRate});
				}
			}
		}

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		if (ClientPrefs.camZooms) {
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;

			if (!camZooming) {
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.5 / playbackRate);
				FlxTween.tween(camHUD, {zoom: 1}, 0.5 / playbackRate);
			}
		}

		if(ClientPrefs.flashing) {
			halloweenWhite.visible = true;
			halloweenWhite.alpha = 0.4;
			FlxTween.tween(halloweenWhite, {alpha: 0.5}, 0.075 / playbackRate);
			FlxTween.tween(halloweenWhite, {alpha: 0.001}, 0.25 / playbackRate, {startDelay: 0.15 / playbackRate, onComplete: _ -> halloweenWhite.visible = false});
		}
	}

	var tankX:Float = 400;
	var tankSpeed:Float = FlxG.random.float(5, 7);
	var tankAngle:Float = FlxG.random.int(-90, 45);

	function moveTank(?elapsed:Float = 0):Void
	{
		if(!inCutscene)
		{
			tankAngle += elapsed * tankSpeed;
			tankGround.angle = tankAngle - 90 + 15;
			tankGround.x = tankX + 1500 * Math.cos(Math.PI / 180 * (1 * tankAngle + 180));
			tankGround.y = 1300 + 1100 * Math.sin(Math.PI / 180 * (1 * tankAngle + 180));
		}
	}

	override function destroy() {
		#if LUA_ALLOWED
		for (lua in luaArray) {
			lua.call('onDestroy', []);
			lua.stop();
		}
		luaArray = [];
		#end

		#if HSCRIPT_ALLOWED
		callOnScripts('destroy', []);
		super.destroy();

		for (script in scriptArray)
			script?.destroy();
		scriptArray = [];
		#end

		#if hscript
		if (FunkinLua.hscript != null) FunkinLua.hscript = null;
		#end

		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);

		FlxG.timeScale = 1;
		#if FLX_PITCH FlxG.sound.music.pitch = 1; #end

		instance = null;
		
		super.destroy();
	}

	private function callOnScripts(funcName:String, args:Array<Dynamic>):Dynamic {
		var value:Dynamic = FunkinHScript.Function_Continue;

		for (i in 0...scriptArray.length) {
			final call:Dynamic = scriptArray[i].executeFunc(funcName, args);
			final bool:Bool = call == FunkinHScript.Function_Continue;
			if (!bool && call != null)
				value = call;
		}

		return value;
	}

	public static function cancelMusicFadeTween() {
		if(FlxG.sound.music.fadeTween != null) {
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	var lastStepHit:Int = -1;
	override function stepHit()
	{
		super.stepHit();

		if (SONG.needsVoices && FlxG.sound.music.time >= -ClientPrefs.noteOffset)
		{
			var timeSub:Float = Conductor.songPosition - Conductor.offset;
			var syncTime:Float = 20 * playbackRate;
			if (Math.abs(FlxG.sound.music.time - timeSub) > syncTime ||
				(vocals.length > 0 && Math.abs(vocals.time - timeSub) > syncTime))
			{
				resyncVocals();
			}
		}

		if (curStep == lastStepHit)
			return;
		
		switch (SONG.song.toLowerCase()) {
			case 'guns':
				switch (curStep) {
					case 896:
						var moveVals:Array<Float> = [40];
						for (i in 0...6 + 1) moveVals.push(40);
						function tweenNote(note:StrumNote, delay:Float, id:Int) {
							gunsNoteTweens[id] = FlxTween.tween(note, {y: strumLine.y + moveVals[id]}, 2 / playbackRate, {
								ease: FlxEase.sineInOut,
								startDelay: delay,
								onComplete: _ -> {
									moveVals[id] /= -1;
									tweenNote(note, 0, id);
								}
							});
						}
						var i = 0;
						opponentStrums.forEach(note -> {
							gunsNoteTweens.push(null);
							tweenNote(note, (0.12 * i) / playbackRate, i);
							i++;
						});
						playerStrums.forEach(note -> {
							gunsNoteTweens.push(null);
							tweenNote(note, (0.12 * i) / playbackRate, i);
							i++;
						});
						gunsThing.visible = true;
						gunsExtraClouds.visible = true;
						FlxTween.tween(dad, {y: dad.y - 50}, 1.35 / playbackRate, {
							ease: FlxEase.quadInOut,
							onComplete: _ -> tankmanRainbow = true
						});
						cameraSpeed = 2;
						FlxTween.tween(camGame, {zoom: 1.05}, 1.35 / playbackRate, {
							ease: FlxEase.circInOut,
							onComplete: _ -> defaultCamZoom = 1.05
						});
						FlxTween.tween(gunsThing, {alpha: 0.75}, 1.2 / playbackRate, {ease: FlxEase.quadInOut});
						FlxTween.tween(gunsExtraClouds, {alpha: 1}, 1.35 / playbackRate, {ease: FlxEase.quadInOut});
						foregroundSprites.forEach(spr -> FlxTween.tween(spr, {alpha: 0}, 1.35 / playbackRate, {ease: FlxEase.quadInOut}));
						for (object in stageGraphicArray) if (object != null) FlxTween.tween(object, {y: object.y + 820}, 1.35 / playbackRate, {ease: FlxEase.expoInOut});
						if (gf != null) FlxTween.tween(gf, {y: gf.y + 840}, 1.35 / playbackRate, {ease: FlxEase.expoInOut});
						FlxTween.tween(tankGround, {alpha: 0}, 1.35 / playbackRate, {ease: FlxEase.quadInOut});
					case 1024:
						boyfriend.colorSwap = new ColorSwap();
						boyfriend.shader = boyfriend.colorSwap.shader;
						iconP1.shader = boyfriend.colorSwap.shader;
						healthBar.shader = boyfriend.colorSwap.shader;
						FlxTween.tween(camGame, {zoom: defaultCamZoom + 0.5}, stepsToSecs(128), {ease: FlxEase.quadInOut});
						FlxTween.tween(boyfriend.colorSwap, {hue: 0.9}, stepsToSecs(128), {ease: FlxEase.quadInOut});
					case 1152:
						for (tween in gunsNoteTweens) {
							if (tween != null) {
								tween.cancel();
								tween = null;
							}
						}
						FlxTween.tween(boyfriend.colorSwap, {hue: 1}, 0.4 / playbackRate, {
							ease: FlxEase.quadInOut,
							onComplete: _ -> {
								healthBar.shader = null;
								iconP1.shader = null;
								boyfriend.shader = null;
								boyfriend.colorSwap = null;
							}
						});
						opponentStrums.forEach(note -> FlxTween.tween(note, {y: strumLine.y}, 0.4 / playbackRate, {ease: FlxEase.sineInOut}));
						playerStrums.forEach(note -> FlxTween.tween(note, {y: strumLine.y}, 0.4 / playbackRate, {ease: FlxEase.sineInOut}));
						tankmanRainbow = false;
						cameraSpeed = 1;
						if (gunsTween != null) gunsTween.cancel();
						gunsTween = null;
						FlxTween.tween(camGame, {zoom: 0.9}, 1.35 / playbackRate, {
							ease: FlxEase.circInOut,
							onComplete: _ -> defaultCamZoom = 0.9
						});
						FlxTween.tween(gunsThing, {alpha: 0}, 1.2 / playbackRate, {
							ease: FlxEase.quadInOut,
							onComplete: _ -> {
								remove(gunsThing, true);
								gunsThing.destroy();
							}
						});
						FlxTween.tween(gunsExtraClouds, {alpha: 0}, 1.35 / playbackRate, {
							ease: FlxEase.quadInOut,
							onComplete: _ -> {
								remove(gunsExtraClouds, true);
								gunsExtraClouds.destroy();
							}
						});
						foregroundSprites.forEach(spr -> FlxTween.tween(spr, {alpha: 1}, 1.35 / playbackRate, {ease: FlxEase.quadInOut}));
						FlxTween.tween(dad, {y: 340}, 1.3 / playbackRate, {ease: FlxEase.circInOut});
						for (object in stageGraphicArray) if (object != null) FlxTween.tween(object, {y: object.y - 820}, 1.35 / playbackRate, {ease: FlxEase.expoInOut});
						if (gf != null) FlxTween.tween(gf, {y: gf.y - 840}, 1.35 / playbackRate, {ease: FlxEase.expoInOut});
						FlxTween.tween(tankGround, {alpha: 1}, 1.35 / playbackRate, {ease: FlxEase.quadInOut});
				}
			case 'roses':
				switch (curStep) {
					case 416:
						FlxTween.tween(tintMap['roses'], {alpha: 0.3}, ((Conductor.stepCrochet / 1000) * 16) / playbackRate);
					case 444:
						schoolRain = new FlxSprite(0, 0);
						schoolRain.frames = Paths.getSparrowAtlas('stages/school/weeb/rain');
						schoolRain.animation.addByPrefix("idle", "rain", 24, true);
						schoolRain.animation.play("idle");

						schoolRain.scale.set(6,6);
						schoolRain.updateHitbox();
						schoolRain.screenCenter();
						schoolRain.alpha = 0.95;
						schoolRain.x += 115;
						schoolRain.y += 130;
						schoolRain.scrollFactor.set(0.7, 0.9);
						schoolRain.antialiasing = false;
						add(schoolRain);

						rainSound = new FlxSound().loadEmbedded(Paths.sound('rainSnd'));
						FlxG.sound.list.add(rainSound);
						rainSound.volume = 0;
						rainSound.looped = true;
						rainSound.play();
						rainSound.fadeIn(((Conductor.stepCrochet / 1000) * 4) / playbackRate, 0, 0.3);

						tintMap.set('roses-red', addATint(0.175, FlxColor.fromRGB(128, 0, 0)));
						
						rosesLightningStrike();
						if(ClientPrefs.flashing) FlxG.camera.flash(FlxColor.WHITE, ((Conductor.stepCrochet / 1000) * 4) / playbackRate);
					case 704:
						FlxTween.tween(this, {defaultCamZoom: defaultCamZoom - 0.08}, 0.25 / playbackRate, {ease: FlxEase.quadInOut});
				}
		}

		lastStepHit = curStep;
		callOnScripts('stepHit', [curStep]);

		setOnLuas('curStep', curStep);
		callOnLuas('onStepHit', []);
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;
	var gunsColorIncrementor:Int = 0;

	var lastBeatHit:Int = -1;
	override function beatHit()
	{
		super.beatHit();

		if (lastBeatHit >= curBeat)
			return;

		#if sys
		ArtemisIntegration.setBeat (curBeat);
		#end

		if (generatedMusic)
			notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);

		iconP1.bounce();
		iconP2.bounce();

		if (curBeat % 2 == 0) {
			FlxTween.angle(iconP1, -15, 0, Conductor.crochet / 1300 * gfSpeed, {ease: FlxEase.quadOut});
			FlxTween.angle(iconP2, 15, 0, Conductor.crochet / 1300 * gfSpeed, {ease: FlxEase.quadOut});
		} else {
			FlxTween.angle(iconP1, 15, 0, Conductor.crochet / 1300 * gfSpeed, {ease: FlxEase.quadOut});
			FlxTween.angle(iconP2, -15, 0, Conductor.crochet / 1300 * gfSpeed, {ease: FlxEase.quadOut});
		}

		if (gf != null && curBeat % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
		{
			gf.dance();
		}
		if (curBeat % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
		{
			boyfriend.dance();
		}
		if (curBeat % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
		{
			dad.dance();
		}

		switch (curStage)
		{
			case 'tank':
				if(!ClientPrefs.lowQuality) tankWatchtower.dance();
				foregroundSprites.forEach(function(spr:BGSprite)
				{
					spr.dance();
				});
				switch (SONG.song.toLowerCase()) {
					case 'guns':
						if (curBeat % 4 == 0 && tankmanRainbow && gunsThing != null) {
							if (gunsTween != null) gunsTween.cancel();
							gunsTween = null;
							gunsTween = FlxTween.color(gunsThing, 1, gunsThing.color, gunsColors[gunsColorIncrementor]);
							gunsColorIncrementor++;
							if (gunsColorIncrementor > 5) gunsColorIncrementor = 0;
						}
				}

			case 'school':
				if(!ClientPrefs.lowQuality) bgGirls.forEach(bgGirl -> bgGirl.dance());

			case 'mall':
				if(!ClientPrefs.lowQuality) {
					upperBoppers.dance(true);
				}

				if(heyTimer <= 0) bottomBoppers.dance(true);
				santa.dance(true);

			case 'limo':
				if(!ClientPrefs.lowQuality) grpLimoDancers.forEach(dancer -> dancer.dance());
				if (FlxG.random.bool(10) && fastCarCanDrive) fastCarDrive();
				if (FlxG.random.bool(5) && billBoardCanBill) billBoardBill();
			case "philly":
				if (!trainMoving)
					trainCooldown++;

				if (curBeat % 4 == 0)
				{
					curLight = FlxG.random.int(0, phillyLightsColors.length - 1, [curLight]);

					#if sys
					// man it would sure be a shame if all the philly lights were individual files rather than one desaturated image that's tinted the right color
					// which i could just grab the tint color from and forward it to the client. that'd be so inconvenient, wouldn't it?
					switch (curLight)
					{
						case 0:
							ArtemisIntegration.triggerCustomEvent ("cityLights", "#FF31A2FD", curBeat);
						case 1:
							ArtemisIntegration.triggerCustomEvent ("cityLights", "#FF31FD8C", curBeat);
						case 2:
							ArtemisIntegration.triggerCustomEvent ("cityLights", "#FFFB33F5", curBeat);
						case 3:
							ArtemisIntegration.triggerCustomEvent ("cityLights", "#FFFD4531", curBeat);
						case 4:
							ArtemisIntegration.triggerCustomEvent ("cityLights", "#FFFBA633", curBeat);
					}
					#end
					
					phillyWindow.color = phillyLightsColors[curLight];
					phillyWindow.alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		if (curStage == 'spooky' && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}

		lastBeatHit = curBeat;

		if (dad.curCharacter.startsWith('spirit') && dad.animation.curAnim.name.startsWith('sing') && SONG.song.toLowerCase() == 'thorns')
		{
			FlxG.camera.shake(0.01, 0.1);
		}

		//buttplug fuckery
		if (ButtplugUtils.depsRunning || (bpPayload != 'BPDEPSNOTRUNNING')) // so to not spam the console
			ButtplugUtils.sendPayload(bpPayload);

		if(generatedMusic) { //prevent random null ref (it already happened so this is infact not useless)
			if ((curStage == 'school') && SONG.song.toLowerCase() == 'roses' && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
				rosesLightningStrike();
		}

		callOnScripts('beatHit', [curBeat]);

		setOnLuas('curBeat', curBeat); //DAWGG?????
		callOnLuas('onBeatHit', []);
	}

	override function sectionHit()
	{
		super.sectionHit();

		if (SONG.notes[curSection] != null)
		{
			if (generatedMusic && !endingSong && !isCameraOnForcedPos)
				moveCameraSection();

			if (camZooming && FlxG.camera.zoom < 1.35 && ClientPrefs.camZooms)
			{
				FlxG.camera.zoom += 0.015 * camZoomingMult;
				camHUD.zoom += 0.03 * camZoomingMult;
			}

			if (SONG.notes[curSection].changeBPM)
			{
				Conductor.bpm = SONG.notes[curSection].bpm;
				setOnLuas('curBpm', Conductor.bpm);
				setOnLuas('crochet', Conductor.crochet);
				setOnLuas('stepCrochet', Conductor.stepCrochet);
			}
			setOnLuas('mustHitSection', SONG.notes[curSection].mustHitSection);
			setOnLuas('altAnim', SONG.notes[curSection].altAnim);
			setOnLuas('gfSection', SONG.notes[curSection].gfSection);
		}
		
		setOnLuas('curSection', curSection);
		callOnLuas('onSectionHit', []);
	}

	public function callOnLuas(event:String, args:Array<Dynamic>, ?callOnScript:Bool = true, ignoreStops = true, exclusions:Array<String> = null):Dynamic {
		var returnVal:Dynamic = FunkinLua.Function_Continue;
		#if LUA_ALLOWED
		if(exclusions == null) exclusions = [];
		for (script in luaArray) {
			if(exclusions.contains(script.scriptName))
				continue;

			var ret:Dynamic = script.call(event, args);
			if(ret == FunkinLua.Function_StopLua && !ignoreStops)
				break;
			
			// had to do this because there is a bug in haxe where Stop != Continue doesnt work
			var bool:Bool = ret == FunkinLua.Function_Continue;
			if(!bool && ret != 0) {
				returnVal = cast ret;
			}
		}
		#end

		/*#if HSCRIPT_ALLOWED
		for (script in hscriptMap.keys()) {
			var hscript = hscriptMap.get(script);
			if(hscript.closed || exclusions.contains(hscript.scriptName))
				continue;

			var ret:Dynamic = callHscript(script, event, args);
			if(ret == FunkinLua.Function_StopLua && !ignoreStops)
				break;

			if (ret != FunkinLua.Function_Continue)
				returnVal = ret;
		}
		for (i in achievementsArray)
		i.call(event, args);
		#end*/
			
		return returnVal;
	}

	public function setOnLuas(variable:String, arg:Dynamic) {
		#if LUA_ALLOWED
		for (i in 0...luaArray.length) {
			luaArray[i].set(variable, arg);
		}
		#end
		for(i in achievementsArray)
			i.set(variable, arg);

		/*#if HSCRIPT_ALLOWED
		setOnHscripts(variable, arg);
		#end*/
	}

	function StrumPlayAnim(isDad:Bool, id:Int, time:Float) {
		var spr:StrumNote = null;
		if(isDad) {
			spr = strumLineNotes.members[id];
		} else {
			spr = playerStrums.members[id];
		}

		if(spr != null) {
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	function StrumPress(id:Int, ?time:Float = 0)
	{
		var spr:StrumNote = playerStrums.members[id];
		spr.playAnim('pressed');
		spr.resetAnim = time == null ? 0 : time;
	}

	public var ratingName:String = '?';
	public var ratingPercent:Float;
	public var ratingFC:String;
	public function RecalculateRating(badHit:Bool = false) {
		setOnLuas('score', songScore);
		setOnLuas('misses', songMisses);
		setOnLuas('hits', songHits);

		var ret:Dynamic = callOnLuas('onRecalculateRating', [], false);
		if(ret != FunkinLua.Function_Stop)
		{
			if (totalPlayed < 1) //Prevent divide by 0
				ratingName = '?';
			else
			{
				// Rating Percent
				ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));
				if(ratingPercent >= 1)
					ratingName = ratingStuff[ratingStuff.length - 1][0];
				else
				{
					for (i in 0...ratingStuff.length - 1)
					{
						if(ratingPercent < ratingStuff[i][1])
						{
							ratingName = ratingStuff[i][0];
							break;
						}
					}
				}
			}
			comboFunction();
		}
		updateScore(badHit); // score will only update after rating is calculated, if it's a badHit, it shouldn't bounce -Ghost
		setOnLuas('rating', ratingPercent);
		setOnLuas('ratingName', ratingName);
		setOnLuas('ratingFC', ratingFC);
	}

	#if ACHIEVEMENTS_ALLOWED
	private function checkForAchievement(achievesToCheck:Array<String> = null):String
	{
		if(chartingMode || inReplay) return null;

		var usedPractice:Bool = (ClientPrefs.getGameplaySetting('practice', false) || ClientPrefs.getGameplaySetting('botplay', false));
		for (i in 0...achievesToCheck.length) {
			var achievementName:String = achievesToCheck[i];
			if(!Achievements.isAchievementUnlocked(achievementName) && !cpuControlled && Achievements.exists(achievementName)) {
				var unlock:Bool = false;
				
				if (achievementName.contains(WeekData.getWeekFileName()) && achievementName.endsWith('nomiss')) // any FC achievements, name should be "weekFileName_nomiss", e.g: "weekd_nomiss";
				{
					if(isStoryMode && campaignMisses + songMisses < 1 && CoolUtil.difficultyString() == 'HARD'
						&& storyPlaylist.length <= 1 && !changedDifficulty && !usedPractice)
						unlock = true;
				}
				switch(achievementName)
				{
					case 'ur_bad':
						if(ratingPercent < 0.2 && !practiceMode) {
							unlock = true;
						}
					case 'ur_good':
						if(ratingPercent >= 1 && !usedPractice) {
							unlock = true;
						}
					case 'roadkill_enthusiast':
						if(Achievements.henchmenDeath >= 100) {
							unlock = true;
						}
					case 'oversinging':
						if(boyfriend.holdTimer >= 10 && !usedPractice) {
							unlock = true;
						}
					case 'hype':
						if(!boyfriendIdled && !usedPractice) {
							unlock = true;
						}
					case 'two_keys':
						if(!usedPractice) {
							var howManyPresses:Int = 0;
							for (j in 0...keysPressed.length) {
								if(keysPressed[j]) howManyPresses++;
							}

							if(howManyPresses <= 2) {
								unlock = true;
							}
						}
					case 'toastie':
						if(!ClientPrefs.shaders && ClientPrefs.lowQuality && !ClientPrefs.globalAntialiasing) {
							unlock = true;
						}
					case 'debugger':
						if(Paths.formatToSongPath(SONG.song) == 'test' && !usedPractice) {
							unlock = true;
						}
				}

				if(unlock) {
					Achievements.unlockAchievement(achievementName);
					return achievementName;
				}
			}
		}
		return null;
	}
	#end

	var curLight:Int = -1;
	var curLightEvent:Int = -1;

	// messing with ur application window lmao
	static inline var upperCase:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	static inline var lowerCase:String = "abcdefghijklmnopqrstuvwxyz";
	static inline var numbers:String = "0123456789";
	static inline var symbols:String = "!@#$%&()*+-,./:;<=>?^[]{}";

	inline public static function randomString() 
	{
		var str = "";
		for (e in [upperCase, lowerCase, numbers, symbols])
			str += e.charAt(FlxG.random.int(0, e.length - 1));

		return str;
	}

	// thanks denpa team
	public function autoLayer(array:Array<FlxBasic>, ?group:FlxTypedGroup<FlxBasic>):Void {
		try {
			if (group != null) for (object in array) group.add(object);
			else for (object in array) add(object);
		} catch (e) {
			trace('exception: ' + e);
			return;
		}
	}

	inline function addATint(alpha:Float, color:FlxColor):FlxSprite {
		var tint:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.width, FlxColor.WHITE);
		tint.scrollFactor.set();
		tint.screenCenter();
		tint.alpha = alpha;
		tint.blend = BlendMode.MULTIPLY;
		tint.color = color;
		tint.cameras = [camTint];
		tint.active = false;
		add(tint);
		return(tint);
	}
}

class RatingSprite extends FlxSprite
{
	public var tween:FlxTween;

	public var isSimply:Bool;

	public function new() {
		super();
		moves = !isSimply;

		//antialiasing = ClientPrefs.globalAntialiasing;
		//cameras = [ClientPrefs.simpleJudge ? PlayState.instance.camHUD : PlayState.instance.camGame];
		cameras = [PlayState.instance.camHUD];

		scrollFactor.set();
	}

	override public function kill() {
		if (tween != null) {
			tween.cancel();
			tween.destroy();
		}
		super.kill();
	}
}