package system;

/**
 * crazy system shit!!!!!
 * originally from VS Marcello
 * used in VS Dave and Bambi
 * @see https://github.com/Lokitot/FNF-SoulEngine
 */

#if sys
import sys.io.File;
import sys.io.Process;
#end
import haxe.io.Bytes;

class CoolSystemStuff
{
	public static function getUsername():String
	{
		// uhh this one is self explanatory
		#if windows
		return Sys.getEnv("USERNAME");
		#else
		return Sys.getEnv("USER");
		#end
	}

	public static function getUserPath():String
	{
		// this one is also self explantory
		#if windows
		return Sys.getEnv("USERPROFILE");
		#else
		return Sys.getEnv("HOME");
		#end
	}

	public static function getTempPath():String
	{
		// gets appdata temp folder lol
		#if windows
		return Sys.getEnv("TEMP");
		#else
		// most non-windows os dont have a temp path, or if they do its not 100% compatible, so the user folder will be a fallback
		return Sys.getEnv("HOME");
		#end
	}

	public static function executableFileName():Dynamic // idk what type it was originally
	{
		#if windows
		var programPath = Sys.programPath().split("\\");
		#else
		var programPath = Sys.programPath().split("/");

		return programPath != null ? [programPath.length - 1] : null;
		#end
		return null;
	}

	public static function generateTextFile(fileContent:String, fileName:String):Void
	{
		#if desktop
		final path = CoolSystemStuff.getTempPath() + "/" + fileName + ".txt";

		File.saveContent(path, fileContent);
		#end

		#if windows
		Sys.command("start " + path);
		#elseif linux
		Sys.command("xdg-open " + path);
		#else
		Sys.command("open " + path);
		#end
	}
}