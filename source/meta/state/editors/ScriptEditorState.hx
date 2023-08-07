package meta.state.editors;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUIInputText;

import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.utils.Assets as OpenFlAssets;
import openfl.utils.ByteArray;

import openfl.net.FileReference;

import meta.*;
import meta.state.*;
import meta.state.editors.*;

using StringTools;

// this is basically just a notepad
// TODO: file saving cuz idk how (save as .lua)
class ScriptEditorState extends MusicBeatState
{
	var notePad:FlxUIInputText;
	var bg:FlxSprite;

	var saveBtn:FlxButton;

	override function create()
	{
		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);

		notePad = new FlxUIInputText(0, 0, 1024, "");
		notePad.screenCenter(XY);
		add(notePad);

		saveBtn = new FlxButton(15, 40, "Save");
		saveBtn.scale.set(1.5, 1.5);
		saveBtn.label.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(saveBtn);

		FlxG.mouse.visible = true;

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

        	if (FlxG.keys.justPressed.ESCAPE)
        	{
            		MusicBeatState.switchState(new MasterEditorMenu());
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
        	}
	}
}
