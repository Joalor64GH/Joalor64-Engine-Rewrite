package meta.data.options;

class SocialCreditState extends MusicBeatState
{
    public static var socialCredit:Int = 0;

    public static var wentDown:Bool = false;
    public static var wentUp:Bool = false;
    public static var underZero:Bool = false;

    var guy:FlxSprite;

	override public function create()
	{
		super.create();

        underZero = (socialCredit <= 0);

		#if desktop
		DiscordClient.changePresence("Social Credit Menu", null);
		#end

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
        	bg.color = 0xFFea71fd;
		add(bg);

        var titleTxt:Alphabet = new Alphabet(0, 40, "Your current social credit score:", false);
        titleTxt.screenCenter(X);
        add(titleTxt);

        var creditTxt:Alphabet = new Alphabet(5, FlxG.height - 444, Std.string(socialCredit), true);
        add(creditTxt);

        var creditTxt2:Alphabet = new Alphabet(5, FlxG.height - 300, "Social Credit", false);
        add(creditTxt2);

        guy = new FlxSprite(700, 0);
        guy.frames = Paths.getSparrowAtlas('socialcredit/socialCreditGuy');
        guy.animation.addByPrefix('default', 'default', 12);
        guy.animation.addByPrefix('shocked', 'ohno', 12);
        guy.animation.addByPrefix('why', 'waaa', 12);
        guy.animation.play('default');
        guy.screenCenter(Y);
        add(guy);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

        guy.animation.play((underZero) ? 'why' : (wentDown) ? 'shocked' : 'default');

		if (controls.BACK) 
		{
            underZero = wentDown = wentUp = false;
			MusicBeatState.switchState(new OptionsState());
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}
	}
}