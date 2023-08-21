package meta.data.options;

#if desktop
import meta.data.dependency.Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.math.FlxMath;
import flixel.ui.FlxButton;

import meta.*;
import meta.data.*;
import meta.data.alphabet.*;
import meta.data.options.*;

import objects.*;
import objects.shaders.*;
import objects.userinterface.menu.*;

using StringTools;

class NotesSubState extends MusicBeatSubstate
{
	private static var curSelected:Int = 0;
	private static var typeSelected:Int = 0;
	private var grpNumbers:FlxTypedGroup<Alphabet>;
	private var grpNotes:FlxTypedGroup<FlxSprite>;
	private var shaderArray:Array<ColorMask> = [];
	public var defaultColors:Array<Array<Int>> = [
		[194, 75, 153], 
		[0, 255, 255], 
		[18, 250, 5], 
		[249, 57, 63]
	];
	var curValue:Float = 0;
	var holdTime:Float = 0;
	var nextAccept:Int = 5;

	var angleTween:FlxTween;
	var scaleTween:FlxTween;

	var btn1:FlxButton;
	var btn2:FlxButton;
	var btn3:FlxButton;
	var btn4:FlxButton;
	var btn5:FlxButton;
	var btn6:FlxButton;
	var btn7:FlxButton;
	var btn8:FlxButton;

