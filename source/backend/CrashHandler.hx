package backend;

import openfl.events.Event;
import openfl.events.KeyboardEvent;

import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;

import openfl.ui.Keyboard;

/**
 * @author crowplexus
 * @see https://github.com/crowplexus/Forever-Engine/
 */

class CrashHandler extends Sprite 
{
	var errorTitle:RotatableTextField;
	var loggedError:TextField;

	private static var _active:Bool = false;

	var _stage:openfl.display.Stage;
	var random = new flixel.math.FlxRandom();

	final imagineBeingFunny:Array<String> = [
		"Fatal Error!",
		"!rorrE lataF",
		"Okay, what'd you do this time?",
		"I told you the human would crash the game.",
		"The operation completed successfully.",
		"Task failed successfully.",
		"Something error'd, but honestly, we're just gonna ignore it!",
		"We found a bug in your software. It's a freaking butterfly.",
		"Oops, I did it again.",
		"Uh oh. You're screwed.",
		"Something bad",
		"Catastrophic failure",
		"Something happened",
		"I caught the error!",
		"so long gay bowser!!",
		"im gone fire!!!!!",
		"fix your grammer",
		"Can't",
		"lmfao",
		"removeChild(game);",
		"POW! Haha!",
		"Invalid Canary",
		"Don't",
		"I, ummm... What was I gonna say?",
		"there is an error on your screen plz close it",
		"Hi, I'm an error!",
		"e",
		"failed to display error",
		"Alt+F4",
		"What is this?",
		"nya~ - The Boykisser",
		"Youre Computer HAS BEEN HACKED!!!!",
		"hello",
		"Try something else.",
		"You know you're trapped here, right?",
		"All your base are belong to us.",
		"Yes",
		"OH NO",
		"it is so winmdy... my ppoore umbreella,,, goner,,, rainyt,",
		"pwned",
		"Click to fix error. ...wait",
		"Welp, time to self-destruct.",
		"Extinction is imminent",
		"You prove that stupidity is real",
		"You are",
		"Your mom",
		"The quick brown fox jumps over the lazy dog",
		"Error 404 - Brain.exe not found",
		"Press F",
		"Error",
		"C:\\_",
		"time to destroy",
		"air detected",
		"Are you stoopid",
		"Sorry, this error is under construction.",
		"Error 1001",
		"Check your internet and try again. (Error Code: 277)",
		"Your MLG level is at 0.",
		"all the world connected to ur pc",
		"ERR_NO_WIFI",
		"It's all gone",
		"trash",
		"ur pc is dead",
		"I'm confused.",
		"There's a cow in your hard drive. You should probably fix that.",
		"The End is Nigh",
		"help",
		"LEAVE LEAVE LEAVE LEAVE LEAVE LEAVE LEAVE",
		"no error found",
		"Please, just leave.",
		"???",
		"?",
		"X",
		"you're welcome",
		"Welcome back.",
		"It's all in your head.",
		"Nothing is wrong.",
		"look",
		"it is raining on the co mputer.. oh no..",
		"womp womp",
		"Get some duct tape or something.",
		"cry about it",
		"When YOU have the WILL, don't say NEVER. Just LEAVE those thoughts!",
		"I think you should leave",
		"Nothing can be done.",
		"You are an idiot! :D",
		"ERROR CODE /WYGIG-TTD/",
		"Can you?",
		"Did you commit tax faud again?",
		"IP found. All of china knows your location.",
		"why tho",
		"You should take a break.",
		"um",
		"error",
		"You can't go back.",
		"got dam"
	];

