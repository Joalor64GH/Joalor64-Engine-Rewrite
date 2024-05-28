package debug;

class FPS extends TextField
{
	var times:Array<Float> = [];

	public function new(x:Float, y:Float, color:Int, ?font:String)
	{
		super();

		text = "";
		this.x = x;
		this.y = y;
		width = 1280;
		height = 720;
		selectable = false;
		defaultTextFormat = new TextFormat(Paths.font((font != null) ? font : 'vcr.ttf'), 18, 0xFFFFFF);
		alpha = 0.8; // to see things from the back better

		addEventListener(openfl.events.Event.ENTER_FRAME, (_) ->
		{
			final now:Float = haxe.Timer.stamp() * 1000;
			times.push(now);
			while (times[0] < now - 1000) times.shift();

			var mem:Float = System.totalMemory;
			var memPeak:Float = 0;
			if (mem > memPeak) memPeak = mem;
			
			text = (visible) ? 
				'FPS: ${times.length}\nMemory: ${FlxStringUtil.formatBytes(mem)} / ${FlxStringUtil.formatBytes(memPeak)}' : '';

			textColor = (times.length < FlxG.drawFramerate * 0.5) ? 0xFFFF0000 : 0xFFFFFFFF;
		});
	}
}