package meta.state;

class OutdatedState extends MusicBeatState
{
	public static var leftState:Bool = false;
	public static var mustUpdate:Bool = false;
	public static var daJson:Dynamic;

	var warnText:FlxText;
	
	override function create()
	{
		super.create();

		warnText = new FlxText(0, 0, FlxG.width,
			"Hey! You're running an outdated version of Joalor64 Engine Rewritten!\n
			Your current version is v" + MainMenuState.joalor64EngineVersion + ", while the most recent version is v" + daJson.version + "!\n
			What's New:\n"
			+ daJson.description +
			"\nPress ENTER to go to GitHub. Otherwise, press ESCAPE to proceed anyways.\n
 			Thank you for using the Engine! :)",
			32);
		warnText.setFormat(Paths.font('vcr.ttf'), 25, FlxColor.WHITE, CENTER);
		warnText.screenCenter(XY);
		add(warnText);
	}

	public static function updateCheck()
	{
		trace('checking for updates...');
		var http = new Http('https://raw.githubusercontent.com/Joalor64GH/Joalor64-Engine-Rewrite/main/gitVersion.json');
		http.onData = function(data:String)
		{
			var daRawJson:Dynamic = Json.parse(data);
			if (daRawJson.version != MainMenuState.joalor64EngineVersion)
			{
				trace('oh noo outdated!!');
				daJson = daRawJson;
				mustUpdate = true;
			}
			else
				mustUpdate = false;
		}

		http.onError = (error) -> trace('error: $error');
		http.request();
	}

	override function update(elapsed:Float)
	{
		if(!leftState) {
			if (controls.ACCEPT) {
				leftState = true;
				CoolUtil.browserLoad("https://github.com/Joalor64GH/Joalor64-Engine-Rewrite/releases");
			}
			else if(controls.BACK) {
				leftState = true;
			}

			if(leftState)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxTween.tween(warnText, {alpha: 0}, 1, {
					onComplete: function (twn:FlxTween) {
						if (FlxG.save.data.flashing == null && !FlashingState.leftState)
							MusicBeatState.switchState(new FlashingState());
						else
							MusicBeatState.switchState(new TitleState());
					}
				});
			}
		}
		super.update(elapsed);
	}
}