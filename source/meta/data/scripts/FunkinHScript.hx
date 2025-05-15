package meta.data.scripts;

import hscript.*;

// NEW HSCRIPT SYSTEM!! YES!!
// VERY BASIC ATM, BUT WILL ADD MORE STUFF LATER!!
class FunkinHScript extends FlxBasic {
	public var locals(get, set):Map<String, {r:Dynamic}>;

	function get_locals():Map<String, {r:Dynamic}> {
		@:privateAccess
		return interp.locals;
	}

	function set_locals(local:Map<String, {r:Dynamic}>) {
		@:privateAccess
		return interp.locals = local;
	}

	public static var Function_Stop:Dynamic = 1;
	public static var Function_Continue:Dynamic = 0;

	public var parser:Parser = new Parser();
	public var interp:Interp = new Interp();

	public function new(file:String, ?execute:Bool = true) {
		super();

		parser.allowJSON = parser.allowTypes = parser.allowMetadata = true;
		parser.preprocesorValues = macros.MacroUtil.getDefines();

		// Default Variables
		setVariable('this', this);

		setVariable('Function_Stop', Function_Stop);
		setVariable('Function_Continue', Function_Continue);

		setVariable('version', Lib.application.meta.get('version'));

		// Default Functions
		setVariable('import', function(daClass:String, ?asDa:String) {
			final splitClassName:Array<String> = [for (e in daClass.split('.')) e.trim()];
			final className:String = splitClassName.join('.');
			final daClass:Class<Dynamic> = Type.resolveClass(className);
			final daEnum:Enum<Dynamic> = Type.resolveEnum(className);

			if (daClass == null && daEnum == null)
				Lib.application.window.alert('Class / Enum at $className does not exist.', 'Hscript Error!');
			else {
				if (daEnum != null) {
					var daEnumField = {};
					for (daConstructor in daEnum.getConstructors())
						Reflect.setField(daEnumField, daConstructor, daEnum.createByName(daConstructor));

					if (asDa != null && asDa != '')
						setVariable(asDa, daEnumField);
					else
						setVariable(splitClassName[splitClassName.length - 1], daEnumField);
				} else {
					if (asDa != null && asDa != '')
						setVariable(asDa, daClass);
					else
						setVariable(splitClassName[splitClassName.length - 1], daClass);
				}
			}
		});

		setVariable('trace', function(value:Dynamic) {
			trace(value);
		});

		setVariable('importScript', function(source:String) {
			var name:String = StringTools.replace(source, '.', '/');
			var script:FunkinHScript = new FunkinHScript(Paths.script(name), false);
			script.execute(Paths.script(name), false);
			return script.getAll();
		});

		setVariable('stopScript', function() {
			this.destroy();
		});

		// Haxe
		setVariable('Array', Array);
		setVariable('Bool', Bool);
		setVariable('Date', Date);
		setVariable('DateTools', DateTools);
		setVariable('Dynamic', Dynamic);
		setVariable('EReg', EReg);
		#if sys
		setVariable('File', File);
		setVariable('FileSystem', FileSystem);
		#end
		setVariable('Float', Float);
		setVariable('Int', Int);
		setVariable('Json', Json);
		setVariable('Lambda', Lambda);
		setVariable('Math', Math);
		setVariable('Path', Path);
		setVariable('Reflect', Reflect);
		setVariable('Std', Std);
		setVariable('StringBuf', StringBuf);
		setVariable('String', String);
		setVariable('StringTools', StringTools);
		#if sys
		setVariable('Sys', Sys);
		#end
		setVariable('Type', Type);
		setVariable('Xml', Xml);

		setVariable('createThread', function(func:Void->Void) {
			#if sys
			sys.thread.Thread.create(() -> {
				func();
			});
			#else
			func();
			#end
		});

		// OpenFL
		setVariable('Assets', Assets);
		setVariable('BitmapData', BitmapData);
		setVariable('Lib', Lib);
		setVariable('ShaderFilter', openfl.filters.ShaderFilter);
		setVariable('Sound', openfl.media.Sound);

		// Flixel
		setVariable('FlxAxes', getFlxAxes());
		setVariable('FlxBasic', FlxBasic);
		setVariable('FlxCamera', FlxCamera);
		setVariable('FlxCameraFollowStyle', getFlxCameraFollowStyle());
		setVariable('FlxColor', getFlxColor());
		setVariable('FlxEase', FlxEase);
		setVariable('FlxG', FlxG);
		setVariable('FlxGroup', FlxGroup);
		setVariable('FlxMath', FlxMath);
		setVariable('FlxObject', FlxObject);
		setVariable('FlxSound', FlxSound);
		setVariable('FlxSprite', FlxSprite);
		setVariable('FlxSpriteGroup', FlxSpriteGroup);
		setVariable('FlxText', FlxText);
		setVariable('FlxTextAlign', getFlxTextAlign());
		setVariable('FlxTextBorderStyle', getFlxTextBorderStyle());
		setVariable('FlxTimer', FlxTimer);
		setVariable('FlxTween', FlxTween);
		setVariable('FlxTypedGroup', FlxTypedGroup);
		setVariable('createTypedGroup', function(?variable) {
			return variable = new FlxTypedGroup<Dynamic>();
		});
		setVariable('createSpriteGroup', function(?variable) {
			return variable = new FlxSpriteGroup();
		});

		// State Stuff
		setVariable('add', FlxG.state.add);
		setVariable('remove', FlxG.state.remove);
		setVariable('insert', FlxG.state.insert);
		setVariable('members', FlxG.state.members);
		setVariable('state', FlxG.state);

		setVariable('game', PlayState.instance);

		if (execute)
			this.execute(file);
	}

