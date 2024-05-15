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
#if desktop
import meta.data.dependency.Discord;
#end
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

import meta.data.options.*;
import meta.data.alphabet.*;
import meta.data.*;
import meta.state.*;
import meta.substate.*;
import meta.state.editors.*;
import meta.*;

import Paths;

#if MODS_ALLOWED 
import backend.Mods; 
#end

import objects.*;
import hscript.*;

// MISCELLANEOUS
#if (sys || desktop || MODS_ALLOWED)
import sys.io.File;
import sys.FileSystem;
#end

import haxe.Json;

import lime.app.Application;

import openfl.Lib;
import openfl.Assets; // i know this is the same thing, but still
import openfl.utils.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.system.System;
import openfl.geom.*;

using Globals;
using StringTools;
using meta.CoolUtil;

#if !debug
@:noDebug
#end
#end