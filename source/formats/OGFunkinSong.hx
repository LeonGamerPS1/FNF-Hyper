package formats;

import flixel.FlxG;
import flixel.util.FlxStringUtil;
import haxe.Json;
import openfl.utils.Assets;
import song.Song.SwagSection;
import song.Song.SwagSong;

using StringTools;

typedef LegacyFunkin =
{
	var song:String;
	var notes:Array<LegacyFunkinSection>;
	var bpm:Int;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var validScore:Bool;
}

typedef LegacyFunkinSection =
{
	var sectionNotes:Array<Dynamic>;
	var lengthInSteps:Int;
	var typeOfSection:Int;
	var mustHitSection:Bool;
	var bpm:Int;
	var changeBPM:Bool;
	var altAnim:Bool;
}

class OGFunkinSong
{
	public var song:String;
	public var notes:Array<LegacyFunkinSection>;
	public var bpm:Int;
	public var needsVoices:Bool = true;
	public var speed:Float = 1;

	public var player1:String = 'bf';
	public var player2:String = 'dad';

	public function new(song, notes, bpm)
	{
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}

	public static function loadFromJson(jsonInput:String):LegacyFunkin
	{
		var rawJson = Assets.getText(jsonInput).trim();

		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
			// LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
		}

		return parseJSONshit(rawJson);
	}

	public static function toHyper(song:LegacyFunkin):SwagSong
	{
		// TODO: Convert the note shit and stuff

		var songbpm = song.bpm;
		var songSpeed = song.speed;
		var songName = song.song;
		var songNotes = song.notes;
		var songVoices = song.needsVoices;
		var sections:Array<LegacyFunkinSection> = songNotes;

		var swaggy:Array<SwagSection> = [];
		for (index => sec in sections)
		{
			var section:SwagSection = {
				notes: []
			};

			for (index => value in sec.sectionNotes)
			{
				var strumTime:Float = value[0];
				var huhaa:Int = sec.mustHitSection ? 1 : 0;
				section.notes.push({
					strumTime: strumTime,
					lane: value[1],
					daLine: huhaa,
					sustainLength: value[2],
					noteType: 'normal',
				});
			}
			swaggy.push(section);
		}

		var songShit:SwagSong = {
			sections: swaggy,
			title: songName,
			needsVoices: songVoices,
			meta: {
				Speed: songSpeed,
				BPM: songbpm,
				Artist: "Unknown",
			}
		};

		var savedJSON:String = Json.stringify(songShit);
		trace("Writing to save data to FlxG.save.data.lastConvertedSong.....");
		FlxG.save.data.lastConvertedSong = savedJSON;
		#if sys
		trace('Writing converted song "$songName" to conv/$songName.json file.');
		if (!sys.FileSystem.exists('./conv/'))
			sys.FileSystem.createDirectory('./conv/');

		sys.io.File.saveContent('./conv/$songName.json', savedJSON);
		trace('Saved ${FlxStringUtil.formatBytes(Std.parseFloat('${sys.FileSystem.stat('./conv/$songName.json').size} '))} "to ./conv/$songName.json". ');
		#end

		return songShit;
	}

	public static function parseJSONshit(rawJson:String):LegacyFunkin
	{
		var swagShit:LegacyFunkin = cast Json.parse(rawJson).song;
		swagShit.validScore = true;
		return swagShit;
	}
}
