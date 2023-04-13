// This just contains global imports.
// FLIXEL
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.FlxSprite;
import flixel.FlxG;

// JOALOR64
import animateatlas.AtlasFrameMaker;
import meta.data.alphabet.Alphabet;
import meta.data.dependency.Discord;
import meta.data.Conductor;
import meta.data.Conductor.BPMChangeEvent;
import meta.data.Section;
import meta.data.Song;
import meta.CoolUtil;
import meta.data.Highscore;
import meta.data.PlayerSettings;
import meta.MusicBeatState;
import meta.MusicBeatSubstate;
import meta.state.PlayState;
import meta.Controls;
import Paths;

import objects.AttachedSprite;
import meta.data.options.*;
import hscript.*;

// MISCELLANEOUS
#if (polymod && FUTURE_POLYMOD)
import polymod.Polymod;
#end
#if sys
import sys.io.File;
import sys.FileSystem;
#end
import tjson.TJSON as Json;
import openfl.utils.Assets as OpenFlAssets;
import lime.utils.Assets as LimeAssets;

using StringTools;
using meta.CoolUtil;