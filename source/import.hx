#if !macro
// Default Imports
import flixel.*;
import flixel.util.*;
import flixel.math.*;
import flixel.addons.effects.FlxTrail;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.animation.FlxAnimationController;
import flixel.effects.FlxFlicker;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import flixel.sound.FlxSound;
import flixel.ui.FlxButton;
import flixel.ui.FlxBar;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

import lime.app.Application;

import openfl.Lib;
import openfl.geom.*;
import openfl.Assets;
import openfl.system.System;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.filters.BitmapFilter;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;

import haxe.*;
import haxe.io.Path;
import Type.ValueType;

import hscript.*;

#if (sys || desktop || MODS_ALLOWED)
import sys.io.File;
import sys.FileSystem;
#elseif js
import js.html.*;
#else
import openfl.utils.Assets;
#end

// Joalor64 Engine Imports
import animateatlas.AtlasFrameMaker;

#if desktop
import meta.data.dependency.Discord;
#end
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

#if MODS_ALLOWED 
import backend.Mods; 
#end
import backend.Paths;
import backend.animation.PsychAnimationController;

#if LUA_ALLOWED
import llua.*;
import llua.Lua;
#end

using StringTools;
using meta.CoolUtil;
using meta.CoolUtil.MapUtil;

#if !debug
@:noDebug
#end
#end