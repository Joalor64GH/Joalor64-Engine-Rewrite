package meta.data.options;

import backend.Localization.Locale;

class LanguageState extends MusicBeatState 
{
    	var coolGrp:FlxTypedGroup<Alphabet>;
		var iconArray:Array<AttachedSprite> = [];
	var langStrings:Array<Locale> = [];
    	var curSelected:Int = 0;

	override function create()
	{
		super.create();

		var initLangString = CoolUtil.coolTextFile(Paths.getPath('locales/languagesData.txt'));

        if (Assets.exists(Paths.getPath('locales/languagesData.txt')))
        {
            initLangString = Assets.getText(Paths.getPath('locales/languagesData.txt')).trim().split('\n');

            for (i in 0...initLangString.length)
                initLangString[i] = initLangString[i].trim();
        }

        for (i in 0...initLangString.length)
        {
            var data:Array<String> = initLangString[i].split(':');
            langStrings.push(new Locale(data[0], data[1]));
        }
        
        #if MODS_ALLOWED
        var filesPushed:Array<String> = [];
        var foldersToCheck:Array<String> = [Paths.mods('locales/')];

        if (Mods.currentModDirectory != null && Mods.currentModDirectory.length > 0)
            foldersToCheck.insert(0, Paths.mods(Mods.currentModDirectory + '/locales/'));

        for (mod in Mods.getGlobalMods())
            foldersToCheck.insert(0, Paths.mods(mod + '/locales/'));
        
        for (folder in foldersToCheck) {
            if (FileSystem.exists(folder) && FileSystem.isDirectory(folder)) {
                var path:String = folder + "languagesData.txt";
                if (FileSystem.exists(path)) {
                    var modLangData:String = File.getContent(path).trim();
                    var modLangDataSplit:Array<String> = modLangData.split(':');

                    if (modLangDataSplit.length == 2)
                        langStrings.push(new Locale(modLangDataSplit[0], modLangDataSplit[1]));

                    filesPushed.push(path);
                }
            }
        }
        #end

		#if desktop
		DiscordClient.changePresence("Languages Menu", null);
		#end

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		bg.screenCenter();
        	bg.color = 0xFFea71fd;
		add(bg);

		coolGrp = new FlxTypedGroup<Alphabet>();
		add(coolGrp);

		for (i in 0...langStrings.length)
		{
			var label:Alphabet = new Alphabet(200, 320, langStrings[i].lang, true);
            label.isMenuItem = true;
            label.targetY = i;
            label.snapToPosition();
            coolGrp.add(label);

			var assetPath = 'flags/' + langStrings[i].code;
			var animString = Assets.exists(Paths.getSparrowAtlas(assetPath)) ? langStrings[i].code : 'flag_base';
			
			var icon:AttachedSprite = new AttachedSprite();
			icon.frames = Assets.exists(Paths.getSparrowAtlas(assetPath)) ? 
				Paths.getSparrowAtlas(assetPath) : Paths.getSparrowAtlas('flags/null'); // fallback attempt idk??
            icon.animation.addByPrefix('idle', animString, 24);
            icon.animation.play('idle');
            icon.xAdd = -icon.width - 10;
            icon.sprTracker = label;
            iconArray.push(icon);
            add(icon);
		}

        	changeSelection();
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
		}
            
		if (controls.ACCEPT)
		{
			ClientPrefs.language = langStrings[curSelected].code;
			Localization.switchLanguage(ClientPrefs.language);
			FlxG.sound.play(Paths.sound('confirmMenu'));
			ClientPrefs.saveSettings();
            MusicBeatState.switchState(new OptionsState());
		}

		for (num => item in coolGrp.members)
		{
			item.targetY = num - curSelected;
			item.alpha = (item.targetY == 0) ? 1 : 0.6;
		}
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		curSelected = FlxMath.wrap(curSelected + change, 0, langStrings.length - 1);
	}
}