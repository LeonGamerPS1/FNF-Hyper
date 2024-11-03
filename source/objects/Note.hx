package objects;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class Note extends FlxSprite {
	public static var colArray:Array<String> = ["purple", "blue", "green", "red"];

	public var strumTime:Float = 0;
	public var noteData:Int = 0;
	public var mustPress:Bool = false;
	public var isSustainNote:Bool = false;
	public var sustainLength:Float = 0;
    public var prevNote:Note;

	public function new(strumTime:Float = 0, noteData:Int = 0, mustPress:Bool = false, isSustainNote:Bool = false, sustainLength:Float = 0, ?prevNote:Note) {
		super(-203, -2000);
		frames = FlxAtlasFrames.fromSparrow(AssetPaths.NOTE_assets__png, AssetPaths.NOTE_assets__xml);
		setGraphicSize(width * 0.7);
		animation.addByPrefix("arrow", '${colArray[noteData % 4]}');
		animation.play('arrow');

		this.strumTime = strumTime;
		this.noteData = noteData;
		this.mustPress = mustPress;
		this.isSustainNote = isSustainNote;
		this.sustainLength = sustainLength;
        this.prevNote = prevNote;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}
