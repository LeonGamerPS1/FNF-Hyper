package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import formats.OGFunkinSong.LegacyFunkin;
import formats.OGFunkinSong;
import haxe.Timer;
import objects.Note;
import objects.StrumLine;
import objects.StrumNote;
import song.Song.SwagSong;
import song.Song;
import states.Conductor;
import states.MusicBeatState;

using StringTools;


class PlayState extends MusicBeatState
{
	var strumLinePlayer:StrumLine;
	var strumLine:StrumLine;

	public var camHUD:FlxCamera;

	public static var swag:Float = 160 * 0.7;

	public static var SONG:SwagSong;

	public var songLength:Float = 0;
	public var songPos:Float = 0;
	public var songName:String = "";

	public var notes:FlxTypedGroup<Note>;

	public var strumLines:Array<StrumLine> = [];

	public var unspawnNotes:Array<Note> = [];

	public var controlledStrum:Int = 1;

	public var voices:FlxSound;

	public static var verbose = #if sys Sys.args().contains('--v') || Sys.args().contains('--verbose') || Sys.args().contains('-v')
		|| Sys.args().contains('-verbose') #else false #end;

	override public function create()
	{
		// var songy:LegacyFunkin = OGFunkinSong.loadFromJson('assets/songs/bopeebo/legacy.json');

		if (SONG == null)
			SONG = Song.parseSong('assets/songs/bopeebo/hard.json');
		//	trace(SONG);

		notes = new FlxTypedGroup();

		FlxG.sound.cache('assets/songs/${SONG.title.toLowerCase().replace(" ", "-")}/Voices.ogg');
		FlxG.sound.cache('assets/songs/${SONG.title.toLowerCase().replace(" ", "-")}/Inst.ogg');

		FlxG.sound.playMusic('');
		FlxG.sound.music.loadEmbedded('assets/songs/${SONG.title.toLowerCase().replace(" ", "-")}/Inst.ogg');

		voices = new FlxSound();
		if (SONG.needsVoices)
			voices.loadEmbedded('assets/songs/${SONG.title.toLowerCase().replace(" ", "-")}/Voices.ogg');
		FlxG.sound.list.add(voices);

		Conductor.changeBPM(SONG.meta.BPM);

		camHUD = new FlxCamera();
		FlxG.cameras.add(camHUD, false);
		camHUD.bgColor.alpha = 0;

		var sections = SONG.sections;
		var first = Timer.stamp();
		if (verbose)
		{
			trace('Preparing to parse ${sections.length} Sections for Song "${SONG.title}"');
		}

		for (index => sec in sections)
		{
			for (index => note in sec.notes)
			{
				var noteMeta = note;
				var daStrumTime:Float = noteMeta.strumTime;
				// ar daHit:Bool = noteMeta.mustPress; //! dumped this bitch! \\
				var daSus:Float = noteMeta.sustainLength;
				var daLane:Int = noteMeta.lane;
				var daLine:Int = noteMeta.daLine;

				var note:Note = new Note(daStrumTime, daLane, false);

				note.daLine = daLine;
				note.botNote = note.daLine != controlledStrum;
				// trace(note.botNote);

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var susLength:Float = daSus / Conductor.stepCrochet;
				var songSpeed:Float = SONG.meta.Speed;

				unspawnNotes.push(note);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime
						+ (Conductor.stepCrochet * susNote)
						+ (Conductor.stepCrochet / FlxMath.roundDecimal(songSpeed, 2)), daLane, true, 0,
						oldNote);

					sustainNote.botNote = note.botNote;
					sustainNote.daLine = daLine;
					sustainNote.scrollFactor.set();
					// unspawnNotes.push(sustainNote);
					// note.isSustai = false;
					unspawnNotes.push(sustainNote);

					// if (sustainNote.mustPress)
					//	sustainNote.x += FlxG.width / 2; // general offset
				}
			}
		}
		var last = Timer.stamp();
		if (verbose)
			trace('It took around ${last - first} Seconds to load and parse the chart.');
		super.create();

		strumLine = new StrumLine(4, swag / 2, 50);
		strumLine.cameras = [camHUD];
		strumLinePlayer = new StrumLine(4, FlxG.width * 0.525, 50);
		strumLinePlayer.cameras = [camHUD];
		strumLines.push(strumLine);
		strumLines.push(strumLinePlayer);
		for (index => value in strumLines)
		{
			add(value);
		}

		notes.cameras = [camHUD];
		add(notes);

		FlxG.sound.music.play();
		voices.play();
	}

	override public function update(elapsed:Float)
	{
		for (index => value in strumLines)
			value.playableStrumLine = index == controlledStrum;

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500 / SONG.meta.Speed)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		super.update(elapsed);
		keyShit(elapsed);

		Conductor.songPosition = FlxG.sound.music.time;
		FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, 0.95);
		camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);

		notes.forEach(function(daNote:Note)
		{
			var daStrumTime:Float = daNote.strumTime;
			// 	var daHit:Bool = daNote.mustPress; nuh uh
			// var daSus:Float = daNote.sustainLength;
			var daData:Int = daNote.lane;
			var daLine:Int = daNote.daLine;
			var strumGroup = strumLines[daLine % strumLines.length];
			var strumNote:StrumNote = strumGroup.members[daData % strumGroup.length];
			daNote.exists = daNote.isOnScreen(camHUD);

			daNote.botNote = !strumGroup.playableStrumLine;

			daNote.x = strumNote.x + daNote.offsetX;
			daNote.y = (strumNote.y - (Conductor.songPosition - daStrumTime) * (0.45 * FlxMath.roundDecimal(SONG.meta.Speed, 2)));
			if (daNote.botNote && daNote.wasGoodHit && !daNote.wasHit)
			{
				daNote.wasHit = true;
				strumNote.playAnim('confirm', true);
				if (!daNote.isSustainNote)
					fuckingDestroy(daNote, notes);
			}
			if (daNote.isSustainNote && strumNote.sustainReduce)
				daNote.clipToStrumNote(strumNote);

			var daKill:Bool = daNote.y <= strumNote.y - daNote.height;
			if (daKill)
				fuckingDestroy(daNote, notes);
		});
	}

	function keyShit(elapsed:Float)
	{
		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		var upR = controls.UP_R;
		var rightR = controls.RIGHT_R;
		var downR = controls.DOWN_R;
		var leftR = controls.LEFT_R;

		var left = controls.LEFT;
		var down = controls.DOWN;
		var up = controls.UP;
		var right = controls.RIGHT;
		var pressArray = [leftP, downP, upP, rightP];
		var releaseArray = [leftR, downR, upR, rightR];
		var holdArray = [left, down, up, right];

		for (i => key in pressArray)
		{
			var strum:StrumNote = strumLines[controlledStrum].members[i];
			if (pressArray[i])
				strum.playAnim('press', true);
			else if (releaseArray[i])
				strum.playAnim('static', false);

			notes.forEach(function(daNote:Note)
			{
				if (daNote.canBeHit && !daNote.wasHit && !daNote.isSustainNote && !daNote.botNote && daNote.lane == i && pressArray[daNote.lane])
				{
					daNote.wasHit = true;
					daNote.wasGoodHit = true;
					// strum = strumLinePlayer.members[daNote.lane];
					strum.playAnim('confirm', true);

					fuckingDestroy(daNote, notes);
				}
				else if (daNote.canBeHit && !daNote.wasHit && daNote.isSustainNote && !daNote.botNote && daNote.lane == i && holdArray[daNote.lane])
				{
					daNote.wasHit = true;
					daNote.wasGoodHit = true;
					// strum = strumLinePlayer.members[daNote.lane];
					strum.playAnim('confirm', true);

					// fuckingDestroy(daNote, notes);
				}
			});
		}
	}

	function fuckingDestroy(dundy:Note, dundys:FlxTypedGroup<Note>)
	{
		dundy.kill();
		dundys.remove(dundy, true);
		dundy.destroy();
	}

	override public function beatHit()
	{
		super.beatHit();
		if (curBeat % 4 == 0)
			zoomcam();
	}

	function zoomcam()
	{
		FlxG.camera.zoom += 0.13;
		camHUD.zoom += 0.05;
	}
}
