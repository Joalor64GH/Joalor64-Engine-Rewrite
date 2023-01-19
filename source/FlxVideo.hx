package;

import openfl.net.NetStream;
import openfl.net.NetConnection;
import flixel.FlxG;
import openfl.media.Video;
import flixel.FlxBasic;

using StringTools;

class FlxVideo extends FlxBasic
{
	var video:Video;
	var netStream:NetStream;

	public var finishCallback:Void->Void; // it should be void->void not dynamic so it works as a callback

	override public function new(VideoAsset:String)
	{
		super();

		video = new Video();
		video.x = 0;
		video.y = 0;
		FlxG.addChildBelowMouse(video);

		var netConnection:NetConnection = new NetConnection();
		netConnection.connect(null);
		netStream = new NetStream(netConnection);
		netStream.client = {onMetaData: client_onMetaData};
		netConnection.addEventListener('netStatus', netConnection_onNetStatus);
		@:privateAccess
		netStream.play(Paths.file(VideoAsset));
	}

	public function finishVideo()
	{
		netStream.dispose();
		if (FlxG.game.contains(video))
		{
			FlxG.game.removeChild(video);
		}
		if (finishCallback != null)
		{
			finishCallback();
		}
	}

	private function client_onMetaData(e)
	{
		video.attachNetStream(netStream);
		video.width = FlxG.width;
		video.height = FlxG.height;
	}

	private function netConnection_onNetStatus(e)
	{
		if (e.info.code == 'NetStream.Play.Complete')
		{
			finishVideo();
		}
	}
}