package minigames;

import minigames.FallingIcon;

class KillBF extends MusicBeatState
{
    var score:Int = 0;
    var misses:Int = 0;
    var spawnTimer:Float = 0;

    var beef:Array<FallingIcon> = [];
    var scoreText:FlxText;

    override function create()
    {
        FlxG.mouse.visible = true;
        FlxG.sound.playMusic(Paths.music('minigame'));

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('stages/stage/stageback'));
        bg.screenCenter();
        add(bg);

        scoreText = new FlxText(0, (FlxG.height * 0.89) + 36, FlxG.height, 'Score: ${score} // Misses: ${misses}', 20);
        scoreText.setFormat(Paths.font('vcr.ttf'), 48, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        scoreText.screenCenter(X);
        add(scoreText);

        super.create();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        scoreText.text = 'Score: ${score} // Misses: ${misses}';

        spawnTimer += elapsed;

        if (spawnTimer >= 1)
        {
            spawnSprite();
            spawnTimer = 0;
        }

        for (bf in beef)
        {
            if (FlxG.mouse.overlaps(bf) && FlxG.mouse.justPressed)
            {
                FlxG.sound.play(Paths.sound('bfkill'));
                bf.kill();
                score++;
            }

            if (bf.y > FlxG.height)
            {
                FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
                bf.kill();
                score--;
                misses++;
            }
        }

        if (controls.BACK)
        {
            FlxG.switchState(() -> new MinigamesState());
            FlxG.sound.playMusic(Paths.music('freakyMenu'));
        }
    }

    private function spawnSprite()
    {
        var sprite:FallingIcon = new FallingIcon(FlxG.random.int(0, FlxG.width - 20), -80);
        sprite.velocity.y = FlxG.random.int(60, 150);
        beef.push(sprite);
        add(sprite);
    }
}