package meta.video;

import flixel.sound.FlxSound;

import openfl.Lib;
import openfl.Assets;
import openfl.display.Sprite;
import openfl.display.MovieClip;
import openfl.events.Event;

class SWF extends Sprite {
	public var clip:MovieClip;

	private var barLeft:Sprite;
	private var barRight:Sprite;

	public function new(movieClip:String, sound:String, onComplete:Void->Void):Void {
		super();

		barLeft = new Sprite();
		barRight = new Sprite();

		var audio:FlxSound = new FlxSound().loadEmbedded(sound);
		Assets.loadLibrary('$movieClip').onComplete((_) -> {
			clip = Assets.getMovieClip('$movieClip:');
			addChild(clip);

			addChild(barLeft);
			addChild(barRight);

			audio.onComplete = () -> {
				onComplete();
				removeChild(clip);
				(cast(Lib.current.getChildAt(0), Main)).removeChild(this);
			};

			if (audio != null)
				audio.play();
		});

		(cast(Lib.current.getChildAt(0), Main)).addChild(this);

		addEventListener(Event.ENTER_FRAME, onResize);
	}

	function onResize(_):Void {
		var width:Int = FlxG.stage.stageWidth;
		var height:Int = FlxG.stage.stageHeight;

		if (clip != null)
			width > height ? clip.scaleX = clip.scaleY = height / 720 : clip.scaleY = clip.scaleX = width / 1280;

		screenCenter();
	}

	public function screenCenter() {
		var ratio:Float = FlxG.width / FlxG.height;
		var realRatio:Float = FlxG.stage.stageWidth / FlxG.stage.stageHeight;
		var preX:Float = 0;

		preX = Math.floor(FlxG.stage.stageHeight * ratio);

		if (clip != null)
			clip.x = Math.ceil((FlxG.stage.stageWidth - preX) * 0.5);

		barLeft.graphics.clear();
		barRight.graphics.clear();
		barLeft.graphics.beginFill();
		barRight.graphics.beginFill();
		barLeft.graphics.drawRect(0, 0, clip.x, FlxG.stage.stageHeight);
		barRight.graphics.drawRect(FlxG.stage.stageWidth - clip.x, 0, clip.x, FlxG.stage.stageHeight);
	}
}