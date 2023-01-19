package options;

//this is what happens when you try to recreate a feature from scratch
//i haven't tested it, but how did i do?
import FlxVideo;
import flixel.FlxG;

class TheSpecialState extends MusicBeatState
{
    var video:FlxVideo;
    public static var vidPaths:Array<String> = [
	'test',
        'test2'
    ];

    override function create()
    {
        video = new FlxVideo(randomizeVideo);
        video.finishCallback = () -> done();

        super.create();
    }

    function done() 
    {
        Sys.exit(0);
    }

    public static function randomizeVideo()
    {
	var chance:Int = FlxG.random.int(0, vidPaths.length - 1);
	return Paths.video('The Special/${vidPaths[chance]}');
    }
}
