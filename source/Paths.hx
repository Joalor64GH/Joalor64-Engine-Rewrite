package;

import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.system.FlxAssets.FlxSoundAsset;
import animateatlas.AtlasFrameMaker;
import flixel.math.FlxPoint;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import openfl.geom.Rectangle;
import flixel.math.FlxRect;
import haxe.xml.Access;
import openfl.system.System;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import openfl.utils.ByteArray;
import lime.utils.Assets;
import flixel.FlxSprite;
#if sys
import sys.io.File;
import sys.FileSystem;
#end
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import haxe.Json;

import flash.media.Sound;
import openfl.media.Sound;

using StringTools;

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;
	public static final VIDEO_EXT = ['mp4', 'webm'];

	#if (MODS_ALLOWED && FUTURE_POLYMOD)
	public static var ignoreModFolders:Array<String> = [
		#if FUTURE_POLYMOD 
		'_append', 
		'_merge', 
		#end
		'characters',
		'custom_events',
		'custom_notetypes',
		'data',
		'songs',
		'music',
		#if sys
		'mainMods',
		#end
		'sounds',
		'shaders',
		'videos',
		'images',
		'stages',
		'weeks',
		'fonts',
		'scripts',
		'libs',
		'achievements',
		'art'
	];
	#end

	public static function excludeAsset(key:String) {
		if (!dumpExclusions.contains(key))
			dumpExclusions.push(key);
	}

	public static var dumpExclusions:Array<String> =
	[
		'assets/music/freakyMenu.$SOUND_EXT',
		'assets/shared/music/breakfast.$SOUND_EXT',
		'assets/shared/music/tea-time.$SOUND_EXT',
	];
	/// haya I love you for the base cache dump I took to the max
	public static function clearUnusedMemory() {
		// clear non local assets in the tracked assets list
		for (key in currentTrackedAssets.keys()) {
			// if it is not currently contained within the used local assets
			if (!localTrackedAssets.contains(key)
				&& !dumpExclusions.contains(key)) {
				// get rid of it
				var obj = currentTrackedAssets.get(key);
				@:privateAccess
				if (obj != null) {
					openfl.Assets.cache.removeBitmapData(key);
					FlxG.bitmap._cache.remove(key);
					obj.destroy();
					currentTrackedAssets.remove(key);
				}
			}
		}
		// run the garbage collector for good measure lmfao
		System.gc();
	}

	// define the locally tracked assets
	public static var localTrackedAssets:Array<String> = [];
	public static function clearStoredMemory(?cleanUnused:Bool = false) {
		// clear anything not in the tracked assets list
		@:privateAccess
		for (key in FlxG.bitmap._cache.keys())
		{
			var obj = FlxG.bitmap._cache.get(key);
			if (obj != null && !currentTrackedAssets.exists(key)) {
				openfl.Assets.cache.removeBitmapData(key);
				FlxG.bitmap._cache.remove(key);
				obj.destroy();
			}
		}

		// clear all sounds that are cached
		for (key in currentTrackedSounds.keys()) {
			if (!localTrackedAssets.contains(key)
			&& !dumpExclusions.contains(key) && key != null) {
				//trace('test: ' + dumpExclusions, key);
				Assets.cache.clear(key);
				currentTrackedSounds.remove(key);
			}
		}
		// flags everything to be cleared out next unused memory clear
		localTrackedAssets = [];
		openfl.Assets.cache.clear("songs");
	}

	static public var currentModDirectory:String = '';
	static public var currentLevel:String;
	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	public static function getPath(file:String, type:AssetType, ?library:Null<String> = null)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath:String = '';
			if(currentLevel != 'shared') {
				levelPath = getLibraryPathForce(file, currentLevel);
				if (OpenFlAssets.exists(levelPath, type))
					return levelPath;
			}

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	#if sys
	static function getPathImage(file:String, type:AssetType, library:Null<String>):FlxGraphicAsset
	{
		if (library != null)
			return getImageLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return BitmapData.fromBytes(ByteArray.fromBytes(File.getBytes(levelPath)));

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return BitmapData.fromBytes(ByteArray.fromBytes(File.getBytes(levelPath)));
		}

		return getImagePath(file);
	}

	static function getPathSound(file:String, type:AssetType, library:Null<String>):FlxSoundAsset
	{
		if (library != null)
			return getSoundLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath:openfl.media.Sound = getSoundPathForce(file, currentLevel);
			if (OpenFlAssets.exists(levelPath.toString(), type))
				return levelPath;

			levelPath = getSoundPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath.toString(), type))
				return levelPath;
		}

		return getSoundPath(file);
	}
	#end

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	#if sys
	static public function getImageLibraryPath(file:String, library = "preload"):FlxGraphicAsset
	{
		return if (library == "preload" || library == "default") getImagePath(file); else getImagePathForce(file, library);
	}

	static public function getSoundLibraryPath(file:String, library = "preload"):FlxSoundAsset
	{
		return if (library == "preload" || library == "default") getSoundPath(file); else getSoundPathForce(file, library);
	}
	#end

	inline static function getLibraryPathForce(file:String, library:String)
	{
		var returnPath = '$library:assets/$library/$file';
		#if sys
		if (FileSystem.exists('mods/mainMods/_append/$library/$file'))
		{
			return File.getContent('mods/mainMods/_append/$library/$file');
		}
		else
		{
			return returnPath;
		}
		#else
		return returnPath;
		#end
	}

	inline public static function getPreloadPath(file:String = '')
	{
		#if sys
		if (FileSystem.exists('mods/mainMods/_append/$file'))
		{
			return File.getContent('mods/mainMods/_append/$file');
		}
		else
		{
			return 'assets/$file';
		}
		#else
		return 'assets/$file';
		#end
	}

	inline static function getSoundPathForce(file:String, library:String):FlxSoundAsset
	{
		#if sys
		if (FileSystem.exists('mods/mainMods/_append/$library/$file'))
		{
			return Sound.fromFile('mods/mainMods/_append/$library/$file');
		}
		else
		{
			return Sound.fromFile('assets/$library/$file');
		}
		#else
		return Sound.fromFile('assets/$library/$file');
		#end
	}

	inline static function getSoundPath(file:String):FlxSoundAsset
	{
		#if sys
		if (FileSystem.exists('mods/mainMods/_append/$file'))
		{
			return Sound.fromFile('mods/mainMods/_append/$file');
		}
		else
		{
			return Sound.fromFile('assets/$file');
		}
		#else
		return Sound.fromFile('assets/$file');
		#end
	}

	#if sys
	inline static function getImagePathForce(file:String, library:String):FlxGraphicAsset
	{
		if (FileSystem.exists('mods/mainMods/_append/$library/$file'))
		{
			var rawPic = File.getBytes('mods/mainMods/_append/$library/$file');
			return BitmapData.fromBytes(ByteArray.fromBytes(rawPic));
		}
		else
		{
			var rawPic = File.getBytes('assets/$library/$file');
			return BitmapData.fromBytes(ByteArray.fromBytes(rawPic));
		}
	}

	inline static function getImagePath(file:String):FlxGraphicAsset
	{
		if (FileSystem.exists('mods/mainMods/_append/$file'))
		{
			var rawPic = File.getBytes('mods/mainMods/_append/$file');
			return BitmapData.fromBytes(ByteArray.fromBytes(rawPic));
		}
		else
		{
			var rawPic = File.getBytes('assets/$file');
			return BitmapData.fromBytes(ByteArray.fromBytes(rawPic));
		}
	}
	#end

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		#if !sys
		library = null;
		#end

		return getPath(file, type, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		#if !sys
		library = null;
		#end

		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		#if !sys
		return getPath('data/$key.json', TEXT, library);
		#else
		if (FileSystem.exists(('mods/mainMods/_append/data/$key.json')))
		{
			return 'mods/mainMods/_append/data/$key.json';
		}
		else
			return getPath('data/$key.json', TEXT, library);
		#end
	}

	inline static public function tjson(key:String, ?library:String)
	{
		return getPath('data/$key.jsonc', TEXT, library);
	}

	inline static public function fla(key:String, ?library:String)
	{
		return getPath('art/$key.fla', BINARY, library);
	}

	inline static public function flp(key:String, ?library:String)
	{
		return getPath('art/$key.flp', BINARY, library);
	}

	inline static public function shaderFragment(key:String, ?library:String)
	{
		return getPath('shaders/$key.frag', TEXT, library);
	}
	inline static public function shaderVertex(key:String, ?library:String)
	{
		return getPath('shaders/$key.vert', TEXT, library);
	}
	inline static public function lua(key:String, ?library:String)
	{
		return getPath('$key.lua', TEXT, library);
	}
	inline static public function hscript(key:String, ?library:String)
	{
		return getPath('$key.hscript', TEXT, library);
	}
	inline static public function hx(key:String, ?library:String)
	{
		return getPath('$key.hx', TEXT, library);
	}
	inline static public function py(key:String, ?library:String)
	{
		return getPath('$key.py', TEXT, library);
	}
	static public function video(key:String)
	{
		#if (MODS_ALLOWED && FUTURE_POLYMOD)
		var file:String = modsVideo(key);
		if(FileSystem.exists(file)) {
			return file;
		}
		#end
		for (i in VIDEO_EXT) {
			var path = 'assets/videos/$key.$i';
			#if (MODS_ALLOWED && FUTURE_POLYMOD)
			if (FileSystem.exists(path))
			#else
			if (OpenFlAssets.exists(path))
			#end
			{
				return path;
			}
		}
		return 'assets/videos/$key.mp4';
	}

	static public function sound(key:String, ?library:String):Sound
	{
		var sound:Sound = returnSound('sounds', key, library);
		#if sys
		if (FileSystem.exists('mods/mainMods/_append/sounds/$key.ogg')
			|| FileSystem.exists('mods/mainMods/_append/shared/sounds/$key.ogg')
			|| FileSystem.exists('mods/mainMods/_append/week1/sounds/$key.ogg')
			|| FileSystem.exists('mods/mainMods/_append/week2/sounds/$key.ogg')
			|| FileSystem.exists('mods/mainMods/_append/week3/sounds/$key.ogg')
			|| FileSystem.exists('mods/mainMods/_append/week4/sounds/$key.ogg')
			|| FileSystem.exists('mods/mainMods/_append/week5/sounds/$key.ogg')
			|| FileSystem.exists('mods/mainMods/_append/week6/sounds/$key.ogg')
			|| FileSystem.exists('mods/mainMods/_append/$library/sounds/$key.ogg'))
			return getPathSound('sounds/$key.$SOUND_EXT', SOUND, library);
		else
			return sound;
		#else
		return sound;
		#end
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		#if !sys
		library = null;
		#end

		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String):Sound
	{
		var file:Sound = returnSound('music', key, library);
		#if sys
		if (FileSystem.exists('mods/mainMods/_append/music/$key.ogg')
			|| FileSystem.exists('mods/mainMods/_append/shared/music/$key.ogg')
			|| FileSystem.exists('mods/mainMods/_append/week1/music/$key.ogg')
			|| FileSystem.exists('mods/mainMods/_append/week2/music/$key.ogg')
			|| FileSystem.exists('mods/mainMods/_append/week3/music/$key.ogg')
			|| FileSystem.exists('mods/mainMods/_append/week4/music/$key.ogg')
			|| FileSystem.exists('mods/mainMods/_append/week5/music/$key.ogg')
			|| FileSystem.exists('mods/mainMods/_append/week6/music/$key.ogg')
			|| FileSystem.exists('mods/mainMods/_append/$library/music/$key.ogg'))
			return getPathSound('music/$key.$SOUND_EXT', MUSIC, library);
		else
			return file;
		#else
		return file;
		#end
	}

	inline static public function voices(song:String)
	{
		var songKey:String = '${formatToSongPath(song)}/Voices';
		var voices = returnSound('songs', songKey);
		#if sys
		if (FileSystem.exists('mods/mainMods/_append/songs/${song.toLowerCase()}/Voices.$SOUND_EXT'))
			voices = openfl.media.Sound.fromFile('mods/mainMods/_append/songs/${song.toLowerCase()}/Voices.$SOUND_EXT');
		else
			return voices;
		#else
		return voices;
		#end
	}

	inline static public function inst(song:String)
	{
		var songKey:String = '${formatToSongPath(song)}/Inst';
		var inst = returnSound('songs', songKey);
		#if sys
		if (FileSystem.exists('mods/mainMods/_append/songs/${song.toLowerCase()}/Inst.$SOUND_EXT'))
			inst = openfl.media.Sound.fromFile('mods/mainMods/_append/songs/${song.toLowerCase()}/Inst.$SOUND_EXT');
		else
			return inst;
		#else
		return inst;
		#end
	}

	inline static public function image(key:String, ?library:String):FlxGraphic
	{
		// streamlined the assets process more
		var returnAsset:FlxGraphic = returnGraphic(key, library);
		#if sys
		if (FileSystem.exists('mods/mainMods/_append/images/$key.png')
			|| FileSystem.exists('mods/mainMods/_append/shared/images/$key.png')
			|| FileSystem.exists('mods/mainMods/_append/week1/images/$key.png')
			|| FileSystem.exists('mods/mainMods/_append/week2/images/$key.png')
			|| FileSystem.exists('mods/mainMods/_append/week3/images/$key.png')
			|| FileSystem.exists('mods/mainMods/_append/week4/images/$key.png')
			|| FileSystem.exists('mods/mainMods/_append/week5/images/$key.png')
			|| FileSystem.exists('mods/mainMods/_append/week6/images/$key.png')
			|| FileSystem.exists('mods/mainMods/_append/$library/images/$key.png')) // lol
			return getPathImage('images/$key.png', IMAGE, library);
		else
			return returnAsset;
		#else
		return returnAsset;
		#end
	}

	static public function getTextFromFile(key:String, ?ignoreMods:Bool = false):String
	{
		#if sys
		#if (MODS_ALLOWED && FUTURE_POLYMOD)
		if (!ignoreMods && FileSystem.exists(modFolders(key)))
			return File.getContent(modFolders(key));
		#end

		if (FileSystem.exists(getPreloadPath(key)))
			return File.getContent(getPreloadPath(key));

		if (currentLevel != null)
		{
			var levelPath:String = '';
			if(currentLevel != 'shared') {
				levelPath = getLibraryPathForce(key, currentLevel);
				if (FileSystem.exists(levelPath))
					return File.getContent(levelPath);
			}

			levelPath = getLibraryPathForce(key, 'shared');
			if (FileSystem.exists(levelPath))
				return File.getContent(levelPath);
		}
		#end
		return Assets.getText(getPath(key, TEXT));
	}

	inline static public function font(key:String)
	{
		#if (MODS_ALLOWED && FUTURE_POLYMOD)
		var file:String = modsFont(key);
		if(FileSystem.exists(file)) {
			return file;
		}
		#end
		return 'assets/fonts/$key';
	}

	inline static public function fileExists(key:String, type:AssetType, ?ignoreMods:Bool = false, ?library:String)
	{
		#if (MODS_ALLOWED && FUTURE_POLYMOD)
		if(FileSystem.exists(mods(currentModDirectory + '/' + key)) || FileSystem.exists(mods(key))) {
			return true;
		}
		#end

		if(OpenFlAssets.exists(getPath(key, type))) {
			return true;
		}
		return false;
	}

	inline static public function getSparrowAtlas(key:String, ?library:String):FlxAtlasFrames
	{
		#if (MODS_ALLOWED && FUTURE_POLYMOD)
		var imageLoaded:FlxGraphic = returnGraphic(key);
		var xmlExists:Bool = false;
		if(FileSystem.exists(modsXml(key))) {
			xmlExists = true;
		}

		return FlxAtlasFrames.fromSparrow((imageLoaded != null ? imageLoaded : image(key, library)), (xmlExists ? File.getContent(modsXml(key)) : file('images/$key.xml', library)));
		#else
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
		#end
	}


	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		#if (MODS_ALLOWED && FUTURE_POLYMOD)
		var imageLoaded:FlxGraphic = returnGraphic(key);
		var txtExists:Bool = false;
		if(FileSystem.exists(modsTxt(key))) {
			txtExists = true;
		}

		return FlxAtlasFrames.fromSpriteSheetPacker((imageLoaded != null ? imageLoaded : image(key, library)), (txtExists ? File.getContent(modsTxt(key)) : file('images/$key.txt', library)));
		#else
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
		#end
	}

	inline static public function formatToSongPath(path:String) {
		var invalidChars = ~/[~&\\;:<>#]/;
		var hideChars = ~/[.,'"%?!]/;

		var path = invalidChars.split(path.replace(' ', '-')).join("-");
		return hideChars.split(path).join("").toLowerCase();
	}

	// completely rewritten asset loading? fuck!
	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
	public static function returnGraphic(key:String, ?library:String) {
		#if (MODS_ALLOWED && FUTURE_POLYMOD)
		var modKey:String = modsImages(key);
		if(FileSystem.exists(modKey)) {
			if(!currentTrackedAssets.exists(modKey)) {
				var newBitmap:BitmapData = BitmapData.fromFile(modKey);
				var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(newBitmap, false, modKey);
				newGraphic.persist = true;
				currentTrackedAssets.set(modKey, newGraphic);
			}
			localTrackedAssets.push(modKey);
			return currentTrackedAssets.get(modKey);
		}
		#end

		var path = getPath('images/$key.png', IMAGE, library);
		//trace(path);
		if (OpenFlAssets.exists(path, IMAGE)) {
			if(!currentTrackedAssets.exists(path)) {
				var newGraphic:FlxGraphic = FlxG.bitmap.add(path, false, path);
				newGraphic.persist = true;
				currentTrackedAssets.set(path, newGraphic);
			}
			localTrackedAssets.push(path);
			return currentTrackedAssets.get(path);
		}
		trace('oh no its returning null NOOOO');
		return null;
	}

	public static var currentTrackedSounds:Map<String, Sound> = [];
	public static function returnSound(path:String, key:String, ?library:String) {
		#if (MODS_ALLOWED && FUTURE_POLYMOD)
		var file:String = modsSounds(path, key);
		if(FileSystem.exists(file)) {
			if(!currentTrackedSounds.exists(file)) {
				currentTrackedSounds.set(file, Sound.fromFile(file));
			}
			localTrackedAssets.push(key);
			return currentTrackedSounds.get(file);
		}
		#end
		// I hate this so god damn much
		var gottenPath:String = getPath('$path/$key.$SOUND_EXT', SOUND, library);
		gottenPath = gottenPath.substring(gottenPath.indexOf(':') + 1, gottenPath.length);
		// trace(gottenPath);
		if(!currentTrackedSounds.exists(gottenPath))
		#if (MODS_ALLOWED && FUTURE_POLYMOD)
			currentTrackedSounds.set(gottenPath, Sound.fromFile('./' + gottenPath));
		#else
		{
			var folder:String = '';
			if(path == 'songs') folder = 'songs:';

			currentTrackedSounds.set(gottenPath, OpenFlAssets.getSound(folder + getPath('$path/$key.$SOUND_EXT', SOUND, library)));
		}
		#end
		localTrackedAssets.push(gottenPath);
		return currentTrackedSounds.get(gottenPath);
	}

	inline public static function getContent(path:String) {
		#if sys
		return File.getContent(path);
		#else
		return OpenFlAssets.getText(path);
		#end
	}

	#if (MODS_ALLOWED && FUTURE_POLYMOD)
	inline static public function mods(key:String = '') {
		return 'mods/' + key;
	}

	inline static public function modsFont(key:String) {
		return modFolders('fonts/' + key);
	}

	inline static public function modsJson(key:String) {
		return modFolders('data/' + key + '.json');
	}

	inline static public function modsTjson(key:String) {
		return modFolders('data/' + key + '.jsonc');
	}

    	#if FUTURE_POLYMOD
	inline static public function appendTxt(key:String) {
		return modFolders('_append/data/' + key + '.txt');
	}

	inline static public function appendJson(key:String) {
		return modFolders('_append/data/' + key + '.json');
	}

	inline static public function appendCsv(key:String) {
		return modFolders('_append/data/' + key + '.csv');
	}

	inline static public function appendXml(key:String) {
		return modFolders('_append/data/' + key + '.xml');
	}

	inline static public function mergeTxt(key:String) {
		return modFolders('_merge/data/' + key + '.txt');
	}

	inline static public function mergeJson(key:String) {
		return modFolders('_merge/data/' + key + '.json');
	}

	inline static public function mergeCsv(key:String) {
		return modFolders('_merge/data/' + key + '.csv');
	}

	inline static public function mergeTsv(key:String) {
		return modFolders('_merge/data/' + key + '.tsv');
	}

	inline static public function mergeXml(key:String) {
		return modFolders('_merge/data/' + key + '.xml');
	}

	inline static public function tsv(key:String) {
		return modFolders(key + '.tsv');
	}
	#end

	static public function modsVideo(key:String) {
		for (i in VIDEO_EXT) {
			var path = modFolders('videos/$key.$i');
			if (FileSystem.exists(path))
			{
				return path;
			}
		}
		return modFolders('videos/$key.mp4');
	}

	inline static public function modsSounds(path:String, key:String) {
		return modFolders(path + '/' + key + '.' + SOUND_EXT);
	}

	inline static public function modsImages(key:String) {
		return modFolders('images/' + key + '.png');
	}

	inline static public function modsXml(key:String) {
		return modFolders('images/' + key + '.xml');
	}

	inline static public function modsTxt(key:String) {
		return modFolders('images/' + key + '.txt');
	}

	inline static public function modsFla(key:String) {
		return modFolders('art/' + key + '.fla');
	}

	inline static public function modsFlp(key:String) {
		return modFolders('art/' + key + '.flp');
	}

	inline static public function modsAchievements(key:String) {
		return modFolders('achievements/' + key + '.json');
	}

	static public function modFolders(key:String) {
		if(currentModDirectory != null && currentModDirectory.length > 0) {
			var fileToCheck:String = mods(currentModDirectory + '/' + key);
			if(FileSystem.exists(fileToCheck)) {
				return fileToCheck;
			}
		}

		for(mod in getGlobalMods()){
			var fileToCheck:String = mods(mod + '/' + key);
			if(FileSystem.exists(fileToCheck))
				return fileToCheck;

		}
		return 'mods/' + key;
	}

	public static var globalMods:Array<String> = [];

	static public function getGlobalMods()
		return globalMods;

	static public function pushGlobalMods() // prob a better way to do this but idc
	{
		globalMods = [];
		var path:String = 'modsList.txt';
		if(FileSystem.exists(path))
		{
			var list:Array<String> = CoolUtil.coolTextFile(path);
			for (i in list)
			{
				var dat = i.split("|");
				if (dat[1] == "1")
				{
					var folder = dat[0];
					var path = Paths.mods(folder + '/#if FUTURE_POLYMOD _polymod_meta.json #else pack.json #end');
					if(FileSystem.exists(path)) {
						try{
							var rawJson:String = File.getContent(path);
							if(rawJson != null && rawJson.length > 0) {
								var stuff:Dynamic = Json.parse(rawJson);
								var global:Bool = Reflect.getProperty(stuff, "runsGlobally");
								if(global)globalMods.push(dat[0]);
							}
						} catch(e:Dynamic){
							trace(e);
						}
					}
				}
			}
		}
		return globalMods;
	}

	static public function getModDirectories():Array<String> {
		var list:Array<String> = [];
		var modsFolder:String = mods();
		if(FileSystem.exists(modsFolder)) {
			for (folder in FileSystem.readDirectory(modsFolder)) {
				var path = haxe.io.Path.join([modsFolder, folder]);
				if (sys.FileSystem.isDirectory(path) && !ignoreModFolders.contains(folder) && !list.contains(folder)) {
					list.push(folder);
				}
			}
		}
		return list;
	}
	#end
}