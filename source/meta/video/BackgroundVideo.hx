package meta.video;

import meta.video.*;

class BackgroundVideo
{
	private static var video:VideoHandler;
	private static var webm:WebmHandler;

	public static var isWebm:Bool = false;
	public static var isAndroid:Bool = false;
	public static var daAlpha1:Float = 0.2;
	public static var daAlpha2:Float = 1;

	inline public static function setVid(vid:VideoHandler):Void
	{
		if (vid != null)
			video = vid;
	}
	
	inline public static function getVid():VideoHandler
	{
		return (video != null) ? video : null;
	}
	
	inline public static function setWebm(vid:WebmHandler):Void
	{
		if (vid != null)
			webm = vid;
		isWebm = true;
	}
	
	inline public static function getWebm():WebmHandler
	{
		return (webm != null) ? webm : null;
	}
	
	public static function get():Dynamic
	{
		if (isWebm)
			return getWebm();

		return getVid();
	}

	public static function calc(ind:Int):Dynamic
	{
		var stageWidth:Int = openfl.Lib.current.stage.stageWidth;
		var stageHeight:Int = openfl.Lib.current.stage.stageHeight;

		var width:Float = 1280;
		var height:Float = 720;

		var ratioX:Float = height / width;
		var ratioY:Float = width / height;

		var appliedWidth:Float = stageHeight * ratioY;
		var appliedHeight:Float = stageWidth * ratioX;

		var remainingX:Float = stageWidth - appliedWidth;
		var remainingY:Float = stageHeight - appliedHeight;

		remainingX = remainingX / 2;
		remainingY = remainingY / 2;
		
		appliedWidth = Std.int(appliedWidth);
		appliedHeight = Std.int(appliedHeight);
		
		if (appliedHeight > stageHeight)
		{
			remainingY = 0;
			appliedHeight = stageHeight;
		}
		
		if (appliedWidth > stageWidth)
		{
			remainingX = 0;
			appliedWidth = stageWidth;
		}
		
		switch (ind)
		{
			case 0:
				return remainingX;
			case 1:
				return remainingY;
			case 2:
				return appliedWidth;
			case 3:
				return appliedHeight;
		}
		
		return null;
	}
}