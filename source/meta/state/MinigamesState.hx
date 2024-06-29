package meta.state;

import objects.userinterface.HealthIcon;

class MinigamesState extends MusicBeatState
{
    	var grpControls:FlxTypedGroup<Alphabet>;
        var grpIcons:FlxTypedGroup<HealthIcon>;
	var controlStrings:Array<Minigame> = [
		new Minigame('GET OUT OF MY HEAD', 'the pain never stops\n(Amogus)', 'mgicons/sus'),
		new Minigame('.jpegs are funny', "they are and you can't tell me otherwise\n(Compression)", 'mgicons/pico'),
		new Minigame('Kill BF', 'lmao\n(Point & Click)', 'mgicons/killBf')
		// soon...
		// new Minigame('Funky Memory', 'Do you remember?\n(Point & Click)', 'mgicons/card')
		// new Minigame("Joalor64's Special", 'It\'s me!\n(Melodic Circuit)', 'mgicons/me')
	];

	var descTxt:FlxText;
    	var curSelected:Int = 0;

	override function create()
	{
		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
        	menuBG.antialiasing = ClientPrefs.globalAntialiasing;
		add(menuBG);

        	var slash:FlxSprite = new FlxSprite().loadGraphic(Paths.image('minigames/slash'));
		slash.antialiasing = ClientPrefs.globalAntialiasing;
		slash.screenCenter();
		add(slash);

        	grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);
		grpIcons = new FlxTypedGroup<HealthIcon>();
		add(grpIcons);

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
			icon.ID = i;
			grpIcons.add(icon);
		}
        
        	var bottomPanel:FlxSprite = new FlxSprite(0, FlxG.height - 100).makeGraphic(FlxG.width, 100, 0xFF000000);
		bottomPanel.alpha = 0.5;
		add(bottomPanel);

        	descTxt = new FlxText(20, FlxG.height - 80, 1000, "", 22);
        	descTxt.screenCenter(X);
		descTxt.setFormat(Paths.font('vcr.ttf'), 26, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
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
			MusicBeatState.switchState((ClientPrefs.simpleMain) ? new SimpleMainMenuState() : new MainMenuState());
            
		if (controls.ACCEPT)
		{
			switch (curSelected)
			{
				case 0:
					PlayState.SONG = Song.loadFromJson('amogus', 'amogus');
					PlayState.inMini = true;
					LoadingState.loadAndSwitchState(new PlayState());
				case 1:
					PlayState.SONG = Song.loadFromJson('compression', 'compression');
					PlayState.inMini = true;
					LoadingState.loadAndSwitchState(new PlayState());
				case 2:
					MusicBeatState.switchState(new minigames.KillBF());
				/* case 3:
					MusicBeatState.switchState(new minigames.CardGame()); */
			}
		}
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected = FlxMath.wrap(curSelected + change, 0, grpControls.length - 1);

		descTxt.text = controlStrings[curSelected].description;
		for (i in grpIcons.members) i.alpha = (i.ID == curSelected ? 1 : 0.6);

		for (num => item in grpControls.members)
		{
			item.targetY = num - curSelected;
			item.alpha = (item.targetY == 0) ? 1 : 0.6;
		}
	}
}

class Minigame
{
	public var name:String;
	public var description:String;
	public var icon:String;

	public function new(name:String, description:String, icon:String)
	{
		this.name = name;
		this.description = description;
		this.icon = icon;
	}
}