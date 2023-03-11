package meta.video;

import meta.video.*;
import flixel.FlxSprite;
#if WEBM_ALLOWED
import webm.*;
#end

/**
	In order to not experience a very low framerate or get any crashes related to webm codec. 
	Use Wondershare Uniconverter to convert your videos to webm (1280x720)
**/
// Separated class instead of making this shit every time you want to put a video mid-song (-Bolo)
class WebmSprite extends FlxSprite
{
	#if WEBM_ALLOWED
	public var webmHandler:WebmHandler;

	private var blackDisplay = 'assets/videos/DO NOT DELETE OR GAME WILL CRASH/dontDelete.webm';

	public function new(X:Float = 0, Y:Float = 0)
	{
		super(X, Y);
		webmHandler = new WebmHandler();
	}

	public function loadVideo(vidPath:String)
	{ // Load the video you want
		webmHandler.source(blackDisplay); // Load black screen to not get null exception during sex.
		WebmPlayer.SKIP_STEP_LIMIT = 90;
		webmHandler.makePlayer();
		webmHandler.webm.name = 'WEBM SHIT';
		webmHandler.source(vidPath);
		webmHandler.clearPause();
		webmHandler.updatePlayer();
		webmHandler.show();
		webmHandler.restart();

		loadGraphic(webmHandler.webm.bitmapData);

		if (!PlayState.instance.songStarted)
			webmHandler.pause();
		else
			webmHandler.resume();
	}
	#end
}