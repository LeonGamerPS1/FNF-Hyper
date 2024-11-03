package objects;

import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import haxe.ds.StringMap;

class StrumLine extends FlxTypedGroup<StrumNote> {
	public var x:Float = 0;
	public var y:Float = 0;
	public var lanes(default, set):Int = 0;

	public function new(lanes:Int = 4, X:Float = 0, Y:Float = 0) {
		super();
		setPos(X, Y);
		this.lanes = lanes;
		genArrows(lanes);
	}

	function setPos(X:Float, Y:Float) {
		x = X;
		y = Y;
	}

	function set_lanes(value:Int):Int {
		if (value == lanes)
			return lanes;

		return value;
	}

	function genArrows(value:Int) {
		for (i in 0...value) {
			var strumNote:StrumNote = new StrumNote(60 * value, i);
			strumNote.animation.play('static');
			add(strumNote);
		}
	}

	/**
	 * Calls `destroy()` on the group's  `members`.
	 * @since 5.6.1
	 */
	public function destroyMembers():Void {
		for (basic in members) {
			if (basic != null)
				basic.destroy();
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		var i = 0;
		forEach(function(strumNote:StrumNote) {
			strumNote.x = x + (strumNote.width * 0.7 * i);
			strumNote.y = y;
			i++;
		});
	}
}
