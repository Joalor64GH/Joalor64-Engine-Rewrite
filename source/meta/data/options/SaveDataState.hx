package meta.data.options;

class SaveDataState extends MusicBeatState
{
    	private var grpControls:FlxTypedGroup<Alphabet>;
	
	var controlsStrings:Array<String> = [
		"Reset High Scores",
		"Reset Week Progress",
		"Reset Achievement Data",
		"Reset ALL Data"
	];

    	var curSelected:Int = 0;

	override public function create()
	{
		super.create();

		#if desktop
		DiscordClient.changePresence("Save Data Menu", null);
		#end

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
        	bg.color = 0xFFea71fd;
		add(bg);

		var mainSide:FlxSprite = new FlxSprite().loadGraphic(Paths.image('mainSide'));
		mainSide.setGraphicSize(Std.int(mainSide.width * 0.75));
		mainSide.updateHitbox();
		mainSide.antialiasing = ClientPrefs.globalAntialiasing;
		add(mainSide);

		grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);

		for (i in 0...controlsStrings.length)
		{
			var controlLabel:Alphabet = new Alphabet(90, 320, controlsStrings[i], true);
			controlLabel.isMenuItem = true;
			controlLabel.targetY = i;
			controlLabel.snapToPosition();
			grpControls.add(controlLabel);
		}

        	changeSelection();

		FlxG.mouse.visible = true;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

        	if (controls.UI_UP_P || controls.UI_DOWN_P)
			changeSelection(controls.UI_UP_P ? -1 : 1);

		if (controls.BACK) 
		{
			MusicBeatState.switchState(new OptionsState());
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.mouse.visible = false;
		}
            
		if (controls.ACCEPT)
		{
			switch (curSelected)
            		{
				case 0:
					openSubState(new Prompt('Are you sure you want to reset your high scores?\nThis action is irreversible.', function() {
				        	clearScores();
				        	FlxG.sound.play(Paths.sound('confirmMenu'));
			        	}, function() {
					    	FlxG.sound.play(Paths.sound('cancelMenu'));
				    	}, false));
				case 1:
					openSubState(new Prompt('Are you sure you want to reset your week progress?\nThis action is irreversible.', function() {
				        	clearWeeks();
				        	FlxG.sound.play(Paths.sound('confirmMenu'));
			        	}, function() {
					    	FlxG.sound.play(Paths.sound('cancelMenu'));
				    	}, false));
				case 2:
					openSubState(new Prompt('Are you sure you want to reset all of your achievements?\nThis action is irreversible.', function() {
				        	clearAchievements();
				        	FlxG.sound.play(Paths.sound('confirmMenu'));
			        	}, function() {
					    FlxG.sound.play(Paths.sound('cancelMenu'));
				    	}, false));
				case 3:
					openSubState(new Prompt('Are you sure you want to reset ALL of your data?\nThis action is irreversible.', function() {
                        			clearWeeks();
                        			clearScores();                        
				        	clearAchievements();
				        	FlxG.sound.play(Paths.sound('confirmMenu'));
			        	}, function() {
					    FlxG.sound.play(Paths.sound('cancelMenu'));
				    	}, false));
			}
		}

		for (num => item in grpControls.members)
		{
			item.targetY = num - curSelected;
			item.alpha = (item.targetY == 0) ? 1 : 0.6;
		}
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		curSelected = FlxMath.wrap(curSelected + change, 0, controlsStrings.length - 1);
	}

    function clearScores() 
    {
            Highscore.songScores.clear();
            Highscore.songRating.clear();
            Highscore.weekScores.clear();
            FlxG.save.data.songScores = Highscore.songScores;
            FlxG.save.data.songRating = Highscore.songRating;
            FlxG.save.data.weekScores = Highscore.weekScores;
            FlxG.save.flush();
    }

    function clearWeeks() 
    {
            StoryMenuState.weekCompleted.clear();
            FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
            FlxG.save.flush();
    }

    function clearAchievements() 
    {
            Achievements.achievementsMap.clear();
	    Achievements.henchmenDeath = 0;
            FlxG.save.data.achievementsMap = Achievements.achievementsMap;
	    FlxG.save.data.achievementsUnlocked = null;
	    FlxG.save.data.henchmenDeath = Achievements.henchmenDeath;
            FlxG.save.flush();
    }
}