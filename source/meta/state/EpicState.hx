package meta.state;

class EpicState extends MusicBeatState
{
    	private var grpControls:FlxTypedGroup<Alphabet>;

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
        	menuBG.color = FlxColor.fromRGB(FlxG.random.int(0, 255), FlxG.random.int(0, 255), FlxG.random.int(0, 255));
		add(menuBG);

        	var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Check out my other projects!", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat(Paths.font('vcr.ttf'), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
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
}