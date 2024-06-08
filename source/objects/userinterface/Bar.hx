package objects.userinterface;

import flixel.util.helpers.FlxBounds;

class Bar extends FlxSpriteGroup {
	public var leftBar:FlxSprite;
	public var rightBar:FlxSprite;
	public var bg:FlxSprite;
	public var valueFunction:Void->Float;
	public var percent(default, set):Float = 0;
	public var bounded(default, null):Float = 0;
	public var bounds:FlxBounds<Float> = new FlxBounds<Float>(0, 1);
	public var leftToRight(default, set):Bool = true;
	public var barCenter(default, null):Float = 0;

	public var barWidth(default, set):Int = 1;
	public var barHeight(default, set):Int = 1;
	public var barOffset:FlxPoint = FlxPoint.get(3, 3);

	public function new(x:Float, y:Float, image:String = 'healthBar', ?valueFunction:Void->Float, boundX:Float = 0, boundY:Float = 1) {
		super(x, y);

		this.valueFunction = valueFunction;
		setBounds(boundX, boundY);

		bg = new FlxSprite(Paths.image(image));
		barWidth = Std.int(bg.width - 6);
		barHeight = Std.int(bg.height - 6);

		leftBar = new FlxSprite().makeGraphic(Std.int(bg.width), Std.int(bg.height));
		rightBar = new FlxSprite().makeGraphic(Std.int(bg.width), Std.int(bg.height));
		rightBar.color = FlxColor.BLACK;

		antialiasing = ClientPrefs.globalAntialiasing;

		add(leftBar);
		add(rightBar);
		add(bg);
		regenerateClips();
	}

	public var enabled:Bool = true;
	override function update(elapsed:Float) {
		if(!enabled) {
			super.update(elapsed);
			return;
		}

		var value:Null<Float> = null;
		if(valueFunction != null) {
			bounded = FlxMath.bound(valueFunction(), bounds.min, bounds.max);
			value = FlxMath.remapToRange(bounded, bounds.min, bounds.max, 0, 100);
		}
		percent = (value != null ? value : 0);
		super.update(elapsed);
	}

	override public function destroy() {
		bounds = null;
		barOffset = FlxDestroyUtil.put(barOffset);
		super.destroy();
	}

	public function setBounds(min:Float, max:Float):FlxBounds<Float> {
		return bounds.set(min, max);
	}

	public function setColors(?left:FlxColor, ?right:FlxColor) {
		if (left != null) leftBar.color = left;
		if (right != null) rightBar.color = right;
	}

	public function updateBar() {
		if(leftBar == null || rightBar == null) return;

		leftBar.setPosition(bg.x, bg.y);
		rightBar.setPosition(bg.x, bg.y);

		final leftSize:Float = FlxMath.lerp(0, barWidth, (leftToRight ? percent / 100 : 1 - percent / 100));

        leftBar.clipRect.set(barOffset.x, barOffset.y, leftSize, barHeight);
        rightBar.clipRect.set(barOffset.x + leftSize, barOffset.y, barWidth - leftSize, barHeight);
		barCenter = leftBar.x + leftSize + barOffset.x;

		leftBar.clipRect = leftBar.clipRect;
		rightBar.clipRect = rightBar.clipRect;
	}

	public function regenerateClips() {
		if (leftBar == null && rightBar == null) return;

		final width = Std.int(bg.width);
		final height = Std.int(bg.height);
		if (leftBar != null) {
			leftBar.setGraphicSize(width, height);
			leftBar.updateHitbox();
			if (leftBar.clipRect == null) leftBar.clipRect = FlxRect.get(0, 0, width, height);
			else leftBar.clipRect.set(0, 0, width, height);
		}
		if (rightBar != null) {
			rightBar.setGraphicSize(width, height);
			rightBar.updateHitbox();
			if (rightBar.clipRect == null) rightBar.clipRect = FlxRect.get(0, 0, width, height);
			else rightBar.clipRect.set(0, 0, width, height);
		}
		updateBar();
	}

	function set_percent(value:Float) {
		final doUpdate:Bool = (value != percent);
		percent = value;

		if(doUpdate) updateBar();
		return value;
	}

	function set_leftToRight(value:Bool) {
		leftToRight = value;
		updateBar();
		return value;
	}

	function set_barWidth(value:Int) {
		barWidth = value;
		regenerateClips();
		return value;
	}

	function set_barHeight(value:Int) {
		barHeight = value;
		regenerateClips();
		return value;
	}

	override function set_x(Value:Float):Float {
		final prevX:Float = x;
		super.set_x(Value);
		barCenter += Value - prevX;
		return Value;
	}

	override function set_antialiasing(Antialiasing:Bool):Bool {
		for (member in members)
			member.antialiasing = Antialiasing;
		return antialiasing = Antialiasing;
	}
}