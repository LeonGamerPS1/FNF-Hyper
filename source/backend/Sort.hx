package backend;

import flixel.util.FlxSort;
import objects.Note;

class Sort
{
	public static function sortByTime(Obj1:Dynamic, Obj2:Dynamic):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);

	public static function sortHitNotes(a:Note, b:Note):Int
		return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
}
