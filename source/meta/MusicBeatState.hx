package meta;

import flixel.addons.ui.FlxUIState;

class MusicBeatState extends modcharting.ModchartMusicBeatState
{
	private var curSection:Int = 0;
	private var stepsToDo:Int = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;

	private var curDecStep:Float = 0;
	private var curDecBeat:Float = 0;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	public static var camBeat:FlxCamera;

	override function create() {
		camBeat = FlxG.camera;

		if (!FlxTransitionableState.skipNextTransOut)
			openSubState(new CustomFadeTransition(0.5, true));
		FlxTransitionableState.skipNextTransOut = false;

		if (transIn != null)
			trace('reg ' + transIn.region);

		#if MODS_ALLOWED 
		Mods.updatedOnState = false; 
		#end
	}

	override function update(elapsed:Float)
	{
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep)
		{
			if(curStep > 0)
				stepHit();

			if(PlayState.SONG != null)
			{
				if (oldStep < curStep)
					updateSection();
				else
					rollbackSection();
			}
		}

		if(FlxG.save.data != null) FlxG.save.data.fullscreen = FlxG.fullscreen;

		super.update(elapsed);
	}

	var trackedBPMChanges:Int = 0;
	inline function stepsToSecs(targetStep:Int, isFixedStep:Bool = false):Float {
		final playbackRate:Single = PlayState.instance != null ? PlayState.instance.playbackRate : 1;
		function calc(stepVal:Single, crochetBPM:Int = -1) {
			return ((crochetBPM == -1 ? Conductor.calculateCrochet(Conductor.bpm) / 4 : Conductor.calculateCrochet(crochetBPM) / 4) * (stepVal - curStep)) / 1000;
		}

		final realStep:Single = isFixedStep ? targetStep : targetStep + curStep;
		var secRet:Float = calc(realStep);

		for (i in 0...Conductor.bpmChangeMap.length - trackedBPMChanges) {
			var nextChange = Conductor.bpmChangeMap[trackedBPMChanges+i];
			if(realStep < nextChange.stepTime) break;

			final diff = realStep - nextChange.stepTime;
			if (i == 0) secRet -= calc(diff);
			else secRet -= calc(diff, Std.int(Conductor.bpmChangeMap[(trackedBPMChanges + i) - 1].bpm));

			secRet += calc(diff, Std.int(nextChange.bpm));
		}
		return secRet / playbackRate;
	}

	inline function beatsToSecs(targetBeat:Int, isFixedBeat:Bool = false):Float
		return stepsToSecs(targetBeat * 4, isFixedBeat);

	private function updateSection():Void
	{
		if(stepsToDo < 1) stepsToDo = Math.round(getBeatsOnSection() * 4);
		while(curStep >= stepsToDo)
		{
			curSection++;
			var beats:Float = getBeatsOnSection();
			stepsToDo += Math.round(beats * 4);
			sectionHit();
		}
	}

	private function rollbackSection():Void
	{
		if(curStep < 0) return;

		var lastSection:Int = curSection;
		curSection = 0;
		stepsToDo = 0;
		for (i in 0...PlayState.SONG.notes.length)
		{
			if (PlayState.SONG.notes[i] != null)
			{
				stepsToDo += Math.round(getBeatsOnSection() * 4);
				if(stepsToDo > curStep) break;
				
				curSection++;
			}
		}

		if(curSection > lastSection) sectionHit();
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
		curDecBeat = curDecStep/4;
	}

	private function updateCurStep():Void
	{
		var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);

		var shit = ((Conductor.songPosition - ClientPrefs.noteOffset) - lastChange.songTime) / lastChange.stepCrochet;
		curDecStep = lastChange.stepTime + shit;
		curStep = lastChange.stepTime + Math.floor(shit);
	}

	public static function switchState(nextState:FlxState = null) {
		if (nextState == null) nextState = FlxG.state;
		if (nextState == FlxG.state)
		{
			resetState();
			return;
		}

		if (FlxTransitionableState.skipNextTransIn) FlxG.switchState(nextState);
		else startTransition(nextState);
		FlxTransitionableState.skipNextTransIn = false;
	}

	public static function resetState() {
		if (FlxTransitionableState.skipNextTransIn) FlxG.resetState();
		else startTransition();
		FlxTransitionableState.skipNextTransIn = false;
	}

	public static function startTransition(nextState:FlxState = null)
	{
		if (nextState == null)
			nextState = FlxG.state;

		FlxG.state.openSubState(new CustomFadeTransition(0.35, false));
		if (nextState == FlxG.state) {
			CustomFadeTransition.finishCallback = function() {
				#if sys
				ArtemisIntegration.toggleFade (false);
				#end
				FlxG.resetState();
			};
		} else {
			CustomFadeTransition.finishCallback = function() {
				#if sys
				ArtemisIntegration.toggleFade (false);
				#end
				FlxG.switchState(nextState);
			};
		}
	}

	public static function getState():MusicBeatState {
		return cast(FlxG.state, MusicBeatState);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void {}
	public function sectionHit():Void {}

	function getBeatsOnSection()
	{
		var val:Null<Float> = 4;
		if(PlayState.SONG != null && PlayState.SONG.notes[curSection] != null) val = PlayState.SONG.notes[curSection].sectionBeats;
		return val == null ? 4 : val;
	}
}