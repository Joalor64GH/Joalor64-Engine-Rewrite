package meta.state;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.util.FlxColor;

import meta.*;
import meta.state.*;
import meta.data.*;
import meta.data.alphabet.*;

using StringTools;

class TestState extends MusicBeatState
{
    public var bg:FlxSprite;
    public var disc:FlxSprite;
    public var musplayer:FlxSprite;
    public var playerneedle:FlxSprite;

    public var nameTxt:Alphabet;
    public var testTxt:Alphabet;

    override public function create()
    {
        super.create();

        bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
        bg.scale.set(10, 10);
	bg.screenCenter();
        add(bg);
        
        musplayer = new FlxSprite(0, 0).loadGraphic(Paths.image('test/musplayer'));
        musplayer.screenCenter();
        musplayer.antialiasing = ClientPrefs.globalAntialiasing;
        add(musplayer);
        playerneedle = new FlxSprite(0, 0).loadGraphic(Paths.image('test/playerneedle'));
        playerneedle.screenCenter();
        playerneedle.antialiasing = ClientPrefs.globalAntialiasing;
        add(playerneedle);
        disc = new FlxSprite(0, 0).loadGraphic(Paths.image('test/disk'));
        disc.setPosition(musplayer.x + 268, musplayer.y + 13);
        disc.antialiasing = ClientPrefs.globalAntialiasing;
        disc.angularVelocity = 30;
        add(disc);

        nameTxt = new Alphabet(musplayer.x + 90, musplayer.y - 120, 'Test', true);
        add(nameTxt);
        testTxt = new Alphabet(nameTxt.x, musplayer.height + 140, 'This is a test.', true);
        add(testTxt);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (controls.BACK)
        {
            FlxG.sound.play(Paths.sound('cancelMenu'));
            if (ClientPrefs.simpleMain)
		MusicBeatState.switchState(new SimpleMainMenuState());
	    else
		MusicBeatState.switchState(new MainMenuState());
        }
    }

    override function beatHit()
    {
        super.beatHit();            
    }
}
