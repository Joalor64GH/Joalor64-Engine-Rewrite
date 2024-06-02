package meta.data;

/**
 * @author DiogoTVV
 * @see https://github.com/DiogoTVV/funky-moonleap-source
 */

class CustomFadeTransition extends FlxSubState
{
	public static var finishCallback:Void->Void;
	public static var nextCamera:FlxCamera;

	var rhombus:FlxSprite;
	var isTransIn:Bool = false;

	public function new(duration:Float, isTransIn:Bool)
	{
		super();

		this.isTransIn = isTransIn;
		
		var width:Int = Std.int(FlxG.width);
		var height:Int = Std.int(FlxG.height);
		
		rhombus = new FlxSprite();
		rhombus.frames = Paths.getSparrowAtlas('transition');
		rhombus.animation.addByIndices('fadeIn', 'fade', [29,28,27,26,25,24,23,22,21,20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0], "", Std.int(20 / duration), false);
		rhombus.animation.addByIndices('fadeOut','fade', [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29], "", Std.int(20 / duration), false);
		rhombus.animation.play('fade' + (isTransIn ? 'In' : 'Out'));
		rhombus.color = FlxColor.fromRGB(0, 0, 0);
		rhombus.scrollFactor.set();
		add(rhombus);
	}

	var stopNow:Bool = false;

	override function update(elapsed:Float)
	{
		var camList = FlxG.cameras.list;
		camera = camList[camList.length - 1];
		rhombus.cameras = [camera];

		super.update(elapsed);
		
		if (rhombus.animation.curAnim.finished && !stopNow)
		{
			stopNow = true;
		
			if (isTransIn)
				close();
			else if (finishCallback != null)
				finishCallback();
		}
	}

	override function destroy()
	{
		super.destroy();
	}
}