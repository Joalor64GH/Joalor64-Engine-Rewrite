package meta.substate;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

import flixel.util.FlxColor;
import flixel.util.FlxTimer;

import meta.*;
import meta.state.*;
import meta.state.PlayState;

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
	var points = 0;
	var miss = 0;
	var percentage = 0.0;
	var rate = '';
	var combo = '';

    	public function new(sicks:Int, goods:Int, bads:Int, shits:Int, score:Int, misses:Int, percent:Float, rating:String, fc:String) 
	{
        	super();

		sick = sicks;
		good = goods;
		bad = bads;
		shit = shits;
		points = score;
		miss = misses;
		percentage = percent;
		rate = rating;
		combo = fc;
	}

	override function create() 
	{
		persistentUpdate = true;

        	bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        	bg.scale.set(10, 10);
        	bg.alpha = 0;
        	add(bg);

		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, 'Press ACCEPT to continue.', 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 26, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

        	titleTxt = new FlxText(0, 0, 0, 'RESULTS', 72);
		titleTxt.scrollFactor.set();
		titleTxt.setFormat("VCR OSD Mono", 60, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		titleTxt.screenCenter(X);
		titleTxt.updateHitbox();
		add(titleTxt);

		resultsTxt = new FlxText(0, 0, 0, 
			'Sicks: ' + sick
			+ '\nGoods: ' + good
			+ '\nBads: ' + bad
			+ '\nShits: ' + shit
			+ '\nScore: ' + points
			+ '\nMisses: ' + miss
			+ '\nPercent Rating: ' + percentage + '%'
			+ '\nRating: ' + rate + ' (' + combo + ')'
		, 72);
		resultsTxt.scrollFactor.set();
		resultsTxt.setFormat("VCR OSD Mono", 45, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		resultsTxt.screenCenter(XY);
		resultsTxt.updateHitbox();
		add(resultsTxt);

		versionShit.alpha = 0;
		resultsTxt.alpha = 0;
		titleTxt.alpha = 0;

		FlxTween.tween(bg, {alpha: 0.5}, 0.75, {ease: FlxEase.quadOut});
		FlxTween.tween(titleTxt, {alpha: 1}, 1, {ease: FlxEase.quadOut});
		FlxTween.tween(resultsTxt, {alpha: 1}, 2, {ease: FlxEase.quadOut});
		FlxTween.tween(versionShit, {alpha: 1}, 3, {ease: FlxEase.quadOut});

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
		    PlayState.inMini = false;
		    MusicBeatState.switchState(new MinigamesState());
		} else {
		    MusicBeatState.switchState(new FreeplayState());
		}
            }
	    FlxG.sound.playMusic(Paths.music('freakyMenu'));
	}
    }
}