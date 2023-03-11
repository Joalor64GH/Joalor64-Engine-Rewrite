package objects.userinterface;

import flixel.FlxSprite;
import openfl.utils.Assets as OpenFlAssets;
import meta.data.ClientPrefs;

using StringTools;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	private var isOldIcon:Bool = false;
	private var isPlayer:Bool = false;
	private var char:String = '';
	public var widthThing:Float = 0;

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		isOldIcon = (char == 'bf-old');
		this.isPlayer = isPlayer;
		changeIcon(char);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 12, sprTracker.y - 30);
	}

	inline public function swapOldIcon() {
		(!isOldIcon) ? changeIcon('bf-old') : changeIcon('bf');
	}

	private var iconOffsets:Array<Float> = [0, 0];
	public function changeIcon(char:String) {
		if(this.char != char) {
			var name:String = 'icons/' + char;
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/' + char; //Older versions of psych engine's support
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/face'; //Prevents crash from missing icon
			var file:Dynamic = Paths.image(name);

			loadGraphic(file); //Load stupidly first for getting the file size
			this.widthThing = width;
			switch(width) {
				// 1 icon
				case 150:
					loadGraphic(file, true, Math.floor(width), Math.floor(height));
					iconOffsets[0] = (width - 150);
					updateHitbox();
		
					animation.add(char, [0], 0, false, isPlayer);
					animation.play(char);
				// 2 icons
				case 300:
					loadGraphic(file, true, Math.floor(width / 2), Math.floor(height));
					iconOffsets[0] = (width - 150) / 2;
					iconOffsets[1] = (width - 150) / 2;
					updateHitbox();
		
					animation.add(char, [0, 1], 0, false, isPlayer);
					animation.play(char);
				// 3 icons
				case 450:
					loadGraphic(file, true, Math.floor(width / 3), Math.floor(height));
					iconOffsets[0] = (width - 150) / 3;
					iconOffsets[1] = (width - 150) / 3;
					iconOffsets[2] = (width - 150) / 3;
					updateHitbox();
			
					animation.add(char, [1, 0, 2], 0, false, isPlayer);
					animation.play(char);
				// 5 icons
				case 750:
					loadGraphic(file, true, Math.floor(width / 5), Math.floor(height));
					iconOffsets[0] = (width - 150) / 5;
					iconOffsets[1] = (width - 150) / 5;
					iconOffsets[2] = (width - 150) / 5;
					iconOffsets[3] = (width - 150) / 5;
					iconOffsets[4] = (width - 150) / 5;
					updateHitbox();
			
					animation.add(char, [2, 1, 0, 3, 4], 0, false, isPlayer);
					animation.play(char);
			}

			this.char = char;
			antialiasing = ClientPrefs.globalAntialiasing;
			if(char.endsWith('-pixel')) {
				antialiasing = false;
			}
		}
	}

	override function updateHitbox()
	{
		super.updateHitbox();
		offset.x = iconOffsets[0];
		offset.y = iconOffsets[1];
	}

	inline public function getCharacter():String {
		return char;
	}
}
