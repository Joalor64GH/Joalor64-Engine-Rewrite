package meta.substate;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;

import meta.*;
import meta.state.*;
import meta.state.PlayState;
import meta.substate.PauseSubState;

// ? <-- looks like the glottal stop!!
class ResultsSubState extends MusicBeatSubstate 
{
	var titleTxt:FlxText;
	var resultsTxt:FlxText;

    	var bg:FlxSprite;

	var sick = 0;
	var good = 0;
	var bad = 0;
	var shit = 0;
	var score = 0;
	var miss = 0;
	var percentage = 0.0;
	var rate = '';

    	public function new(sicks:Int, goods:Int, bads:Int, shits:Int, score:Int, misses:Int, percent:Float, rating:String) 
	{
        	super();

		sick = sicks;
		good = goods;
		bad = bads;
		shit = shits;
		score = score;
		miss = misses;
		percentage = percent;
		rate = rating;
	}

	override function create() 
	{
		persistentUpdate = true;

        	bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.screenCenter();
        	bg.alpha = 0.4;
        	add(bg);

        	titleTxt = new FlxText(0, 0, 0, (PauseSubState.daSelected == 'Skip Song') ? 'y u skip??' : 'RESULTS', 72);
		titleTxt.scrollFactor.set();
		titleTxt.setFormat("VCR OSD Mono", 48, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		titleTxt.screenCenter(X);
		titleTxt.updateHitbox();
		add(titleTxt);

		resultsTxt = new FlxText(0, 0, 0, 
			'Sicks: ' + sick
			+ '\nGoods: ' + good
			+ '\nBads: ' + bad
			+ '\nShits: ' + shit
			+ '\nScore: ' + score
			+ '\nMisses: ' + miss
			+ '\nPercent Rating: ' + percentage
			+ '\nRating: ' + rate
		, 72);
		resultsTxt.scrollFactor.set();
		resultsTxt.setFormat("VCR OSD Mono", 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		resultsTxt.screenCenter(XY);
		resultsTxt.updateHitbox();
		add(resultsTxt);

		super.create();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
    }

    override function update(elapsed:Float) 
    {
	super.update(elapsed);

	if (controls.ACCEPT) 
	{
	    if (PlayState.isStoryMode)
		MusicBeatState.switchState(new StoryMenuState());
	    else 
	    {
		if (PlayState.inMini) {
		    inMini = false;
		    MusicBeatState.switchState(new MinigamesState());
		} else {
		    MusicBeatState.switchState(new FreeplayState());
		}
            }
	}
    }
}
