package;

import polymod.hscript.HScriptable;
import flixel.FlxSprite;

@:hscript({
    context: [FlxG, Std, Math, Paths, FlxSprite, StringTools]
})
interface IHook extends HScriptable
{
}