	public function execute(file:String, ?executeCreate:Bool = true):Void {
		try {
			interp.execute(parser.parseString(File.getContent(file)));
		} catch (e:Dynamic)
			Lib.application.window.alert(Std.string(e), 'Hscript Error!');

		trace('Script Loaded Succesfully: $file');

		if (executeCreate)
			executeFunc('create', []);
	}

	public function setVariable(name:String, val:Dynamic):Void {
		try {
			interp?.variables.set(name, val);
			locals.set(name, {r: val});
		} catch (e:Dynamic)
			Lib.application.window.alert(Std.string(e), 'Hscript Error!');
	}

	public function getVariable(name:String):Dynamic {
		try {
			if (locals.exists(name) && locals[name] != null)
				return locals.get(name).r;
			else if (interp.variables.exists(name))
				return interp?.variables.get(name);
		} catch (e:Dynamic)
			Lib.application.window.alert(Std.string(e), 'Hscript Error!');

		return null;
	}

	public function removeVariable(name:String):Void {
		try {
			interp?.variables.remove(name);
		} catch (e:Dynamic)
			Lib.application.window.alert(Std.string(e), 'Hscript Error!');
	}

	public function existsVariable(name:String):Bool {
		try {
			return interp?.variables.exists(name);
		} catch (e:Dynamic)
			Lib.application.window.alert(Std.string(e), 'Hscript Error!');

		return false;
	}

	public function executeFunc(funcName:String, ?args:Array<Dynamic>):Dynamic {
		if (existsVariable(funcName)) {
			try {
				return Reflect.callMethod(this, getVariable(funcName), args == null ? [] : args);
			} catch (e:Dynamic)
				Lib.application.window.alert(Std.string(e), 'Hscript Error!');
		}

		return null;
	}

	public function getAll():Dynamic {
		var balls:Dynamic = {};

		for (i in locals.keys())
			Reflect.setField(balls, i, getVariable(i));
		for (i in interp.variables.keys())
			Reflect.setField(balls, i, getVariable(i));

		return balls;
	}

	public function getFlxColor() {
		return {
			// colors
			"BLACK": FlxColor.BLACK,
			"BLUE": FlxColor.BLUE,
			"BROWN": FlxColor.BROWN,
			"CYAN": FlxColor.CYAN,
			"GRAY": FlxColor.GRAY,
			"GREEN": FlxColor.GREEN,
			"LIME": FlxColor.LIME,
			"MAGENTA": FlxColor.MAGENTA,
			"ORANGE": FlxColor.ORANGE,
			"PINK": FlxColor.PINK,
			"PURPLE": FlxColor.PURPLE,
			"RED": FlxColor.RED,
			"TRANSPARENT": FlxColor.TRANSPARENT,
			"WHITE": FlxColor.WHITE,
			"YELLOW": FlxColor.YELLOW,

			// functions
			"add": FlxColor.add,
			"fromCMYK": FlxColor.fromCMYK,
			"fromHSB": FlxColor.fromHSB,
			"fromHSL": FlxColor.fromHSL,
			"fromInt": FlxColor.fromInt,
			"fromRGB": FlxColor.fromRGB,
			"fromRGBFloat": FlxColor.fromRGBFloat,
			"fromString": FlxColor.fromString,
			"interpolate": FlxColor.interpolate,
			"to24Bit": function(color:Int) {
				return color & 0xffffff;
			}
		};
	}

	public function getFlxCameraFollowStyle() {
		return {
			"LOCKON": FlxCamera.FlxCameraFollowStyle.LOCKON,
			"PLATFORMER": FlxCamera.FlxCameraFollowStyle.PLATFORMER,
			"TOPDOWN": FlxCamera.FlxCameraFollowStyle.TOPDOWN,
			"TOPDOWN_TIGHT": FlxCamera.FlxCameraFollowStyle.TOPDOWN_TIGHT,
			"SCREEN_BY_SCREEN": FlxCamera.FlxCameraFollowStyle.SCREEN_BY_SCREEN,
			"NO_DEAD_ZONE": FlxCamera.FlxCameraFollowStyle.NO_DEAD_ZONE
		};
	}

	public function getFlxTextAlign() {
		return {
			"LEFT": FlxTextAlign.LEFT,
			"CENTER": FlxTextAlign.CENTER,
			"RIGHT": FlxTextAlign.RIGHT,
			"JUSTIFY": FlxTextAlign.JUSTIFY
		};
	}

	public function getFlxTextBorderStyle() {
		return {
			"NONE": FlxTextBorderStyle.NONE,
			"SHADOW": FlxTextBorderStyle.SHADOW,
			"OUTLINE": FlxTextBorderStyle.OUTLINE,
			"OUTLINE_FAST": FlxTextBorderStyle.OUTLINE_FAST
		};
	}

	public function getFlxAxes() {
		return {
			"X": FlxAxes.X,
			"Y": FlxAxes.Y,
			"XY": FlxAxes.XY
		};
	}

	override function destroy() {
		super.destroy();
		parser = null;
		interp = null;
	}
}