package song;

import haxe.Json;
import openfl.utils.Assets;

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
	var notes:Array<
		{
			strumTime:Float,
			lane:Int,
			daLine:Int,
			sustainLength:Float
		}>;
}

class Song
{
	public static function parseSong(path:String):SwagSong
	{
		var rawJson = Assets.getText(path);
		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
			// LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
		}

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
