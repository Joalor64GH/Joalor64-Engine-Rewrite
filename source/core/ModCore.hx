package core;

import flixel.FlxG;
import openfl.Lib;
#if FUTURE_POLYMOD
import polymod.Polymod;
import polymod.backends.PolymodAssets.PolymodAssetType;
import polymod.format.ParseRules;
#end

/**
 * Class based originally from Kade Engine.
 * Credits: KadeDev & MasterEric.
 */
class ModCore
{
	private static final MOD_DIR:String = 'mods';

	#if FUTURE_POLYMOD
	private static final extensions:Map<String, PolymodAssetType> = [ 
		'ogg' => AUDIO_GENERIC,
		'mp3' => AUDIO_GENERIC,
		'png' => IMAGE,
		'xml' => TEXT, 
		'json' => TEXT, 
		'jsonc' => TEXT, 
		'csv' => TEXT, 
		'tsv' => TEXT, 
		'txt' => TEXT, 
		'hx' => TEXT, 
		'hscript' => TEXT,
		'lua' => TEXT, 
		'py' => TEXT,
		'frag' => TEXT,
		'vert' => TEXT,
		'ttf' => FONT,
		'otf' => FONT, 
		'webm' => VIDEO,
		'mp4' => VIDEO,
		'swf' => VIDEO,
		'fla' => BINARY,
		'flp' => BINARY,
		'zip' => BINARY,
		'dll' => BINARY,
		'ndll' => BINARY
	];

	public static var trackedMods:Array<ModMetadata> = [];
	#end

	public static function reload():Void
	{
		#if FUTURE_POLYMOD
		trace('Reloading Polymod...');
		loadMods(getMods());
		#else
		trace("Polymod reloading is not supported on your Platform!");
		#end
	}

	#if FUTURE_POLYMOD
	public static function loadMods(folders:Array<String>):Void
	{
		var loadedModlist:Array<ModMetadata> = Polymod.init({
			modRoot: MOD_DIR,
			dirs: folders,
			framework: OPENFL,
			apiVersion: Lib.application.meta.get('version'),
			errorCallback: onError,
			parseRules: getParseRules(),
			extensionMap: extensions,
			ignoredFiles: Polymod.getDefaultIgnoreList()
		});

		trace('Loading Successful, ${loadedModlist.length} / ${folders.length} new mods.');

		for (mod in loadedModlist)
			trace('Name: ${mod.title}, [${mod.id}]');
	}

	public static function getMods():Array<String>
	{
		trackedMods = [];

		if (FlxG.save.data.disabledMods == null)
		{
			FlxG.save.data.disabledMods = [];
			FlxG.save.flush();
		}

		var daList:Array<String> = [];

		trace('Searching for Mods...');

		for (i in Polymod.scan(MOD_DIR, '*.*.*', onError))
		{
			trackedMods.push(i);
			if (!FlxG.save.data.disabledMods.contains(i.id))
				daList.push(i.id);
		}

		trace('Found ${daList.length} new mods.');

		return daList;
	}

	public static function getParseRules():ParseRules
	{
		var output:ParseRules = ParseRules.getDefault();
		output.addType("txt", TextFileFormat.LINES);
		output.addType("hx", TextFileFormat.PLAINTEXT);
		return output;
	}

	static function onError(error:PolymodError):Void
	{
		switch (error.severity)
		{
			case NOTICE:
				trace(error.message);
			case WARNING:
				trace(error.message);
			case ERROR:
				trace(error.message);
		}
	}
	#end
}