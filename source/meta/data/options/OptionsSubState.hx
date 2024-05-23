package meta.data.options;

import backend.Localization.Locale;

import objects.shaders.*;
import objects.userinterface.menu.*;

import flixel.input.keyboard.FlxKey;
import flixel.ui.FlxButton;

class ControlsSubState extends MusicBeatSubstate {
	private static var curSelected:Int = 1;
	private static var curAlt:Bool = false;

	private static var defaultKey:String = 'Reset to Default Keys';
	private var bindLength:Int = 0;

	var optionShit:Array<Dynamic> = [
		['NOTES'],
		['Left', 'note_left'],
		['Down', 'note_down'],
		['Up', 'note_up'],
		['Right', 'note_right'],
		[''],
		['UI'],
		['Left', 'ui_left'],
		['Down', 'ui_down'],
		['Up', 'ui_up'],
		['Right', 'ui_right'],
		[''],
		['Reset', 'reset'],
		['Accept', 'accept'],
		['Back', 'back'],
		['Pause', 'pause'],
		[''],
		['VOLUME'],
		['Mute', 'volume_mute'],
		['Up', 'volume_up'],
		['Down', 'volume_down'],
		[''],
		['DEBUG'],
		['Key 1', 'debug_1'],
		['Key 2', 'debug_2']
	];

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var grpInputs:Array<AttachedText> = [];
	private var grpInputsAlt:Array<AttachedText> = [];
	var rebindingKey:Bool = false;
	var nextAccept:Int = 5;

