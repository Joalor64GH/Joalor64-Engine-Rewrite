// This just contains global imports.
#if !macro
// FLIXEL
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.text.FlxText;
import flixel.util.*;
import flixel.math.*;
import flixel.*;

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

#if MODS_ALLOWED 
import backend.Mods; 
#end

import objects.AttachedSprite;
import meta.data.options.*;
import hscript.*;

// MISCELLANEOUS
#if (polymod && FUTURE_POLYMOD)
import polymod.Polymod;
#end
#if (sys || desktop)
import sys.io.File;
import sys.FileSystem;
#end

import openfl.utils.Assets as OpenFlAssets;

using Global;
using StringTools;
using meta.CoolUtil;

#if !debug
@:noDebug
#end
#end