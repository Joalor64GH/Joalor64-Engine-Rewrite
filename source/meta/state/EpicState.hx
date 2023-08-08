package meta.state;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

import meta.*;
import meta.state.*;
import meta.data.*;
import meta.data.alphabet.*;

class EpicState extends MusicBeatState
{
    	private var grpControls:FlxTypedGroup<Alphabet>;

    	public static var coolColors:Array<FlxColor> = [
		0x00000000, // Transparent
		0xFFFFFFFF, // White
		0xFF808080, // Gray
		0xFF000000, // Black
		0xFF008000, // Green
		0xFF00FF00, // Lime
		0xFFFFFF00, // Yellow
		0xFFFFA500, // Orange
		0xFFFF0000, // Red
		0xFF800080, // Purple
		0xFF0000FF, // Blue
		0xFF8B4513, // Brown
		0xFFFFC0CB, // Pink
		0xFFFF00FF, // Magenta
		0xFF00FFFF // Cyan
	];

	var theCool:Array<String> = [
		"VS Joalor64",
		"Joalor64 Engine",
		"BandLab Radio Player",
		"BandLab OST Player",
        	"2048 Clicker"
	];

    	var curSelected:Int = 0;
   	var menuBG:FlxSprite;

	override function create()
	{
		menuBG = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
        	menuBG.color = randomizeColor();
		add(menuBG);

        	var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Check out my other projects!", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);

		for (i in 0...theCool.length)
		{
			var label:Alphabet = new Alphabet(90, 320, theCool[i], true);
			label.isMenuItem = true;
			label.targetY = i;
			grpControls.add(label);
		}

        	changeSelection();

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

        	if (controls.UI_UP_P || controls.UI_DOWN_P)
			changeSelection(controls.UI_UP_P ? -1 : 1);

		if (controls.BACK) 
		{
			if (ClientPrefs.simpleMain)
				MusicBeatState.switchState(new SimpleMainMenuState());
			else
				MusicBeatState.switchState(new MainMenuState());
		}
            
		if (controls.ACCEPT)
		{
			switch (curSelected)
            		{
				case 0:
					CoolUtil.browserLoad('https://gamebanana.com/mods/417238');
				case 1:
					CoolUtil.browserLoad('https://joalor64.itch.io/joalor64-engine');
				case 2:
					CoolUtil.browserLoad('https://github.com/Joalor64GH/BandLab-Radio-Player');
				case 3:
					CoolUtil.browserLoad('https://github.com/Joalor64GH/BandLabOST-Player');
        			case 4:
					CoolUtil.browserLoad('https://github.com/Joalor64GH/2048-Clicker');
			}
		}
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpControls.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}
	}

    	public static function randomizeColor()
    	{
		var chance:Int = FlxG.random.int(0, coolColors.length - 1);
		var color:FlxColor = coolColors[chance];
		return color;
   	}
}