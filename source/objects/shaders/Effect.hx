package objects.shaders;

import flixel.system.FlxAssets.FlxShader;

typedef ShaderEffect = 
{
	var shader:Dynamic;
}

class Effect {
	public function setValue(name:FlxShader, variable:String, value:Float){
		Reflect.setProperty(Reflect.getProperty(name, 'variable'), 'value', [value]);
	}
}