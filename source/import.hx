#if !macro
// Default Imports
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.text.FlxText;
import flixel.util.*;
import flixel.math.*;
import flixel.*;

import haxe.Json;

import lime.app.Application;

import openfl.Lib;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.system.System;
import openfl.geom.*;

import hscript.*;

#if (sys || desktop || MODS_ALLOWED)
import sys.io.File;
import sys.FileSystem;
#elseif js
import js.html.*;
#end

// Joalor64 Engine Imports
#if desktop
import meta.data.dependency.Discord;
#end

import animateatlas.AtlasFrameMaker;
import meta.data.alphabet.Alphabet;
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
import meta.ArtemisIntegration;
import meta.Controls;

import meta.data.options.*;
import meta.data.alphabet.*;
import meta.data.*;
import meta.state.*;
import meta.substate.*;
import meta.state.editors.*;
import meta.*;

import objects.*;
import objects.userinterface.*;

import Paths;

#if MODS_ALLOWED 
import backend.Mods; 
#end
import backend.Localization;

using Globals;
using StringTools;
using meta.CoolUtil;

#if !debug
@:noDebug
#end
#end