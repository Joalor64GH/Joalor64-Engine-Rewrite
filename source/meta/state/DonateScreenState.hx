package meta.state;

import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxG;
import flixel.FlxSprite;
import openfl.Assets;

import meta.*;
import meta.data.*;
import meta.state.*;

import meta.data.alphabet.*;

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
		bg.setGraphicSize(Std.int(bg.width * 1.1));
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
		add(menuItem);
		menuItem.antialiasing = ClientPrefs.globalAntialiasing;

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
			FlxG.switchState(new MainMenuState());
		}

		if (controls.ACCEPT)
		{
			if (FlxG.keys.justPressed.K) // added other links lol
				CoolUtil.browserLoad('https://www.kickstarter.com/projects/funkin/friday-night-funkin-the-full-ass-game');
			else if (FlxG.keys.justPressed.M)
				CoolUtil.browserLoad('https://github.com/Joalor64GH/Joalor64-Engine-Rewrite/wiki');
			else if (FlxG.keys.justPressed.W)
				CoolUtil.browserLoad('https://sites.google.com/view/joalor64website-new/home');
			else
				CoolUtil.browserLoad(Assets.getText(Paths.txt('donate_button_link')));
		}

		super.update(elapsed);
	}
}