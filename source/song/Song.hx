package song;

import haxe.Json;

using StringTools;

typedef SwagSong =
{
    var title:String;
    var sections:Array<SwagSection>;

    var needsVoices:Bool;

    var meta:{Artist:String, Speed:Float, BPM:Float};
}

typedef SwagSection =
{
    var bpm:Int;
    var changeBPM:Bool;
    var altAnim:Bool;
    var notes:Array<
    {
        strumTime:Float,
        lane:Int,
        daLine:Int,
        sustainLength:Float,
        noteType:String,
    }>;
}

class Song {
    public static function parseSong(path:String):SwagSong {
        var rawJson = Assets.getText(path);

        var jsonData:SwagSong = Json.parse(rawJson);

        #if sys
        if (Sys.args().contains('--v')
        || Sys.args().contains('--verbose')
        || Sys.args().contains('-v')
        || Sys.args().contains('-verbose'))
            trace(jsonData);
        #end
        return cast jsonData;
    }
}
