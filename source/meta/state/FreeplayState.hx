package meta.state;

import flixel.sound.FlxSound;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	private static var curSelected:Int = 0;
	var curDifficulty:Int = -1;
	private static var lastDifficultyName:String = '';

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	public static var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	var bg:FlxSprite;
	var intendedColor:Int;
	var colorTween:FlxTween;

	var colorArray:Array<FlxColor> = [
		FlxColor.fromRGB(0, 255, 0), // green
		FlxColor.fromRGB(255, 255, 0), // yellow
		FlxColor.fromRGB(255, 0, 0), // red
	];
	var diffTween:FlxTween;

	var repText:FlxText;

	var missingText:FlxText;
	var missingBG:FlxSprite;

	override function create()
	{
		Application.current.window.title = Application.current.meta.get('name');

		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		#if sys
		ArtemisIntegration.setGameState ("menu");
		ArtemisIntegration.resetModName ();
		#end

		if (WeekData.weeksList.length < 1)
		{
			FlxTransitionableState.skipNextTransIn = true;
			persistentUpdate = false;
			MusicBeatState.switchState(new ErrorState("NO WEEKS ADDED FOR FREEPLAY\n\nPress ACCEPT to go to the Week Editor Menu.\nPress BACK to return to Main Menu.",
				function() MusicBeatState.switchState(new WeekEditorState()),
				function() MusicBeatState.switchState(new MainMenuState())));
			return;
		}

		for (i in 0...WeekData.weeksList.length) {
			if(weekIsLocked(WeekData.weeksList[i])) continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];

			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				var colors:Array<Int> = song[2];
				if(colors == null || colors.length < 3)
					colors = [146, 113, 253];

				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
			}
		}
		Mods.loadTheFirstEnabledMod();

		if (!curPlaying) Conductor.bpm = TitleState.titleJSON.bpm;

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);
		bg.screenCenter();

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
		grid.velocity.set(40, 40);
		grid.alpha = 0;
		FlxTween.tween(grid, {alpha: 0.6}, 0.5, {ease: FlxEase.quadOut});
		add(grid);

			var slash:FlxSprite = new FlxSprite().loadGraphic(Paths.image('minigames/slash'));
		slash.antialiasing = ClientPrefs.globalAntialiasing;
		slash.flipX = (ClientPrefs.songDisplay == 'C-Shape') ? true : false;
		slash.screenCenter();
		add(slash);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(90, 320, songs[i].songName, true);
			songText.isMenuItem = true;
			switch (ClientPrefs.songDisplay)
			{
				case 'Classic':
					songText.itemType = 'Classic';

				case 'Vertical':
					songText.itemType = 'Vertical';

				case 'C-Shape':
					songText.itemType = 'C-Shape';

				case 'D-Shape':
					songText.itemType = 'D-Shape';
			}
			songText.targetY = i - curSelected;
			grpSongs.add(songText);

			var maxWidth = 980;
			if (songText.width > maxWidth)
				songText.scaleX = maxWidth / songText.width;

			Mods.currentModDirectory = songs[i].folder;
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);
		}
		WeekData.setDirectoryFromWeek();

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 92, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		repText = new FlxText(FlxG.width * 0.7 - 270, scoreText.y + 65, 600, "", 20);
		repText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT);
		add(repText);

		if(curSelected >= songs.length) curSelected = 0;
		bg.color = songs[curSelected].color;
		intendedColor = bg.color;

		#if sys
		ArtemisIntegration.setBackgroundFlxColor (intendedColor);
		#end

		if (lastDifficultyName == '')
			lastDifficultyName = CoolUtil.defaultDifficulty;

		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficultyName)));

		if (curPlaying)
			iconArray[instPlaying].canBounce = true;
		
		changeSelection();
		changeDiff();

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

		var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, "Press SPACE to listen to the Song / Press CTRL to open the Gameplay Changers Menu / Press R to Reset your Score and Accuracy.", 16);
		text.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT);
		text.scrollFactor.set();
		add(text);

		missingBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		missingBG.alpha = 0;
		add(missingBG);

		missingText = new FlxText(0, 0, 0, '', 72);
		missingText.scrollFactor.set();
		missingText.setFormat("VCR OSD Mono", 60, FlxColor.RED, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		missingText.screenCenter(XY);
		missingText.alpha = 0;
		add(missingText);

		super.create();
	}

	override function closeSubState() {
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();
	}

	// in case your mod uses a freeplay category system
	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color));

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>, weekColor:Int)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num], weekColor);
			this.songs[this.songs.length-1].color = weekColor;

			if (songCharacters.length != 1)
				num++;
		}
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	public static var instPlaying:Int = -1;
	public static var vocals:FlxSound = null;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		
		if (FlxG.sound.music.volume < 0.7)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, CoolUtil.boundTo(elapsed * 12, 0, 1));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(Highscore.floorDecimal(lerpRating * 100, 2)).split('.');
		if(ratingSplit.length < 2) //No decimals, add an empty space
			ratingSplit.push('');
		
		while(ratingSplit[1].length < 2) //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';

		scoreText.text = 'PERSONAL BEST: ' + lerpScore + ' (' + ratingSplit.join('.') + '%)';
		positionHighscore();

		repText.text = 'Press ALT to show the replays of ${songs[curSelected].songName.toUpperCase()}';

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;
		var space = FlxG.keys.justPressed.SPACE;
		var ctrl = FlxG.keys.justPressed.CONTROL;
		var alt =  FlxG.keys.justPressed.ALT;

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

		if(songs.length > 1 && (upP || downP))
		{
			if (upP)
			{
				changeSelection(-shiftMult);
				holdTime = 0;
			}
			if (downP)
			{
				changeSelection(shiftMult);
				holdTime = 0;
			}

			var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
			holdTime += elapsed;
			var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

			if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
			{
				changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
				changeDiff();
			}

			if(FlxG.mouse.wheel != 0)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
				changeSelection(-shiftMult * FlxG.mouse.wheel, false);
				changeDiff();
			}
		}

		if (controls.UI_LEFT_P)
			changeDiff(-1);
		else if (controls.UI_RIGHT_P)
			changeDiff(1);
		else if (upP || downP) changeDiff();
		#if sys 
		else if (alt && ClientPrefs.saveReplay) 
			MusicBeatState.switchState(new ReplaySelectState(songs[curSelected].songName)); 
		#end

		if (controls.BACK)
		{
			persistentUpdate = false;
			if(colorTween != null) {
				colorTween.cancel();
			}
			FlxG.sound.play(Paths.sound('cancelMenu'));
			if (ClientPrefs.simpleMain)
				MusicBeatState.switchState(new SimpleMainMenuState());
			else
				MusicBeatState.switchState(new MainMenuState());
		}

		if(ctrl)
		{
			persistentUpdate = false;
			openSubState(new GameplayChangersSubstate());
		}
		else if(space)
		{
			if(instPlaying != curSelected)
			{
				destroyFreeplayVocals();
				FlxG.sound.music.volume = 0;
				Mods.currentModDirectory = songs[curSelected].folder;
				var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
				PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
				if (PlayState.SONG.needsVoices)
					vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
				else
					vocals = new FlxSound();

				FlxG.sound.list.add(vocals);
				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.7);
				vocals.play();
				vocals.persist = true;
				vocals.looped = true;
				vocals.volume = 0.7;
				instPlaying = curSelected;
				Conductor.bpm = PlayState.SONG.bpm;
				for (i in 0...iconArray.length)
					iconArray[i].canBounce = false;
				iconArray[instPlaying].canBounce = true;
				curPlaying = true;
			}
		}
		else if (accepted)
		{
			try 
			{
				persistentUpdate = false;
				var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
				var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
				trace(poop);

				PlayState.SONG = Song.loadFromJson(poop, songLowercase);
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = curDifficulty;

				trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
				if(colorTween != null)
					colorTween.cancel();

				curPlaying = false;
			
				if (FlxG.keys.pressed.SHIFT)
					LoadingState.loadAndSwitchState(new ChartingState());
				else
					LoadingState.loadAndSwitchState(new PlayState());

				FlxG.sound.music.volume = 0;
				FlxG.sound.play(Paths.sound('storySelect'));
				destroyFreeplayVocals();
				return;
			}
			catch(e:Dynamic)
			{
				var errorStr:String = e.toString();
				if(errorStr.startsWith('[file_contents,assets/data/')) 
					errorStr = 'Missing file: ' + errorStr.substring(34, errorStr.length-1); //Missing chart
				
				missingText.text = 'ERROR LOADING CHART:\n$errorStr';

				FlxTween.tween(missingBG, {alpha: 0.5}, 0.75, {ease: FlxEase.quadOut});
				FlxTween.tween(missingText, {alpha: 1}, 1, {ease: FlxEase.quadOut});

				// please ignore this god awful code :skull:
				new FlxTimer().start(3, function(tmr:FlxTimer)
				{
					FlxTween.tween(missingBG, {alpha: 0}, 1, {ease: FlxEase.quadOut});
					FlxTween.tween(missingText, {alpha: 0}, 1, {ease: FlxEase.quadOut});

					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						missingText.text = '';
					});
				});

				FlxG.sound.play(Paths.sound('cancelMenu'));

				super.update(elapsed);
				return;
			}
		}
		else if(controls.RESET)
		{
			persistentUpdate = false;
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
		super.update(elapsed);

		for (icon in iconArray) icon.y = icon.sprTracker.y - 36;
	}

	override function beatHit() {
		super.beatHit();

		if (curPlaying)
			iconArray[instPlaying].bounce();
	}

	public static function destroyFreeplayVocals() {
		if(vocals != null) {
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficulties.length-1;
		if (curDifficulty >= CoolUtil.difficulties.length)
			curDifficulty = 0;

		lastDifficultyName = CoolUtil.difficulties[curDifficulty];

		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);

		PlayState.storyDifficulty = curDifficulty;
		diffText.text = '< ' + CoolUtil.difficultyString() + ' >';

		if (diffTween != null)
			diffTween.cancel();

		if (diffText.color != colorArray[curDifficulty])
			diffTween = FlxTween.color(diffText, 0.3, diffText.color, colorArray[curDifficulty], {
				onComplete: function(twn) diffTween = null
			});

		positionHighscore();
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected = FlxMath.wrap(curSelected + change, 0, songs.length - 1);
			
		var newColor:Int = songs[curSelected].color;
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			#if sys
			ArtemisIntegration.setBackgroundFlxColor (intendedColor);
			#end
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);

		// TO-DO: Not make 5 icons look weird in Freeplay
		for (i in 0...iconArray.length)
			iconArray[i].alpha = 0.6;

		iconArray[curSelected].alpha = 1;

		for (num => item in grpSongs.members)
		{
			item.targetY = num - curSelected;
			item.alpha = (item.targetY == 0) ? 1 : 0.6;
		}
		
		Mods.currentModDirectory = songs[curSelected].folder;
		PlayState.storyWeek = songs[curSelected].week;

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		var diffStr:String = WeekData.getCurrentWeek().difficulties;
		if(diffStr != null) diffStr = diffStr.trim(); //Fuck you HTML5

		if(diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if(diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if(diffs[i].length < 1) diffs.remove(diffs[i]);
				}
				--i;
			}

			if(diffs.length > 0 && diffs[0].length > 0)
				CoolUtil.difficulties = diffs;
		}
		
		if(CoolUtil.difficulties.contains(CoolUtil.defaultDifficulty))
			curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(CoolUtil.defaultDifficulty)));
		else
			curDifficulty = 0;

		var newPos:Int = CoolUtil.difficulties.indexOf(lastDifficultyName);
		if(newPos > -1)
			curDifficulty = newPos;
	}

	private function positionHighscore() {
		scoreText.x = FlxG.width - scoreText.width - 6;

		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
		diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
		diffText.x -= diffText.width / 2;
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";

	public function new(song:String, week:Int, songCharacter:String, color:Int)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Mods.currentModDirectory;
		if(this.folder == null) this.folder = '';
	}
}