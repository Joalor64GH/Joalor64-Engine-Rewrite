package meta.data;

import meta.*;
import flixel.*;
import flixel.addons.ui.FlxUIInputText;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using StringTools;

/**
 * @author bbpanzu
 * @see https://github.com/bbpanzu/vswhitty-public
 */

class PasswordPrompt extends meta.MusicBeatSubstate
{
	var input:FlxUIInputText;

	public function new() 
	{
		super();

		var black:FlxSprite = new FlxSprite(0, 0).makeGraphic(1280, 400,FlxColor.BLACK);
		black.screenCenter();

		var txt:FlxText = new FlxText(0, 0, 0, "Enter Password", 32);
		txt.screenCenter();
		input = new FlxUIInputText(10, 10, FlxG.width, '', 8);
		input.setFormat(Paths.font("vcr.ttf"), 96, FlxColor.WHITE,FlxTextAlign.CENTER);
		input.alignment = CENTER;
		input.setBorderStyle(OUTLINE, 0xFF000000, 5, 1);
		input.screenCenter();
		input.y += 50;
        	input.scrollFactor.set();
		add(black);
		add(txt);
		add(input);
        	input.backgroundColor = 0xFF000000;
        	input.maxLength = 15;
        	input.lines = 1;
        	input.caretColor = 0xFFFFFFFF;
		FlxG.mouse.visible = true;
	}

	override function update(elapsed:Float) 
	{
		super.update(elapsed);
        	input.hasFocus = true;

		if (controls.ACCEPT){
            		// add custom functions here
			FlxG.state.closeSubState();
		}
		if (controls.BACK){
			FlxG.mouse.visible = false;
			FlxG.state.closeSubState();
		}
	}
}
