package meta;

import lime.utils.Assets;

using StringTools;

class AUtil
{
	public static function txtSplit(path:String)
	{
		var tempArray:Array<String> = [];

		tempArray = Assets.getText(path).trim().split('\n');
		for (i in 0...tempArray.length)
		{
			tempArray[i] = tempArray[i].trim();
		}
		return tempArray;
	}
}