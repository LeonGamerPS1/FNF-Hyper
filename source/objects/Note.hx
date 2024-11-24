package objects;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxRect;
import states.Conductor;

using StringTools;

class Note extends FlxSprite {
    public static var colArray:Array<String> = ["purple", "blue", "green", "red"] ;
    public static var susArray:Array<String> = ["purpl", "blu", "gree", "re"] ;

    public var prevNote:Note;

    public var daLine:Int = 0 ;
    public var lane:Int = 0 ;

    public var wasGoodHit:Bool = false ;
    public var botNote:Bool = false ;
    public var wasHit:Bool = false ;
    public var canBeHit:Bool = false ;
    public var tooLate:Bool = false ;
    public var mustPress:Bool = false ;
    public var isSustainNote:Bool = false ;
    public var ignoreNote:Bool = false ;

    public var noteType:String = 'normal' ;
    public var hitSound:String = '' ;

    public var speedModifier:Float = 1 ;
    public var strumTime:Float = 0 ;
    public var offsetX:Float = 0 ;
    public var offsetY:Float = 0 ;
    public var sustainLength:Float = 0 ;
    public var isEnd:Bool = false ;

    public var tail:Array<Note> = [] ; // for sustains
    public var parent:Note;
    public var blockHit:Bool = false ; // only works for player

    public var offsetAngle:Float = 0 ;
    public var multAlpha:Float = 1 ;
    public var multSpeed(default, set):Float = 1 ;

    public var copyX:Bool = true ;
    public var copyY:Bool = true ;
    public var copyAngle:Bool = true ;
    public var copyAlpha:Bool = true ;

    public var distance:Float = 2000 ;


    public function new(strumTime:Float = 0, lane:Int = 0, isSustainNote:Bool = false, sustainLength:Float = 0, ?prevNote:Note, noteType:String = 'normal') {
        super(-203, -2000);

        this.strumTime = strumTime;
        this.lane = lane;
        this.isSustainNote = isSustainNote;
        this.sustainLength = sustainLength;
        this.prevNote = prevNote;
        this.noteType = noteType;

        //copyAngle = !isSustainNote;

        switch noteType.toLowerCase()
        {
            case 'warning':
                hitSound = 'shooters';
                loadGraphic('assets/images/warning.png', true, 157, 154, false, 'warning_png');
                animation.add('arrow', [0], 4, true);
                animation.play('arrow');
                setGraphicSize(width * 0.7);
                speedModifier = 1.2;
                updateHitbox();

            case _:
                frames = FlxAtlasFrames.fromSparrow('assets/images/noteSkins/NOTE_assets.png', 'assets/images/noteSkins/NOTE_assets.xml');
                setGraphicSize(width * 0.7);
                // updateHitbox();
                animation.addByPrefix("arrow", '${colArray[lane % 4]}');
                animation.play('arrow');
                updateHitbox();

                if (isSustainNote && prevNote != null) {
                    animation.addByPrefix('end', '${susArray[lane % 4]} hold end');
                    animation.play('end');
                    isEnd = true;
                    //	alpha = 0.8;

                    updateHitbox();
                    offsetX = width;
                    if (prevNote.isSustainNote) {
                        prevNote.animation.addByPrefix('hold', '${susArray[lane % 4]} hold piece');
                        prevNote.animation.play('hold');

                        prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.meta.Speed;
                        prevNote.updateHitbox();
                        isEnd = false;
                    }
                    // prevNote.updateHitbox();
                }
        }
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if (!botNote) {
            // The * 0.5 us so that its easier to hit them too late, instead of too early
            canBeHit = strumTime > Conductor.songPosition - Conductor.safeZoneOffset
            && strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5);

            if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset)
                tooLate = true;
        }
        else {
            canBeHit = false;

            if (strumTime <= Conductor.songPosition) {
                wasGoodHit = true;
            }
        }

        if (tooLate) {
            if (alpha > 0.3)
                alpha = 0.9;
        }
    }

    public function clipToStrumNote(myStrum:StrumNote) {
        var center:Float = myStrum.y + offsetY + PlayState.swag / 2;
        if (isSustainNote && (!botNote || !ignoreNote) && (botNote || (wasGoodHit || (prevNote.wasGoodHit && !canBeHit)))) {
            var swagRect:FlxRect = clipRect;
            if (swagRect == null)
                swagRect = new FlxRect(0, 0, frameWidth, frameHeight);

            if (myStrum.downScroll) {
                if (y - offset.y * scale.y + height >= center) {
                    swagRect.width = frameWidth;
                    swagRect.height = (center - y) / scale.y;
                    swagRect.y = frameHeight - swagRect.height;
                }
            }
            else if (y + offset.y * scale.y <= center) {
                swagRect.y = (center - y) / scale.y;
                swagRect.width = width / scale.x;
                swagRect.height = (height / scale.y) - swagRect.y;
            }

            clipRect = swagRect;
        }
    }

    /*
		public override function set_clipRect(rect:FlxRect):FlxRect
		{
			clipRect = rect;
			if (prevNote != null && prevNote.clipRect != null)
				if (prevNote.wasGoodHit && animation.curAnim.name == 'end' && prevNote.clipRect.height < 1)
					kill();

			if (frames != null)
				frame = frames.frames[animation.frameIndex];

			return rect;
		}
	 */
    private function set_multSpeed(value:Float):Float {
        resizeByRatio(value / multSpeed);
        multSpeed = value;
        // trace('fuck cock');
        return value;
    }

    public function resizeByRatio(ratio:Float) // haha funny twitter shit {
        if (isSustainNote && !animation.curAnim.name.endsWith('end')) {
            scale.y *= ratio;
            updateHitbox();
        }
    }
}
