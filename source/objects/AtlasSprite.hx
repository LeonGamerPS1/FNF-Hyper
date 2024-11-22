package objects;

import flixel.FlxSprite;
import flxanimate.*;

class AtlasSprite extends FlxSprite
{
	public var atlas:FlxAnimate;

	public function new(?X:Float = 0, ?Y:Float = 0, char:String = "assets\\other\\texture_atlases\\title\\gf")
	{
		super(X, Y);
		atlas = new FlxAnimate(X, Y, char);
		atlas.anim.addBySymbol('left', 'GF Dancing Beat', 24, true, 0, 0);
		atlas.anim.play('left');
	}

	override function update(e)
	{
		super.update(e);
		atlas.setPosition(x, y);
	}
}