	public function new() {
		super();

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xFFea71fd;
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		#if sys
		ArtemisIntegration.setBackgroundFlxColor (bg.color);
		#end

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		optionShit.push(['']);
		optionShit.push([defaultKey]);

		for (i in 0...optionShit.length) {
			var isCentered:Bool = false;
			var isDefaultKey:Bool = (optionShit[i][0] == defaultKey);
			if(unselectableCheck(i, true)) {
				isCentered = true;
			}

			var optionText:Alphabet = new Alphabet(200, 300, optionShit[i][0], (!isCentered || isDefaultKey));
			optionText.isMenuItem = true;
			if(isCentered) {
				optionText.screenCenter(X);
				optionText.y -= 55;
				optionText.startPosition.y -= 55;
			}
			optionText.changeX = false;
			optionText.distancePerItem.y = 60;
			optionText.targetY = i - curSelected;
			optionText.snapToPosition();
			grpOptions.add(optionText);

			if(!isCentered) {
				addBindTexts(optionText, i);
				bindLength++;
				if(curSelected < 0) curSelected = i;
			}
		}
		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	var leaving:Bool = false;
	var bindingTime:Float = 0;
	override function update(elapsed:Float) {
		if(!rebindingKey) {
			if (controls.UI_UP_P || controls.UI_DOWN_P) {
				changeSelection(controls.UI_UP_P ? -1 : 1);
			}
			if (controls.UI_LEFT_P || controls.UI_RIGHT_P) {
				changeAlt();
			}

			if (controls.BACK) {
				ClientPrefs.reloadControls();
				close();
				FlxG.sound.play(Paths.sound('cancelMenu'));
			}

			if(controls.ACCEPT && nextAccept <= 0) {
				if(optionShit[curSelected][0] == defaultKey) {
					ClientPrefs.keyBinds = ClientPrefs.defaultKeys.copy();
					reloadKeys();
					changeSelection();
					FlxG.sound.play(Paths.sound('confirmMenu'));
				} else if(!unselectableCheck(curSelected)) {
					bindingTime = 0;
					rebindingKey = true;
					if (curAlt) {
						grpInputsAlt[getInputTextNum()].alpha = 0;
					} else {
						grpInputs[getInputTextNum()].alpha = 0;
					}
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}
			}
		} else {
			var keyPressed:Int = FlxG.keys.firstJustPressed();
			if (keyPressed > -1) {
				var keysArray:Array<FlxKey> = ClientPrefs.keyBinds.get(optionShit[curSelected][1]);
				keysArray[curAlt ? 1 : 0] = keyPressed;

				var opposite:Int = (curAlt ? 0 : 1);
				if(keysArray[opposite] == keysArray[1 - opposite]) {
					keysArray[opposite] = NONE;
				}
				ClientPrefs.keyBinds.set(optionShit[curSelected][1], keysArray);

				reloadKeys();
				FlxG.sound.play(Paths.sound('confirmMenu'));
				rebindingKey = false;
			}

			bindingTime += elapsed;
			if(bindingTime > 5) {
				if (curAlt) {
					grpInputsAlt[curSelected].alpha = 1;
				} else {
					grpInputs[curSelected].alpha = 1;
				}
				FlxG.sound.play(Paths.sound('scrollMenu'));
				rebindingKey = false;
				bindingTime = 0;
			}
		}

		if(nextAccept > 0) {
			nextAccept -= 1;
		}
		super.update(elapsed);
	}

	function getInputTextNum() {
		var num:Int = 0;
		for (i in 0...curSelected) {
			if(optionShit[i].length > 1) {
				num++;
			}
		}
		return num;
	}
	
	function changeSelection(change:Int = 0) {
		do {
			curSelected += change;
			if (curSelected < 0)
				curSelected = optionShit.length - 1;
			if (curSelected >= optionShit.length)
				curSelected = 0;
		} while(unselectableCheck(curSelected));

		var bullShit:Int = 0;

		for (i in 0...grpInputs.length) {
			grpInputs[i].alpha = 0.6;
		}
		for (i in 0...grpInputsAlt.length) {
			grpInputsAlt[i].alpha = 0.6;
		}

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			if(!unselectableCheck(bullShit-1)) {
				item.alpha = 0.6;
				if (item.targetY == 0) {
					item.alpha = 1;
					if(curAlt) {
						for (i in 0...grpInputsAlt.length) {
							if(grpInputsAlt[i].sprTracker == item) {
								grpInputsAlt[i].alpha = 1;
								break;
							}
						}
					} else {
						for (i in 0...grpInputs.length) {
							if(grpInputs[i].sprTracker == item) {
								grpInputs[i].alpha = 1;
								break;
							}
						}
					}
				}
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	function changeAlt() {
		curAlt = !curAlt;
		for (i in 0...grpInputs.length) {
			if(grpInputs[i].sprTracker == grpOptions.members[curSelected]) {
				grpInputs[i].alpha = 0.6;
				if(!curAlt) {
					grpInputs[i].alpha = 1;
				}
				break;
			}
		}
		for (i in 0...grpInputsAlt.length) {
			if(grpInputsAlt[i].sprTracker == grpOptions.members[curSelected]) {
				grpInputsAlt[i].alpha = 0.6;
				if(curAlt) {
					grpInputsAlt[i].alpha = 1;
				}
				break;
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	private function unselectableCheck(num:Int, ?checkDefaultKey:Bool = false):Bool {
		if(optionShit[num][0] == defaultKey) {
			return checkDefaultKey;
		}
		return optionShit[num].length < 2 && optionShit[num][0] != defaultKey;
	}

	private function addBindTexts(optionText:Alphabet, num:Int) {
		var keys:Array<Dynamic> = ClientPrefs.keyBinds.get(optionShit[num][1]);
		var text1 = new AttachedText(InputFormatter.getKeyName(keys[0]), 400, -55);
		text1.setPosition(optionText.x + 400, optionText.y - 55);
		text1.sprTracker = optionText;
		grpInputs.push(text1);
		add(text1);

		var text2 = new AttachedText(InputFormatter.getKeyName(keys[1]), 650, -55);
		text2.setPosition(optionText.x + 650, optionText.y - 55);
		text2.sprTracker = optionText;
		grpInputsAlt.push(text2);
		add(text2);
	}

	function reloadKeys() {
		while(grpInputs.length > 0) {
			var item:AttachedText = grpInputs[0];
			item.kill();
			grpInputs.remove(item);
			item.destroy();
		}
		while(grpInputsAlt.length > 0) {
			var item:AttachedText = grpInputsAlt[0];
			item.kill();
			grpInputsAlt.remove(item);
			item.destroy();
		}

		trace('Reloaded keys: ' + ClientPrefs.keyBinds);

		#if sys
		ArtemisIntegration.autoUpdateControls ();
		#end

		for (i in 0...grpOptions.length) {
			if(!unselectableCheck(i, true)) {
				addBindTexts(grpOptions.members[i], i);
			}
		}

		var bullShit:Int = 0;
		for (i in 0...grpInputs.length) {
			grpInputs[i].alpha = 0.6;
		}
		for (i in 0...grpInputsAlt.length) {
			grpInputsAlt[i].alpha = 0.6;
		}

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			if(!unselectableCheck(bullShit-1)) {
				item.alpha = 0.6;
				if (item.targetY == 0) {
					item.alpha = 1;
					if(curAlt) {
						for (i in 0...grpInputsAlt.length) {
							if(grpInputsAlt[i].sprTracker == item) {
								grpInputsAlt[i].alpha = 1;
							}
						}
					} else {
						for (i in 0...grpInputs.length) {
							if(grpInputs[i].sprTracker == item) {
								grpInputs[i].alpha = 1;
							}
						}
					}
				}
			}
		}
	}
}

class DeleteSavesSubState extends MusicBeatSubstate
{
    private var curSelected:Int = 0;
    private var grpName:FlxTypedGroup<Alphabet>;
    private var daList:Array<Array<Dynamic>> = [];

    private var noModsTxt:FlxText;
    private var descBox:FlxSprite;
	private var descText:FlxText;
    private var statusText:FlxText;

    public function new()
    {
        super();

        #if desktop
		DiscordClient.changePresence("Modpacks Options Saves Menu", null);
		#end

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xFFea71fd;
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

        noModsTxt = new FlxText(0, 0, FlxG.width, "NO MODPACK OPTIONS SAVES FOUND\nPRESS BACK TO EXIT", 48);
		if(FlxG.random.bool(0.1)) noModsTxt.text += '\nBITCH.';
		noModsTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		noModsTxt.scrollFactor.set();
		noModsTxt.borderSize = 2;
		add(noModsTxt);
		noModsTxt.screenCenter();

		grpName = new FlxTypedGroup<Alphabet>();
		add(grpName);

        var titleText:Alphabet = new Alphabet(75, 40, 'Modpacks Options Saves Menu', true);
		titleText.scaleX = 0.6;
		titleText.scaleY = 0.6;
		titleText.alpha = 0.4;
		add(titleText);

        descBox = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		descBox.alpha = 0.6;
		add(descBox);

        descText = new FlxText(50, 600, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);

        statusText = new FlxText(descBox.getGraphicMidpoint().x, descBox.y, descText.fieldWidth, "", 20);
		statusText.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		statusText.scrollFactor.set();
		statusText.borderSize = 1.4;
		add(statusText);

        var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

		var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, "Select a mod's options saves that you want to delete: Press ACCEPT to delete the selected save / Press RESET to delete every save.", 16);
		text.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT);
		text.scrollFactor.set();
		add(text);

        var active:Array<String> = Mods.getActiveModsDir();
        for (save in ClientPrefs.modsOptsSaves.keys())
        {
            var toCheck:Array<Dynamic> = [save, null, false];
            if (save != '') {
                var path:String = Paths.mods(save + '/pack.json');
                if (FileSystem.exists(path)) {
                    var rawJson:String = File.getContent(path);
                    if (rawJson != null && rawJson.length > 0) {
                        toCheck[1] = Reflect.getProperty(Json.parse(rawJson), "name");
                        toCheck[2] = active.contains(save);
                    }
                }
                daList.push(toCheck);
            }
            else daList.insert(0, toCheck);
        }

        if (daList.length > 0)
        {
            for (i in 0...daList.length)
            {
                var modName:Alphabet = new Alphabet(200, 360, daList[i][0] == '' ? 'Main Global Folder' : daList[i][0], true);
                modName.isMenuItem = true;
                grpName.add(modName);
            }
        }
        loadOptions();

        cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
    }

    private function loadOptions(mod:Array<Dynamic> = null)
    {
        if (mod != null) {
            ClientPrefs.modsOptsSaves.remove(mod[0]);
            grpName.remove(grpName.members[daList.indexOf(mod)], true);
            daList.remove(mod);
        }

        if (daList.length > 0)
        {
            noModsTxt.visible = false;
            for (i in 0...daList.length)
            {
                grpName.members[i].targetY = i;
                grpName.members[i].snapToPosition();
            }
            changeSelection(0, mod == null);
        }
        else noModsTxt.visible = true;
        descBox.visible = !noModsTxt.visible;
        descText.visible = !noModsTxt.visible;
        statusText.visible = !noModsTxt.visible;
    }

    var nextAccept:Int = 5;
    var holdTime:Float = 0;
    var noModsSine:Float = 0;
    override function update(elapsed:Float) {
        if(noModsTxt.visible)
		{
			noModsSine += 180 * elapsed;
			noModsTxt.alpha = 1 - Math.sin((Math.PI * noModsSine) / 180);
		}

        if (controls.BACK) {
            close();
            FlxG.sound.play(Paths.sound('cancelMenu'));
        }

        if (daList.length > 0 && nextAccept <= 0)
        {
            if (controls.RESET) {
                ClientPrefs.modsOptsSaves = [];
                daList = [];
                while (grpName.members.length > 0) {
                    grpName.remove(grpName.members[0], true);
                }

                loadOptions();
                FlxG.sound.play(Paths.sound('cancelMenu'));
            }

            if (controls.ACCEPT) {
                loadOptions(daList[curSelected]);
                FlxG.sound.play(Paths.sound('cancelMenu'));
            }

            if ((controls.UI_DOWN || controls.UI_UP) && daList.length > 1)
            {
                var shiftMult:Int = 1;
                if(FlxG.keys.pressed.SHIFT && daList.length > 5) shiftMult = 3;

                var upP = controls.UI_UP_P;
                var downP = controls.UI_DOWN_P;

                if (upP)
                {
                    changeSelection(-shiftMult);
                    holdTime = 0;
                }
                if (downP)
                {
                    changeSelection(shiftMult);
                    holdTime = 0;
                }

                var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
                holdTime += elapsed;
                var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

                if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
                {
                    changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
                }
            }
        }

        if (nextAccept > 0) {
			nextAccept -= 1;
		}

        super.update(elapsed);
    }

    function changeSelection(change:Int = 0, playSound:Bool = true)
	{
        if (playSound) {
            FlxG.sound.play(Paths.sound('scrollMenu'));
        }

        curSelected += change;
        if (curSelected < 0)
            curSelected = daList.length - 1;
        if (curSelected >= daList.length)
            curSelected = 0;

        var daString:String;
        if (daList[curSelected][0] == '') daString = "From the Main Global Folder.";
        else if (daList[curSelected][1] == null) daString = "Couldn't find Modpack's name.";
        else daString = "Modpack's name: " + daList[curSelected][1] + ".";
        descText.text = daString;
        descText.screenCenter(Y);
        descText.y += 270;

		var bullShit:Int = 0;

		for (item in grpName.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0) {
				item.alpha = 1;
			}
		}

        descBox.setPosition(descText.x - 10, descText.y - 10);
        descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
        descBox.updateHitbox();

        if (daList[curSelected][0] != '') {
			statusText.text = 'Status: ' + (daList[curSelected][2] ? 'Active' : 'Inactive');
			statusText.setPosition(descBox.getGraphicMidpoint().x, descBox.y - 15);
		}
		else statusText.text = '';
	}
}

class GameplaySubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Gameplay Preferences';
		rpcTitle = 'Gameplay Settings Menu'; //for Discord Rich Presence

		var option:Option = new Option('Note Splashes',
			"If unchecked, hitting \"Sick!\" notes won't show particles.",
			'noteSplashes',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Hide HUD',
			'If checked, hides most HUD elements.',
			'hideHud',
			'bool',
			false);
		addOption(option);
		
		var option:Option = new Option('Time Bar:',
			"What should the Time Bar display?",
			'timeBarType',
			'string',
			'Time Left',
			['Time Left', 'Time Elapsed', 'Song Name', 'Disabled']);
		addOption(option);

		var option:Option = new Option('Score Text Style:',
			"How should the score text look like?",
			'scoreTxtType',
			'string',
			'Default',
			['Default', 'Psych', 'Kade', 'Simple']);
		addOption(option);

		var option:Option = new Option('Camera Zooms',
			"If unchecked, the camera won't zoom in on a beat hit.",
			'camZooms',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Score Text Zoom on Hit',
			"If unchecked, disables the Score text zooming\neverytime you hit a note.",
			'scoreZoom',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Health Bar Transparency',
			'How much transparent should the health bar and icons be.',
			'healthBarAlpha',
			'percent',
			1);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);

