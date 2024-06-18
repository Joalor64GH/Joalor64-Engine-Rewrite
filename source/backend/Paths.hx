package backend;

import openfl.media.Sound;

using haxe.io.Path;

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

@:keep
@:access(openfl.display.BitmapData)
class Paths
{
	inline public static final SOUND_EXT = #if !web "ogg" #else "mp3" #end;

	public static function excludeAsset(key:String) {
		if (!dumpExclusions.contains(key))
			dumpExclusions.push(key);
	}

	public static var dumpExclusions:Array<String> = ['assets/music/freakyMenu.$SOUND_EXT'];

	@:noCompletion private inline static function _gc(major:Bool) {
		#if (cpp || neko)
		Gc.run(major);
		#elseif hl
		Gc.major();
		#end
	}

	@:noCompletion public inline static function compress() {
		#if cpp
		Gc.compact();
		#elseif hl
		Gc.major();
		#elseif neko
		Gc.run(true);
		#end
	}

	public inline static function gc(major:Bool = false, repeat:Int = 1) {
		while(repeat-- > 0) _gc(major);
	}


	public static function clearUnusedMemory()
	{
		for (key in currentTrackedAssets.keys())
		{
			// if it is not currently contained within the used local assets
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key))
			{
				destroyGraphic(currentTrackedAssets.get(key)); // get rid of the graphic
				currentTrackedAssets.remove(key); // and remove the key from local cache map
			}
		}
		// run the garbage collector for good measure lmfao
		compress();
		gc(true);
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

	@:access(flixel.system.frontEnds.BitmapFrontEnd._cache)
	public static function clearStoredMemory()
	{
		for (key in FlxG.bitmap._cache.keys())
		{
			if (!currentTrackedAssets.exists(key))
				destroyGraphic(FlxG.bitmap.get(key));
		}

		for (key => asset in currentTrackedSounds)
		{
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key) && asset != null)
			{
				Assets.cache.clear(key);
				currentTrackedSounds.remove(key);
			}
		}
		// flags everything to be cleared out next unused memory clear
		localTrackedAssets = [];
		Assets.cache.clear("songs");
		gc(true);
		compress();
	}

	inline static function destroyGraphic(graphic:FlxGraphic)
	{
		if (graphic != null && graphic.bitmap != null && graphic.bitmap.__texture != null)
			graphic.bitmap.__texture.dispose();
		FlxG.bitmap.remove(graphic);
	}

	private static var trackedBitmaps:Map<String, BitmapData> = new Map();

	public static function setBitmap(id:String, ?bitmap:BitmapData):BitmapData
	{
		if (!trackedBitmaps.exists(id) && bitmap != null)
			trackedBitmaps.set(id, bitmap);
		pushTracked(id);
		return trackedBitmaps.get(id);
	}

	public static function disposeBitmap(id:String)
	{
		var obj:Null<BitmapData> = trackedBitmaps.get(id);
		if (obj != null)
		{
			obj.dispose();
			obj.disposeImage();
			obj = null;
			trackedBitmaps.remove(id);
		}
	}

	public static function pushTracked(file:String)
	{
		if (!localTrackedAssets.contains(file))
			localTrackedAssets.push(file);
	}

	public static function getPath(file:String, ?modsAllowed:Bool = false):String
	{
		#if MODS_ALLOWED
		if (modsAllowed)
			if (FileSystem.exists(modFolders(file))) return modFolders(file);
		#end

		return getPreloadPath(file);
	}
	
	inline public static function getPreloadPath(file:String = '')
		return 'assets/$file';

	inline static public function txt(key:String)
		return getPath('data/$key.txt');

	inline static public function xml(key:String) 
		return getPath('data/$key.xml');

	inline static public function json(key:String)
		return getPath('data/$key.json');

	#if yaml
	inline static public function yaml(key:String)
		return getPath('data/$key.yaml');
	#end

	inline static public function shaderFragment(key:String) 
		return getPath('shaders/$key.frag');

	inline static public function shaderVertex(key:String) 
		return getPath('shaders/$key.vert');
	
	inline static public function lua(key:String)
		return getPath('$key.lua');

	inline static public function hscript(key:String)
		return getPath('$key.hscript');

	inline static public function hx(key:String)
		return getPath('$key.hx');

	inline static public function exists(asset:String)
	{
		#if sys 
		return FileSystem.exists(asset);
		#else
		return Assets.exists(asset);
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
	
	inline static public function iterateDirectory(Directory:String, Func:String->Void)
	{
		var dir:String = Directory.endsWith("/") ? Directory.substr(0, -1) : Directory; // remove ending slash

		if (!pathMap.exists(dir))
			return;

		for (i in pathMap.get(dir))
			Func(i);
	}
	#else
	inline static public function iterateDirectory(Directory:String, Func:String->Void):Bool
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
		#if MODS_ALLOWED
		if (FileSystem.exists(modsVideo(key))) return modsVideo(key);
		#end
		return getPath('videos/$key.mp4');
	}

	static public function webm(key:String)
	{
		#if MODS_ALLOWED
		if (FileSystem.exists(modsWebm(key))) return modsWebm(key);
		#end
		return getPath('videos/$key.webm');
	}

	static public function webmSound(key:String)
		return getPath('videos/$key.ogg');

	static public function flashMovie(key:String)
	{
		#if MODS_ALLOWED
		if (FileSystem.exists(modsFlashMovie(key))) return modsFlashMovie(key);
		#end
		return getPath('videos/$key.swf');
	}

	static public function sound(key:String):Sound
		return returnSound('sounds', key);

	inline static public function soundRandom(key:String, min:Int, max:Int)
		return sound(key + FlxG.random.int(min, max));

	static public function music(key:String):Sound
		return returnSound('music', key);

	inline static public function track(song:String, track:String):Any
		return returnSound('songs', '${formatToSongPath(song)}/$track');

	inline static public function voices(song:String):Any
		return track(song, "Voices");

	inline static public function inst(song:String):Any
		return track(song, "Inst");

	static public function image(key:String):FlxGraphic
		return returnGraphic(key);

	public static function fromI8(key:String):Null<Dynamic> {
		var Description:String = null;
		#if MODS_ALLOWED
		if (FileSystem.exists(getPath('images/$key.json')))
			Description = getPath('images/$key.json');
		else if (FileSystem.exists(modFolders('images/$key.json')))
			Description = modFolders('images/$key.json');
		#else
		if (Assets.exists(getPath('images/$key.json')))
			Description = getPath('images/$key.json');
		#end

		var graphic:FlxGraphic = FlxG.bitmap.add(returnGraphic(key));
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

		#if MODS_ALLOWED
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
	public static function fromI8Array(array:Array<String>):FlxAtlasFrames {
		var i8frames:Array<FlxAtlasFrames> = [];
		for (i8 in 0...array.length)
			i8frames.push(fromI8(array[i8]));

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
		#if MODS_ALLOWED
		if (!ignoreMods && FileSystem.exists(modFolders(key)))
			return File.getContent(modFolders(key));
		#end

		if (FileSystem.exists(getPreloadPath(key)))
			return File.getContent(getPreloadPath(key));
		#end

		return Assets.getText(getPath(key));
	}

	inline static public function font(key:String)
	{
		#if MODS_ALLOWED
		if (FileSystem.exists(modsFont(key))) return modsFont(key);
		#end

		var path:String = getPath('fonts/$key');

		if (path.extension() == '')
		{
			if (exists(path.withExtension("ttf")))
				path = path.withExtension("ttf");
			else if (exists(path.withExtension("otf")))
				path = path.withExtension("otf");
		}

		return path;
	}

	public static function fileExists(key:String, ?ignoreMods:Bool = false)
	{
		#if MODS_ALLOWED
		if (!ignoreMods)
		{
			for (mod in Mods.getGlobalMods())
				if (FileSystem.exists(mods('$mod/$key')))
					return true;

			if (FileSystem.exists(mods(Mods.currentModDirectory + '/' + key)) || FileSystem.exists(mods(key)))
				return true;

			if (FileSystem.exists(mods('$key')))
				return true;
		}
		#end

		return (Assets.exists(getPath(key, false))) ? true : false;
	}

	inline static public function getSparrowAtlas(key:String):FlxAtlasFrames
	{
		#if MODS_ALLOWED
		var imageLoaded:FlxGraphic = returnGraphic(key);

		return FlxAtlasFrames.fromSparrow(
			(imageLoaded != null ? imageLoaded : image(key)),
			(FileSystem.exists(modsXml(key)) ? File.getContent(modsXml(key)) : getPath('images/$key.xml'))
		);
		#else
		return FlxAtlasFrames.fromSparrow(image(key), getPath('images/$key.xml'));
		#end
	}

	inline static public function getPackerAtlas(key:String)
	{
		#if MODS_ALLOWED
		var imageLoaded:FlxGraphic = returnGraphic(key);
		var txtExists:Bool = FileSystem.exists(modFolders('images/$key.txt'));
		
		return FlxAtlasFrames.fromSpriteSheetPacker((imageLoaded != null ? imageLoaded : image(key)),
			(txtExists ? File.getContent(modFolders('images/$key.txt')) : getPath('images/$key.txt')));
		#else
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key), getPath('images/$key.txt'));
		#end
	}

	inline static public function formatToSongPath(path:String) {
		var invalidChars = ~/[~&\\;:<>#]/;
		var hideChars = ~/[.,'"%?!]/;

		var path = invalidChars.split(path.replace(' ', '-')).join("-");
		return hideChars.split(path).join("").toLowerCase();
	}

	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
	public static function getGraphic(path:String):FlxGraphic
	{
		#if html5
		return FlxG.bitmap.add(path, false, path);
		#elseif sys
		return FlxGraphic.fromBitmapData(BitmapData.fromFile(path), false, path);
		#end
	}

	public static function returnGraphic(key:String)
	{
		#if MODS_ALLOWED
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

		var path = getPath('images/$key.png');
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
		trace('oh no!! $key returned null!');
		return null;
	}

	public static var currentTrackedSounds:Map<String, Sound> = [];
	
	public static function returnSoundPath(path:String, key:String)
	{
		#if MODS_ALLOWED
		if (FileSystem.exists(modsSounds(path, key))) return modsSounds(path, key);
		#end
		return getPath('$path/$key.$SOUND_EXT');
	}

	public static function returnSound(path:String, key:String)
	{
		#if MODS_ALLOWED
		var file:String = modsSounds(path, key);
		if (FileSystem.exists(file))
		{
			if (!currentTrackedSounds.exists(file))
				currentTrackedSounds.set(file, Sound.fromFile(file));
			
			localTrackedAssets.push(key);
			return currentTrackedSounds.get(file);
		}
		#end
		var gottenPath:String = getPath('$path/$key.$SOUND_EXT');
		gottenPath = gottenPath.substring(gottenPath.indexOf(':') + 1, gottenPath.length);
		if (!currentTrackedSounds.exists(gottenPath))
			#if MODS_ALLOWED
			currentTrackedSounds.set(gottenPath, Sound.fromFile('./$gottenPath'));
			#else
				currentTrackedSounds.set(
					gottenPath, 
					Assets.getSound((path == 'songs' ? folder = 'songs:' : '') + getPath('$path/$key.$SOUND_EXT'))
				);
			#end
		localTrackedAssets.push(gottenPath);
		return currentTrackedSounds.get(gottenPath);
	}

	#if MODS_ALLOWED
	static final modFolderPath:String = "mods/";

	inline static public function mods(key:String = '')
		return modFolderPath + key;

	inline static public function modsFont(key:String)
		return modFolders('fonts/$key');

	inline static public function modsJson(key:String)
		return modFolders('data/$key.json');

	inline static public function modsVideo(key:String)
		return modFolders('videos/$key.mp4');

	inline static public function modsWebm(key:String)
		return modFolders('videos/$key.webm');
	
	inline static public function modsWebmSound(key:String)
		return modFolders('videos/$key.ogg');

	inline static public function modsFlashMovie(key:String)
		return modFolders('videos/$key.swf');

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
		if (Mods.currentModDirectory != null && Mods.currentModDirectory.length > 0)
			if (FileSystem.exists(mods(Mods.currentModDirectory + '/' + key)))
				return mods(Mods.currentModDirectory + '/' + key);

		for (mod in Mods.getGlobalMods())
			if (FileSystem.exists(mods('$mod/$key')))
				return mods('$mod/$key');
		
		return 'mods/$key';
	}

	@:deprecated("please ignore this")
	static public function optionsExist(?key:String = null)
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