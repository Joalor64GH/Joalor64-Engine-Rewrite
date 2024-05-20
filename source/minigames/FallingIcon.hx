package minigames;

class FallingIcon extends FlxSprite
{
    public function new(x:Float, y:Float)
    {
        super(x, y);

        loadGraphic(Paths.image('icons/bf'), true, 150, 150);

        scale.set(0.75, 0.75);

        animation.add('normal', [0], 1);
        animation.add('oof', [1], 1);
        animation.play('normal');
    }

    override function kill()
    {
        alive = false;
        animation.play('oof');
        FlxTween.tween(this, {alpha: 0, y: y - 16}, 0.22, {
            ease: FlxEase.circOut, onComplete: (_) -> {
                exists = false;
            }
        });
    }
}