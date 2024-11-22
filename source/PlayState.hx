package;

import backend.Sort;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import flixel.tweens.FlxTween;
import flixel.util.FlxSort;
import flixel.util.FlxSort;
import haxe.Timer;
import objects.CountdownHandler;
import objects.Note;
import objects.StrumLine;
import objects.StrumNote;
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

	public var startingSong:Bool = false;
	public var startedCountdown:Bool = false;

	public static var downScroll:Bool = true;

	public static var verbose = #if sys Sys.args().contains('--v') || Sys.args().contains('--verbose') || Sys.args().contains('-v')
		|| Sys.args().contains('-verbose') #else false #end;

	var blockedTypes:Array<String> = ['warning'];
	var startedSong:Bool = false;

	override public function create()
	{
		// var songy:LegacyFunkin = OGFunkinSong.loadFromJson('assets/songs/bopeebo/legacy.json');

		if (SONG == null)
			SONG = Song.parseSong('assets/songs/milf/hard.json'); // OGFunkinSong.toHyper(songy);
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
		Conductor.mapBPMChanges(SONG);

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
				var daType:String = noteMeta.noteType;
				if (daType == null)
					daType = 'normal';

				var note:Note = new Note(daStrumTime, daLane, false, daSus, null, daType);

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

				if (susLength > 0 && !blockedTypes.contains(daType))
				{
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
		}
		var last = Timer.stamp();
		if (verbose)
			trace('It took around ${last - first} Seconds to load and parse the chart.');
		super.create();

		strumLine = new StrumLine(4, swag / 2, !downScroll ? 50 : FlxG.height - 150);
		strumLine.cameras = [camHUD];
		strumLinePlayer = new StrumLine(4, FlxG.width * 0.5 + swag / 2, !downScroll ? 50 : FlxG.height - 150);
		strumLinePlayer.cameras = [camHUD];
		strumLines.push(strumLine);
		strumLines.push(strumLinePlayer);
		for (index => value in strumLines)
		{
			add(value);
		}

		notes.cameras = [camHUD];
		add(notes);

		Conductor.songPosition = -1000;
		FlxTween.tween(Conductor, {songPosition: -50}, Conductor.crochet / 1000 * 4.5);

		startCountdown();

		unspawnNotes.sort(Sort.sortByTime);
	}

	function startSong()
	{
		FlxG.sound.music.play();
		voices.play();
		startingSong = false;
		startedSong = true;
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	override public function update(elapsed:Float)
	{
		for (index => value in strumLines)
			value.playableStrumLine = index == controlledStrum;

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 3000 / SONG.meta.Speed)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		super.update(elapsed);
		keyShit(elapsed);

		if (startedSong)
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
			var strumY = strumNote.y;
			var strumX = strumNote.x;
			var strumAngle = strumNote.angle;
			var strumDirection = strumNote.direction;

			// daNote.exists = daNote.isOnScreen(camHUD);

			daNote.botNote = !strumGroup.playableStrumLine;

			daNote.flipY = daNote.isSustainNote && downScroll;

			if (daNote.copyAngle && daNote.angle != strumDirection - 90 + strumAngle)
				daNote.angle = strumDirection - 90 + strumAngle;

			var angleDir = strumDirection * Math.PI / 180;

			if (daNote.copyX && daNote.x != strumX + daNote.offsetX + Math.cos(angleDir) * daNote.distance)
				daNote.x = strumX + daNote.offsetX + Math.cos(angleDir) * daNote.distance;

			if (downScroll)
				daNote.distance = (0.45 * (Conductor.songPosition - daNote.strumTime) * SONG.meta.Speed * daNote.multSpeed);
			else
				daNote.distance = (-0.45 * (Conductor.songPosition - daNote.strumTime) * SONG.meta.Speed * daNote.multSpeed);

			if (daNote.copyY)
			{
				daNote.y = strumY + Math.sin(angleDir) * daNote.distance;
				var songSpeed = SONG.meta.Speed;
				var fakeCrochet:Float = (60 / SONG.meta.BPM) * 1000;
				if (downScroll && daNote.isSustainNote)
				{
					if (daNote.animation.curAnim.name.endsWith('end'))
					{
						daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * songSpeed + (46 * (songSpeed - 1));
						daNote.y -= 46 * (1 - (fakeCrochet / 600)) * songSpeed;
					}
					daNote.y += (swag / 2) - (60.5 * (songSpeed - 1));
					daNote.y += 27.5 * ((SONG.meta.BPM / 100) - 1) * (songSpeed - 1);
				}
			}

			if (daNote.botNote && daNote.wasGoodHit && !daNote.wasHit)
			{
				daNote.wasHit = true;
				strumNote.playAnim('confirm', true);
				if (!daNote.isSustainNote)
					fuckingDestroy(daNote, notes);
			}
			if (daNote.isSustainNote && strumNote.sustainReduce)
				daNote.clipToStrumNote(strumNote);

			var daKill:Bool = !downScroll ? daNote.y <= strumNote.y - daNote.height : daNote.y >= strumNote.y + daNote.height * 2;
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
		if (dundy.wasGoodHit && dundy.hitSound != '' && dundy.hitSound != null)
			FlxG.sound.play('assets/sounds/${dundy.hitSound}.ogg');
		dundy.kill();

		dundys.remove(dundy, true);
		dundy.destroy();
	}

	function startCountdown()
	{
		var ct:CountdownHandler;
		ct = new CountdownHandler(startSong);
		startingSong = true;
		startedCountdown = true;
		ct.cameras = [camHUD];
		add(ct);
		ct.startass();
	}

	override public function beatHit()
	{
		super.beatHit();
		if (startedCountdown || startedSong)
			notes.sort(FlxSort.byY,downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		if (curBeat % 4 == 0)
			zoomcam();
	}

	function zoomcam()
	{
		FlxG.camera.zoom += 0.13;
		camHUD.zoom += 0.05;
	}
}
