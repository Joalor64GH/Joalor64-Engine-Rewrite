package meta.data.options;

#if desktop
import meta.data.dependency.Discord.DiscordClient;
#end
import meta.*;
import meta.data.*;
import meta.data.options.*;

import flixel.FlxG;
import flixel.text.FlxText;

using StringTools;

class VisualsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Visuals and Graphics';
		rpcTitle = 'Visuals Settings Menu'; //for Discord Rich Presence

		//I'd suggest using "Low Quality" as an example for making your own option since it is the simplest here
		var option:Option = new Option('Low Quality', //Name
			'If checked, disables some background details,\ndecreases loading times and improves performance.', //Description
			'lowQuality', //Save data variable name
			'bool', //Variable type
			false); //Default value
		addOption(option);

		var option:Option = new Option('Anti-Aliasing',
			'If unchecked, disables anti-aliasing, increases performance\nat the cost of sharper visuals.',
			'globalAntialiasing',
			'bool',
			true);
		option.showBoyfriend = true;
		option.onChange = onChangeAntiAliasing; //Changing onChange is only needed if you want to make a special interaction after it changes the value
		addOption(option);

		var option:Option = new Option('Shaders', //Name
			'If unchecked, disables shaders.\nIt\'s used for some visual effects, and also CPU intensive for weaker PCs.', //Description
			'shaders', //Save data variable name
			'bool', //Variable type
			true); //Default value
		addOption(option);

		var option:Option = new Option('Floating Letters', //Name
			'If checked, makes the letters float like in Hypnos Lullaby', //Description
			'floatyLetters', //Save data variable name
			'bool', //Variable type
			false); //Default value
		addOption(option);
		option.onChange = () -> Alphabet.alphabet.shouldDisplace = true;

		var option:Option = new Option('Song Display Style:',
			"How should the songs in Freeplay be displayed?",
			'songDisplay',
			'string',
			'None',
			['Classic', 'Vertical', 'C-Shape', 'D-Shape']);
		addOption(option);

		#if !html5 //Apparently other framerates isn't correctly supported on Browser? Probably it has some V-Sync shit enabled by default, idk
		var option:Option = new Option('Framerate',
			"Pretty self explanatory, isn't it?",
			'framerate',
			'int',
			60);
		addOption(option);

		option.minValue = 60;
		option.maxValue = 240;
		option.displayFormat = '%v FPS';
		option.onChange = onChangeFramerate;
		#end

		var option:Option = new Option('Flashing Lights',
			"Uncheck this if you're sensitive to flashing lights!",
			'flashing',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Rainbow FPS',
		'If checked, makes the FPS have a chroma effect.',
		'fpsRainbow',
		'bool',
		false);
		addOption(option);
		
		var option:Option = new Option('FPS Counter',
			'If unchecked, hides FPS Counter.',
			'showFPS',
			'bool',
			true);
		addOption(option);
		option.onChange = onChangeFPSCounter;
	
		var option:Option = new Option('Colorblind Filter:',
			"Filters for colorblind people.",
			'colorBlindFilter',
			'string',
			'None',
			['None', 'Deuteranopia', 'Protanopia', 'Tritanopia']);
		addOption(option);
		option.onChange = () -> meta.Colorblind.updateFilter();

		var option:Option = new Option('Simple Main Menu',
			'Just a simple version of the Main Menu for low-end users.',
			'simpleMain',
			'bool',
			false);
		addOption(option);

		super();
	}

	#if !mobile
	function onChangeFPSCounter()
	{
		if(Main.fpsVar != null)
			Main.fpsVar.visible = ClientPrefs.showFPS;
	}
	#end

	function onChangeAntiAliasing()
	{
		for (sprite in members)
		{
			var sprite:Dynamic = sprite; //Make it check for FlxSprite instead of FlxBasic
			var sprite:FlxSprite = sprite; //Don't judge me ok
			if(sprite != null && (sprite is FlxSprite) && !(sprite is FlxText)) {
				sprite.antialiasing = ClientPrefs.globalAntialiasing;
			}
		}
	}

	function onChangeFramerate()
	{
		if(ClientPrefs.framerate > FlxG.drawFramerate)
		{
			FlxG.updateFramerate = ClientPrefs.framerate;
			FlxG.drawFramerate = ClientPrefs.framerate;
		}
		else
		{
			FlxG.drawFramerate = ClientPrefs.framerate;
			FlxG.updateFramerate = ClientPrefs.framerate;
		}
	}
}