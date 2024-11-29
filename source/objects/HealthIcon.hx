package objects;

import flixel.FlxSprite;
import lime.utils.Assets;

using StringTools;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;

	private var isOldIcon:Bool = false;
	private var isPlayer:Bool = false;
	private var char:String = '';

	private var iconOffsets:Array<Float> = [0, 0];

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		isOldIcon = (char == 'bf-old');
		this.isPlayer = isPlayer;
		changeIcon(char);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}

	public function swapOldIcon()
	{
		if (isOldIcon = !isOldIcon)
			changeIcon('bf-old');
		else
			changeIcon('bf');
	}

	public function changeIcon(char:String)
	{
		if (this.char != char)
		{

			var path = "";
			trace("Loading Icon for " + char + ".");
			if (Assets.exists('assets/images/characters/$char/icon.png'))
				path = 'assets/images/characters/$char/icon.png';
			else
				path = 'assets/images/default/icon.png';

			loadGraphic(path);
			loadGraphic(path, true, Math.floor(width / 2), Math.floor(height)); // Then load it fr
			
			iconOffsets[0] = (width - 150) / 2;
			iconOffsets[1] = (width - 150) / 2;
			updateHitbox();

			animation.add(char, [0, 1], 0, false, isPlayer);
			animation.play(char);
			this.char = char;

			switch (char)
			{
				case 'bf-pixel' | 'senpai' | 'spirit':
					antialiasing = false;

				default:
					antialiasing = true;
			}
		}
	}

	override function updateHitbox()
	{
		super.updateHitbox();
		offset.x = iconOffsets[0];
		offset.y = iconOffsets[1];
	}

	public function getCharacter():String
	{
		return char;
	}
}
