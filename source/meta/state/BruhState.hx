package meta.state;

class BruhState extends MusicBeatState
{
	override function create() 
	{
		super.create();
		add(new FlxSprite().loadGraphic(Paths.image('kbhgames')));
	}

	override function update(elapsed:Float) 
	{
		if (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.ENTER) {
			MusicBeatState.switchState(new MainMenuState());
			if (!FlxG.keys.justPressed.ENTER)
				CoolUtil.browserLoad('https://github.com/Joalor64GH/Joalor64-Engine-Rewrite/releases/latest');
		}
		super.update(elapsed);
	}
}