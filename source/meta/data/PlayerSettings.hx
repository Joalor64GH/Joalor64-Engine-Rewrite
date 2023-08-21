package meta.data;

import meta.Controls;
import flixel.FlxG;

class PlayerSettings
{
	static public var player1(default, null):PlayerSettings;

	public var id(default, null):Int;

	public final controls:Controls;

	function new(scheme)
		this.controls = new Controls('player0', scheme);

	public function setKeyboardScheme(scheme)
		controls.setKeyboardScheme(scheme);

	static public function init():Void
	{
		if (player1 == null)
			player1 = new PlayerSettings(Solo);

		var numGamepads = FlxG.gamepads.numActiveGamepads;
		if (numGamepads > 0)
		{
			var gamepad = FlxG.gamepads.getByID(0);
			if (gamepad == null)
				throw 'Unexpected null gamepad. id:0';

			player1.controls.addDefaultGamepad(0);
		}
	}

	static public inline function reset()
		player1 = null;
}
