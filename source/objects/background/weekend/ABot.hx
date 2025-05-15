package objects.background.weekend;

import objects.background.weekend.ABotVis

class ABot extends FlxSpriteGroup
{
	public var lookingTo:Int = 0;	// 0 = opponent; 1 = player; 2 = middle
	public var abotThing = new FlxSprite();
	public var eyes = new FlxSprite();
	public var aBG = new FlxSprite();
	public var abotViz:ABotVis;
	public function new(x:Float, y:Float)
	{
		super(x, y);
		aBG = new FlxSprite(x - 120, y + 316);
		abotViz = new ABotVis(FlxG.sound.music);
		abotViz.x = x + 100;
		abotViz.y = y + 400;
		eyes = new FlxSprite(aBG.x, aBG.y);
		abotThing = new FlxSprite(aBG.x, aBG.y);

		aBG.loadGraphic(Paths.image('characters/abot/AbotBG'));
		FlxG.debugger.track(abotViz);
		eyes.frames = Paths.getSparrowAtlas('characters/abot/eyes');
		abotThing.frames = Paths.getSparrowAtlas('characters/abot/ABot');

		abotThing.animation.addByPrefix('bump', 'idle', 24, false);
		eyes.animation.addByPrefix('changeLookingPL', 'tweenPL', 24, false);
		eyes.animation.addByPrefix('changeLookingOP', 'tweenOP', 24, false);
		eyes.animation.addByPrefix('middleLooking', 'middle', 24, false);
		//animation.play('danceLeft');
	}

	public function eyesTween(cam:Int = 0):Void
	{
		switch(cam)
		{
			case 0:
				eyes.animation.play('changeLookingOP', false, false); //looks to opponent
				lookingTo = 0;
			case 1:
				eyes.animation.play('changeLookingPL', false, false); //looks to player --- THIS
				lookingTo = 1;
			case 2:
				eyes.animation.play('middleLooking', true); //unused for now
				lookingTo = 2;
		}
		//eyes.animation.play('changeLooking', true, reversed);
	}

	public function Beat():Void
	{
		abotThing.animation.play('bump', true);
	}
}