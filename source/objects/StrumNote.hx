package objects;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class StrumNote extends FlxSprite {
    public static var directionColArray:Array<String> = ["arrowLEFT", "arrowDOWN", "arrowUP", "arrowRIGHT"] ;
    public static var dirArray:Array<String> = ["left", "down", "up", "right"] ;

    public var sustainReduce:Bool = true ;
    public var direction:Float = 90 ;
    public var downScroll:Bool = false ;

    public function new(X:Float = 1, id:Int = 0) {
        super(X, 50);
        frames = FlxAtlasFrames.fromSparrow('assets/images/noteSkins/NOTE_assets.png', 'assets/images/noteSkins/NOTE_assets.xml');
        setGraphicSize(width * 0.7);
        animation.addByPrefix("static", '${directionColArray[id % 4]}', 1, false);
        animation.addByPrefix("confirm", '${dirArray[id % 4]} confirm', 24, false);
        animation.addByPrefix("press", '${dirArray[id % 4]} press', 30, false);
        playAnim('static');
        updateHitbox();
        antialiasing = true;
        this.ID = id;
    }

    public function playAnim(anim:String, ?force:Bool = false) {
        animation.play(anim, force);
        if (animation.curAnim != null) {
            centerOffsets();
            centerOrigin();
        }
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        // direction += 0.1;
    }
}
