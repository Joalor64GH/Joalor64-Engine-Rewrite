package meta.state;

class FlashingState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var bg:FlxSprite;

	override function create()
	{
		super.create();

		bg = new FlxSprite().loadGraphic(Localization.getLocalizedImage('warning', ClientPrefs.lang));
		add(bg);
	}

	override function update(elapsed:Float)
	{
		if (!leftState) {
			var accept:Bool = FlxG.keys.justPressed.ENTER;
			if (FlxG.keys.justPressed.ESCAPE || accept) {
				leftState = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxTween.tween(bg, {alpha: 0}, 1, {
					onComplete: function(twn:FlxTween) {
						MusicBeatState.switchState(new TitleState());
					}
				});

				if (!accept) {
					ClientPrefs.flashing = false;
					ClientPrefs.saveSettings();
				}
			}
		}
		super.update(elapsed);
	}
}