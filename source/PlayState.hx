package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import objects.Note;
import objects.StrumLine;
import objects.StrumNote;
import song.Song.SwagSong;
import song.Song;
import states.Conductor;
import states.MusicBeatState;
import sys.thread.Condition;

using StringTools;

class PlayState extends MusicBeatState {
	var strumLinePlayer:StrumLine;
	var strumLine:StrumLine;

	public var camHUD:FlxCamera;

	public static var swag:Float = 160 * 0.7;

	public static var SONG:SwagSong;

	public var songLength:Float = 0;
	public var songPos:Float = 0;
	public var songName:String = "";

	public var notes:FlxTypedGroup<Note>;

	override public function create() {
		if (SONG == null)
			SONG = Song.parseSong('assets/songs/bopeebo/normal.json');

		notes = new FlxTypedGroup();

		FlxG.sound.cache('assets/songs/${SONG.title.toLowerCase().replace(" ", "-")}/Voices.ogg');
		FlxG.sound.cache('assets/songs/${SONG.title.toLowerCase().replace(" ", "-")}/Inst.ogg');

		Conductor.changeBPM(SONG.meta.BPM);
		FlxG.sound.playMusic('');
		FlxG.sound.music.loadEmbedded('assets/songs/${SONG.title.toLowerCase().replace(" ", "-")}/Inst.ogg');
		FlxG.sound.music.play();

		camHUD = new FlxCamera();
		FlxG.cameras.add(camHUD, false);
		camHUD.bgColor.alpha = 0;

		var songData = SONG.notes;

		for (index => noteMeta in songData) {
			var daStrumTime:Float = noteMeta.strumTime;
			var daHit:Bool = noteMeta.mustPress;
			var daSus:Float = noteMeta.sustainLength;
			var daData:Int = noteMeta.noteData;

			var note:Note = new Note(daStrumTime, daData, daHit, daSus);
			notes.add(note);

			var oldNote:Note;
			if (notes.members.length > 0)
				oldNote = notes.members[Std.int(notes.members.length - 1)];
			else
				oldNote = null;

			var susLength:Float = daSus / Conductor.stepCrochet;

			for (susNote in 0...Math.floor(susLength)) {
				oldNote = notes.members[Std.int(notes.length - 1)];

				var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daData, daHit, true, 0, oldNote);
				sustainNote.scrollFactor.set();
				notes.add(sustainNote);
				// unspawnNotes.push(sustainNote);

				// if (sustainNote.mustPress)
				//	sustainNote.x += FlxG.width / 2; // general offset
			}
		}

		super.create();
		strumLinePlayer = new StrumLine(4, swag / 2, 50);
		strumLinePlayer.cameras = [camHUD];
		add(strumLinePlayer);

		strumLine = new StrumLine(4, FlxG.width * 0.525, 50);
		strumLine.cameras = [camHUD];
		add(strumLine);

		notes.cameras = [camHUD];
		add(notes);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
		Conductor.songPosition = FlxG.sound.music.time;
		FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, 0.95);
		camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);

		notes.forEach(function(daNote:Note) {
			var daStrumTime:Float = daNote.strumTime;
			var daHit:Bool = daNote.mustPress;
			var daSus:Float = daNote.sustainLength;
			var daData:Int = daNote.noteData;
			var strumGroup = daHit ? strumLinePlayer : strumLine;
			var strumNote:StrumNote = strumGroup.members[daData];

			daNote.x = strumNote.x;
			daNote.y = (strumNote.y - (Conductor.songPosition - daStrumTime) * (0.45 * FlxMath.roundDecimal(SONG.meta.Speed, 2)));
		});
	}

	override public function beatHit() {
		super.beatHit();
		if (curBeat % 4 == 0)
			zoomcam();
	}

	function zoomcam() {
		FlxG.camera.zoom += 0.13;
		camHUD.zoom += 0.05;
	}
}
