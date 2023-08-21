package;

#if sys
import sys.io.File;
import sys.FileSystem;
#end

import flash.media.Sound;
import animateatlas.AtlasFrameMaker;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import haxe.xml.Access;
import openfl.system.System;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as Assets;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import haxe.CallStack;
import haxe.io.Bytes;
import haxe.Json;

import github.APIShit;
import meta.CoolUtil;
#if MODS_ALLOWED
import backend.Mods;
#end

using StringTools;

// JSONI8 Format code by luckydog https://www.youtube.com/channel/UCeHXKGpDKo2eqYKVkqCUdaA
// Modified and PsychEngine support by ZackDroid https://twitter.com/ZackDroidCoder
typedef I8frame = {
	var frame:{ x:Float, y:Float, w:Float, h:Float }
	var rotated:Bool;
	var trimmed:Bool;
	var spriteSourceSize:{ x:Float, y:Float, w:Float, h:Float }
	var sourceSize:{ w:Float, h:Float }
	var duration:Float;
}

class Paths
{
	inline public static final SOUND_EXT = #if !web "ogg" #else "mp3" #end;
	inline public static var FLASH_EXT = "swf";

	public static final VIDEO_EXT = ['mp4', 'webm'];

	public static function excludeAsset(key:String) {
		if (!dumpExclusions.contains(key))
			dumpExclusions.push(key);
	}

	public static var dumpExclusions:Array<String> = [
		'assets/music/freakyMenu.$SOUND_EXT',
		'assets/music/breakfast.$SOUND_EXT',
		'assets/music/tea-time.$SOUND_EXT', // what's with the trailing comma??
	];

