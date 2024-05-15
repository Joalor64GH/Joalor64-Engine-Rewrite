package meta.state;

/*
 * old code from Chocolate Engine
 * @author Joalor64GH
 * @see https://github.com/Joalor64GH/Chocolate-Engine
 */

class DonateScreenState extends MusicBeatState
{
	var blurb:Array<String> = [
		"your contributions help us",
		"develop the funkiest engine",
		"on this side of the internet",
		"",
		"support the cause",
		"and sub to me on yt"
	];

	override function create()
	{
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		FlxG.sound.playMusic(Paths.music('givealittlebitback'), 1, false);

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xFF4E4E;
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		var menuItem:FlxSprite = new FlxSprite(0, 520);
		menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_donate');
		menuItem.animation.addByPrefix('selected', "donate white", 24);
		menuItem.animation.play('selected');
		menuItem.updateHitbox();
		menuItem.screenCenter(X);
		menuItem.antialiasing = ClientPrefs.globalAntialiasing;
		add(menuItem);

		var textGroup:FlxTypedGroup<Alphabet> = new FlxTypedGroup<Alphabet>();
		add(textGroup);
		
		for (i in 0...blurb.length)
		{
			var money:Alphabet = new Alphabet(0, 0, blurb[i], true);
			money.screenCenter(X);
			money.y += (i * 60) + 120;
			textGroup.add(money);
		}

		#if web
		var someText:FlxText = new FlxText(0, 684, 0, "(opens the itch.io page in a new tab)");
		#else
		var someText:FlxText = new FlxText(0, 684, 0, "(opens the itch.io page in a browser window)");
		#end
		someText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		someText.updateHitbox();
		someText.screenCenter(X);
		add(someText);

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (controls.BACK)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 1);
			FlxG.switchState(() -> new MainMenuState());
		}

		if (controls.ACCEPT)
			CoolUtil.browserLoad(Assets.getText(Paths.txt('donate_button_link')));
		else if (FlxG.keys.justPressed.K) // support the funkin crew as well!!
			CoolUtil.browserLoad('https://www.kickstarter.com/projects/funkin/friday-night-funkin-the-full-ass-game');

		super.update(elapsed);
	}
}