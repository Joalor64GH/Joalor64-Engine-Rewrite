package backend;

@:keepInit class ALSoftConfig {
	#if desktop
	static function __init__():Void {
		var origin:String = #if hl Sys.getCwd() #else Sys.programPath() #end;

		var configPath:String = Path.directory(Path.withoutExtension(origin));
		#if windows
		configPath += "/alsoft.ini";
		#elseif mac
		configPath = Path.directory(configPath) + "/Resources/alsoft.conf";
		#else
		configPath += "/alsoft.conf";
		#end

		Sys.putEnv("ALSOFT_CONF", configPath);
	}
	#end
}