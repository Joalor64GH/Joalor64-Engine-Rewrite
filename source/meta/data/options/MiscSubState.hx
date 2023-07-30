package meta.data.options;

#if desktop
import meta.data.dependency.Discord.DiscordClient;
#end

import flixel.FlxG;

import meta.*;
import meta.data.*;
import meta.data.options.*;

using StringTools;

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
		if(changedMusic) FlxG.sound.playMusic(Paths.music('freakyMenu'));
		super.destroy();
	}
}