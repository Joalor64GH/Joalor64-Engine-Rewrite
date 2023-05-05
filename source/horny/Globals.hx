package horny;

class Globals {
	public static var globals:Map<String, Dynamic> = [];
	
	public static function set(name:String, value:Dynamic) {
		globals.set(name, value);
	}
	
	public static function get(name:String):Dynamic {
		return globals.get(name);
	}
	
	public static function getKeys():Dynamic {
		return globals.keys();
	}
}