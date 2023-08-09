package meta.state.editors;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.ui.FlxButton;

import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUIInputText;

import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileReference;

import meta.*;
import meta.state.*;
import meta.state.editors.*;

using StringTools;

// TODO: file saving cuz idk how (save as .lua), make input size bigger
class ScriptEditorState extends MusicBeatState
{
	var notePad:FlxUIInputText;

	var saveBtn:FlxButton;

	var bg:FlxSprite;

	override function create()
	{
		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);

		notePad = new FlxUIInputText(0, 0, 1024, "");
		notePad.screenCenter(XY);
		add(notePad);

		saveBtn = new FlxButton(22, 40, "Save");
		saveBtn.label.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		saveBtn.label.screenCenter(XY);
		saveBtn.scale.set(1.5, 1.5);
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