	var blackBG:FlxSprite;
	var rgbText:Alphabet;
	var posX = 230;
	public function new() 
	{
		super();

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xFFea71fd;
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		blackBG = new FlxSprite(posX - 25).makeGraphic(1140, 200, FlxColor.BLACK);
		blackBG.alpha = 0.4;
		add(blackBG);

		grpNotes = new FlxTypedGroup<FlxSprite>();
		add(grpNotes);
		grpNumbers = new FlxTypedGroup<Alphabet>();
		add(grpNumbers);

		for (i in 0...ClientPrefs.arrowRGB.length) {
			var yPos:Float = (80 * i) - 40;
			for (j in 0...3) {
				var optionText:Alphabet = new Alphabet(0, yPos + 60, Std.string(ClientPrefs.arrowRGB[i][j]), true);
				optionText.x = posX + (225 * j) + 250;
				optionText.ID = i;
				grpNumbers.add(optionText);
			}

			var note:FlxSprite = new FlxSprite(posX, yPos);
			note.frames = Paths.getSparrowAtlas('NOTE_assets');
			var animations:Array<String> = ['purple0', 'blue0', 'green0', 'red0'];
			note.animation.addByPrefix('idle', animations[i]);
			note.animation.play('idle');
			note.antialiasing = ClientPrefs.globalAntialiasing;
			note.ID = i;
			grpNotes.add(note);

			var newShader:ColorMask = new ColorMask();
			note.shader = newShader.shader;
			newShader.rCol = FlxColor.fromRGB(ClientPrefs.arrowRGB[i][0], ClientPrefs.arrowRGB[i][1], ClientPrefs.arrowRGB[i][2]);
			newShader.gCol = newShader.rCol.getDarkened(0.6);
			shaderArray.push(newShader);
		}

		btn1 = new FlxButton(15, 40, "Joalor64", () ->
		{
			ClientPrefs.arrowRGB = [
				[89, 0, 153], 
				[0, 255, 255], 
				[18, 255, 175], 
				[223, 0, 118]
			];
			updateValue();
			// updateAll();
			ClientPrefs.saveSettings();
        	});
		btn1.scale.set(1.5, 1.5);
		btn1.color = 0x7b2977;
		btn1.label.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		btn1.label.screenCenter(XY);
		btn1.updateHitbox();
		add(btn1);

		btn2 = new FlxButton(15, btn1.y + 50, "Vibrant", () ->
		{
			ClientPrefs.arrowRGB = [
				[250, 52, 15], 
				[255, 255, 3], 
				[30, 252, 42], 
				[0, 192, 255]
			];
			updateValue();
			// updateAll();
			ClientPrefs.saveSettings();
        	});
		btn2.scale.set(1.5, 1.5);
		btn2.color = 0xfff700;
		btn2.label.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		btn2.label.screenCenter(XY);
		btn2.updateHitbox();
		add(btn2);

		btn3 = new FlxButton(15, btn2.y + 50, "Warm", () ->
		{
			ClientPrefs.arrowRGB = [
				[135, 0, 9], 
				[179, 0, 65], 
				[215, 0, 138], 
				[237, 48, 205]
			];
			updateValue();
			// updateAll();
			ClientPrefs.saveSettings();
        	});
		btn3.scale.set(1.5, 1.5);
		btn3.color = 0xac415e;
		btn3.label.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		btn3.label.screenCenter(XY);
		btn3.updateHitbox();
		add(btn3);

		btn4 = new FlxButton(15, btn3.y + 50, "Cold", () ->
		{
			ClientPrefs.arrowRGB = [
				[0, 229, 75], 
				[0, 212, 176], 
				[0, 183, 216], 
				[24, 138, 240]
			];
			updateValue();
			// updateAll();
			ClientPrefs.saveSettings();
        	});
		btn4.scale.set(1.5, 1.5);
		btn4.color = 0x417ea3;
		btn4.label.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		btn4.label.screenCenter(XY);
		btn4.updateHitbox();
		add(btn4);

		btn5 = new FlxButton(15, btn4.y + 50, "Cum", () ->
		{
			ClientPrefs.arrowRGB = [
				[255, 255, 255], 
				[255, 255, 255], 
				[255, 255, 255], 
				[255, 255, 255]
			];
			updateValue();
			// updateAll();
			ClientPrefs.saveSettings();
        	});
		btn5.scale.set(1.5, 1.5);
		btn5.color = 0xffffff;
		btn5.label.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		btn5.label.screenCenter(XY);
		btn5.updateHitbox();
		add(btn5);

		btn6 = new FlxButton(15, btn5.y + 50, "Void", () ->
		{
			ClientPrefs.arrowRGB = [
				[0, 0, 0], 
				[0, 0, 0], 
				[0, 0, 0], 
				[0, 0, 0]
			];
			updateValue();
			// updateAll();
			ClientPrefs.saveSettings();
        	});
		btn6.scale.set(1.5, 1.5);
		btn6.color = 0x000000;
		btn6.label.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		btn6.label.screenCenter(XY);
		btn6.updateHitbox();
		add(btn6);

		btn7 = new FlxButton(15, btn6.y + 50, "DDR", () ->
		{
			ClientPrefs.arrowRGB = [
				[255, 124, 232], 
				[0, 255, 255], 
				[0, 255, 255], 
				[255, 124, 232]
			];
			updateValue();
			// updateAll();
			ClientPrefs.saveSettings();
        	});
		btn7.scale.set(1.5, 1.5);
		btn7.color = 0xea00ff;
		btn7.label.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		btn7.label.screenCenter(XY);
		btn7.updateHitbox();
		add(btn7);

		btn8 = new FlxButton(15, btn7.y + 50, "Pastel", () ->
		{
			ClientPrefs.arrowRGB = [
				[186, 144, 198], 
				[192, 219, 234], 
				[221, 255, 187], 
				[242, 190, 209]
			];
			updateValue();
			// updateAll();
			ClientPrefs.saveSettings();
        	});
		btn8.scale.set(1.5, 1.5);
		btn8.color = 0xa26dad;
		btn8.label.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		btn8.label.screenCenter(XY);
		btn8.updateHitbox();
		add(btn8);

		rgbText = new Alphabet(posX + 720, 0, "Red        Green      Blue", false);
		rgbText.scaleX = 0.6;
		rgbText.scaleY = 0.6;
		add(rgbText);

		changeSelection();

		FlxG.mouse.visible = true;

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	var lastSelected:Int = 99;
	var changingNote:Bool = false;
	override function update(elapsed:Float) {
		var rownum = 0;
		var lerpVal:Float = CoolUtil.clamp(elapsed * 9.6, 0, 1);
		for (i in 0...grpNumbers.length) {
			var item = grpNumbers.members[i];
			var scaledY = FlxMath.remapToRange(item.ID, 0, 1, 0, 1.3);
			item.y = FlxMath.lerp(item.y, (scaledY * 165) + 270 + 60, lerpVal);
			item.x = FlxMath.lerp(item.x, (item.ID * 20) + 90 + posX + (225 * rownum + 250), lerpVal);
			rownum++;
			if (rownum == 3) rownum = 0;
		}
		for (i in 0...grpNotes.length) {
			var item = grpNotes.members[i];
			var scaledY = FlxMath.remapToRange(item.ID, 0, 1, 0, 1.3);
			item.y = FlxMath.lerp(item.y, (scaledY * 165) + 270, lerpVal);
			item.x = FlxMath.lerp(item.x, (item.ID * 20) + 90, lerpVal);
			if (i == curSelected) {
				rgbText.y = item.y - 70;
				blackBG.y = item.y - 20;
				blackBG.x = item.x - 20;
				if (lastSelected != curSelected) {
					lastSelected = curSelected;
					if (angleTween != null) angleTween.cancel();
					angleTween = null;
					if (scaleTween != null) scaleTween.cancel();
					scaleTween = null;
					item.scale.set(0.78,0.78);
					angleTween = FlxTween.angle(item, -12, 12, 2, {ease: FlxEase.quadInOut, type: FlxTweenType.PINGPONG});
					scaleTween = FlxTween.tween(item, {"scale.x": 0.92, "scale.y": 0.92}, 1, {ease: FlxEase.quadInOut, type: FlxTweenType.PINGPONG});
				}
			} else {
				item.scale.set(0.6,0.6);
				item.angle = 0;
			}
		}
		if(changingNote) {
			if(holdTime < 0.5) {
				if(controls.UI_LEFT_P) {
					updateValue(-1);
					FlxG.sound.play(Paths.sound('scrollMenu'));
				} else if(controls.UI_RIGHT_P) {
					updateValue(1);
					FlxG.sound.play(Paths.sound('scrollMenu'));
				} else if(controls.RESET) {
					resetValue(curSelected, typeSelected);
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}
				if(controls.UI_LEFT_R || controls.UI_RIGHT_R) {
					holdTime = 0;
				} else if(controls.UI_LEFT || controls.UI_RIGHT) {
					holdTime += elapsed;
				}
			} else {
				if(controls.UI_LEFT) {
					updateValue(elapsed * -50);
				} else if(controls.UI_RIGHT) {
					updateValue(elapsed * 50);
				}
				if(controls.UI_LEFT_R || controls.UI_RIGHT_R) {
					FlxG.sound.play(Paths.sound('scrollMenu'));
					holdTime = 0;
				}
			}
		} else {
			if (controls.UI_UP_P) {
				changeSelection(-1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			if (controls.UI_DOWN_P) {
				changeSelection(1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			if (controls.UI_LEFT_P) {
				changeType(-1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			if (controls.UI_RIGHT_P) {
				changeType(1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			if(controls.RESET) {
				for (i in 0...3) {
					resetValue(curSelected, i);
				}
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			if (controls.ACCEPT && nextAccept <= 0) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changingNote = true;
				holdTime = 0;
				for (i in 0...grpNumbers.length) {
					var item = grpNumbers.members[i];
					item.alpha = 0;
					if ((curSelected * 3) + typeSelected == i) {
						item.alpha = 1;
					}
				}
				for (i in 0...grpNotes.length) {
					var item = grpNotes.members[i];
					item.alpha = 0;
					if (curSelected == i) {
						item.alpha = 1;
					}
				}
				super.update(elapsed);
				return;
			}
		}

		if (controls.BACK || (changingNote && controls.ACCEPT)) {
			if(!changingNote) {
				FlxG.mouse.visible = false;
				close();
			} else {
				changeSelection();
			}
			changingNote = false;
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}

		if(nextAccept > 0) {
			nextAccept -= 1;
		}
		super.update(elapsed);
	}

	override function destroy() {
		if (angleTween != null) angleTween.cancel();
		angleTween = null;
		if (scaleTween != null) scaleTween.cancel();
		scaleTween = null;
		super.destroy();
	}

	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = ClientPrefs.arrowRGB.length - 1;
		if (curSelected >= ClientPrefs.arrowRGB.length)
			curSelected = 0;

		curValue = ClientPrefs.arrowRGB[curSelected][typeSelected];
		updateValue();

		var bullshit = 0;
		var rownum = 0;
		//var currow;
		var bullshit2 = 0;
		for (i in 0...grpNumbers.length) {
			var item = grpNumbers.members[i];
			item.alpha = 0.6;
			if ((curSelected * 3) + typeSelected == i) {
				item.alpha = 1;
			}
			item.ID = bullshit - curSelected;
			rownum++;
			if (rownum == 3) {
				rownum = 0;
				bullshit++;
			}
		}
		for (i in 0...grpNotes.length) {
			var item = grpNotes.members[i];
			item.alpha = 0.6;
			item.scale.set(0.5, 0.5);
			if (curSelected == i) {
				item.alpha = 1;
				item.scale.set(0.6, 0.6);
				rgbText.y = item.y - 40;
				blackBG.y = item.y + 28;
			}
			item.ID = bullshit2 - curSelected;
			bullshit2++;
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	function changeType(change:Int = 0) {
		typeSelected += change;
		if (typeSelected < 0)
			typeSelected = 2;
		if (typeSelected > 2)
			typeSelected = 0;

		curValue = ClientPrefs.arrowRGB[curSelected][typeSelected];
		updateValue();

		for (i in 0...grpNumbers.length) {
			var item = grpNumbers.members[i];
			item.alpha = 0.6;
			if ((curSelected * 3) + typeSelected == i) {
				item.alpha = 1;
			}
		}
	}

	function resetValue(selected:Int, type:Int) {
		curValue = 0;
		ClientPrefs.arrowRGB[selected][type] = defaultColors[selected][type];

		shaderArray[selected].rCol = FlxColor.fromRGB(ClientPrefs.arrowRGB[selected][0], ClientPrefs.arrowRGB[selected][1], ClientPrefs.arrowRGB[selected][2]);
		shaderArray[selected].gCol = shaderArray[selected].rCol.getDarkened(0.6);

		var item = grpNumbers.members[(selected * 3) + type];
		item.text = Std.string(ClientPrefs.arrowRGB[selected][type]);

		var add = (40 * (item.letters.length - 1)) / 2;
		for (letter in item.letters)
		{
			letter.offset.x += add;
		}
	}
	function updateValue(change:Float = 0) {
		curValue += change;
		var roundedValue:Int = Math.round(curValue);

		if(roundedValue < 0) {
			curValue = 0;
		} else if(roundedValue > 255) {
			curValue = 255;
		}
		roundedValue = Math.round(curValue);
		ClientPrefs.arrowRGB[curSelected][typeSelected] = roundedValue;

		shaderArray[curSelected].rCol = FlxColor.fromRGB(ClientPrefs.arrowRGB[curSelected][0], ClientPrefs.arrowRGB[curSelected][1], ClientPrefs.arrowRGB[curSelected][2]);
		shaderArray[curSelected].gCol = shaderArray[curSelected].rCol.getDarkened(0.6);

		var item = grpNumbers.members[(curSelected * 3) + typeSelected];
		item.text = Std.string(roundedValue);

		var add = (40 * (item.letters.length - 1)) / 2;
		for (letter in item.letters)
		{
			letter.offset.x += add;
		}
	}
	function updateAll() 
	{
		// does nothing yet
	}
}