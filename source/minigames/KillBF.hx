package minigames;

import flixel.ui.FlxBar;
import minigames.FallingIcon;

class KillBF extends MusicBeatState
{
    var score:Int = 0;
    var misses:Int = 0;
    var spawnTimer:Float = 0;

    var beef:Array<FallingIcon> = [];
    var scoreText:FlxText;

    var healthBarBG:AttachedSprite;
	var healthBar:FlxBar;
    var health:Float = 1;

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

        healthBarBG = new AttachedSprite('healthBar');
        healthBarBG.x = scoreText.x;
		healthBarBG.y = scoreText.y - 20;
		healthBarBG.screenCenter(X);
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		add(healthBar);
		healthBarBG.sprTracker = healthBar;

        super.create();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        scoreText.text = 'Score: ${score} // Misses: ${misses}';

        if (health > 2)
            health = 2;

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
                score++;
                health += 0.023;
                bf.kill();
            }
            else if (bf.y > FlxG.height)
            {
                score--;
                misses++;
                health -= 0.05;
                bf.kill();
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
        var sprite:FallingIcon = new FallingIcon(FlxG.random.int(0, FlxG.width - 20), -20);
        sprite.velocity.y = FlxG.random.int(50, 100);
        beef.push(sprite);
        add(sprite);
    }
}