	public function new(stack:String):Void 
	{
		super();

		this._stage = Lib.application.window.stage;

		if (!_active)
			_active = true;

		final _matrix = new flixel.math.FlxMatrix().rotateByPositive90();

		graphics.beginGradientFill(LINEAR, [0xFF000000, 0xFFA84444], [0.5, 1], [75, 255], _matrix);
		graphics.drawRect(0, 0, _stage.stageWidth, _stage.stageHeight);
		graphics.endFill();

		final tf = new openfl.text.TextFormat(Paths.font("vcr.ttf"), 24, 0xFFFFFF);
		final tf2 = new openfl.text.TextFormat(Paths.font("vcr.ttf"), 48, 0xDADADA);

		errorTitle = new RotatableTextField();
		loggedError = new TextField();

		errorTitle.defaultTextFormat = tf2;

		random.shuffle(imagineBeingFunny);
		var quote:String = random.getObject(imagineBeingFunny);
		errorTitle.text = '${quote}\n';

		for (i in 0...quote.length)
			errorTitle.appendText('-');

		errorTitle.width = _stage.stageWidth * 0.5;
		errorTitle.x = centerX(errorTitle.width);
		errorTitle.y = _stage.stageHeight * 0.1;

		errorTitle.autoSize = CENTER;
		errorTitle.multiline = true;

		loggedError.defaultTextFormat = tf;
		loggedError.text = '\n\n${stack}\n'
			+ "\nPress R to restart the game."
			+ "\nIf you feel like this error shouldn't have happened, please report it to the GitHub Page by pressing G."
			+ "\nOtherwise, Press Q to exit the game.";

		loggedError.autoSize = errorTitle.autoSize;
		loggedError.y = errorTitle.y + (errorTitle.height) + 50;
		loggedError.autoSize = CENTER;

		addChild(errorTitle);
		addChild(loggedError);

		if (loggedError.width > _stage.stageWidth)
			loggedError.scaleX = loggedError.scaleY = _stage.stageWidth / (loggedError.width + 100);
		loggedError.x = centerX(loggedError.width);

		if (errorTitle.width > _stage.stageWidth)
			errorTitle.scaleX = errorTitle.scaleY = _stage.stageWidth / (errorTitle.width + 100);
		errorTitle.x = centerX(errorTitle.width);

		final sound:openfl.media.Sound = Paths.sound('crash');
		sound.play(new openfl.media.SoundTransform()).addEventListener(Event.SOUND_COMPLETE, (_) -> {
			sound.close();
		});

		_stage.addEventListener(KeyboardEvent.KEY_DOWN, keyActions);
		addEventListener(Event.ENTER_FRAME, (e) -> {
			var time = Lib.getTimer() / 1000;
			if (time - lastTime > 1 / 5) {
				if (!setupOrigin) {
					errorTitle.originX = errorTitle.width * 0.5;
					errorTitle.originY = errorTitle.height * 0.5;
					setupOrigin = true;
				}
				errorTitle.rotation = random.float(-1, 1);
				lastTime = time;
			}
		});
	}

	var lastTime = 0.0;
	var setupOrigin = false;

	public function keyActions(e:KeyboardEvent):Void {
		switch e.keyCode {
			case Keyboard.R:
				_stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyActions);
				FlxG.switchState(new Init());
				_active = false;
				@:privateAccess
				Main.instance.game._viewingCrash = false;
				if (Main.instance != null && Main.instance.contains(this))
					Main.instance.removeChild(this);
			case Keyboard.G:
				CoolUtil.browserLoad("https://github.com/Joalor64GH/Joalor64-Engine-Rewrite/issues/");
			case Keyboard.Q:
				#if (sys || cpp)
				Sys.exit(0);
				#else
				System.exit(0);
				#end
		}
	}

	inline function centerX(w:Float):Float {
		return (0.5 * (_stage.stageWidth - w));
	}
}

class RotatableTextField extends TextField 
{
	public var originX(default, set):Float = 0;
	public var originY(default, set):Float = 0;

	private override function set_rotation(value:Float):Float {
		if (value != __rotation) {
			__rotation = value;
			var radians = __rotation * (Math.PI / 180);
			__rotationSine = Math.sin(radians);
			__rotationCosine = Math.cos(radians);
			updateRotation();
		}

		return value;
	}

	private function set_originX(value:Float):Float {
		if (value != originX) {
			originX = value;
			updateRotation();
		}

		return value;
	}

	private function set_originY(value:Float):Float {
		if (value != originY) {
			originY = value;
			updateRotation();
		}

		return value;
	}

	private var __x:Float = 0;
	private var __y:Float = 0;

	@:keep @:noCompletion override private function set_x(value:Float):Float {
		if (value != __x) {
			__x = value;
			updateRotation();
		}
		return value;
	}

	@:keep @:noCompletion override private function get_x():Float {
		return __x;
	}

	@:keep @:noCompletion override private function set_y(value:Float):Float {
		if (value != __y) {
			__y = value;
			updateRotation();
		}

		return value;
	}

	@:keep @:noCompletion override private function get_y():Float {
		return __y;
	}

	public function updateRotation() {
		__transform.tx = 0;
		__transform.ty = 0;
		__transform.translate(-originX, -originY);

		__transform.a = __rotationCosine * __scaleX;
		__transform.b = __rotationSine * __scaleX;
		__transform.c = -__rotationSine * __scaleY;
		__transform.d = __rotationCosine * __scaleY;

		var tx1 = __transform.tx * __rotationCosine - __transform.ty * __rotationSine;
		__transform.ty = __transform.tx * __rotationSine + __transform.ty * __rotationCosine;
		__transform.tx = tx1;

		__transform.translate(originX, originY);
		__transform.translate(__x, __y);

		__setTransformDirty();
	}

	public inline function rotateWithTrig(cos:Float, sin:Float):Matrix {
		var a1:Float = __transform.a * cos - __transform.b * sin;
		__transform.b = __transform.a * sin + __transform.b * cos;
		__transform.a = a1;

		var c1:Float = __transform.c * cos - __transform.d * sin;
		__transform.d = __transform.c * sin + __transform.d * cos;
		__transform.c = c1;

		var tx1:Float = __transform.tx * cos - __transform.ty * sin;
		__transform.ty = __transform.tx * sin + __transform.ty * cos;
		__transform.tx = tx1;

		return __transform;
	}
}