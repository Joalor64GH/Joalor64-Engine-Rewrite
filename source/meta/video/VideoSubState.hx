package meta.video;

class VideoSubState extends MusicBeatSubstate
{
	var leSource:String = "";

	var txt:FlxText;
	var vidSound:FlxSound = null;
	var pauseText:String = "Press P To Pause/Unpause";

	var holdTimer:Int = 0;
	var crashMoment:Int = 0;
	var itsTooLate:Bool = false;
	var skipTxt:FlxText;

	var onComplete:Void->Void;

	public function new(source:String, ?onComplete:Void->Void):Void
	{
		super();
		
		this.leSource = source;
		this.onComplete = onComplete;
	}
	
	public override function create():Void
	{
		super.create();

		if (FlxG.sound.music != null)
			FlxG.sound.music.pause();

		var isHTML:Bool = #if web true #else false #end;

		var bg:FlxSprite = new FlxSprite();
		bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		txt = new FlxText(0, 0, FlxG.width,
			"If Your On HTML5\nTap Anything...\nThe Bottom Text Indicates If You\nAre Using HTML5...\n\n" +
			(isHTML ? "You Are Using HTML5!" : "You Are Not Using HTML5...\nThe Video Didnt Load!"),
			32);
		txt.setFormat(Paths.getFont('vcr.ttf'), 32, FlxColor.WHITE, CENTER);
		txt.screenCenter();
		add(txt);

		skipTxt = new FlxText(FlxG.width / 1.5, FlxG.height - 50, FlxG.width, 'hold ANY KEY to skip', 32);
		skipTxt.setFormat(Paths.getFont('vcr.ttf'), 32, FlxColor.WHITE, LEFT);

		if (GlobalVideo.isWebm)
			if (Paths.fileExists(Paths.webmSound(leSource)))
				vidSound = FlxG.sound.play(Paths.webmSound(leSource), 1, false, null, true);

		var ourVideo:Dynamic = GlobalVideo.get();
		ourVideo.source(Paths.webm(leSource));

		if (ourVideo == null)
		{
			end();
			return;
		}

		ourVideo.clearPause();

		if (GlobalVideo.isWebm)
			ourVideo.updatePlayer();

		ourVideo.show();

		if (GlobalVideo.isWebm) ourVideo.restart();
		else ourVideo.play();

		add(skipTxt);

		if (!PlayState.seenCutscene)
			PlayState.seenCutscene = true;

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	public override function update(elapsed:Float):Void
	{
		var ourVideo:Dynamic = GlobalVideo.get();

		if (ourVideo == null)
		{
			end();
			return;
		}

		ourVideo.update(elapsed);

		if (ourVideo.ended || ourVideo.stopped)
		{
			txt.visible = false;
			skipTxt.visible = false;

			ourVideo.hide();
			ourVideo.stop();
		}

		if (crashMoment > 0) crashMoment--;

		if (FlxG.keys.pressed.ANY && crashMoment <= 0 || itsTooLate && FlxG.keys.pressed.ANY)
		{
			holdTimer++;

			crashMoment = 16;
			itsTooLate = true;
	
			FlxG.sound.music.volume = 0;
			ourVideo.alpha();
	
			txt.visible = false;
	
			if (holdTimer > 100)
			{
				skipTxt.visible = false;
				ourVideo.stop();

				end();
				return;
			}
		}
		else if (!ourVideo.paused)
		{
			ourVideo.unalpha();

			holdTimer = 0;
			itsTooLate = false;
		}
		
		if (ourVideo.ended)
		{
			end();
			return;
		}

		if (ourVideo.played || ourVideo.restarted)
			ourVideo.show();

		ourVideo.restarted = false;
		ourVideo.played = false;

		ourVideo.stopped = false;
		ourVideo.ended = false;

		super.update(elapsed);
	}

	public function end():Void
	{
		txt.text = pauseText;

		if (vidSound != null)
			vidSound.destroy();

		close();

		if (onComplete != null)
			onComplete();
	}
}