		var option:Option = new Option('UI Skin:',
			"What should your Judgements look like?",
			'uiSkin',
			'string',
			'Default',
			['Default', 'Vanilla', 'Forever', 'Kade', 'Simplylove']);
		addOption(option);

		var option:Option = new Option('Long Health Bar',
			'why would you want this anyways',
			'longBar',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Combo Stacking',
			"If unchecked, Ratings and Combo won't stack, saving on System Memory and making them easier to read",
			'comboStacking',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Downscroll', //Name
			'If checked, notes go Down instead of Up, simple enough.', //Description
			'downScroll', //Save data variable name
			'bool', //Variable type
			false); //Default value
		addOption(option);

		var option:Option = new Option('Middlescroll',
			'If checked, your notes get centered.',
			'middleScroll',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Opponent Notes',
			'If unchecked, opponent notes get hidden.',
			'opponentStrums',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Ghost Tapping',
			"If checked, you won't get misses from pressing keys\nwhile there are no notes able to be hit.",
			'ghostTapping',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Disable Reset Button',
			"If checked, pressing Reset won't do anything.",
			'noReset',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Hitsound Volume',
			'Funny notes does \"Tick!\" when you hit them."',
			'hitsoundVolume',
			'percent',
			0);
		addOption(option);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		option.onChange = onChangeHitsoundVolume;

