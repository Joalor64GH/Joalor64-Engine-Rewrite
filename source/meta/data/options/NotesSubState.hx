package meta.data.options;

#if desktop
import meta.data.dependency.Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
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

	var btn1:FlxButton;
	var btn2:FlxButton;

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

		blackBG = new FlxSprite(posX - 25).makeGraphic(870, 200, FlxColor.BLACK);
		blackBG.alpha = 0.4;
		add(blackBG);

		grpNotes = new FlxTypedGroup<FlxSprite>();
		add(grpNotes);
		grpNumbers = new FlxTypedGroup<Alphabet>();
		add(grpNumbers);

		for (i in 0...ClientPrefs.arrowRGB.length) {
			var yPos:Float = (165 * i) + 35;
			for (j in 0...3) {
				var optionText:Alphabet = new Alphabet(posX + (205 * j) + 250, yPos + 60, Std.string(ClientPrefs.arrowRGB[i][j]), true);
				grpNumbers.add(optionText);

				var item = grpNumbers.members[(i * 3) + j];
				var add = (40 * (item.letters.length - 1)) / 2;
				for (letter in item.letters)
				{
					letter.offset.x += add;
				}
			}

			var note:FlxSprite = new FlxSprite(posX, yPos);
			note.frames = Paths.getSparrowAtlas('NOTE_assets');
			var animations:Array<String> = ['purple0', 'blue0', 'green0', 'red0'];
			note.animation.addByPrefix('idle', animations[i]);
			note.animation.play('idle');
			note.antialiasing = ClientPrefs.globalAntialiasing;
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
			ClientPrefs.saveSettings();
        	});
		btn1.scale.set(1.5, 1.5);
		btn1.color = 0x7b2977;
		btn1.label.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		btn1.updateHitbox();
		add(btn1);

		btn2 = new FlxButton(15, btn1.y + 50, "Vibrant", () ->
		{
			ClientPrefs.arrowRGB = [
				[221, 0, 255], 
				[0, 213, 255], 
				[0, 255, 110], 
				[255, 0, 200]
			];
			updateValue();
			ClientPrefs.saveSettings();
        	});
		btn2.scale.set(1.5, 1.5);
		btn2.color = 0xfff700;
		btn2.label.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		btn2.updateHitbox();
		add(btn2);

		rgbText = new Alphabet(posX + 550, 0, "Red        Green      Blue", false);
		rgbText.scaleX = 0.6;
		rgbText.scaleY = 0.6;
		add(rgbText);

		changeSelection();

		FlxG.mouse.visible = true;

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	var changingNote:Bool = false;
	override function update(elapsed:Float) {
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

	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = ClientPrefs.arrowRGB.length-1;
		if (curSelected >= ClientPrefs.arrowRGB.length)
			curSelected = 0;

		curValue = ClientPrefs.arrowRGB[curSelected][typeSelected];
		updateValue();

		for (i in 0...grpNumbers.length) {
			var item = grpNumbers.members[i];
			item.alpha = 0.6;
			if ((curSelected * 3) + typeSelected == i) {
				item.alpha = 1;
			}
		}
		for (i in 0...grpNotes.length) {
			var item = grpNotes.members[i];
			item.alpha = 0.6;
			item.scale.set(0.75, 0.75);
			if (curSelected == i) {
				item.alpha = 1;
				item.scale.set(1, 1);
				rgbText.y = item.y - 70;
				blackBG.y = item.y - 20;
			}
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
}