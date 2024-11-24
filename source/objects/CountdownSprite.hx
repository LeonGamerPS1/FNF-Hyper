package objects;

import flixel.FlxSprite;

/**
 * The Countdown class.
 * @author LeonGamerPS1
 */
class CountdownSprite extends FlxSprite {
    /**
	 * Constructor for the Countdown Sprite.
	 * @param x The X Position.
	 * @param y The Y Position.
	 * @param spr The sprite that should be used.
	 */
    public function new(?x, ?y, ?spr:String = 'ready') {
        super(x, y);
        loadGraphic('assets/images/$spr.png');
    }

    public function ass(?spr:String = 'ready', ?skin:String = 'funkin') {
        loadGraphic('assets/images/$spr.png');
        alpha = 1;
    }
}
