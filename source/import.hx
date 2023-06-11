// This just contains global imports.
// FLIXEL
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.FlxSprite;
import flixel.FlxG;

// JOALOR64
import meta.data.alphabet.Alphabet;
import meta.data.dependency.Discord;
import meta.data.Conductor;
import meta.data.Conductor.BPMChangeEvent;
import meta.data.Section;
import meta.data.Song;
import meta.CoolUtil;
import meta.data.Highscore;
import meta.MusicBeatState;
import meta.MusicBeatSubstate;
import meta.state.PlayState;
import meta.Controls;
import Paths;

#if MODS_ALLOWED import backend.Mods; #end

import animateatlas.AtlasFrameMaker;
import objects.AttachedSprite;
import meta.data.options.*;

// MISCELLANEOUS
#if (polymod && FUTURE_POLYMOD)
import polymod.Polymod;
#end
#if sys
import sys.io.File;
import sys.FileSystem;
#end
import openfl.utils.Assets as OpenFlAssets;

using StringTools;
using meta.CoolUtil;