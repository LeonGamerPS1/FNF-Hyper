package;

import flixel.FlxG;
import flixel.FlxState;
import objects.StrumLine;

class PlayState extends FlxState {
	var strumLine:StrumLine;

	override public function create() {
		strumLine = new StrumLine(4, 0, 0);
		add(strumLine);
	
		
		super.create();
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
	}
}
