package meta.state.error;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

using StringTools;

typedef MenuSelection =
{
	id:Int,
	text:String
}

class Menu extends FlxSubState
{
	public static var title:String;
	public static var options:Array<String>;
	public static var includeExitBtn:Bool = true;
	public static var callback:MenuSelection->Void;

	var ready:Bool = false;

	var cursor:FlxSprite;

	var uhhhh:Float = 1;

	var maxOptions:Int;
	var currentOption:Int = 0;
	var justPressedEnter:Bool;

	var optionsT = new FlxText(0, 0, 0, "placeholder", 32, true);

	// Bind callback
	public var cb:MenuSelection->Void;

	public override function create()
	{
		openfl.system.System.gc();

		cb = callback.bind(_);

		var titleT = new FlxText(20, 0, 0, title, 40, true);
		titleT.screenCenter(X);
		add(titleT);

		optionsT.alignment = FlxTextAlign.CENTER;
		var tempString = "";
		for (option in options)
			tempString = tempString + option + "\n";

		if (includeExitBtn)
			tempString = tempString + "Exit Menu";

		optionsT.text = tempString;
		optionsT.screenCenter();
		add(optionsT);

		maxOptions = options.length - 1;

		cursor = new FlxSprite().loadGraphic(Paths.image('error/arrow'), false, 512, 512, false);
		cursor.antialiasing = false;
		cursor.setGraphicSize(45);
		cursor.updateHitbox();
		cursor.x = optionsT.x + optionsT.width;
		cursor.y = optionsT.y;

		add(cursor);
		trace('DEBUG SHIT:\nArrow Positions: [${cursor.x}, ${cursor.y}]\nCurrent Menu Options: [${options}]');

		ready = true;
	}

	public override function update(elapsed:Float)
	{
		if (ready)
		{
			// Cursor left/right bop thingy
			cursor.x += Math.sin(uhhhh);
			cursor.setGraphicSize(Std.int(cursor.width += Math.sin(uhhhh))); // very bad but works lmao
			uhhhh += 0.1;

			// Check for input bounds
			if (currentOption < 0)
			{
				currentOption = maxOptions;
				FlxTween.tween(cursor, {y: optionsT.y + (40 * maxOptions)}, 0.2, {ease: FlxEase.quadInOut});
			}
			else if (currentOption > maxOptions)
			{
				currentOption = 0;
				FlxTween.tween(cursor, {y: optionsT.y}, 0.2, {ease: FlxEase.quadInOut});
			}

			// Start accepting input here.
			if (FlxG.keys.justPressed.UP && !justPressedEnter && currentOption >= 0 && currentOption <= maxOptions)
			{
				currentOption--;
				moveArrowUp();
			}
			else if (FlxG.keys.justPressed.DOWN && !justPressedEnter && currentOption >= 0 && currentOption <= maxOptions)
			{
				currentOption++;
				moveArrowDown();
			}
			else if (FlxG.keys.justPressed.ENTER && !justPressedEnter && currentOption >= 0 && currentOption <= maxOptions)
			{
				// Close Menu action
				flashArrow();
				justPressedEnter = true; // lock inputs
				FlxG.sound.play(Paths.sound('confirmMenu'));
				new FlxTimer().start(2, doAction, 1);
			}
		}
	}

	// Arrow logic or smth
	inline function moveArrowDown()
	{
		FlxTween.tween(cursor, {y: cursor.y + 40}, 0.2, {ease: FlxEase.quadInOut});
	}

	inline function moveArrowUp()
	{
		FlxTween.tween(cursor, {y: cursor.y - 40}, 0.2, {ease: FlxEase.quadInOut});
	}

	inline function flashArrow()
	{
		new FlxTimer().start(0.1, (timer:FlxTimer) -> {cursor.visible = !cursor.visible;}, 0);
	}

	inline function doAction(?timer:FlxTimer)
	{
		trace("eugh");
		if (includeExitBtn && currentOption == maxOptions)
			close();
		else
		{
			cb({id: currentOption, text: splitText(currentOption)});
			close();
		}
	}

	inline function splitText(returnOption:Int)
	{
		final tempArray = optionsT.text.trim().split('\n');
		return tempArray[returnOption].trim();
	}
}