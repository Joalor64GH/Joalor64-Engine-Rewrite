package objects.background;

class BackgroundGirls extends FlxSprite
{
	var isPissed:Bool = true;

	public var stopDancing:Bool = false;
	public var danceDir(default, set):Bool = false;

	var animSuffix:String = 'Left';

	public function new(x:Float, y:Float)
	{
		super(x, y);

		// BG fangirls dissuaded
		frames = Paths.getSparrowAtlas('stages/school/weeb/bgFreaks');
		if (frames == null){
			trace("Failed to load images for background girls");
			return;
		}	

		swapDanceType();

		animation.play('danceLeft');
	}

	function set_danceDir(dir:Bool):Bool {
		danceDir = dir;
		animSuffix = danceDir ? 'Right' : 'Left';
		return danceDir;
	}

	public function swapDanceType():Void
	{
		isPissed = !isPissed;

		final xmlName:String = isPissed ? 'BG fangirls dissuaded' : 'BG girls group';

		animation.addByIndices('danceLeft', xmlName, CoolUtil.numberArray(14), "", 24, false);
		animation.addByIndices('danceRight', xmlName, CoolUtil.numberArray(30, 15), "", 24, false);

		dance();
	}

	public function dance():Void
	{
		if (stopDancing) return;
		danceDir = !danceDir;
		animation.play('dance$animSuffix', true);
	}
}