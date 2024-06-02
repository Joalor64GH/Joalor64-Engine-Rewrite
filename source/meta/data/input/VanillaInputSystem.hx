package meta.data.input;

import objects.userinterface.note.*;

class VanillaInputSystem extends meta.data.input.InputSystem {
    public override function updateNote(note:Note, elapsed:Float) {
        if (note.mustPress)
        {
            if (note.willMiss && !note.wasGoodHit)
            {
                note.tooLate = true;
                note.canBeHit = false;
            }
            else
            {
                if (note.strumTime > Conductor.songPosition - Conductor.safeZoneOffset)
                {
                    if (note.strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
                        note.canBeHit = true;
                }
                else
                {
                    note.canBeHit = true;
                    note.willMiss = true;
                }
            }
        }
        else
        {
            note.canBeHit = false;

            if (note.strumTime <= Conductor.songPosition)
                note.wasGoodHit = true;
        }

        if (note.tooLate)
        {
            if (note.alpha > 0.3)
                note.alpha = 0.3;
        }
    }

    public override function keysCheck():Void {
        var boyfriend = PlayState.instance.boyfriend;
        var canMiss:Bool = !ClientPrefs.data.ghostTapping;

        var perfectMode = false;

        if (holdArray.contains(true))
        {
            var notes = PlayState.instance.notes;
            notes.forEachAlive(function(daNote:Note)
            {
                if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData])
                    goodNoteHit(daNote);
            });
        }

        if (pressArray.contains(true))
        {
            boyfriend.holdTimer = 0;

            var possibleNotes:Array<Note> = []; // notes that can be hit
            var directionList:Array<Int> = []; // directions that can be hit
            var dumbNotes:Array<Note> = []; // notes to kill later

            var notes = PlayState.instance.notes;

            notes.forEachAlive(function(daNote:Note)
            {
                if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
                {
                    if (directionList.contains(daNote.noteData))
                    {
                        for (coolNote in possibleNotes)
                        {
                            if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10)
                            {
                                dumbNotes.push(daNote);
                                break;
                            }
                            else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime)
                            {
                                possibleNotes.remove(coolNote);
                                possibleNotes.push(daNote);
                                break;
                            }
                        }
                    }
                    else
                    {
                        possibleNotes.push(daNote);
                        directionList.push(daNote.noteData);
                    }
                }
            });

            for (note in dumbNotes)
            {
                FlxG.log.add("killing dumb ass note at " + note.strumTime);
                note.kill();
                PlayState.instance.notes.remove(note, true);
                note.destroy();
            }

            possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

            if (perfectMode)
                goodNoteHit(possibleNotes[0]);
            else if (possibleNotes.length > 0)
            {
                for (shit in 0...pressArray.length)
                {
                    if (pressArray[shit] && !directionList.contains(shit)) {
                        noteMissPress(shit);
                    }
                }
                for (coolNote in possibleNotes)
                {
                    if (pressArray[coolNote.noteData])
                        goodNoteHit(coolNote);
                }
            }
            else
            {
                for (key in 0...pressArray.length) {
                    if (pressArray[key]) {
                        PlayState.instance.callOnScripts('onGhostTap', [key]);
                        if (canMiss && !boyfriend.stunned) noteMissPress(key);
                    }
                }
            }
        }
    }
}