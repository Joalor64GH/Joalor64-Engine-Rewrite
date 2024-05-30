package meta.substate;

// TO-DO: add rating sprites based on rating
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

	var fcSprite:FlxSprite;

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

        bg = new FlxSprite().loadGraphic(Paths.image('menuBGSubstate'));
		bg.scrollFactor.set();
		add(bg);

		var hint:FlxText = new FlxText(12, FlxG.height - 24, 0, 'You passed, but try getting under 10 misses for SDCB.', 12);
		hint.scrollFactor.set();
		hint.setFormat("VCR OSD Mono", 26, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(hint);

		switch (fc)
		{
			case 'SDCB':
				hint.text = 'Nice, but try not to miss at all for FC.';
			case 'FC':
				hint.text = 'Good job, but try getting bads at minimum for GFC.';
			case 'GFC':
				hint.text = 'You\'re getting there. Try getting goods at minimum for MFC.'
			case 'MFC':
				hint.text = 'Almost there! Try getting only sicks for SFC!';
			case 'SFC':
				hint.text = 'You did it! You\'re perfect!';
			case 'WTF??':
				hint.text = '...You suck.';
			case 'Cheater!' | 'BotPlay':
				hint.text = 'If you want something, disable Botplay.';
		}

		if (PlayState.practiceMode)
			hint.text = 'You did good, but you used practice mode. So you don\'t really get anything.';

        	titleTxt = new FlxText(0, 0, 0, 'RESULTS', 72);
		titleTxt.scrollFactor.set();
		titleTxt.setFormat("VCR OSD Mono", 60, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		titleTxt.screenCenter(X);
		titleTxt.updateHitbox();
		add(titleTxt);
		if (PlayState.isStoryMode) titleTxt.text += ' (STORY MODE)';

		resultsTxt = new FlxText(titleTxt.x, 0, 0, 
			'Sicks: ' + sicks
			+ '\nGoods: ' + goods
			+ '\nBads: ' + bads
			+ '\nShits: ' + shits
			+ '\nScore: ' + score
			+ '\nMisses: ' + misses
			+ '\nPercent Rating: ' + percent + '%' 
			+ '\nRating: ' + rating + ' (' + fc + ')'
		, 72);
		resultsTxt.scrollFactor.set();
		resultsTxt.setFormat("VCR OSD Mono", 45, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		resultsTxt.screenCenter(XY);
		resultsTxt.updateHitbox();
		add(resultsTxt);

		hint.alpha = 0;
		resultsTxt.alpha = 0;
		titleTxt.alpha = 0;
		bg.alpha = 0;

		FlxTween.tween(bg, {alpha: 0.55}, 0.75, {ease: FlxEase.quadOut});
		FlxTween.tween(titleTxt, {alpha: 1}, 1, {ease: FlxEase.quadOut});
		FlxTween.tween(resultsTxt, {alpha: 1}, 2, {ease: FlxEase.quadOut});
		FlxTween.tween(hint, {alpha: 1}, 3, {ease: FlxEase.quadOut});

		super.create();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
    }

    override function update(elapsed:Float) 
    {
	super.update(elapsed);

	if (FlxG.keys.justPressed.ANY) 
	{
	    if (PlayState.isStoryMode)
		FlxG.switchState(() -> new StoryMenuState());
	    else 
	    {
		if (PlayState.inMini) {
		    PlayState.inMini = false;
		    FlxG.switchState(() -> new MinigamesState());
		} else {
		    FlxG.switchState(() -> new FreeplayState());
		}
            }
	    FlxG.sound.playMusic(Paths.music('freakyMenu'));
	}
    }
}