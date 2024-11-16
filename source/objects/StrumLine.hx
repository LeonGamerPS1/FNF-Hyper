package objects;

import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import haxe.ds.StringMap;

class StrumLine extends FlxTypedGroup<StrumNote>
{
	public var x:Float = 0;
	public var y:Float = 0;

	public var playableStrumLine:Bool = false;

	public var lanes(default, set):Int = 0;

	public function new(lanes:Int = 4, X:Float = 0, Y:Float = 0)
	{
		super();
		setPos(X, Y);
		this.lanes = lanes;
		genArrows(lanes);
	}

	function setPos(X:Float, Y:Float)
	{
		x = X;
		y = Y;
	}

	function set_lanes(value:Int):Int
	{
		if (value == lanes)
			return lanes;

		return value;
	}

	function genArrows(value:Int)
	{
		killMembers();
		destroyMembers();
		for (i in 0...value)
		{
			var strumNote:StrumNote = new StrumNote(0, i);
			strumNote.playAnim('static');
			strumNote.x = x + PlayState.swag * i;
			strumNote.y = y;
			strumNote.downScroll = PlayState.downScroll;
			add(strumNote);
		}
	}

	/**
	 * Calls `destroy()` on the group's  `members`.
	 * @since 5.6.1
	 */
	public function destroyMembers():Void
	{
		for (basic in members)
		{
			if (basic != null)
				basic.destroy();
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		var i = 0;
		forEach(function(strumNote:StrumNote)
		{
			//.x = x + PlayState.swag * i;
			//strumNote.y = y;
			strumNote.camera = camera;
			strumNote.cameras = cameras;
			// ! i am too lazy to like uuuuuuuuuuuuuuuuuuuuhm add daline thing to strumnotes aswell boyyyyyyyyyyyyyyyyyyyyy
			i++;

			if (!playableStrumLine
				&& strumNote.animation.curAnim != null
				&& strumNote.animation.curAnim.finished
				&& strumNote.animation.curAnim.name == 'confirm')
				strumNote.playAnim('static', true);
		});
	}
}
