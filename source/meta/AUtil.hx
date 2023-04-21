package meta;

import lime.utils.Assets;

using StringTools;

class AUtil
{
	inline public static function txtSplit(path:String)
	{
		return [
			for (i in Assets.getText(path).trim().split('\n')) i.trim()
		];
	}
}