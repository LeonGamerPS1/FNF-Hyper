package objects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;

class Checkbox extends FlxSprite
{
	public var checked(default, set):Bool = false;

	public var onClick:Void->Void;
	public var clickable:Bool = true;

	public function new(x:Float = 1, y:Float = 1)
	{
		super(x, y);
		frames = FlxAtlasFrames.fromSparrow('assets/images/checkbox.png', 'assets/images/checkbox.xml');
		animation.addByPrefix('false', 'off');
		animation.addByPrefix('true', 'on', 30, false);
		animation.addByPrefix('pop', 'pop', 24, false);
		playAnim(Std.string(checked));
		setGraphicSize(width * 0.7);
		updateHitbox();
		playAnim(Std.string(checked));
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (FlxG.mouse.overlaps(this, this.camera) && clickable)
		{
			if (FlxG.mouse.justPressed)
			{
				checked = !checked;

				if (onClick != null && clickable)
					onClick();
			}

			color = FlxColor.fromRGB(222, 222, 222, 255);
		}
		else
			color = FlxColor.WHITE;

		if (animation.curAnim != null && animation.curAnim.name == 'pop' && animation.curAnim.finished)
			animation.play(Std.string("false"), true);
	}

	public function playAnim(name:String, ?force:Bool = false)
	{
		animation.play(name, force);
		centerOffsets();
		centerOrigin();
	}

	public function lerpToPoint(?point:FlxPoint, ?xAdd:Null<Float> = 0, yAdd:Null<Float> = 0)
	{
		point ??= getPosition();
		xAdd ??= 0;
		yAdd ??= 0;
		x = FlxMath.lerp(point.x, x, Math.exp(-FlxG.elapsed * 9 * 1)) + xAdd;
		y = FlxMath.lerp(point.y, y, Math.exp(-FlxG.elapsed * 9 * 1)) + yAdd;
	}

	function set_checked(value:Bool):Bool
	{
		if (animation.curAnim.name == "true")
			playAnim(Std.string("pop"), true);
		else
			playAnim(Std.string(value), true);
		trace(value);
		checked = value;
		return value;
	}
}
