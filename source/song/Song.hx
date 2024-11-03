package song;

import haxe.Json;
import openfl.utils.Assets;

typedef SwagSong = {
	var title:String;
	var notes:Array<{
		strumTime:Float,
		noteData:Int,
		mustPress:Bool,
		sustainLength:Float
	}>;
	var meta:{Artist:String, Speed:Float, BPM:Float};
}

class Song {
	public static function parseSong(path:String):SwagSong {
		var jsonData = Json.parse(Assets.getText(path));

		var song:SwagSong = {
			title: jsonData.title,
			notes: [],
			meta: {
				Artist: jsonData.meta.Artist,
				Speed: Math.min(10, Math.max(0, jsonData.meta.Speed)), // Ensure Speed is between 0 and 10,
				BPM: jsonData.meta.BPM
			}
		};

		// Parse each note in the notes array
		var json = jsonData;
		var notes:Array<{
			strumTime:Float,
			noteData:Int,
			mustPress:Bool,
			sustainLength:Float
		}> = json.notes;

		for (note in notes) {
			song.notes.push({
				strumTime: note.strumTime,
				noteData: note.noteData,
				mustPress: note.mustPress,
				sustainLength: note.sustainLength
			});
		}

		#if sys
		if (Sys.args().contains('--v')
			|| Sys.args().contains('--verbose')
			|| Sys.args().contains('-v')
			|| Sys.args().contains('-verbose'))
			trace(song);
		#end
		return song;
	}
}
