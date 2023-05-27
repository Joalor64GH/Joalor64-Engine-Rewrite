package meta;

import meta.state.PlayState;
import openfl.utils.Assets;
import flixel.FlxG;

using StringTools;

class CoolUtil
{
	public static final defaultDifficulties:Array<String> = [
		'Easy',
		'Normal',
		'Hard'
	];
	public static final defaultDifficulty:String = 'Normal'; //The chart that has no suffix and starting difficulty on Freeplay/Story Mode

	public static var difficulties:Array<String> = [];

	inline public static function quantize(f:Float, snap:Float){
		// changed so this actually works lol
		var m:Float = Math.fround(f * snap);
		return (m / snap);
	}
	
	inline public static function getDifficultyFilePath(num:Null<Int> = null)
	{
		if (num == null) num = PlayState.storyDifficulty;
		return Paths.formatToSongPath((difficulties[num] != defaultDifficulty) ? '-' + difficulties[num] : '');
	}

	inline public static function difficultyString():String
		return difficulties[PlayState.storyDifficulty].toUpperCase();
	
	inline public static function boundTo(value:Float, min:Float, max:Float):Float
		return Math.max(min, Math.min(max, value));

	inline public static function coolTextFile(path:String):Array<String>
		return Assets.exists(path) ? [for (i in Assets.getText(path).trim().split('\n')) i.trim()] : [];

	// this is actual source code from VS Null https://gamebanana.com/wips/70592
	// now outdated 😅
	public static inline function coolerTextFile(path:String, daString:String = ''):String
		return Assets.exists(path) ? daString = Assets.getText(path).trim() : '';

	public static function coolReplace(string:String, sub:String, by:String):String
		return string.split(sub).join(by);

	//Example: "winter-horrorland" to "Winter Horrorland". Used for replays
	public static function coolSongFormatter(song:String):String
	{
		var swag:String = coolReplace(song, '-', ' ');
		var splitSong:Array<String> = swag.split(' ');

		for (i in 0...splitSong.length)
		{
			var firstLetter = splitSong[i].substring(0, 1);
			var coolSong:String = coolReplace(splitSong[i], firstLetter, firstLetter.toUpperCase());
			var splitCoolSong:Array<String> = coolSong.split('');

			coolSong = Std.string(splitCoolSong[0]).toUpperCase();

			for (e in 0...splitCoolSong.length)
				coolSong += Std.string(splitCoolSong[e+1]).toLowerCase();

			coolSong = coolReplace(coolSong, 'null', '');

			for (l in 0...splitSong.length)
			{
				var stringSong:String = Std.string(splitSong[l+1]);
				var stringFirstLetter:String = stringSong.substring(0, 1);

				var splitStringSong = stringSong.split('');
				stringSong = Std.string(splitStringSong[0]).toUpperCase();

				for (l in 0...splitStringSong.length)
					stringSong += Std.string(splitStringSong[l+1]).toLowerCase();

				stringSong = coolReplace(stringSong, 'null', '');

					coolSong += ' $stringSong';
			}

			song = coolSong.replace(' Null', '');
			return song;
		}

		return swag;
	}

	#if sys
	public static function coolPathArray(path:String):Array<String>
		return FileSystem.readDirectory(FileSystem.absolutePath(path));
	#end
	
	inline public static function listFromString(string:String):Array<String>
		return string.trim().split('\n').map(str -> str.trim());

	public static function dominantColor(sprite:flixel.FlxSprite):Int {
		var countByColor:Map<Int, Int> = [];
		for(col in 0...sprite.frameWidth){
			for(row in 0...sprite.frameHeight){
			  var colorOfThisPixel:Int = sprite.pixels.getPixel32(col, row);
			  if(colorOfThisPixel != 0){
				  if(countByColor.exists(colorOfThisPixel)){
				    countByColor[colorOfThisPixel] =  countByColor[colorOfThisPixel] + 1;
				  }else if(countByColor[colorOfThisPixel] != 13520687 - (2*13520687)){
					 countByColor[colorOfThisPixel] = 1;
				  }
			  }
			}
		 }
		var maxCount = 0;
		var maxKey:Int = 0;//after the loop this will store the max color
		countByColor[flixel.util.FlxColor.BLACK] = 0;
			for(key in countByColor.keys()){
			if(countByColor[key] >= maxCount){
				maxCount = countByColor[key];
				maxKey = key;
			}
		}
		return maxKey;
	}

	inline public static function numberArray(max:Int, ?min = 0):Array<Int>
		return [
			for (i in min...max) 
				i
		];

	//uhhhh does this even work at all? i'm starting to doubt
	inline public static function precacheSound(sound:String, ?library:String = null):Void
		Paths.sound(sound, library);

	inline public static function precacheMusic(sound:String, ?library:String = null):Void
		Paths.music(sound, library);

	inline public static function browserLoad(site:String) {
		#if linux
		Sys.command('/usr/bin/xdg-open', [site]);
		#else
		FlxG.openURL(site);
		#end
	}
}
