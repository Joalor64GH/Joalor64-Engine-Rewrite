package minigames;

import flixel.system.FlxAssets.FlxGraphicAsset;

class Card extends FlxSprite
{
	public var index(default, null):Int;

	public function new(_index, ?x:Float = 0, ?y:Float = 0, ?SimpleGraphic:FlxGraphicAsset)
	{
		var _fr:Int = 1;
		super(x, y, SimpleGraphic);

		index = _index;

		loadGraphic("assets/images/minigames/cards.png", true, 96, 160);

		animation.add("back", [0], _fr, false);
		animation.add("front", [index], _fr, false);
	}

	public function flip()
	{
		FlxTween.tween(this.scale, {x: .1, y: 1}, .1, {onComplete: flip2});
	}

	public function flip2(tween:FlxTween):Void
	{
		animation.play("front", true);
		FlxTween.tween(this.scale, {x: 1, y: 1}, .1);
	}

	public function flipBack()
	{
		FlxTween.tween(this.scale, {x: .1, y: 1}, .1, {onComplete: flipBack2});
	}

	public function flipBack2(tween:FlxTween):Void
	{
		animation.play("back", true);
		FlxTween.tween(this.scale, {x: 1, y: 1}, .1);
	}
}