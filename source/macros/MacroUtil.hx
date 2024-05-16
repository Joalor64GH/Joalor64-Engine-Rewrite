package macros;

import sys.io.File;
import sys.io.Process;
import sys.FileSystem;

class MacroUtil
{
    public static macro function getFlag(flag:String):haxe.macro.Expr
    {
        if (haxe.macro.Context.defined(flag))
            return macro $v{haxe.macro.Context.definedValue(flag)};
        else
            return macro $v{""};
    }

    /**
     * @author Leather128
     * @see https://github.com/Leather128/FabricEngine/
     */
    
    public static macro function get_commit_id():haxe.macro.Expr.ExprOf<String>
    {
        try {
            var daProcess = new Process('git', ['log', '--format=%h', '-n', '1']);
            daProcess.exitCode(true);
            return macro $v{daProcess.stdout.readLine()};
        } catch(e) {}
        return macro $v{"-"};
    }

    public static macro function get_build_num()
    {
        try {
            var proc = new Process('git', ['rev-list', 'HEAD', '--count'], false);
            proc.exitCode(true);
            return macro $v{Std.parseInt(proc.stdout.readLine())};
        } catch(e) {}
        return macro $v{0};
    }

    /**
     * @author khuonghoanghuy
     * @see https://github.com/Cool-Team-Development/Simple-Clicker-Game/
     */

    static macro function getDefine(key:String):haxe.macro.Expr
    {
        return macro $v{haxe.macro.Context.definedValue(key)};
    }

    static macro function setDefine(key:String, value:String):haxe.macro.Expr
    {
        haxe.macro.Compiler.define(key, value);
        return macro null;
    }

    static macro function isDefined(key:String):haxe.macro.Expr
    {
        return macro $v{haxe.macro.Context.defined(key)};
    }

    static macro function getDefines():haxe.macro.Expr
    {
        var defines:Map<String, String> = haxe.macro.Context.getDefines();
        var map:Array<haxe.macro.Expr> = [];
        for (key in defines.keys())
            map.push(macro $v{key} => $v{Std.string(defines.get(key))});

        return macro $a{map};
    }
}