package meta.state;

import meta.state.menuObjects.*;

class GlobalMenuState extends MusicBeatState
{
	public static var spawnMenu:String = 'title';
	public static var nextMenu:MusicBeatGroup = null;

	var curMenu:MusicBeatGroup = null;
	
	override function create()
	{
		super.create();
		
		switch (spawnMenu)
		{
            // these don't exist yet i'll work on it
			case 'options': nextMenu = new OptionsGroup();
			case 'freeplay': nextMenu = new FreeplayGroup();
            case 'menu': nextMenu = new MainMenuGroup();
			default: nextMenu = new MainMenuGroup();
		}
		
		curMenu = nextMenu;
		
		add(curMenu);
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (!curMenu.alive)
		{
			remove(curMenu);
			curMenu = nextMenu;
			add(curMenu);
		}
	}
	
	override function stepHit()
	{
		super.stepHit();

		if (curMenu != null)
		{
			curMenu.stepHit(curStep);
			if (curStep % 4 == 0)
				curMenu.beatHit(Math.floor(curStep / 4));
		}
	}
}