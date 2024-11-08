package objects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxRect;
import states.Conductor;

class Note extends FlxSprite
{
	public static var colArray:Array<String> = ["purple", "blue", "green", "red"];
	public static var susArray:Array<String> = ["purpl", "blu", "gree", "re"];

	public var prevNote:Note;

	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var sustainLength:Float = 0;
	public var strumTime:Float = 0;
	public var daLine:Int = 0;
	public var lane:Int = 0;

	public var wasGoodHit:Bool = false;
	public var botNote:Bool = false;
	public var wasHit:Bool = false;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var mustPress:Bool = false;
	public var isSustainNote:Bool = false;
	public var ignoreNote:Bool = false;
	public var noteType:String = 'normal';
	public var hitSound:String = '';
	public var speedModifier:Float = 1;

	public function new(strumTime:Float = 0, lane:Int = 0, isSustainNote:Bool = false, sustainLength:Float = 0, ?prevNote:Note, noteType:String = 'normal')
	{
		super(-203, -2000);

		this.strumTime = strumTime;
		this.lane = lane;
		this.isSustainNote = isSustainNote;
		this.sustainLength = sustainLength;
		this.prevNote = prevNote;
		this.noteType = noteType;

		switch noteType.toLowerCase()
		{
			case 'warning':
				hitSound = 'shooters';
				loadGraphic('assets/images/warning.png', true, 157, 154, false, 'warning_png');
				animation.add('arrow', [0], 4, true);
				animation.play('arrow');
				setGraphicSize(width * 0.7);
				speedModifier = 1.2;

			case _ | 'normal':
				frames = FlxAtlasFrames.fromSparrow(AssetPaths.NOTE_assets__png, AssetPaths.NOTE_assets__xml);
				setGraphicSize(width * 0.7);
				// updateHitbox();
				animation.addByPrefix("arrow", '${colArray[lane % 4]}');
				animation.play('arrow');

				if (isSustainNote && prevNote != null)
				{
					animation.addByPrefix('end', '${susArray[lane % 4]} hold end');
					animation.play('end');
					//alpha = 0.4;
					offsetX = width * 0.76 / 2;
					updateHitbox();
					if (prevNote.isSustainNote)
					{
						prevNote.animation.addByPrefix('hold', '${susArray[lane % 4]} hold piece');
						prevNote.animation.play('hold');

						prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.meta.Speed;
						prevNote.updateHitbox();
					}
					// prevNote.updateHitbox();
				}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (!botNote)
		{
			// The * 0.5 us so that its easier to hit them too late, instead of too early
			canBeHit = strumTime > Conductor.songPosition - Conductor.safeZoneOffset
				&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5);

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset)
				tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition)
			{
				wasGoodHit = true;
			}
		}

		if (tooLate)
		{
			if (alpha > 0.3)
				alpha = 0.9;
		}
	}

	public function clipToStrumNote(myStrum:StrumNote)
	{
		var center:Float = myStrum.y + offsetY + PlayState.swag / 2;
		if (isSustainNote && (!botNote || !ignoreNote) && (botNote || (wasGoodHit || (prevNote.wasGoodHit && !canBeHit))))
		{
			var swagRect:FlxRect = clipRect;
			if (swagRect == null)
				swagRect = new FlxRect(0, 0, frameWidth, frameHeight);

			if (myStrum.downScroll)
			{
				if (y - offset.y * scale.y + height >= center)
				{
					swagRect.width = frameWidth;
					swagRect.height = (center - y) / scale.y;
					swagRect.y = frameHeight - swagRect.height;
				}
			}
			else if (y + offset.y * scale.y <= center)
			{
				swagRect.y = (center - y) / scale.y;
				swagRect.width = width / scale.x;
				swagRect.height = (height / scale.y) - swagRect.y;
			}
			clipRect = swagRect;
		}
	}
}
