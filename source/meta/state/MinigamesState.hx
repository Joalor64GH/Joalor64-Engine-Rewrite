package meta.state;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

import lime.app.Application;

import meta.*;
import meta.data.*;
import meta.state.*;
import meta.data.alphabet.*;

import objects.userinterface.HealthIcon;
import meta.state.PlayState;

class MinigamesState extends MusicBeatState
{
    	private var grpControls:FlxTypedGroup<Alphabet>;

        private var iconArray:Array<HealthIcon> = [];

	var controlStrings:Array<Minigame> = [
		new Minigame('GET OUT OF MY HEAD', 'the pain never stops\n(Amogus)', 'mgicons/sus'),
		new Minigame('.jpegs are funny', "they are and you can't tell me otherwise\n(Compression)", 'mgicons/pico')
	];

	var descTxt:FlxText;

    	var curSelected:Int = 0;
   	var menuBG:FlxSprite;

	override function create()
	{
		Application.current.window.title = Application.current.meta.get('name');
		
		menuBG = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
        	menuBG.antialiasing = ClientPrefs.globalAntialiasing;
		add(menuBG);

        	var slash:FlxSprite = new FlxSprite().loadGraphic(Paths.image('minigames/slash'));
		slash.antialiasing = ClientPrefs.globalAntialiasing;
		slash.screenCenter();
		add(slash);

        	grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);

		for (i in 0...controlStrings.length)
		{
			var controlLabel:Alphabet = new Alphabet(90, 320, controlStrings[i].name, true);
			controlLabel.isMenuItem = true;
			controlLabel.targetY = i;
			controlLabel.snapToPosition();
			grpControls.add(controlLabel);

            		var icon:HealthIcon = new HealthIcon(controlStrings[i].icon);
			icon.sprTracker = controlLabel;
			icon.scale.set(0.7, 0.7);
			icon.updateHitbox();
			iconArray.push(icon);
			add(icon);
		}
        
        	var bottomPanel:FlxSprite = new FlxSprite(0, FlxG.height - 100).makeGraphic(FlxG.width, 100, 0xFF000000);
		bottomPanel.alpha = 0.5;
		add(bottomPanel);

        	descTxt = new FlxText(20, FlxG.height - 80, 1000, "", 22);
        	descTxt.screenCenter(X);
		descTxt.scrollFactor.set();
		descTxt.setFormat("VCR OSD Mono", 26, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(descTxt);

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
            		PlayState.inMini = true;
			switch (curSelected)
            		{
				case 0:
					PlayState.SONG = Song.loadFromJson('amogus', 'amogus');
                    			LoadingState.loadAndSwitchState(new PlayState());

				case 1:
					PlayState.SONG = Song.loadFromJson('compression', 'compression');
                    			LoadingState.loadAndSwitchState(new PlayState());
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

		descTxt.text = controlStrings[curSelected].description;

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
			iconArray[i].alpha = 0.6;

		iconArray[curSelected].alpha = 1;

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
}

class Minigame
{
	public var name:String;
	public var description:String;
	public var icon:String;

	public function new(Name:String, dsc:String, img:String)
	{
		name = Name;
        	description = dsc;
        	icon = img;
	}
}