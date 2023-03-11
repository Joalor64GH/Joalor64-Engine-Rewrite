package unused;

class Loader
{
	public var text(default, null):String;
	public var percent(default, set):Float;

	public function new()
	{
		text = '';
		percent = 0;
	}

	function set_percent(value:Float):Float
	{
		if (value % 10 == 0 && value > 0)
			text += '#';

		percent = value;

		if (percent > 100)
			percent = 100;

		return percent;
	}
}