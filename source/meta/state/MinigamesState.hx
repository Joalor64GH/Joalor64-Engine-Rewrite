package meta.state;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

import meta.*;
import meta.data.*;
import meta.state.*;
import meta.data.alphabet.*;

import meta.state.PlayState;
import core.ToastCore;

class MinigamesState extends MusicBeatState
{
    	private var grpControls:FlxTypedGroup<Alphabet>;

        private var iconArray:Array<FlxSprite> = [];

	var controlStrings:Array<Minigame> = [
		new Minigame('GET OUT OF MY HEAD', 'the pain never stops\nType: Mania', 'sus'),
		new Minigame('Low Quality .jpegs are funny', "they are and you can't tell me otherwise\nType: Mania", 'pico')
	];

    	var curSelected:Int = 0;
   	var menuBG:FlxSprite;

	override function create()
	{
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
			var controlLabel:Alphabet = new Alphabet(90, 320, controlStrings[i], true);
			controlLabel.isMenuItem = true;
			controlLabel.targetY = i;
			grpControls.add(controlLabel);

            var icon:FlxSprite = new FlxSprite;
            if (Paths.fileExists)
                icon.loadGraphic(Paths.image('minigames/icons/' + controlStrings[i].icon));
            else
                icon.loadGraphic(Paths.image('minigames/icons/none'));
			icon.sprTracker = controlLabel;
            icon.scale.set(0.7, 0.7);
            icon.updateHitbox();
			iconArray.push(icon);
			add(icon);
		}
        
        var bottomPanel:FlxSprite = new FlxSprite(0, FlxG.height - 100).makeGraphic(FlxG.width, 100, 0xFF000000);
		bottomPanel.alpha = 0.5;
		add(bottomPanel);

        	var descTxt:FlxText = new FlxText(20, FlxG.height - 80, 1000, controlStrings[i].description, 22);
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
					PlayState.SONG = Song.loadFromJson('compression', 'commpresion');
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