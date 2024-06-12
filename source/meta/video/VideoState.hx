package meta.video;

// CAN BE USED ANYWHERE
class VideoState extends MusicBeatState
{
	var leSource:String = "";
	var vidSound:FlxSound = null;

	var holdTimer:Int = 0;
	var crashMoment:Int = 0;
	var itsTooLate:Bool = false;

	var onComplete:Void->Void;

	public function new(source:String, ?onComplete:Void->Void):Void
	{
		super();
		
		this.leSource = source;
		this.onComplete = onComplete;
	}
	
	override public function create():Void
	{
		super.create();

		if (FlxG.sound.music != null)
			FlxG.sound.music.pause();

		var bg:FlxSprite = new FlxSprite();
		bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		if (GlobalVideo.isWebm)
		{
			if (Paths.fileExists('videos/$leSource.ogg'))
				vidSound = FlxG.sound.play(Paths.webmSound(leSource), 1, false, null, true);
		}

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

		if (GlobalVideo.isWebm)
			ourVideo.restart();
		else
			ourVideo.play();
	}

	override public function update(elapsed:Float):Void
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
			ourVideo.hide();
			ourVideo.stop();
		}

		if (crashMoment > 0) crashMoment--;

		if (FlxG.keys.pressed.ANY && crashMoment <= 0 || itsTooLate)
		{
			holdTimer++;

			crashMoment = 16;
			itsTooLate = true;
	
			FlxG.sound.music.volume = 0;
			ourVideo.alpha();
	
			if (holdTimer > 100)
			{
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
		if (vidSound != null)
			vidSound.destroy();

		if (onComplete != null)
			onComplete();
	}
}