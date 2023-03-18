package unused;

using StringTools;

class Globals {
	public static var Function_Stop:Dynamic = 1;
	public static var Function_Continue:Dynamic = 0;

	public static inline function getInstance()
	{
		return meta.state.PlayState.instance.isDead ? meta.substate.GameOverSubstate.instance : meta.state.PlayState.instance;
	}
}