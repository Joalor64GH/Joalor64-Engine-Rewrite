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
import meta.data.*;

class ResultsSubState extends MusicBeatSubstate 
{
	var titleTxt:FlxText;
	var resultsTxt:FlxText;

    	var bg:FlxSprite;

	var sicks:Int;
	var goods:Int;
	var bads:Int;
	var shits:Int;
	var score:Int;
	var misses:Int;
	var percent:Float;
	var rating:String;
	var fc:String;

    	public function new(sicks:Int, goods:Int, bads:Int, shits:Int, score:Int, misses:Int, percent:Float, rating:String, fc:String) 
	{
        	super();

		this.sicks = sicks;
		this.goods = goods;
		this.bads = bads;
		this.shits = shits;
		this.score = score;
		this.misses = misses;
		this.percent = percent;
		this.rating = rating;
		this.fc = fc;
	}

	override function create() 
	{
		persistentUpdate = true;

		FlxG.sound.music.fadeIn(4, 0, 0.7);
		FlxG.sound.playMusic(Paths.music('breakfast'), 1);

        	bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
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

		resultsTxt = new FlxText(titleTxt.x, 0, 0, 
			'Sicks: ' + sicks
			+ '\nGoods: ' + goods
			+ '\nBads: ' + bads
			+ '\nShits: ' + shits
			+ '\nScore: ' + score
			+ '\nMisses: ' + misses
		, 72);
		resultsTxt.scrollFactor.set();
		resultsTxt.setFormat("VCR OSD Mono", 45, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		resultsTxt.screenCenter(XY);
		resultsTxt.updateHitbox();
		add(resultsTxt);

		if (ClientPrefs.scoreTxtType != 'Simple')
		{
			resultsTxt.text += '\nPercent Rating: ' + percent + '%' + '\nRating: ' + rating + ' (' + fc + ')';
		}

		versionShit.alpha = 0;
		resultsTxt.alpha = 0;
		titleTxt.alpha = 0;
		bg.alpha = 0;

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