package objects;

import objects.background.*;
import objects.shaders.*;

#if MODS_ALLOWED
import sys.io.File;
import sys.FileSystem;
#end

typedef CharacterFile = {
	var animations:Array<AnimArray>;
	var image:String;
	var scale:Float;
	var sing_duration:Float;
	var healthicon:String;

	var position:Array<Float>;
	var camera_position:Array<Float>;

	var flip_x:Bool;
	var no_antialiasing:Bool;
	var healthbar_colors:Array<Int>;

	var multipleI8:Bool; // ONLY check this if you have multiple I8 jsons and images. and if youre using I8.
	var I8Count:Int; // If you have multiple I8, please specify their count from 0 to whatever. Like: [Image0, Image1, etc.]
}

// Note from ZackDroid, okay so I DO NOT KNOW how to put the two new json arguments into CharacterEditorState, anyone else please do it instead :(

typedef AnimArray = {
	var anim:String;
	var name:String;
	var fps:Int;
	var loop:Bool;
	var indices:Array<Int>;
	var offsets:Array<Int>;
}

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = DEFAULT_CHARACTER;

	public var colorTween:FlxTween;
	public var holdTimer:Float = 0;
	public var heyTimer:Float = 0;
	public var specialAnim:Bool = false;
	public var animationNotes:Array<Dynamic> = [];
	public var stunned:Bool = false;
	public var singDuration:Float = 4; //Multiplier of how long a character holds the sing pose
	public var idleSuffix:String = '';
	public var danceIdle:Bool = false; //Character use "danceLeft" and "danceRight" instead of "idle"
	public var skipDance:Bool = false;

	public var colorSwap:ColorSwap = null;

	public var healthIcon:String = 'face';
	public var animationsArray:Array<AnimArray> = [];

	public var positionArray:Array<Float> = [0, 0];
	public var cameraPosition:Array<Float> = [0, 0];

	public var hasMissAnimations:Bool = false;

	//Used on Character Editor
	public var imageFile:String = '';
	public var jsonScale:Float = 1;
	public var noAntialiasing:Bool = false;
	public var originalFlipX:Bool = false;
	public var healthColorArray:Array<Int> = [255, 0, 0];

	public static inline final DEFAULT_CHARACTER:String = 'bf'; //In case a character is missing, it will use BF on its place

	public function new(x:Float, y:Float, ?character:String = 'bf', ?isPlayer:Bool = false)
	{
		super(x, y);

		animation = new PsychAnimationController(this);

		animOffsets = new Map();
		curCharacter = character;
		this.isPlayer = isPlayer;
		antialiasing = ClientPrefs.globalAntialiasing;
		var library:String = null;
		switch (curCharacter)
		{
			//case 'your character name in case you want to hardcode them instead':

			default:
				// NOTE TO HARDCODER OF A MOD: this json should be in assets/characters. NOT images/characters. so dont get it confused :)
				var characterPath:String = 'characters/' + curCharacter + '.json';

				#if MODS_ALLOWED
				var path:String = Paths.modFolders(characterPath);
				if (!FileSystem.exists(path))
					path = Paths.getPreloadPath(characterPath);

				if (!FileSystem.exists(path))
				#else
				var path:String = Paths.getPreloadPath(characterPath);
				if (!Assets.exists(path))
				#end
					path = Paths.getPreloadPath('characters/' + DEFAULT_CHARACTER + '.json'); //If a character couldn't be found, change him to BF just to prevent a crash

				#if MODS_ALLOWED
				var rawJson = File.getContent(path);
				#else
				var rawJson = Assets.getText(path);
				#end

				var json:CharacterFile = cast Json.parse(rawJson);
				var spriteType = "sparrow";
				//sparrow
				//packer
				//texture
				//I8
				#if MODS_ALLOWED
				var modTxtToFind:String = Paths.modsTxt(json.image);
				var txtToFind:String = Paths.getPath('images/' + json.image + '.txt');
				
				if (FileSystem.exists(modTxtToFind) || FileSystem.exists(txtToFind) || Assets.exists(txtToFind))
				#else
				if (Assets.exists(Paths.getPath('images/' + json.image + '.txt')))
				#end
					spriteType = "packer";
				
				#if MODS_ALLOWED
				var modAnimToFind:String = Paths.modFolders('images/' + json.image + '/Animation.json');
				var animToFind:String = Paths.getPath('images/' + json.image + '/Animation.json');
				
				if (FileSystem.exists(modAnimToFind) || FileSystem.exists(animToFind) || Assets.exists(animToFind))
				#else
				if (Assets.exists(Paths.getPath('images/' + json.image + '/Animation.json')))
				#end
					spriteType = "texture";

				#if MODS_ALLOWED
				var modI8ToFind:String = Paths.modFolders('images/' + json.image + '.json');
				var I8ToFind:String = Paths.getPath('images/' + json.image + '.json');

				if (FileSystem.exists(modI8ToFind) || FileSystem.exists(I8ToFind) || Assets.exists(I8ToFind))
				#else
				if (Assets.exists(Paths.getPath('images/' + json.image + '.json')))
				#end
					spriteType = "I8";

				switch (spriteType){
					
					case "packer":
						frames = Paths.getPackerAtlas(json.image);
					
					case "sparrow":
						frames = Paths.getSparrowAtlas(json.image);
					
					case "texture":
						frames = AtlasFrameMaker.construct(json.image);

					case "I8":
						if (json.multipleI8) {
							var fuckk:Array<String> = [];

							for (i in 0...json.I8Count) 
								fuckk.push(json.image + i);

							frames = Paths.fromI8Array(fuckk);
						}
						else
							frames = Paths.fromI8(json.image);
				}
				if (json != null || frames != null || json.image != null)
					imageFile = json.image;

				if(json.scale != 1) {
					jsonScale = json.scale;
					setGraphicSize(Std.int(width * jsonScale));
					updateHitbox();
				}

				positionArray = json.position;
				cameraPosition = json.camera_position;

				healthIcon = json.healthicon;
				singDuration = json.sing_duration;
				flipX = !!json.flip_x;
				if(json.no_antialiasing) {
					antialiasing = false;
					noAntialiasing = true;
				}

				if(json.healthbar_colors != null && json.healthbar_colors.length > 2)
					healthColorArray = json.healthbar_colors;

				antialiasing = !noAntialiasing;
				if(!ClientPrefs.globalAntialiasing) antialiasing = false;

				animationsArray = json.animations;
				if(animationsArray != null && animationsArray.length > 0) {
					for (anim in animationsArray) {
						var animAnim:String = '' + anim.anim;
						var animName:String = '' + anim.name;
						var animFps:Int = anim.fps;
						var animLoop:Bool = !!anim.loop; //Bruh
						var animIndices:Array<Int> = anim.indices;
						if(animIndices != null && animIndices.length > 0) {
							animation.addByIndices(animAnim, animName, animIndices, "", animFps, animLoop);
						} else {
							animation.addByPrefix(animAnim, animName, animFps, animLoop);
						}

						if(anim.offsets != null && anim.offsets.length > 1) {
							addOffset(anim.anim, anim.offsets[0], anim.offsets[1]);
						}
					}
				}
				else
					quickAnimAdd('idle', 'BF idle dance');
		}
		originalFlipX = flipX;

		if(animOffsets.exists('singLEFTmiss') 
		|| animOffsets.exists('singDOWNmiss') 
		|| animOffsets.exists('singUPmiss') 
		|| animOffsets.exists('singRIGHTmiss')) hasMissAnimations = true;

		recalculateDanceIdle();
		dance();

		if (isPlayer)
			flipX = !flipX;

		switch(curCharacter)
		{
			case 'pico-speaker':
				skipDance = true;
				loadMappedAnims();
				playAnim("shoot1");
		}
	}

	override function destroy()
	{
		colorSwap = null;
		super.destroy();
	}

	override function update(elapsed:Float)
	{
		if(!debugMode && animation.curAnim != null)
		{
			if(heyTimer > 0)
			{
				var rate:Float = (PlayState.instance != null ? PlayState.instance.playbackRate : 1.0);
				heyTimer -= elapsed * rate;
				if(heyTimer <= 0)
				{
					if(specialAnim && animation.curAnim.name == 'hey' || animation.curAnim.name == 'cheer')
					{
						specialAnim = false;
						dance();
					}
					heyTimer = 0;
				}
			} else if(specialAnim && animation.curAnim.finished)
			{
				specialAnim = false;
				dance();
			}
			
			switch(curCharacter)
			{
				case 'pico-speaker':
					if(animationNotes.length > 0 && Conductor.songPosition > animationNotes[0][0])
					{
						var noteData:Int = 1;
						if(animationNotes[0][1] > 2) noteData = 3;

						noteData += FlxG.random.int(0, 1);
						playAnim('shoot' + noteData, true);
						animationNotes.shift();
					}
					if(animation.curAnim.finished) playAnim(animation.curAnim.name, false, false, animation.curAnim.frames.length - 3);
			}

			if (!isPlayer)
			{
				if (animation.curAnim.name.startsWith('sing'))
					holdTimer += elapsed;

				if (holdTimer >= Conductor.stepCrochet * (0.0011 #if FLX_PITCH / (FlxG.sound.music != null ? FlxG.sound.music.pitch : 1) #end) * singDuration)
				{
					dance();
					holdTimer = 0;
				}
			}

			if(animation.curAnim.finished && animation.getByName(animation.curAnim.name + '-loop') != null)
				playAnim(animation.curAnim.name + '-loop');
		}
		super.update(elapsed);
	}

	public var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance()
	{
		if (!debugMode && !skipDance && !specialAnim)
		{
			if(danceIdle)
			{
				danced = !danced;

				if (danced)
					playAnim('danceRight' + idleSuffix);
				else
					playAnim('danceLeft' + idleSuffix);
			}
			else if(animation.getByName('idle' + idleSuffix) != null)
				playAnim('idle' + idleSuffix);
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		specialAnim = false;
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
			offset.set(daOffset[0], daOffset[1]);
		else
			offset.set(0, 0);

		if (curCharacter.startsWith('gf'))
		{
			if (AnimName == 'singLEFT')
				danced = true;
			else if (AnimName == 'singRIGHT')
				danced = false;

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
				danced = !danced;
		}
	}
	
	function loadMappedAnims():Void
	{
		var noteData:Array<SwagSection> = Song.loadFromJson('picospeaker', Paths.formatToSongPath(PlayState.SONG.song)).notes;
		for (section in noteData) {
			for (songNotes in section.sectionNotes)
				animationNotes.push(songNotes);
		}
		TankmenBG.animationNotes = animationNotes;
		animationNotes.sort(sortAnims);
	}

	inline function sortAnims(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0], Obj2[0]);

	public var danceEveryNumBeats:Int = 2;
	private var settingCharacterUp:Bool = true;
	public function recalculateDanceIdle() {
		var lastDanceIdle:Bool = danceIdle;
		danceIdle = (animation.getByName('danceLeft' + idleSuffix) != null && animation.getByName('danceRight' + idleSuffix) != null);

		if(settingCharacterUp)
			danceEveryNumBeats = (danceIdle ? 1 : 2);
		else if(lastDanceIdle != danceIdle)
		{
			var calc:Float = danceEveryNumBeats;
			if(danceIdle)
				calc /= 2;
			else
				calc *= 2;

			danceEveryNumBeats = Math.round(Math.max(calc, 1));
		}
		settingCharacterUp = false;
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
		animOffsets[name] = [x, y];

	public function quickAnimAdd(name:String, anim:String)
		animation.addByPrefix(name, anim, 24, false);
}

class Boyfriend extends Character
{
	public var startedDeath:Bool = false;

	public function new(x:Float, y:Float, ?char:String = 'bf')
	{
		super(x, y, char, true);
	}

	override function update(elapsed:Float)
	{
		if (!debugMode && animation.curAnim != null)
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}
			else
				holdTimer = 0;

			if (animation.curAnim.name.endsWith('miss') && animation.curAnim.finished && !debugMode)
			{
				playAnim('idle', true, false, 10);
			}

			if (animation.curAnim.name == 'firstDeath' && animation.curAnim.finished && startedDeath)
			{
				playAnim('deathLoop');
			}
		}

		super.update(elapsed);
	}
}