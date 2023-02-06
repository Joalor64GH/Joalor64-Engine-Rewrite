// This just contains global imports.
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.FlxSprite;
import flixel.FlxG;
import meta.data.dependency.Discord;
import meta.data.PlayerSettings;
import meta.data.font.Alphabet;
import meta.MusicBeatSubstate;
import meta.MusicBeatState;
import meta.state.PlayState;
import meta.data.Highscore;
import meta.data.Conductor;
import meta.data.Section;
import meta.data.Song;
import meta.CoolUtil;
import meta.Controls;
import Paths;
#if (polymod && FUTURE_POLYMOD)
import polymod.Polymod;
#end

using StringTools;
using meta.CoolUtil;

#if sys
import sys.io.File;
import sys.FileSystem;
#end
import tjson.TJSON as Json;
import openfl.utils.Assets as OpenFLAssets;
import lime.utils.Assets as LimeAssets;