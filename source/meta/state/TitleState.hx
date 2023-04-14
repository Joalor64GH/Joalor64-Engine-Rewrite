package meta.state;

#if desktop
import meta.data.dependency.Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import haxe.Json;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
#if (MODS_ALLOWED && FUTURE_POLYMOD)
import sys.FileSystem;
import sys.io.File;
#end
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;
#if FUTURE_POLYMOD
import core.ModCore;
#end

import meta.*;
import meta.data.*;
import meta.data.options.*;
import meta.state.*;
import meta.data.alphabet.*;
import objects.shaders.*;

using StringTools;

typedef TitleData =
{
	titlex:Float,
	titley:Float,
	startx:Float,
	starty:Float,
	gfx:Float,
	gfy:Float,
	backgroundSprite:String,
	bpm:Int
}

class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;
	var psychSpr:FlxSprite;
	#if JOALOR64_WATERMARKS
	var credIcon1:FlxSprite;
	var credIcon2:FlxSprite;
	var credIcon3:FlxSprite;
	#elseif PSYCH_WATERMARKS
	var credIconShadow:FlxSprite;
	var credIconRiver:FlxSprite;
	var credIconShubs:FlxSprite;
	var credIconBB:FlxSprite;
	#else
	var credIconMuff:FlxSprite;
	var credIconPhantom:FlxSprite;
	var credIconKawai:FlxSprite;
	var credIconEvil:FlxSprite;
	#end
	
	var titleTextColors:Array<FlxColor> = [0xFF33FFFF, 0xFF3333CC];
	var titleTextAlphas:Array<Float> = [1, .64];

	var curWacky:Array<String> = [];
	var gameName:Array<String> = [];

	var mustUpdate:Bool = false;

	var titleJSON:TitleData;

	public static var updateVersion:String = '';

	var candance:Bool = true;

	var leDate = Date.now();

	override public function create():Void
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		#if LUA_ALLOWED
		Paths.pushGlobalMods();
		#end
		// Just to load a mod on start up if ya got one. For mods that change the menu music and bg
		WeekData.loadTheFirstEnabledMod();

		#if FUTURE_POLYMOD
		ModCore.reload();
		#end

		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;
		FlxG.keys.preventDefaultKeys = [TAB];

		PlayerSettings.init();

		curWacky = FlxG.random.getObject(getIntroTextShit());
		gameName = getName();

		// DEBUG BULLSHIT

		swagShader = new ColorSwap();
		super.create();

		FlxG.save.bind('j64enginerewrite', 'joalor64gh');

		ClientPrefs.loadPrefs();

		#if CHECK_FOR_UPDATES
		if(ClientPrefs.checkForUpdates && !closedState) {
			trace('checking for update');
			var http = new haxe.Http("https://raw.githubusercontent.com/Joalor64GH/Joalor64-Engine-Rewrite/main/gitVersion.txt");

			http.onData = function (data:String)
			{
				updateVersion = data.split('\n')[0].trim();
				var curVersion:String = MainMenuState.joalor64EngineVersion.trim();
				trace('version online: ' + updateVersion + ', your version: ' + curVersion);
				if(updateVersion != curVersion) {
					trace('versions arent matching!');
					mustUpdate = true;
				}
			}

			http.onError = function (error) {
				trace('error: $error');
			}

			http.request();
		}
		#end

		Highscore.load();

		// IGNORE THIS!!!
		titleJSON = Json.parse(Paths.getTextFromFile('images/gfDanceTitle.json'));

		if(!initialized)
		{
			if(FlxG.save.data != null && FlxG.save.data.fullscreen)
			{
				FlxG.fullscreen = FlxG.save.data.fullscreen;
			}
			persistentUpdate = true;
			persistentDraw = true;
		}

		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		FlxG.mouse.visible = false;
		#if desktop
		if (!DiscordClient.isInitialized)
		{
			DiscordClient.initialize();
			Application.current.onExit.add (function (exitCode) {
				DiscordClient.shutdown();
			});
		}
		#end
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			startIntro();
		});

		if (!candance)
			candance = true;
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	var swagShader:ColorSwap = null;

	function startIntro()
	{
		if (!initialized)
		{
			if(FlxG.sound.music == null) 
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
			}
		}

		Conductor.changeBPM(titleJSON.bpm);
		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite();

		if (titleJSON.backgroundSprite != null && titleJSON.backgroundSprite.length > 0 && titleJSON.backgroundSprite != "none")
			bg.loadGraphic(Paths.image(titleJSON.backgroundSprite));
		else
			bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);

		add(bg);

		logoBl = new FlxSprite(titleJSON.titlex, titleJSON.titley);
		#if (desktop && MODS_ALLOWED && FUTURE_POLYMOD)
		var path = "mods/" + Paths.currentModDirectory + "/images/logoBumpin.png";
		if (!FileSystem.exists(path))
		{
			path = "mods/images/logoBumpin.png";
		}
		if (!FileSystem.exists(path))
		{
			path = "assets/images/logoBumpin.png";
		}
		logoBl.frames = FlxAtlasFrames.fromSparrow(BitmapData.fromFile(path), File.getContent(StringTools.replace(path, ".png", ".xml")));
		#else
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		#end

		logoBl.antialiasing = ClientPrefs.globalAntialiasing;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();

		swagShader = new ColorSwap();
		gfDance = new FlxSprite(titleJSON.gfx, titleJSON.gfy);

		#if (desktop && MODS_ALLOWED && FUTURE_POLYMOD)
		var path = "mods/" + Paths.currentModDirectory + "/images/GF_assets.png";
		if (!FileSystem.exists(path))
		{
			path = "mods/images/GF_assets.png";
		}
		if (!FileSystem.exists(path))
		{
			path = "assets/images/GF_assets.png";
		}
		gfDance.frames = FlxAtlasFrames.fromSparrow(BitmapData.fromFile(path), File.getContent(StringTools.replace(path, ".png", ".xml")));
		#else
		gfDance.frames = Paths.getSparrowAtlas('GF_assets');
		#end
		gfDance.animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.animation.addByPrefix('Hey', 'GF Cheer', 24, false);

		gfDance.antialiasing = ClientPrefs.globalAntialiasing;

		add(gfDance);
		if (swagShader != null)
			gfDance.shader = swagShader.shader;
		add(logoBl);
		if (swagShader != null)
			logoBl.shader = swagShader.shader;

		titleText = new FlxSprite(titleJSON.startx, titleJSON.starty);
		#if (desktop && MODS_ALLOWED && FUTURE_POLYMOD)
		var path = "mods/" + Paths.currentModDirectory + "/images/titleEnter.png";
		if (!FileSystem.exists(path)){
			path = "mods/images/titleEnter.png";
		}
		if (!FileSystem.exists(path)){
			path = "assets/images/titleEnter.png";
		}
		titleText.frames = FlxAtlasFrames.fromSparrow(BitmapData.fromFile(path),File.getContent(StringTools.replace(path,".png",".xml")));
		#else

		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		#end
		var animFrames:Array<FlxFrame> = [];
		@:privateAccess {
			titleText.animation.findByPrefix(animFrames, "ENTER IDLE");
			titleText.animation.findByPrefix(animFrames, "ENTER FREEZE");
		}
		
		if (animFrames.length > 0) {
			newTitle = true;
			
			titleText.animation.addByPrefix('idle', "ENTER IDLE", 24);
			titleText.animation.addByPrefix('press', ClientPrefs.flashing ? "ENTER PRESSED" : "ENTER FREEZE", 24);
		}
		else {
			newTitle = false;
			
			titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
			titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		}
		
		titleText.antialiasing = ClientPrefs.globalAntialiasing;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		add(titleText);

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "", true);
		credTextShit.screenCenter();

		credTextShit.visible = false;

		psychSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('psych_logo'));
		add(psychSpr);
		psychSpr.visible = false;
		psychSpr.setGraphicSize(Std.int(psychSpr.width * 0.8));
		psychSpr.updateHitbox();
		psychSpr.screenCenter(X);
		psychSpr.antialiasing = ClientPrefs.globalAntialiasing;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = ClientPrefs.globalAntialiasing;

		#if JOALOR64_WATERMARKS
		credIcon1 = new FlxSprite(150,150).loadGraphic(Paths.image('credits/joalor'));
		add(credIcon1);
		credIcon1.antialiasing = ClientPrefs.globalAntialiasing;
		credIcon1.visible = false;

		credIcon2 = new FlxSprite(FlxG.width-300,150).loadGraphic(Paths.image('credits/meme'));
		add(credIcon2);
		credIcon2.antialiasing = ClientPrefs.globalAntialiasing;
		credIcon2.visible = false;
		credIcon2.flipX = true;

		credIcon3 = new FlxSprite(150, -250).loadGraphic(Paths.image('credits/bot'));
		add(credIcon3);
		credIcon3.antialiasing = ClientPrefs.globalAntialiasing;
		credIcon3.visible = false;
		#elseif PSYCH_WATERMARKS
		credIconShadow = new FlxSprite(150,150).loadGraphic(Paths.image('credits/shadowmario'));
		add(credIconShadow);
		credIconShadow.antialiasing = ClientPrefs.globalAntialiasing;
		credIconShadow.visible = false;

		credIconRiver = new FlxSprite(FlxG.width-300,150).loadGraphic(Paths.image('credits/river'));
		add(credIconRiver);
		credIconRiver.antialiasing = ClientPrefs.globalAntialiasing;
		credIconRiver.visible = false;
		credIconRiver.flipX = true;

		credIconShubs = new FlxSprite(150,FlxG.width-300).loadGraphic(Paths.image('credits/shubs'));
		add(credIconShubs);
		credIconShubs.antialiasing = ClientPrefs.globalAntialiasing;
		credIconShubs.visible = false;

		credIconBB = new FlxSprite(FlxG.width-300,FlxG.height-300).loadGraphic(Paths.image('credits/bb'));
		add(credIconBB);
		credIconBB.antialiasing = ClientPrefs.globalAntialiasing;
		credIconBB.visible = false;
		credIconBB.flipX = true;
		#else
		credIconMuff = new FlxSprite(150,150).loadGraphic(Paths.image('credits/ninjamuffin99'));
		add(credIconMuff);
		credIconMuff.antialiasing = ClientPrefs.globalAntialiasing;
		credIconMuff.visible = false;

		credIconPhantom = new FlxSprite(FlxG.width-300,150).loadGraphic(Paths.image('credits/phantomarcade'));
		add(credIconPhantom);
		credIconPhantom.antialiasing = ClientPrefs.globalAntialiasing;
		credIconPhantom.visible = false;
		credIconPhantom.flipX = true;

		credIconKawai = new FlxSprite(150,FlxG.width-300).loadGraphic(Paths.image('credits/kawaisprite'));
		add(credIconKawai);
		credIconKawai.antialiasing = ClientPrefs.globalAntialiasing;
		credIconKawai.visible = false;

		credIconEvil = new FlxSprite(FlxG.width-300,FlxG.height-300).loadGraphic(Paths.image('credits/evilsk8r'));
		add(credIconEvil);
		credIconEvil.antialiasing = ClientPrefs.globalAntialiasing;
		credIconEvil.visible = false;
		credIconEvil.flipX = true;
		#end

		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Joalor64 Engine Rewritten v1.3.0 (PE 0.6.3)", 12);
		#if debug versionShit.text += "DEBUG BUILD"; #end
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		if (initialized)
			skipIntro();
		else
			initialized = true;
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var moddedFullText:String = '';

		#if (MODS_ALLOWED && FUTURE_POLYMOD)
		var path = "mods/" + Paths.currentModDirectory + "/introText.txt";
		if (!FileSystem.exists(path)){
			path = "mods/introText.txt";
		}
		if (!FileSystem.exists(path)){
			path = null;
		}
		if (path != null){
			moddedFullText = File.getContent(path);
		}			
		#end

		// i did this lol
		// me too joalor lol
		var fullText:String = '';

		final dateShit = Paths.txt((leDate.getDay() == 5 && leDate.getHours() >= 18) ? 'fridayText' : 'introText');

		if (Assets.exists(dateShit))
			fullText = Assets.getText(dateShit #if (MODS_ALLOWED && FUTURE_POLYMOD) + (moddedFullText != '' ? '\n' + moddedFullText : '') #end);
		else {
			trace('IntroText could not be found');
			fullText = Assets.exists(Paths.txt('introText')) ? Assets.getText(Paths.txt('introText')) : '';
		}

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
			swagGoodArray.push(i.split('--'));

		return swagGoodArray;
	}

	function getName():Array<String>
	{
		var fullText:String = Assets.getText(Paths.txt('gameName'));

		var firstArray:Array<String> = fullText.split('--');
		return firstArray;
	}

	var transitioning:Bool = false;
	
	var newTitle:Bool = false;
	var titleTimer:Float = 0;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (FlxG.keys.justPressed.ESCAPE)
                {
	            FlxG.sound.music.fadeOut(0.3);
	            FlxG.camera.fade(FlxColor.BLACK, 0.5, false, function()
	            {
		        Sys.exit(0);
	            }, false);
                }

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end
		
		if (newTitle) {
			titleTimer += CoolUtil.boundTo(elapsed, 0, 1);
			if (titleTimer > 2) titleTimer -= 2;
		}

		if (initialized && !transitioning && skippedIntro)
		{
			if (newTitle && !pressedEnter)
			{
				var timer:Float = titleTimer;
				if (timer >= 1)
					timer = (-timer) + 2;
				
				timer = FlxEase.quadInOut(timer);
				
				titleText.color = FlxColor.interpolate(titleTextColors[0], titleTextColors[1], timer);
				titleText.alpha = FlxMath.lerp(titleTextAlphas[0], titleTextAlphas[1], timer);
			}
			
			if(pressedEnter)
			{
				titleText.color = FlxColor.WHITE;
				titleText.alpha = 1;
				
				if(titleText != null) titleText.animation.play('press');

				FlxG.camera.flash(ClientPrefs.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 1);
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
				FlxTween.tween(logoBl, {x: -1500, angle: 10, alpha: 0}, 2, {ease: FlxEase.expoInOut});
				FlxTween.tween(gfDance, {x: -1500}, 3.7, {ease: FlxEase.expoInOut});
				FlxTween.tween(titleText, {y: 1500}, 3.7, {ease: FlxEase.expoInOut});

				transitioning = true;

				gfDance.animation.play('Hey');
				candance = false;
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					if (mustUpdate) {
						MusicBeatState.switchState(new OutdatedState());
					} else {
						MusicBeatState.switchState(new MainMenuState());
					}
					closedState = true;
				});
			}
		}

		if (initialized && pressedEnter && !skippedIntro)
			skipIntro();

		if(swagShader != null)
		{
			if(controls.UI_LEFT) swagShader.hue -= elapsed * 0.1;
			if(controls.UI_RIGHT) swagShader.hue += elapsed * 0.1;
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray.length > 0 ? textArray[i] : 'Placeholder', true);
			money.screenCenter(X);
			money.y += (i * 60) + 200 + offset;
			if(credGroup != null && textGroup != null) {
				credGroup.add(money);
				textGroup.add(money);
			}
		}
	}

	function addMoreText(text:String, ?offset:Float = 0)
	{
		if(textGroup != null && credGroup != null) {
			var coolText:Alphabet = new Alphabet(0, 0, text != '' ? text : 'bruh', true);
			coolText.screenCenter(X);
			coolText.y += (textGroup.length * 60) + 200 + offset;
			credGroup.add(coolText);
			textGroup.add(coolText);
		}
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	private var sickBeats:Int = 0; //Basically curBeat but won't be skipped if you hold the tab or resize the screen
	public static var closedState:Bool = false;

	override function beatHit()
	{
		super.beatHit();

		FlxTween.tween(FlxG.camera, {zoom:1.03}, 0.3, {ease: FlxEase.quadOut, type: BACKWARD});

		if(logoBl != null)
			logoBl.animation.play('bump', true);

		if (candance)
		{
			if(gfDance != null) 
			{
				danceLeft = !danceLeft;
				if (danceLeft)
					gfDance.animation.play('danceRight');
				else
					gfDance.animation.play('danceLeft');
			}
		}

		if(!closedState) {
			sickBeats++;
			switch (sickBeats)
			{
				case 1:
					FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
					FlxG.sound.music.fadeIn(4, 0, 0.7);
				case 2:
					#if JOALOR64_WATERMARKS
					var teamStuff = Assets.getText(Paths.txt('team')).split('--');
					createCoolText(teamStuff);
					credIcon1.visible = true;
					credIcon2.visible = true;
					credIcon3.visible = true;
					#elseif PSYCH_WATERMARKS
 					createCoolText(['Psych Engine by'], 15);
					#else
					createCoolText(['ninjamuffin99', 'PhantomArcade', 'KawaiSprite', 'Evilsk8er']);
					credIconMuff.visible = true;
					credIconPhantom.visible = true;
					credIconKawai.visible = true;
					credIconEvil.visible = true;
					#end
				case 4:
					#if JOALOR64_WATERMARKS
					addMoreText('present to you');
					#elseif PSYCH_WATERMARKS
					addMoreText('ShadowMario', 15);
					addMoreText('RiverOaken', 15);
					addMoreText('Yoshubs', 15);
					addMoreText('BBPanzu', 15);
					credIconShadow.visible = true;
					credIconRiver.visible = true;
					credIconShubs.visible = true;
					credIconBB.visible = true;
					#else
					addMoreText('present');
					#end
				case 5:
					#if JOALOR64_WATERMARKS
					credIcon1.destroy();
					credIcon2.destroy();
					credIcon3.destroy();
					#elseif PSYCH_WATERMARKS
					credIconShadow.destroy();
					credIconRiver.destroy();
					credIconShubs.destroy();
					credIconBB.destroy();
					#else
					credIconMuff.destroy();
					credIconPhantom.destroy();
					credIconKawai.destroy();
					credIconEvil.destroy();
					#end
					deleteCoolText();
				case 6:
					#if JOALOR64_WATERMARKS
					createCoolText(['Powered', 'with'], -40);
					#elseif PSYCH_WATERMARKS
					createCoolText(['Not in association', 'with'], -40);
					#else
					createCoolText(['In association', 'with'], -40);
					#end
				case 8:
				        #if JOALOR64_WATERMARKS
					addMoreText('Psych Engine', -40);
					psychSpr.visible = true;
					#else
					addMoreText('Newgrounds', -40);
					ngSpr.visible = true;
					#end
				case 9:
					deleteCoolText();
					#if JOALOR64_WATERMARKS
					psychSpr.visible = false;
					#else
					ngSpr.visible = false;
					#end
				case 10:
					createCoolText([curWacky[0]]);
				case 12:
					addMoreText(curWacky[1]);
				case 13:
					deleteCoolText();
				case 14:
					addMoreText(gameName[0]);
				case 15:
					addMoreText(gameName[1]);
				case 16:
					addMoreText(gameName[2]); 

				case 17:
					skipIntro();
			}
		}
	}

	var skippedIntro:Bool = false;
	var increaseVolume:Bool = false;
	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(ngSpr);
			remove(psychSpr);
			remove(credGroup);
			#if JOALOR64_WATERMARKS
			credIcon1.destroy();
			credIcon2.destroy();
			credIcon3.destroy();
			#elseif PSYCH_WATERMARKS
			credIconShadow.destroy();
			credIconRiver.destroy();
			credIconShubs.destroy();
			credIconBB.destroy();
			#else
			credIconMuff.destroy();
			credIconPhantom.destroy();
			credIconKawai.destroy();
			credIconEvil.destroy();
			#end

			FlxG.camera.flash(FlxColor.WHITE, 4);

			skippedIntro = true;
		}
	}
}