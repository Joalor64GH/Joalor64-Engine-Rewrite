package meta.state.menuObjects;

class MusicBeatGroup extends FlxTypedGroup<FlxBasic>
{
	public var groupName:String = 'none';
	
	private var controls(get, never):Controls;
	inline function get_controls():Controls
		return PlayerSettings.player1.controls;
	
	public function new() 
    {
		super();
    }
	
	public function stepHit(curStep:Int = 0) {}
	public function beatHit(curBeat:Int = 0) {}
}