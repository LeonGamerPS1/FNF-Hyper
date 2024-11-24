package objects.characters;

import flixel.FlxSprite;

 class GameCharacter extends FlxSprite {
    public function new(charName:String = "dad") {
        super(0,0);
        trace(charName);
    }
}
