package objects;

import flixel.FlxG;
import flixel.FlxState;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxColor;

class OptionsText extends FlxText
{
	public var attachedCheckbox:Checkbox;

	public function new(?textToDisplay:String)
	{
		super();
		textToDisplay ??= "Null";
		text = textToDisplay;

		setFormat('assets/fonts/vcr.ttf', 15, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		attachedCheckbox = new Checkbox(x + (10 * text.length), y);
		attachedCheckbox.x += attachedCheckbox.width * 3;
		attachedCheckbox.clickable = false;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		x = FlxMath.lerp(attachedCheckbox.x + attachedCheckbox.width + size / 2, x, Math.exp(-FlxG.elapsed * 9 * 1));
		y = FlxMath.lerp(attachedCheckbox.y + attachedCheckbox.height / 2 - size, y, Math.exp(-FlxG.elapsed * 9 * 1));
	}
}