		var option:Option = new Option('Rating Offset',
			'Changes how late/early you have to hit for a "Sick!"\nHigher values mean you have to hit later.',
			'ratingOffset',
			'int',
			0);
		option.displayFormat = '%vms';
		option.scrollSpeed = 20;
		option.minValue = -30;
		option.maxValue = 30;
		addOption(option);

		var option:Option = new Option('Sick! Hit Window',
			'Changes the amount of time you have\nfor hitting a "Sick!" in milliseconds.',
			'sickWindow',
			'int',
			45);
		option.displayFormat = '%vms';
		option.scrollSpeed = 15;
		option.minValue = 15;
		option.maxValue = 45;
		addOption(option);

		var option:Option = new Option('Good Hit Window',
			'Changes the amount of time you have\nfor hitting a "Good" in milliseconds.',
			'goodWindow',
			'int',
			90);
		option.displayFormat = '%vms';
		option.scrollSpeed = 30;
		option.minValue = 15;
		option.maxValue = 90;
		addOption(option);

		var option:Option = new Option('Bad Hit Window',
			'Changes the amount of time you have\nfor hitting a "Bad" in milliseconds.',
			'badWindow',
			'int',
			135);
		option.displayFormat = '%vms';
		option.scrollSpeed = 60;
		option.minValue = 15;
		option.maxValue = 135;
		addOption(option);

		var option:Option = new Option('Safe Frames',
			'Changes how many frames you have for\nhitting a note earlier or late.',
			'safeFrames',
			'float',
			10);
		option.scrollSpeed = 5;
		option.minValue = 2;
		option.maxValue = 10;
		option.changeValue = 0.1;
		addOption(option);

		super();
	}

	function onChangeHitsoundVolume()
	{
		FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.hitsoundVolume);
	}
}

class LanguageSubState extends MusicBeatSubstate {
    	private var coolGrp:FlxTypedGroup<Alphabet>;
		var iconArray:Array<AttachedSprite> = [];
	var langStrings:Array<Locale> = [];
    	var curSelected:Int = 0;

	public function new()
	{
		super();

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
            coolGrp.add(label);

            var icon:AttachedSprite = new AttachedSprite();
            icon.frames = Paths.getSparrowAtlas('flags/' + langStrings[i].code);
            icon.animation.addByPrefix('idle', langStrings[i].code, 24);
            icon.animation.play('idle');
            icon.xAdd = -icon.width - 10;
            icon.sprTracker = label;

            iconArray.push(icon);
            add(icon);
		}

        	changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

        	if (controls.UI_UP_P || controls.UI_DOWN_P)
			changeSelection(controls.UI_UP_P ? -1 : 1);

		if (controls.BACK) 
		{
			close();
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}
            
		if (controls.ACCEPT)
		{
			ClientPrefs.language = langStrings[curSelected].code;
			Localization.switchLanguage(ClientPrefs.language);
			FlxG.sound.play(Paths.sound('confirmMenu'));
			ClientPrefs.saveSettings();
			FlxG.resetState();
			close();
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

class MiscSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Miscellaneous';
		rpcTitle = 'Miscellaneous Settings Menu'; //for Discord Rich Presence
		
		var option:Option = new Option('Pause Screen Song:',
			"What song do you prefer for the Pause Screen?",
			'pauseMusic',
			'string',
			'Tea Time',
			['None', 'Breakfast', 'Tea Time']);
		addOption(option);
		option.onChange = onChangePauseMusic;
		
		#if CHECK_FOR_UPDATES
		var option:Option = new Option('Check for Updates',
			'On Release builds, turn this on to check for updates when you start the game.',
			'checkForUpdates',
			'bool',
			true);
		addOption(option);
		#end

		var option:Option = new Option('Save Replays',
			'If checked, the game will save a recording of your gameplay\nfor every song you complete.
			Note that replays are not a video, so\na replay\'s size will be pretty small.',
			'saveReplay',
			'bool',
			true);
		addOption(option);

		super();
	}

	var changedMusic:Bool = false;
	function onChangePauseMusic()
	{
		if(ClientPrefs.pauseMusic == 'None')
			FlxG.sound.music.volume = 0;
		else
			FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.pauseMusic)));

		changedMusic = true;
	}

	override function destroy()
	{
		if (changedMusic) FlxG.sound.playMusic(Paths.music('freakyMenu'));
		super.destroy();
	}
}

