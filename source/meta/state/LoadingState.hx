package meta.state;

class LoadingState extends MusicBeatState
{
	inline static final MIN_TIME = 1.0;
	
	var target:FlxState = null;
	var stopMusic = false;

	function new(target:FlxState, stopMusic:Bool)
	{
		super();
		
		this.target = target;
		this.stopMusic = stopMusic;
	}

	var funkay:FlxSprite;
	var loadBar:FlxSprite;

	override function create()
	{
		var bg:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xffcaff4d);
		add(bg);
		
		funkay = new FlxSprite(0, 0).loadGraphic(Paths.getPath('images/funkay.png'));
		funkay.antialiasing = ClientPrefs.globalAntialiasing;
		funkay.setGraphicSize(0, FlxG.height);
		funkay.updateHitbox();
		funkay.scrollFactor.set();
		funkay.screenCenter();
		add(funkay);

		loadBar = new FlxSprite(0, FlxG.height - 20).makeGraphic(FlxG.width, 10, 0xffff16d2);
		loadBar.antialiasing = ClientPrefs.globalAntialiasing;
		loadBar.screenCenter(X);
		add(loadBar);

		super.create();
	}

	override function update(elapsed:Float)
	{
		funkay.setGraphicSize(Std.int(0.88 * FlxG.width + 0.9 * (funkay.width - 0.88 * FlxG.width)));
		funkay.updateHitbox();

		if (controls.ACCEPT)
		{
			funkay.setGraphicSize(Std.int(funkay.width + 60));
			funkay.updateHitbox();
		}

		super.update(elapsed);
	}
	
	function onLoad()
	{
		var fadeTime = 0.5;
		
		FlxG.camera.fade(FlxG.camera.bgColor, fadeTime, true);

		new FlxTimer().start(fadeTime + MIN_TIME, (_) -> {
			if (stopMusic)
			{
				if (FlxG.sound.music != null)
					FlxG.sound.music.stop();
			}
			MusicBeatState.switchState(target);
		});
	}

	override function destroy()
	{
		super.destroy();
	}

	inline static public function loadAndSwitchState(target:FlxState, stopMusic = false)
	{
		MusicBeatState.switchState(getNextState(target, stopMusic));
	}

	inline static public function loadAndResetState(stopMusic = false)
	{
		loadAndSwitchState(FlxG.state, stopMusic);
	}
	
	static function getNextState(target:FlxState, stopMusic = false):FlxState
	{
		if (stopMusic)
		{
			if (FlxG.sound.music != null)
				FlxG.sound.music.stop();
		}
		
		return target;
	}
}