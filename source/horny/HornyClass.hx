package horny;

import horny.*;

class HornyClass {
	
	public var script:HornyScript;

    public dynamic function new(path:String, args:Array<Dynamic>) {
        script = new HornyScript(path);
		script.setVariable("class", this);
                script.run();
                script.executeFunc("new", args);
		script.executeFunc("create", args);
    }

    public function set(name:String, val:Dynamic) {
        script.setVariable(name, val);
    }

    public function get(name:String):Dynamic {
        return script.getVariable(name);
    }

    public function call(name:String, args:Array<Any>):Dynamic {
        return script.executeFunc(name, args);
    }
}