	public static function clearUnusedMemory()
	{
		// clear non local assets in the tracked assets list
		for (key in currentTrackedAssets.keys())
		{
			// if it is not currently contained within the used local assets
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key))
			{
				// get rid of it
				var obj = currentTrackedAssets.get(key);
				@:privateAccess
				if (obj != null)
				{
					Assets.cache.removeBitmapData(key);
					FlxG.bitmap._cache.remove(key);
					obj.destroy();
					currentTrackedAssets.remove(key);
				}
			}
		}
		// run the garbage collector for good measure lmfao
		System.gc();
	}

	// fuckin around ._.
	public static function removeBitmap(key)
	{
		var obj = currentTrackedAssets.get(key);
		@:privateAccess
		if (obj != null)
		{
			Assets.cache.removeBitmapData(key);
			FlxG.bitmap._cache.remove(key);
			obj.destroy();
			currentTrackedAssets.remove(key);
		}
	}

	// define the locally tracked assets
	public static var localTrackedAssets:Array<String> = [];
	public static function clearStoredMemory()
	{
		// clear anything not in the tracked assets list
		@:privateAccess
		for (key in FlxG.bitmap._cache.keys())
		{
			var obj = FlxG.bitmap._cache.get(key);
			if (obj != null && !currentTrackedAssets.exists(key))
			{
				Assets.cache.removeBitmapData(key);
				FlxG.bitmap._cache.remove(key);
				obj.destroy();
			}
		}

		// clear all sounds that are cached
		for (key in currentTrackedSounds.keys())
		{
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key) && key != null)
			{
				// trace('test: ' + dumpExclusions, key);
				Assets.cache.clear(key);
				currentTrackedSounds.remove(key);
			}
		}
		// flags everything to be cleared out next unused memory clear
		localTrackedAssets = [];
		Assets.cache.clear("songs");
	}

	// github stuff
	public static function gitGetPath(path:String, branch:String = 'main')
	{
		trace('path: https://${APIShit.personalAccessToken}@raw.githubusercontent.com/${APIShit.repoHolder}/${APIShit.repoName}/$branch/assets/$path');
		var http = new haxe.Http('https://raw.githubusercontent.com/${APIShit.repoHolder}/${APIShit.repoName}/$branch/assets/$path');
		var contents:String = '';
		http.onData = function(data:String) {
			contents = data;
		}
		http.onError = function(error) {
			trace('error: $error');
		}
		http.request();
		return contents;
	}
	public static function gitImage(path:String, branch:String) {
		var http = new haxe.Http('https://raw.githubusercontent.com/${APIShit.repoHolder}/${APIShit.repoName}/$branch/assets/$path');
		var spr:FlxSprite = new FlxSprite();
		http.onBytes = function(bytes:Bytes) {
			var bmp:BitmapData = BitmapData.fromBytes(bytes);
			spr.pixels = bmp;
		}
		http.onError = function(error) {
			trace('error: $error');
		}
		http.request();

		return spr;
	}
	public static function loadGraphicFromURL(url:String, sprite:FlxSprite):FlxSprite
	{
		var http = new haxe.Http(url);
		var spr:FlxSprite = new FlxSprite();
		http.onBytes = function(bytes:Bytes) {
			var bmp:BitmapData = BitmapData.fromBytes(bytes);
			spr.pixels = bmp;
		}
		http.onError = function(error) {
			trace('error: $error');
			return null;
		}
		http.request();

		return spr;
	}
	public static function loadSparrowAtlasFromURL(xmlUrl:String, imageUrl:String)
	{
		var xml:String;
		var xmlHttp = new haxe.Http(xmlUrl);
		xmlHttp.onData = function (data:String) {
			xml = data;
		}
		xmlHttp.onError = function (e) {
			trace('error: $e');
			return null;
		}
		xmlHttp.request();

		var http = new haxe.Http(imageUrl);
		var bmp:BitmapData;
		http.onBytes = function (bytes:Bytes) {
			bmp = BitmapData.fromBytes(bytes);
			trace(bmp.height);
		}
		http.onError = function(error) {
			trace('error: $error');
			return null;
		}
		http.request();
		return FlxAtlasFrames.fromSparrow(bmp, xml);
	}
	public static function loadFileFromURL(url:String):String
	{
		var shit:String;
		var http = new haxe.Http(url);
		http.onData = function (data:String)
			shit = data;
		http.onError = function (e)
		{
			trace('error: $e');
			return null;
		}
		http.request();
		return shit;
	}

	public static function getPath(file:String, ?type:AssetType = TEXT, ?library:Null<String> = null, ?modsAllowed:Bool = false):String
	{
		#if MODS_ALLOWED
		if(modsAllowed)
		{
			var modded:String = modFolders(file);
			if(FileSystem.exists(modded)) return modded;
		}
		#end

		return getPreloadPath(file);
	}

	inline public static function getPreloadPath(file:String = '')
	{
		return 'assets/$file';
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String) 
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
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

	inline static public function exists(asset:String, ?type:lime.utils.AssetType)
	{
		#if sys 
		return FileSystem.exists(asset);
		#else
		return Assets.exists(asset, type);
		#end
	}

	inline static public function getContent(asset:String):Null<String> 
	{
		#if sys
		if (FileSystem.exists(asset))
			return File.getContent(asset);
		#else
		if (Assets.exists(asset))
			return Assets.getText(asset);
		#end

		return null;
	}

	#if html5
	static var pathMap = new Map<String, Array<String>>();

	public static function initPaths() 
	{	
		pathMap.clear();

		for (path in Assets.list())
		{
			var file = path.split("/").pop();
			var parent = path.substr(0, path.length - (file.length + 1)); // + 1 to remove the ending slash

			if (pathMap.exists(parent))
				pathMap.get(parent).push(file);
			else
				pathMap.set(parent, [file]);
		}

		return pathMap;
	}
	
	inline static public function iterateDirectory(Directory:String, Func)
	{
		var dir:String = Directory.endsWith("/") ? Directory.substr(0, -1) : Directory; // remove ending slash

		if (!pathMap.exists(dir))
			return;

		for (i in pathMap.get(dir))
			Func(i);
	}
	#else
	inline static public function iterateDirectory(Directory:String, Func):Bool
	{
		if (!FileSystem.exists(Directory) || !FileSystem.isDirectory(Directory))
			return false;
		
		for (i in FileSystem.readDirectory(Directory))
			Func(i);

		return true;
	}
	#end
	
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
			if (Assets.exists(path))
			#end
			{
				return path;
			}
		}
		return 'assets/videos/$key.mp4';
	}

	static public function flashMovie(key:String)
	{
		#if (MODS_ALLOWED && FUTURE_POLYMOD)
		var file:String = modsFlashMovie(key);
		if(FileSystem.exists(file)) {
			return file;
		}
		#end
		return 'assets/videos/$key.$FLASH_EXT';
	}

	static public function sound(key:String, ?library:String):Sound
	{
		var sound:Sound = returnSound('sounds', key, library);
		return sound;
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	static public function music(key:String, ?library:String):Sound
	{
		var file:Sound = returnSound('music', key, library);
		return file;
	}

	inline static public function track(song:String, track:String):Any
	{
		return returnSound('songs', '${formatToSongPath(song)}/$track');
	}

	inline static public function voices(song:String):Any
	{
		return track(song, "Voices");
	}

	inline static public function inst(song:String):Any
	{
		return track(song, "Inst");
	}

	static public function image(key:String, ?library:String):FlxGraphic
	{
		var returnAsset:FlxGraphic = returnGraphic(key, library);
		return returnAsset;
	}

	public static function fromI8(key:String, ?library:String):Null<Dynamic> {
		var Description:String = null;
		#if (MODS_ALLOWED && FUTURE_POLYMOD)
		if (FileSystem.exists(getPath('images/$key.json', TEXT, library)))
			Description = getPath('images/$key.json', TEXT, library);
		else if (FileSystem.exists(modFolders('images/$key.json')))
			Description = modFolders('images/$key.json');
		#else
		if (Assets.exists(getPath('images/$key.json', TEXT, library)))
			Description = getPath('images/$key.json', TEXT, library);
		#end

		var graphic:FlxGraphic = FlxG.bitmap.add(returnGraphic(key, library));
		if (graphic == null) {
			// please.
			FlxG.stage.window.alert(key + "'s graphic is not found, or is in a bad format. Try to see if you put it in the correct specified directory", 'Error on I8 IMAGE');
			return null;
		}

		// No need to parse data again
		var frames:FlxAtlasFrames = FlxAtlasFrames.findFrame(graphic); // gets it from the cache right away -lucky
		if (frames != null)
			return frames;

		if (Description == null) {
			// please.
			FlxG.stage.window.alert(key + "'s jsonI8 file is not found, or is in a bad format. Try to see if you put it in the correct specified directory", 'Error on I8JSON');
			return null;
		}

		frames = new FlxAtlasFrames(graphic);

		#if (MODS_ALLOWED && FUTURE_POLYMOD)
		if (FileSystem.exists(Description))
			Description = File.getContent(Description);
		#else
		if (Assets.exists(Description))
			Description = Assets.getText(Description);
		#end

		var json:{ frames:Dynamic, meta:Dynamic } = Json.parse(Description);
		var framelist = Reflect.fields(json.frames);

		for (framename in framelist)
		{
			var frame:I8frame = Reflect.field(json.frames, framename);
			var rect = FlxRect.get(frame.frame.x, frame.frame.y, frame.frame.w, frame.frame.h);

			frames.addAtlasFrame(rect, FlxPoint.get(rect.width, rect.height), FlxPoint.get(), framename);
		}

		return frames;
	}

	// if you have multiple I8 Frames
	// Usage: Paths.fromI8Array([ImageIwant, ImageIwant1, ImageIwant2]);
	public static function fromI8Array(array:Array<String>, ?library:String):FlxAtlasFrames {
		var i8frames:Array<FlxAtlasFrames> = [];
		for (i8 in 0...array.length)
			i8frames.push(fromI8(array[i8], library));

		var parent = i8frames[0];
		i8frames.shift();

		for (frames in i8frames)
			for (frame in frames.frames)
				parent.pushFrame(frame);

		return parent;
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

	public static function fileExists(key:String, type:AssetType, ?ignoreMods:Bool = false, ?library:String = null)
	{
		#if (MODS_ALLOWED && FUTURE_POLYMOD)
		if(!ignoreMods)
		{
			for(mod in Mods.getGlobalMods())
				if (FileSystem.exists(mods('$mod/$key')))
					return true;

			if (FileSystem.exists(mods(Mods.currentModDirectory + '/' + key)) || FileSystem.exists(mods(key)))
				return true;
		}
		#end

		return Paths.exists(getPath(key, type));
	}

	inline static public function getSparrowAtlas(key:String, ?library:String):FlxAtlasFrames
	{
		#if (MODS_ALLOWED && FUTURE_POLYMOD)
		var imageLoaded:FlxGraphic = returnGraphic(key);

		return FlxAtlasFrames.fromSparrow(
			(imageLoaded != null ? imageLoaded : image(key, library)),
			(FileSystem.exists(modsXml(key)) ? File.getContent(modsXml(key)) : getPath('images/$key.xml', library))
		);
		#else
		return FlxAtlasFrames.fromSparrow(image(key, library), getPath('images/$key.xml', library));
		#end
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		#if (MODS_ALLOWED && FUTURE_POLYMOD)
		var imageLoaded:FlxGraphic = returnGraphic(key);
		var txtExists:Bool = FileSystem.exists(modFolders('images/$key.txt'));
		
		return FlxAtlasFrames.fromSpriteSheetPacker((imageLoaded != null ? imageLoaded : image(key, library)),
			(txtExists ? File.getContent(modFolders('images/$key.txt')) : getPath('images/$key.txt', library)));
		#else
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), getPath('images/$key.txt', library));
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
	public static function getGraphic(path:String):FlxGraphic
	{
		#if html5
		return FlxG.bitmap.add(path, false, path);
		#elseif sys
		return FlxGraphic.fromBitmapData(BitmapData.fromFile(path), false, path);
		#end
	}

	public static function returnGraphic(key:String, ?library:String)
	{
		#if (MODS_ALLOWED && FUTURE_POLYMOD)
		var modKey:String = modsImages(key);
		if (FileSystem.exists(modKey))
		{
			if (!currentTrackedAssets.exists(modKey)){
				var newGraphic:FlxGraphic = getGraphic(modKey);
				newGraphic.persist = true;
				currentTrackedAssets.set(modKey, newGraphic);
			}
			localTrackedAssets.push(modKey);
			return currentTrackedAssets.get(modKey);
		}
		#end

		var path = getPath('images/$key.png', IMAGE, library);
		if (Assets.exists(path, IMAGE))
		{
			if (!currentTrackedAssets.exists(path))
			{
				var newGraphic:FlxGraphic = getGraphic(path);
				newGraphic.persist = true;
				currentTrackedAssets.set(path, newGraphic);
			}
			localTrackedAssets.push(path);
			return currentTrackedAssets.get(path);
		}
		trace('oh no!!' + ' $key ' + 'returned null!');
		return null;
	}

	public static var currentTrackedSounds:Map<String, Sound> = [];
	
	public static function returnSoundPath(path:String, key:String, ?library:String)
	{
		#if (MODS_ALLOWED && FUTURE_POLYMOD)
		var file:String = modsSounds(path, key);
		if (FileSystem.exists(file))
			return file;
		
		#end
		var gottenPath:String = getPath('$path/$key.$SOUND_EXT', SOUND, library);
		return gottenPath;
	}

	public static function returnSound(path:String, key:String, ?library:String)
	{
		#if (MODS_ALLOWED && FUTURE_POLYMOD)
		var file:String = modsSounds(path, key);
		if (FileSystem.exists(file))
		{
			if (!currentTrackedSounds.exists(file))
				currentTrackedSounds.set(file, Sound.fromFile(file));
			
			localTrackedAssets.push(key);
			return currentTrackedSounds.get(file);
		}
		#end
		// I hate this so god damn much
		var gottenPath:String = getPath('$path/$key.$SOUND_EXT', SOUND, library);
		gottenPath = gottenPath.substring(gottenPath.indexOf(':') + 1, gottenPath.length);
		if (!currentTrackedSounds.exists(gottenPath))
			#if (MODS_ALLOWED && FUTURE_POLYMOD)
			currentTrackedSounds.set(gottenPath, Sound.fromFile('./$gottenPath'));
			#else
				currentTrackedSounds.set(
					gottenPath, 
					Assets.getSound((path == 'songs' ? folder = 'songs:' : '') + getPath('$path/$key.$SOUND_EXT', SOUND, library))
				);
			#end
		localTrackedAssets.push(gottenPath);
		return currentTrackedSounds.get(gottenPath);
	}

	#if (MODS_ALLOWED && FUTURE_POLYMOD)
	static final modFolderPath:String = "mods/";

	inline static public function mods(key:String = '')
		return modFolderPath + key;

	inline static public function modsFont(key:String)
		return modFolders('fonts/$key');

	inline static public function modsJson(key:String)
		return modFolders('data/$key.json');

	#if FUTURE_POLYMOD
	inline static public function appendTxt(key:String)
		return modFolders('_append/data/$key.txt');

	inline static public function appendJson(key:String)
		return modFolders('_append/data/$key.json');

	inline static public function appendXml(key:String)
		return modFolders('_append/data/$key.xml');

	inline static public function mergeTxt(key:String)
		return modFolders('_merge/data/$key.txt');

	inline static public function mergeJson(key:String)
		return modFolders('_merge/data/$key.json');

	inline static public function mergeXml(key:String)
		return modFolders('_merge/data/$key.xml');
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

	inline static public function modsFlashMovie(key:String)
		return modFolders('videos/$key.$FLASH_EXT');

	inline static public function modsSounds(path:String, key:String)
		return modFolders('$path/$key.$SOUND_EXT');

	inline static public function modsImages(key:String)
		return modFolders('images/$key.png');

	inline static public function modsXml(key:String)
		return modFolders('images/$key.xml');

	inline static public function modsTxt(key:String)
		return modFolders('images/$key.txt');

	inline static public function modsAchievements(key:String)
		return modFolders('achievements/$key.json');

	static public function modFolders(key:String) {
		if(Mods.currentModDirectory != null && Mods.currentModDirectory.length > 0) {
			var fileToCheck:String = mods(Mods.currentModDirectory + '/' + key);
			if(FileSystem.exists(fileToCheck)) {
				return fileToCheck;
			}
		}

		for(mod in Mods.getGlobalMods()){
			var fileToCheck:String = mods('$mod/$key');
			if(FileSystem.exists(fileToCheck))
				return fileToCheck;

		}
		return 'mods/$key';
	}

	static public function optionsExist(?key:String = null) // basically checks if a mod contains options
	{
		var modsFolder:Array<String> = Mods.getModDirectories();
		modsFolder.insert(0, '');

		if (key == null) {
			for(mod in modsFolder){
				var directory:String = mods(mod + '/options');
				if (FileSystem.exists(directory)) {
					for(file in FileSystem.readDirectory(directory)) {
						var fileToCheck:String = mods(mod + '/options/' + file);
						if(FileSystem.exists(fileToCheck) && fileToCheck.endsWith('.json'))
							return true;
					}
				}
			}
		}

		var directory:String = mods(key + '/options');
		if (FileSystem.exists(directory)) {
			for(file in FileSystem.readDirectory(directory)) {
				var fileToCheck:String = mods(key + '/options/' + file);
				if(FileSystem.exists(fileToCheck) && fileToCheck.endsWith('.json'))
					return true;
			}
		}
		return false;
	}

	#end
}