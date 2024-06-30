package minigames;

import minigames.Card;

#if (flixel >= "5.0.0")
import flixel.input.mouse.FlxMouseEvent;
#end

class FunkyMemory extends MusicBeatState
{
	static inline final READY = "Ready to play";

	private var NUMBER_OF_CARDS:Int = 24;
	private var CARDS_PER_ROW:Int = 8;
	private var cards:Array<Int> = new Array();
	private var card:Card;
	private var pickedCards:Array<Card> = new Array();
	private var canPick:Bool = true;
	private var matchesFound = 0;
	private var canResetGame = false;
	private var statusText:FlxText;

	override public function create()
	{
		super.create();

        FlxG.sound.playMusic(Paths.music('breakfast'));

		for (i in 0...NUMBER_OF_CARDS)
		{
			cards.push(Math.floor(i / 2) + 1);
		}
		trace("My cards: " + cards);

		var i:Int = NUMBER_OF_CARDS;
		var swap:Int, tmp:Int;
		while (i-- > 0)
		{
			swap = Math.floor(Math.random() * i);
			tmp = cards[i];
			cards[i] = cards[swap];
			cards[swap] = tmp;
		}
		trace("My shuffled cards: " + cards);

		for (i in 0...NUMBER_OF_CARDS)
		{
			card = new Card(cards[i]);
			add(card);
			var hm:Float = (FlxG.width - card.width * CARDS_PER_ROW - 10 * (CARDS_PER_ROW - 1)) / 2;
			var vm:Float = (FlxG.height - card.height * (NUMBER_OF_CARDS / CARDS_PER_ROW) - 10 * (NUMBER_OF_CARDS / CARDS_PER_ROW)) / 2;
			card.x = hm + (card.width + 10) * (i % CARDS_PER_ROW);
			card.y = vm + (card.height + 10) * (Math.floor(i / CARDS_PER_ROW));

            // update your fucking flixel
            #if (flixel >= "5.0.0")
			FlxMouseEvent.add(card, onMouseDown);
            #end
		}

        statusText = new FlxText(0, FlxG.height - 50, FlxG.height, READY, 20);
        statusText.setFormat(Paths.font('vcr.ttf'), 30, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        statusText.screenCenter(X);
		add(statusText);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (((FlxG.mouse.justPressed) && (canResetGame)) || (controls.RESET))
		{
			MusicBeatState.resetState();
		}

        if (controls.BACK)
        {
            MusicBeatState.switchState(new MinigamesState());
            FlxG.sound.playMusic(Paths.music('freakyMenu'));
        }
	}

	private function onMouseDown(picked:Card)
	{
		statusText.text = "You picked a " + minigames.C.color[picked.index] + " card";

		if (canPick)
		{
			if (pickedCards.indexOf(picked) == -1)
			{
				pickedCards.push(picked);
				picked.flip();
			}

			if (pickedCards.length == 2)
			{
				canPick = false;
				if (pickedCards[0].index == pickedCards[1].index)
				{
					statusText.text = "Cards match!!!!";
					FlxMouseEvent.remove(pickedCards[0]);
					FlxMouseEvent.remove(pickedCards[1]);
					canPick = true;
					matchesFound++;
					pickedCards = new Array();
					if (matchesFound == NUMBER_OF_CARDS / 2)
					{
                        FlxG.sound.play(Paths.sound('confirmMenu'));
						statusText.text = "You won! Click anywhere to play again!";
						Timer.delay(function()
						{
							canResetGame = true;
						}, 1000);
					}
				}
				else
				{
                    FlxG.sound.play(Paths.sound('cancelMenu'));
					statusText.text = "Cards do not match";

					Timer.delay(function()
					{
						pickedCards[0].flipBack();
						pickedCards[1].flipBack();
						pickedCards = new Array();
						canPick = true;
						statusText.text = READY;
					}, 1000);
				}
			}
		}
	}
}