class NotesSubState extends MusicBeatSubstate
{
	private static var curSelected:Int = 0;
	private static var typeSelected:Int = 0;
	private var grpNumbers:FlxTypedGroup<Alphabet>;
	private var grpNotes:FlxTypedGroup<FlxSprite>;
	private var shaderArray:Array<ColorMask> = [];
	public var defaultColors:Array<Array<Int>> = [
		[194, 75, 153], 
		[0, 255, 255], 
		[18, 250, 5], 
		[249, 57, 63]
	];
	var curValue:Float = 0;
	var holdTime:Float = 0;
	var nextAccept:Int = 5;

	var angleTween:FlxTween;
	var scaleTween:FlxTween;

	var btn1:FlxButton;
	var btn2:FlxButton;
	var btn3:FlxButton;
	var btn4:FlxButton;
	var btn5:FlxButton;
	var btn6:FlxButton;
	var btn7:FlxButton;
	var btn8:FlxButton;

	var blackBG:FlxSprite;
	var rgbText:Alphabet;
	var posX = 230;
	public function new() 
	{
		super();

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xFFea71fd;
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		#if sys
		ArtemisIntegration.setBackgroundFlxColor (bg.color);
		#end

		blackBG = new FlxSprite(posX - 25).makeGraphic(1140, 200, FlxColor.BLACK);
		blackBG.alpha = 0.4;
		add(blackBG);

		grpNotes = new FlxTypedGroup<FlxSprite>();
		add(grpNotes);
		grpNumbers = new FlxTypedGroup<Alphabet>();
		add(grpNumbers);

		for (i in 0...ClientPrefs.arrowRGB.length) {
			var yPos:Float = (80 * i) - 40;
			for (j in 0...3) {
				var optionText:Alphabet = new Alphabet(0, yPos + 60, Std.string(ClientPrefs.arrowRGB[i][j]), true);
				optionText.x = posX + (225 * j) + 250;
				optionText.ID = i;
				grpNumbers.add(optionText);
			}

			var note:FlxSprite = new FlxSprite(posX, yPos);
			note.frames = Paths.getSparrowAtlas('NOTE_assets');
			var animations:Array<String> = ['purple0', 'blue0', 'green0', 'red0'];
			note.animation.addByPrefix('idle', animations[i]);
			note.animation.play('idle');
			note.antialiasing = ClientPrefs.globalAntialiasing;
			note.ID = i;
			grpNotes.add(note);

			var newShader:ColorMask = new ColorMask();
			note.shader = newShader.shader;
			newShader.rCol = FlxColor.fromRGB(ClientPrefs.arrowRGB[i][0], ClientPrefs.arrowRGB[i][1], ClientPrefs.arrowRGB[i][2]);
			newShader.gCol = newShader.rCol.getDarkened(0.6);
			shaderArray.push(newShader);
		}

		btn1 = new FlxButton(15, 40, "Joalor64", () ->
		{
			ClientPrefs.arrowRGB = [
				[89, 0, 153], 
				[0, 255, 255], 
				[18, 255, 175], 
				[223, 0, 118]
			];
			updateValue();
			updateAll();
			ClientPrefs.saveSettings();
        	});
		btn1.scale.set(1.5, 1.5);
		btn1.color = 0x7b2977;
		btn1.label.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		btn1.label.screenCenter(XY);
		btn1.updateHitbox();
		add(btn1);

		btn2 = new FlxButton(15, btn1.y + 50, "Vibrant", () ->
		{
			ClientPrefs.arrowRGB = [
				[250, 52, 15], 
				[255, 255, 3], 
				[30, 252, 42], 
				[0, 192, 255]
			];
			updateValue();
			updateAll();
			ClientPrefs.saveSettings();
        	});
		btn2.scale.set(1.5, 1.5);
		btn2.color = 0xfff700;
		btn2.label.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		btn2.label.screenCenter(XY);
		btn2.updateHitbox();
		add(btn2);

		btn3 = new FlxButton(15, btn2.y + 50, "Warm", () ->
		{
			ClientPrefs.arrowRGB = [
				[135, 0, 9], 
				[179, 0, 65], 
				[215, 0, 138], 
				[237, 48, 205]
			];
			updateValue();
			updateAll();
			ClientPrefs.saveSettings();
        	});
		btn3.scale.set(1.5, 1.5);
		btn3.color = 0xac415e;
		btn3.label.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		btn3.label.screenCenter(XY);
		btn3.updateHitbox();
		add(btn3);

		btn4 = new FlxButton(15, btn3.y + 50, "Cold", () ->
		{
			ClientPrefs.arrowRGB = [
				[0, 229, 75], 
				[0, 212, 176], 
				[0, 183, 216], 
				[24, 138, 240]
			];
			updateValue();
			updateAll();
			ClientPrefs.saveSettings();
        	});
		btn4.scale.set(1.5, 1.5);
		btn4.color = 0x417ea3;
		btn4.label.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		btn4.label.screenCenter(XY);
		btn4.updateHitbox();
		add(btn4);

		btn5 = new FlxButton(15, btn4.y + 50, "Cum", () ->
		{
			ClientPrefs.arrowRGB = [
				[255, 255, 255], 
				[255, 255, 255], 
				[255, 255, 255], 
				[255, 255, 255]
			];
			updateValue();
			updateAll();
			ClientPrefs.saveSettings();
        	});
		btn5.scale.set(1.5, 1.5);
		btn5.color = 0xffffff;
		btn5.label.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		btn5.label.screenCenter(XY);
		btn5.updateHitbox();
		add(btn5);

		btn6 = new FlxButton(15, btn5.y + 50, "Void", () ->
		{
			ClientPrefs.arrowRGB = [
				[0, 0, 0], 
				[0, 0, 0], 
				[0, 0, 0], 
				[0, 0, 0]
			];
			updateValue();
			updateAll();
			ClientPrefs.saveSettings();
        	});
		btn6.scale.set(1.5, 1.5);
		btn6.color = 0x000000;
		btn6.label.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		btn6.label.screenCenter(XY);
		btn6.updateHitbox();
		add(btn6);

		btn7 = new FlxButton(15, btn6.y + 50, "DDR", () ->
		{
			ClientPrefs.arrowRGB = [
				[255, 124, 232], 
				[0, 255, 255], 
				[0, 255, 255], 
				[255, 124, 232]
			];
			updateValue();
			updateAll();
			ClientPrefs.saveSettings();
        	});
		btn7.scale.set(1.5, 1.5);
		btn7.color = 0xea00ff;
		btn7.label.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		btn7.label.screenCenter(XY);
		btn7.updateHitbox();
		add(btn7);

		btn8 = new FlxButton(15, btn7.y + 50, "Pastel", () ->
		{
			ClientPrefs.arrowRGB = [
				[186, 144, 198], 
				[192, 219, 234], 
				[221, 255, 187], 
				[242, 190, 209]
			];
			updateValue();
			updateAll();
			ClientPrefs.saveSettings();
        	});
		btn8.scale.set(1.5, 1.5);
		btn8.color = 0xa26dad;
		btn8.label.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		btn8.label.screenCenter(XY);
		btn8.updateHitbox();
		add(btn8);

		rgbText = new Alphabet(posX + 720, 0, "Red        Green      Blue", false);
		rgbText.scaleX = 0.6;
		rgbText.scaleY = 0.6;
		add(rgbText);

		changeSelection();

		FlxG.mouse.visible = true;

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	var lastSelected:Int = 99;
	var changingNote:Bool = false;
	override function update(elapsed:Float) {
		var rownum = 0;
		var lerpVal:Float = CoolUtil.boundTo(elapsed * 9.6, 0, 1);
		for (i in 0...grpNumbers.length) {
			var item = grpNumbers.members[i];
			var scaledY = FlxMath.remapToRange(item.ID, 0, 1, 0, 1.3);
			item.y = FlxMath.lerp(item.y, (scaledY * 165) + 270 + 60, lerpVal);
			item.x = FlxMath.lerp(item.x, (item.ID * 20) + 90 + posX + (225 * rownum + 250), lerpVal);
			rownum++;
			if (rownum == 3) rownum = 0;
		}
		for (i in 0...grpNotes.length) {
			var item = grpNotes.members[i];
			var scaledY = FlxMath.remapToRange(item.ID, 0, 1, 0, 1.3);
			item.y = FlxMath.lerp(item.y, (scaledY * 165) + 270, lerpVal);
			item.x = FlxMath.lerp(item.x, (item.ID * 20) + 90, lerpVal);
			if (i == curSelected) {
				rgbText.y = item.y - 70;
				blackBG.y = item.y - 20;
				blackBG.x = item.x - 20;
				if (lastSelected != curSelected) {
					lastSelected = curSelected;
					if (angleTween != null) angleTween.cancel();
					angleTween = null;
					if (scaleTween != null) scaleTween.cancel();
					scaleTween = null;
					item.scale.set(0.78,0.78);
					angleTween = FlxTween.angle(item, -12, 12, 2, {ease: FlxEase.quadInOut, type: FlxTweenType.PINGPONG});
					scaleTween = FlxTween.tween(item, {"scale.x": 0.92, "scale.y": 0.92}, 1, {ease: FlxEase.quadInOut, type: FlxTweenType.PINGPONG});
				}
			} else {
				item.scale.set(0.6,0.6);
				item.angle = 0;
			}
		}
		if(changingNote) {
			if(holdTime < 0.5) {
				if(controls.UI_LEFT_P) {
					updateValue(-1);
					FlxG.sound.play(Paths.sound('scrollMenu'));
				} else if(controls.UI_RIGHT_P) {
					updateValue(1);
					FlxG.sound.play(Paths.sound('scrollMenu'));
				} else if(controls.RESET) {
					resetValue(curSelected, typeSelected);
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}
				if(controls.UI_LEFT_R || controls.UI_RIGHT_R) {
					holdTime = 0;
				} else if(controls.UI_LEFT || controls.UI_RIGHT) {
					holdTime += elapsed;
				}
			} else {
				if(controls.UI_LEFT) {
					updateValue(elapsed * -50);
				} else if(controls.UI_RIGHT) {
					updateValue(elapsed * 50);
				}
				if(controls.UI_LEFT_R || controls.UI_RIGHT_R) {
					FlxG.sound.play(Paths.sound('scrollMenu'));
					holdTime = 0;
				}
			}
		} else {
			if (controls.UI_UP_P) {
				changeSelection(-1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			if (controls.UI_DOWN_P) {
				changeSelection(1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			if (controls.UI_LEFT_P) {
				changeType(-1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			if (controls.UI_RIGHT_P) {
				changeType(1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			if (controls.ACCEPT && nextAccept <= 0) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changingNote = true;
				holdTime = 0;
				for (i in 0...grpNumbers.length) {
					var item = grpNumbers.members[i];
					item.alpha = 0;
					if ((curSelected * 3) + typeSelected == i) {
						item.alpha = 1;
					}
				}
				for (i in 0...grpNotes.length) {
					var item = grpNotes.members[i];
					item.alpha = 0;
					if (curSelected == i) {
						item.alpha = 1;
					}
				}
				super.update(elapsed);
				return;
			}
		}

		if (controls.BACK || (changingNote && controls.ACCEPT)) {
			if(!changingNote) {
				FlxG.mouse.visible = false;
				close();
			} else {
				changeSelection();
			}
			changingNote = false;
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}

		if(nextAccept > 0) {
			nextAccept -= 1;
		}
		super.update(elapsed);
	}

	override function destroy() {
		if (angleTween != null) angleTween.cancel();
		angleTween = null;
		if (scaleTween != null) scaleTween.cancel();
		scaleTween = null;
		super.destroy();
	}

	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = ClientPrefs.arrowRGB.length - 1;
		if (curSelected >= ClientPrefs.arrowRGB.length)
			curSelected = 0;

		curValue = ClientPrefs.arrowRGB[curSelected][typeSelected];
		updateValue();

		var bullshit = 0;
		var rownum = 0;
		var bullshit2 = 0;
		for (i in 0...grpNumbers.length) {
			var item = grpNumbers.members[i];
			item.alpha = 0.6;
			if ((curSelected * 3) + typeSelected == i) {
				item.alpha = 1;
			}
			item.ID = bullshit - curSelected;
			rownum++;
			if (rownum == 3) {
				rownum = 0;
				bullshit++;
			}
		}
		for (i in 0...grpNotes.length) {
			var item = grpNotes.members[i];
			item.alpha = 0.6;
			item.scale.set(0.5, 0.5);
			if (curSelected == i) {
				item.alpha = 1;
				item.scale.set(0.6, 0.6);
				rgbText.y = item.y - 40;
				blackBG.y = item.y + 28;
			}
			item.ID = bullshit2 - curSelected;
			bullshit2++;
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	function changeType(change:Int = 0) {
		typeSelected += change;
		if (typeSelected < 0)
			typeSelected = 2;
		if (typeSelected > 2)
			typeSelected = 0;

		curValue = ClientPrefs.arrowRGB[curSelected][typeSelected];
		updateValue();

		for (i in 0...grpNumbers.length) {
			var item = grpNumbers.members[i];
			item.alpha = 0.6;
			if ((curSelected * 3) + typeSelected == i) {
				item.alpha = 1;
			}
		}
	}

	function resetValue(selected:Int, type:Int) {
		curValue = 0;
		ClientPrefs.arrowRGB[selected][type] = defaultColors[selected][type];

		shaderArray[selected].rCol = FlxColor.fromRGB(ClientPrefs.arrowRGB[selected][0], ClientPrefs.arrowRGB[selected][1], ClientPrefs.arrowRGB[selected][2]);
		shaderArray[selected].gCol = shaderArray[selected].rCol.getDarkened(0.6);

		var item = grpNumbers.members[(selected * 3) + type];
		item.text = Std.string(ClientPrefs.arrowRGB[selected][type]);

		var add = (40 * (item.letters.length - 1)) / 2;
		for (letter in item.letters)
		{
			letter.offset.x += add;
		}
	}
	function updateValue(change:Float = 0) {
		curValue += change;
		var roundedValue:Int = Math.round(curValue);

		if(roundedValue < 0) {
			curValue = 0;
		} else if(roundedValue > 255) {
			curValue = 255;
		}
		roundedValue = Math.round(curValue);
		ClientPrefs.arrowRGB[curSelected][typeSelected] = roundedValue;

		shaderArray[curSelected].rCol = FlxColor.fromRGB(ClientPrefs.arrowRGB[curSelected][0], ClientPrefs.arrowRGB[curSelected][1], ClientPrefs.arrowRGB[curSelected][2]);
		shaderArray[curSelected].gCol = shaderArray[curSelected].rCol.getDarkened(0.6);

		var item = grpNumbers.members[(curSelected * 3) + typeSelected];
		item.text = Std.string(roundedValue);

		var add = (40 * (item.letters.length - 1)) / 2;
		for (letter in item.letters)
		{
			letter.offset.x += add;
		}
	}
	function updateAll() 
	{
		var roundedValue:Int = Math.round(curValue);

		if(roundedValue < 0) {
			curValue = 0;
		} else if(roundedValue > 255) {
			curValue = 255;
		}
		roundedValue = Math.round(curValue);
		ClientPrefs.arrowRGB[curSelected][typeSelected] = roundedValue;

		for (i in 0...grpNotes.members.length){
			shaderArray[i].rCol = FlxColor.fromRGB(ClientPrefs.arrowRGB[curSelected][0], ClientPrefs.arrowRGB[curSelected][1], ClientPrefs.arrowRGB[curSelected][2]);
			shaderArray[i].gCol = shaderArray[i].rCol.getDarkened(0.6);
		}
		var item = grpNumbers.members[(curSelected * 3) + typeSelected];
		item.text = Std.string(roundedValue);

		var add = (40 * (item.letters.length - 1)) / 2;
		for (letter in item.letters)
		{
			letter.offset.x += add;
		}
	}
}

class VisualsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Visuals and Graphics';
		rpcTitle = 'Visuals Settings Menu'; //for Discord Rich Presence

		var option:Option = new Option('Low Quality', //Name
			'If checked, disables some background details,\ndecreases loading times and improves performance.', //Description
			'lowQuality', //Save data variable name
			'bool', //Variable type
			false); //Default value
		addOption(option);

		var option:Option = new Option('Anti-Aliasing',
			'If unchecked, disables anti-aliasing, increases performance\nat the cost of sharper visuals.',
			'globalAntialiasing',
			'bool',
			true);
		option.showBoyfriend = true;
		option.onChange = onChangeAntiAliasing; //Changing onChange is only needed if you want to make a special interaction after it changes the value
		addOption(option);

		var option:Option = new Option('Shaders', //Name
			'If unchecked, disables shaders.\nIt\'s used for some visual effects, and also CPU intensive for weaker PCs.', //Description
			'shaders', //Save data variable name
			'bool', //Variable type
			true); //Default value
		addOption(option);

		var option:Option = new Option('Floating Letters', //Name
			'If checked, makes the letters float like in Hypnos Lullaby', //Description
			'floatyLetters', //Save data variable name
			'bool', //Variable type
			false); //Default value
		addOption(option);
		option.onChange = () -> Alphabet.alphabet.shouldDisplace = true;

		var option:Option = new Option('Song Display Style:',
			"How should the songs in Freeplay be displayed?",
			'songDisplay',
			'string',
			'None',
			['Classic', 'Vertical', 'C-Shape', 'D-Shape']);
		addOption(option);

		#if !html5 //Apparently other framerates isn't correctly supported on Browser? Probably it has some V-Sync shit enabled by default, idk
		var option:Option = new Option('Framerate',
			"Pretty self explanatory, isn't it?",
			'framerate',
			'int',
			60);
		addOption(option);

		option.minValue = 60;
		option.maxValue = 240;
		option.displayFormat = '%v FPS';
		option.onChange = onChangeFramerate;

		var option:Option = new Option('Screen Resolution',
			"Size of the window [Press ACCEPT to apply, CANCEL to cancel]",
			'screenResTemp',
			'string',
			'1280 x 720', ['1280 x 720',
			'1280 x 960',
			'FULLSCREEN'
			]);
		addOption(option);

		if (ClientPrefs.screenRes == "FULLSCREEN") {
			var option:Option = new Option('Scale Mode',
				"How you'd like the screen to scale [Press ACCEPT to apply, CANCEL to cancel] (Adaptive is not compatible with fullscreen.)",
				'screenScaleModeTemp',
				'string',
				'LETTERBOX', ['LETTERBOX',
				'PAN',
				'STRETCH'
				]);
			addOption(option);
		} else {
			var option:Option = new Option('Scale Mode',
				"Scale Mode [Press ACCEPT to apply, CANCEL to cancel] (Adaptive is unstable and may cause visual issues and doesn't work with fullscreen!)",//summerized < 333
				'screenScaleModeTemp',
				'string',
				'LETTERBOX', ['LETTERBOX',
				'PAN',
				'STRETCH',
				'ADAPTIVE'
				]);
			addOption(option);
		}

		ClientPrefs.screenScaleModeTemp = ClientPrefs.screenScaleMode;
		ClientPrefs.screenResTemp = ClientPrefs.screenRes;
		#end

		var option:Option = new Option('Flashing Lights',
			"Uncheck this if you're sensitive to flashing lights!",
			'flashing',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Rainbow FPS',
		'If checked, makes the FPS have a chroma effect.',
		'fpsRainbow',
		'bool',
		false);
		addOption(option);
		
		var option:Option = new Option('FPS Counter',
			'If unchecked, hides FPS Counter.',
			'showFPS',
			'bool',
			true);
		addOption(option);
		option.onChange = onChangeFPSCounter;
	
		var option:Option = new Option('Colorblind Filter:',
			"Filters for colorblind people.",
			'colorBlindFilter',
			'string',
			'None',
			['None', 'Deuteranopia', 'Protanopia', 'Tritanopia']);
		addOption(option);
		option.onChange = () -> meta.Colorblind.updateFilter();

		var option:Option = new Option('Simple Main Menu',
			'Just a simple version of the Main Menu for low-end users.',
			'simpleMain',
			'bool',
			false);
		addOption(option);

		#if sys
		var option:Option = new Option('Enable Artemis',
			'Cool colors for your RGB stuff. Requires Artemis and its FNF plugin to work. https://github.com/skedgyedgy/Artemis.Plugins.FNF/releases/tag/1.1',
			'enableArtemis',
			'bool',
			true);
		addOption(option);
		option.onChange = onToggleArtemis;
		#end

		super();
	}

	#if sys
	function onToggleArtemis()
	{
		if (ClientPrefs.enableArtemis) {
			ArtemisIntegration.initialize();
			ArtemisIntegration.setBackgroundColor ("#FFEA71FD");
			ArtemisIntegration.setFadeColor ("#FF000000");
			ArtemisIntegration.setGameState ("menu");
			ArtemisIntegration.setFadeColor ("#FF000000");
			ArtemisIntegration.sendProfileRelativePath ("assets/artemis/fnf-vanilla.json");
			ArtemisIntegration.autoUpdateControls ();
			ArtemisIntegration.resetAllFlags ();
			ArtemisIntegration.resetModName ();
		} else {
			ArtemisIntegration.setBackgroundColor ("#00000000");
			ArtemisIntegration.setGameState ("closed");
			ArtemisIntegration.resetModName ();
			ArtemisIntegration.artemisAvailable = false;
		}
	}
	#end

	#if !mobile
	function onChangeFPSCounter()
	{
		if(Main.fpsVar != null)
			Main.fpsVar.visible = ClientPrefs.showFPS;
	}
	#end

	function onChangeAntiAliasing()
	{
		for (sprite in members)
		{
			var sprite:Dynamic = sprite; //Make it check for FlxSprite instead of FlxBasic
			var sprite:FlxSprite = sprite; //Don't judge me ok
			if(sprite != null && (sprite is FlxSprite) && !(sprite is FlxText)) {
				sprite.antialiasing = ClientPrefs.globalAntialiasing;
			}
		}
	}

	function onChangeFramerate()
	{
		if(ClientPrefs.framerate > FlxG.drawFramerate)
		{
			FlxG.updateFramerate = ClientPrefs.framerate;
			FlxG.drawFramerate = ClientPrefs.framerate;
		}
		else
		{
			FlxG.drawFramerate = ClientPrefs.framerate;
			FlxG.updateFramerate = ClientPrefs.framerate;
		}
	}
}