package meta.data.options;

//this is what happens when you try to recreate a feature from scratch
//i haven't tested it, but how did i do?
import meta.video.FlxVideo;
import flixel.FlxG;

class TheSpecialState extends meta.MusicBeatState
{
    var video:FlxVideo;
    public static var vidPaths:Array<String> = [
	'a',
        'albion online',
        'amogus',
        'among',
        'apple',
        'asterisk',
        'beluga',
        'cheating',
        'death',
        'disobedient',
        'fart',
        'funi',
        'gun',
        'heavy',
        'here i come',
        'hey alvin',
        'ip',
        'jijijija',
        'poopy',
        'sonic',
        'stove',
        'toddler',
        'xbox live',
        'yo mama'
    ];

    override function create()
    {
        video = new FlxVideo(randomizeVideo());
        video.finishCallback = () -> done();

        super.create();
    }

    function done() 
    {
        video.kill();
        video.destroy();
        Sys.exit(0);
    }

    public static function randomizeVideo()
    {
	var chance:Int = FlxG.random.int(0, vidPaths.length - 1);
	return Paths.video('The Special/${vidPaths[chance]}');
    }
}
