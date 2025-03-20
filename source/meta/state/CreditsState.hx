package meta.state;

#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end

class CreditsState extends MusicBeatState
{
	var curSelected:Int = -1;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<AttachedSprite> = [];
	private var creditsStuff:Array<Array<String>> = [];

	var bg:FlxSprite;
	var descText:FlxText;
	var intendedColor:FlxColor;
	var colorTween:FlxTween;
	var descBox:AttachedSprite;

	var offsetThing:Float = -75;

	var noLink:Bool;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		#if sys
		ArtemisIntegration.setGameState ("menu");
		ArtemisIntegration.resetModName ();
		#end

		persistentUpdate = true;
		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);
		bg.screenCenter();

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		#if MODS_ALLOWED
		for (mod in Mods.parseList().enabled) pushModCreditsToList(mod);
		#end

		var keoikiStr:String = (FlxG.random.bool(30)) ? 'keoiki2' : 'keoiki'; // funny
		var pisspoop:Array<Array<String>> = [
			// name, icon, description, link, color, sound
			['Joalor64 Engine Team'],
			['Joalor64', 'joalor64', 'Project Leader/Main Programmer\n"I do things"', 'https://www.youtube.com/channel/UC4tRMRL_iAHX5n1qQpHibfg', '00FFF6', 'noweyyy'],
			['Moxie', 'moxie', 'Additional Programmer\n"love denpa engine"', 'https://github.com/moxie-coder', 'FFEDD9', 'omori'],
			['FoxLOID', 'fox', 'Epic New Logo\n"this is a quote"', 'https://github.com/FoxLOID', '00A7D4', ''],
			['Bot 404', 'bot', 'Little helper\n"expected more"', 'https://www.youtube.com/channel/UC9ntkZ4Nz3AVKrAnderJnOg', 'FF0040', 'slipperyahhfloor'],
			[''],
			['Special Thanks'],
			['steve-studios', 'mag', 'In-Game Mod Downloader', 'https://github.com/steve-studios', '0000FF', 'squeak'],
			['TheZoroForce240', 'zoro', 'Modcharting Tools Haxelib', 'https://github.com/TheZoroForce240', 'FFD900', 'goofyahhphone'],
			['MAJigsaw77', 'jigsaw', 'ToastCore\n"Just a guy"', 'https://github.com/MAJigsaw77', '444444', ''],
			['CharlesCatYT', 'charles', 'Some code I borrowed\n"your local code steale- i mean fnf haxe coder"', 'https://github.com/CharlesCatYT', '00B0B4', ''],
			['NexIsDumb', 'neo', 'Custom Options\n"Who the fuck is breathing inside my walls"', 'https://github.com/NexIsDumb', '7D485C', ''],
			['Endergreen12', 'ender', 'Custom Gameplay Changers', 'https://github.com/Endergreen12', '00C834', ''],
			['Verwex', 'verwex', 'Micd Up Paths System\n"hell"', 'https://github.com/Verwex', '8FFFFF', ''],
			['ActualMandM', 'mandm', 'RGB Note Coloring System', 'https://linktr.ee/ActualMandM', '9C5D88', ''],
			['You', 'face', 'For playing :)', 'https://joalor64.itch.io/', '7E00FF', 'stolethisfromGamerEnginelol'],
			[''],
			['Psych Engine Team'],
			['ShadowMario', 'shadowmario', 'Main Programmer of Psych Engine', 'https://twitter.com/Shadow_Mario_', '444444', 'JingleShadow'],
			['Riveren', 'riveren', 'Main Artist/Animator of Psych Engine', 'https://twitter.com/riverennn', '14967B', 'JingleRiver'],
			[''],
			['Former Engine Members'],
			['bbpanzu', 'bb', 'Ex-Programmer of Psych Engine', 'https://twitter.com/bbsub3', '3E813A', 'JingleBB'],
			[''],
			['Engine Contributors'],
			['iFlicky', 'flicky', 'Composer of Psync and Tea Time\nMade the Dialogue Sounds', 'https://twitter.com/flicky_i', '9E29CF', ''],
			['gedehari', 'sqirra', 'Crash Handler and Base code for\nChart Editor\'s Waveform', 'https://twitter.com/gedehari', 'E1843A', ''],
			['crowplexus', 'crowplexus', 'Customizable Main Menu with .JSON, Old Latin Support\nCredits Sounds\n', 'https://github.com/crowplexus', 'a1a1a1', ''],
			['TahirKarabekiroglu', 'tahir', 'SScript\nFunkin Cocoa Code\nSoftcoded Achievements, Replay System', 'https://github.com/TahirKarabekiroglu', 'A04397', ''],
			['EliteMasterEric', 'mastereric', 'Runtime Shaders support', 'https://twitter.com/EliteMasterEric', 'FFBD40', ''],
			['PolybiusProxy', 'proxy', 'Creator of hxCodec', 'https://twitter.com/polybiusproxy', 'DCD294', ''],
			['KadeDev', 'kade', 'Fixed Chart Editor and other PRs\nExtension WebM Fork', 'https://twitter.com/kade0912', '64A250', ''],
			['Keoiki', keoikiStr, 'Note Splash Animations\nNew Latin Support', 'https://twitter.com/Keoiki_', 'D2D2D2', ''],
			['Nebula the Zorua', 'nebula', 'LUA JIT Fork and some Lua reworks', 'https://twitter.com/Nebula_Zorua', '7D40B2', ''],
			['Smokey', 'smokey', 'Sprite Atlas Support', 'https://twitter.com/Smokey_5_', '483D92', ''],
			[''],
			["The Funkin' Crew Inc"],
			['ninjamuffin99', 'ninjamuffin99', "Programmer/Creator of Friday Night Funkin'", 'https://twitter.com/ninja_muffin99', 'CF2D2D', ''],
			['PhantomArcade', 'phantomarcade', "Animator of Friday Night Funkin'", 'https://twitter.com/PhantomArcade3K', 'FADC45', ''],
			['evilsk8r', 'evilsk8r', "Artist of Friday Night Funkin'", 'https://twitter.com/evilsk8r', '5ABD4B', ''],
			['kawaisprite', 'kawaisprite', "Composer of Friday Night Funkin'", 'https://twitter.com/kawaisprite', '378FC7', '']
		];

		for (i in pisspoop)
			creditsStuff.push(i);

		for (i in 0...creditsStuff.length)
		{
			var isSelectable:Bool = !(creditsStuff[i].length <= 1);
			var optionText:Alphabet = new Alphabet(90, 320, creditsStuff[i][0], !isSelectable);
			optionText.isMenuItem = true;
			optionText.screenCenter(X);
			optionText.snapToPosition();
			if (isSelectable)
				optionText.x -= 70;
			grpOptions.add(optionText);

			if (isSelectable)
			{
				if (creditsStuff[i][5] != null)
					Mods.currentModDirectory = creditsStuff[i][5];

				var icon:AttachedSprite = new AttachedSprite('credits/' + creditsStuff[i][1]);
				icon.xAdd = optionText.width + 10;
				icon.sprTracker = optionText;

				// using a FlxGroup is too much fuss!
				iconArray.push(icon);
				add(icon);
				Mods.currentModDirectory = '';

				if (curSelected == -1)
					curSelected = i;
			}
		}

		descBox = new AttachedSprite();
		descBox.makeGraphic(1, 1, FlxColor.BLACK);
		descBox.xAdd = -10;
		descBox.yAdd = -10;
		descBox.alphaMult = 0.6;
		descBox.alpha = 0.6;
		add(descBox);

		descText = new FlxText(50, FlxG.height + offsetThing - 25, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
		descText.scrollFactor.set();
		descBox.sprTracker = descText;
		add(descText);

		var blackBox:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 80, FlxColor.BLACK);
		blackBox.scrollFactor.set();
		blackBox.alpha = 0.6;
		add(blackBox);

		var keyText:FlxText = new FlxText(0, 4, FlxG.width, "SPACE // PLAY PERSON'S SOUND\nENTER // ACCESS SOCIALS", 32);
		keyText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
		keyText.scrollFactor.set();
		add(keyText);

		bg.color = CoolUtil.colorFromString(creditsStuff[curSelected][4]);
		intendedColor = bg.color;
		#if sys
		ArtemisIntegration.setBackgroundFlxColor (intendedColor);
		#end
		changeSelection();
		super.create();
	}

	var quitting:Bool = false;
	var holdTime:Float = 0;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (!quitting)
		{
			if (creditsStuff.length > 1)
			{
				var shiftMult:Int = 1;
				if (FlxG.keys.pressed.SHIFT)
					shiftMult = 3;

				var upP = controls.UI_UP_P;
				var downP = controls.UI_DOWN_P;

				if (upP)
				{
					changeSelection(-shiftMult);
					holdTime = 0;
				}
				if (downP)
				{
					changeSelection(shiftMult);
					holdTime = 0;
				}

				if (controls.UI_DOWN || controls.UI_UP)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if (holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					{
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					}
				}
			}

			noLink = (creditsStuff[curSelected][3] == 'nolink') ? true : false;

			if (FlxG.keys.justPressed.ENTER)
			{
				if (noLink)
					FlxG.sound.play(Paths.sound('cancelMenu'));
				else
					CoolUtil.browserLoad(creditsStuff[curSelected][3]);
			}
			if (FlxG.keys.justPressed.SPACE)
			{
				if (creditsStuff[curSelected][5] != '')
					FlxG.sound.play(Paths.sound('credits/' + creditsStuff[curSelected][5]));
				else
					FlxG.sound.play(Paths.sound('cancelMenu'));
			}

			if (controls.BACK)
			{
				if (colorTween != null)
				{
					colorTween.cancel();
				}
				FlxG.sound.play(Paths.sound('cancelMenu'));
				if (ClientPrefs.simpleMain)
					MusicBeatState.switchState(new SimpleMainMenuState());
				else
					MusicBeatState.switchState(new MainMenuState());
				quitting = true;
			}
		}

		super.update(elapsed);
	}

	var moveTween:FlxTween = null;

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		do
		{
			curSelected += change;
			if (curSelected < 0)
				curSelected = creditsStuff.length - 1;
			if (curSelected >= creditsStuff.length)
				curSelected = 0;
		}
		while (creditsStuff[curSelected].length <= 1);

		var newColor:FlxColor = CoolUtil.colorFromString(creditsStuff[curSelected][4]);
		trace('The BG color is: $newColor');
		if (newColor != intendedColor)
		{
			if (colorTween != null)
				colorTween.cancel();
			
			intendedColor = newColor;
			#if sys
			ArtemisIntegration.setBackgroundFlxColor (intendedColor);
			#end
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween)
				{
					colorTween = null;
				}
			});
		}

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if (!(creditsStuff[bullShit - 1].length <= 1))
			{
				item.alpha = 0.6;
				if (item.targetY == 0)
				{
					item.alpha = 1;
				}
			}
		}

		descText.text = creditsStuff[curSelected][2];
		descText.y = FlxG.height - descText.height + offsetThing - 60;

		if (moveTween != null)
			moveTween.cancel();
		moveTween = FlxTween.tween(descText, {y: descText.y + 75}, 0.25, {ease: FlxEase.sineOut});

		descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
		descBox.updateHitbox();
	}

	#if MODS_ALLOWED
	function pushModCreditsToList(folder:String)
	{
		var creditsFile:String = null;
		if (folder != null && folder.trim().length > 0)
			creditsFile = Paths.mods(folder + '/data/credits.txt');
		else
			creditsFile = Paths.mods('data/credits.txt');

		if (FileSystem.exists(creditsFile))
		{
			var firstarray:Array<String> = File.getContent(creditsFile).split('\n');
			for (i in firstarray)
			{
				var arr:Array<String> = i.replace('\\n', '\n').split("::");
				if (arr.length >= 5)
					arr.push(folder);
				creditsStuff.push(arr);
			}
			creditsStuff.push(['']);
		}
	}
	#end
}