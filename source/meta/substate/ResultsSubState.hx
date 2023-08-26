package meta.substate;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;

import meta.*;
import meta.state.*;
import meta.state.PlayState;

import meta.substate.*;

// nothing much yet...
// ? <-- looks like the glottal stop!!
class ResultsSubState extends MusicBeatSubState {

    var bg:FlxSprite;

    public function new(sicks:Int, goods:Int, bads:Int, shits:Int, score:Int, misses:Int, ?weekScore:Int, ?weekMisses:Int, percent:Float, rating:String) {
        super();

        bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
        bg.alpha = 0.4;
        add(bg);

        var titleTxt:FlxText = new FlxText(5, 0, 0, (PauseSubState.daSelected == 'SKip Song') ? 'y u skip??' : 'RESULTS', 72);
		titleTxt.scrollFactor.set();
		titleTxt.setFormat("VCR OSD Mono", 48, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		titleTxt.updateHitbox();
		add(titleTxt);
    }

    override function update(elapsed:Float) {
		super.update(elapsed);

		if (controls.ACCEPT) {
			if (PlayState.isStoryMode)
				MusicBeatState.switchState(new StoryMenuState());
			else {
				if (PlayState.inMini) {
					inMini = false;
					MusicBeatState.switchState(new MinigamesState());
				} else {
					MusicBeatState.switchState(new FreeplayState());
				}
            }
            FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}
	}
}