package objects;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class StrumNote extends FlxSprite {
	public static var directionColArray:Array<String> = ["arrowLEFT", "arrowDOWN", "arrowUP", "arrowRIGHT"];

	public function new(X:Float = 1, id:Int = 0) {
		super(X, 50);
		frames = FlxAtlasFrames.fromSparrow(AssetPaths.NOTE_assets__png, AssetPaths.NOTE_assets__xml);
		setGraphicSize(width * 0.7);
		animation.addByPrefix("static", '${directionColArray[id % 4]}');
		
		this.ID = id;
	}
}
