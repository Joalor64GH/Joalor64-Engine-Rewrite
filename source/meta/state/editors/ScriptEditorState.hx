package meta.state.editors;

import flixel.FlxG;
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

	override function create()
	{
		notePad = new FlxUIInputText(50, 20, 500, "");
		add(notePad);

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

        	if (controls.BACK)
        	{
            		MusicBeatState.switchState(new MasterEditorMenu());
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
        	}
	}
}
