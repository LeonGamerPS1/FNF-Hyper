package objects;

import flixel.FlxSprite;

class AttachedSprite extends FlxSprite
{
	public var xAdd:Float = 0;
	public var yAdd:Float = 0;

	public var parent:FlxSprite = null;

	public function new(x:Float, y:Float, ?parent:FlxSprite)
	{
		super(x, y);
		this.parent = parent;
	}

	override function update(elapsed:Float)
	{
		if (parent != null)
			setPosition(parent.x + xAdd, parent.y + yAdd);

		super.update(elapsed);
	}
}
