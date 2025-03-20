package debug;

import openfl.text.*;
import openfl.events.Event;

class FPS extends TextField {
	public var borderSize:Int = 1;
	public var borders:Array<TextField> = new Array<TextField>();
	
	private var times:Array<Float> = [];

	public function new(x:Float, y:Float, color:Int, ?font:String) {
		super();

		var border:TextField;
		for (i in 0...8) {
			borders.push(border = new TextField());
			border.selectable = false;
			border.mouseEnabled = false;
			border.autoSize = LEFT;
			border.multiline = true;
			border.width = 1280;
			border.height = 720;
		}

		text = "";
		this.x = x;
		this.y = y;
		width = 1280;
		height = 720;
		selectable = false;
		defaultTextFormat = new TextFormat(Paths.font(font ?? 'vcr.ttf'), 16, color);

		addEventListener(Event.ENTER_FRAME, (_) -> {
			final now:Float = Timer.stamp() * 1000;
			times.push(now);
			while (times[0] < now - 1000)
				times.shift();

			var mem:Float = System.totalMemory;
			var memPeak:Float = 0;
			if (mem > memPeak)
				memPeak = mem;

			text = (visible) ? 'FPS: ${times.length}\nMEM: ${FlxStringUtil.formatBytes(mem)} / ${FlxStringUtil.formatBytes(memPeak)}' : '';
			
			textColor = (times.length < FlxG.drawFramerate * 0.5) ? 0xFFFF0000 : 0xFFFFFFFF;
		});

		addEventListener(Event.REMOVED, function(_) {
			for (border in borders)
				this.parent.removeChild(border);
		});

		addEventListener(Event.ADDED, function(_) {
			for (border in borders)
				this.parent.addChildAt(border, this.parent.getChildIndex(this));
		});
	}

	@:noCompletion override function set_visible(value:Bool):Bool {
		for (border in borders)
			border.visible = value;
		return super.set_visible(value);
	}

	@:noCompletion override function set_defaultTextFormat(value:TextFormat):TextFormat {
		for (border in borders) {
			border.defaultTextFormat = value;
			border.textColor = 0xFF000000;
		}
		return super.set_defaultTextFormat(value);
	}

	@:noCompletion override function set_x(x:Float):Float {
		for (i in 0...8)
			borders[i].x = x + ([0, 3, 5].contains(i) ? borderSize : [2, 4, 7].contains(i) ? -borderSize : 0);
		return super.set_x(x);
	}

	@:noCompletion override function set_y(y:Float):Float {
		for (i in 0...8)
			borders[i].y = y + ([0, 1, 2].contains(i) ? borderSize : [5, 6, 7].contains(i) ? -borderSize : 0);
		return super.set_y(y);
	}

	@:noCompletion override function set_text(text:String):String {
		for (border in borders)
			border.text = text;
		return super.set_text(text);
	}
}