package meta.data.input;

import objects.userinterface.note.*;

class KadeInputSystem extends meta.data.input.InputSystem {
    public var closestNotes:Array<Note> = [];

    public override function updateNote(note:Note, elapsed:Float) {
        var mustPress = note.mustPress;
        var strumTime = note.strumTime;
        var tooLate = note.tooLate;
        var wasGoodHit = note.wasGoodHit;
        var lateHitMult = note.lateHitMult;
        var earlyHitMult = note.earlyHitMult;
        var isSustainNote = note.isSustainNote;
        var sustainActive = note.sustainActive;
        var prevNote = note.prevNote;
        var inEditor = note.inEditor;
        
        var songMultiplier = PlayState.instance.playbackRate;
        var timeScale:Float = Conductor.safeZoneOffset / 166;

        if (!sustainActive)
		{
			note.alpha = 0.3;
		}

        if (mustPress)
        {
            if (isSustainNote)
            {
                if (strumTime - Conductor.songPosition <= (((166 * timeScale) / (songMultiplier < 1 ? songMultiplier : 1) * 0.5))
                    && strumTime - Conductor.songPosition >= (((-166 * timeScale) / (songMultiplier < 1 ? songMultiplier : 1))))
                    note.canBeHit = true;
                else
                    note.canBeHit = false;
            }
            else
            {
                if (strumTime - Conductor.songPosition <= (((166 * timeScale) / (songMultiplier < 1 ? songMultiplier : 1)))
                    && strumTime - Conductor.songPosition >= (((-166 * timeScale) / (songMultiplier < 1 ? songMultiplier : 1))))
                    note.canBeHit = true;
                else
                    note.canBeHit = false;
            }
        }
        else
        {
            note.canBeHit = false;
        }

        if (tooLate && !wasGoodHit)
        {
            if (note.multAlpha > 0.3)
                note.multAlpha = 0.3;
        }
    }

    public override function keyPressed(key:Int) {
        var boyfriend = PlayState.instance.boyfriend;
        var notes = PlayState.instance.notes;

        var canMiss:Bool = !ClientPrefs.ghostTapping;
        var data = key;

        closestNotes = [];

        notes.forEachAlive(function(daNote:Note)
        {
            if (daNote.canBeHit && daNote.mustPress && !daNote.wasGoodHit)
                closestNotes.push(daNote);
        });

        var dataNotes = [];
        for (i in closestNotes)
            if (i.noteData == data && !i.isSustainNote)
                dataNotes.push(i);

        closestNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

        var dataNotes = [];
        for (i in closestNotes)
            if (i.noteData == data && !i.isSustainNote)
                dataNotes.push(i);

        if (dataNotes.length > 0)
        {
            var coolNote = null;

            for (i in dataNotes)
            {
                coolNote = i;
                break;
            }

            if (dataNotes.length > 1)
            {
                for (i in 0...dataNotes.length)
                {
                    if (i == 0)
                        continue;

                    var note = dataNotes[i];

                    if (!note.isSustainNote && ((note.strumTime - coolNote.strumTime) < 2) && note.noteData == data)
                    {
                        trace('found a stacked/really close note ' + (note.strumTime - coolNote.strumTime));
                        note.kill();
                        notes.remove(note, true);
                        note.destroy();
                    }
                }
            }

            boyfriend.holdTimer = 0;
            var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);

            goodNoteHit(coolNote);
        }
        else
        {
            PlayState.instance.callOnScripts('onGhostTap', [key]);
            if (canMiss && !boyfriend.stunned) noteMissPress(key);
        }
    }

    public override function keysCheck():Void {
        if (holdArray.contains(true))
        {
            var notes = PlayState.instance.notes;
            notes.forEachAlive(function(daNote:Note)
            {
                // TODO: add sustainactive
                if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData] && daNote.sustainActive)
                {
                    goodNoteHit(daNote);
                }
            });
        }
    }

    private function addMiss() {
        var practiceMode = PlayState.instance.practiceMode;
        var endingSong = PlayState.instance.endingSong;

        if(!practiceMode) PlayState.instance.songScore -= 10;
        if(!endingSong) PlayState.instance.songMisses++;
        PlayState.instance.totalPlayed++;
        PlayState.instance.RecalculateRating(true);
    }

    public override function noteMissed(daNote:Note) {
        if (daNote.tail.length > 0)
        {
            for (i in daNote.tail)
            {
                i.multAlpha = 0.3;
                i.sustainActive = false;

                addMiss();

                PlayState.instance.health -= 0.15;
            }
        } else {
            if (!daNote.wasGoodHit
                && daNote.isSustainNote
                && daNote.sustainActive
                && daNote != daNote.parent.tail[daNote.parent.tail.length])
            {
                for (i in daNote.parent.tail)
                {
                    i.multAlpha = 0.3;
                    i.sustainActive = false;

                    addMiss();
                }
            }
        }
    }
}