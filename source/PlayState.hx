package;

import backend.ClientSettings;
import backend.Sort;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxStrip;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxAnalog;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import haxe.Timer;
import objects.CountdownHandler;
import objects.HealthIcon;
import objects.Note;
import objects.StrumLine;
import objects.StrumNote;
import song.Song;
import states.Conductor;
import states.MusicBeatState;

using StringTools;

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
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

	public static var downScroll:Bool = false;
	public static var middleScroll:Bool = false;
	public static var instance:PlayState;

	public var infoText:FlxText;

	public var healthBar:FlxBar;
	public var health:Float = 1;

	public var score:Float = 0;

	private var curHealth:Float = -2;

	public var analog:FlxAnalog;
	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;

	public static var verbose = #if sys Sys.args().contains('--v') || Sys.args().contains('--verbose') || Sys.args().contains('-v')
		|| Sys.args().contains('-verbose') #else false #end;

	var blockedTypes:Array<String> = ['warning'];
	var startedSong:Bool = false;

	public var notesLeftForPlayer(default, default):Int = 0;
	public var combo_breaks(default, default):Int = 0;
	public var combo(default, default):Int = 0;

	function applyGameplaySettings()
	{
		downScroll = ClientSettings.data.downScroll;
		middleScroll = ClientSettings.data.downScroll;
	}

	override public function create()
	{
		instance = this;

		applyGameplaySettings();
		bgColor = FlxColor.GRAY;
		// var songy:LegacyFunkin = OGFunkinSong.loadFromJson('assets/songs/bopeebo/legacy.json');

		if (SONG == null)
			SONG = Song.parseSong('assets/songs/milf/normal.json'); // OGFunkinSong.toHyper(songy);
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

		strumLine = new StrumLine(4, swag / 2, !downScroll ? 50 : FlxG.height - 150, "dad", false);
		var op_I:Int = 0;
		if (middleScroll)
		{
			strumLine.forEachAlive(function(s:StrumNote)
			{
				if (op_I > strumLine.lanes / 2)
				{
					s.x += FlxG.width / 2 + swag / 2;
				}
				op_I++;
			});
		}
		strumLine.cameras = [camHUD];

		strumLinePlayer = new StrumLine(4, FlxG.width * 0.5 + swag / 2, !downScroll ? 50 : FlxG.height - 150, "bf", true);
		strumLinePlayer.cameras = [camHUD];
		strumLines.push(strumLine);
		strumLines.push(strumLinePlayer);

		camHUD.bgColor.alpha = 0;

		infoText = new FlxText(0, 0);
		infoText.setFormat("assets/fonts/vcr.ttf", 22, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK, true);
		infoText.screenCenter(Y);
		infoText.cameras = [camHUD];
		add(infoText);

		var healthBarBG = new FlxSprite(0, !downScroll ? FlxG.height * 0.89 : FlxG.height * 0.1, 'assets/images/healthBar.png');
		healthBarBG.cameras = [camHUD];
		healthBarBG.screenCenter(X);
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 9), Std.int(healthBarBG.height - 8), this,
			'curHealth', 0, 2);
		healthBar.createFilledBar(FlxColor.RED, FlxColor.LIME);
		healthBar.cameras = [camHUD];
		add(healthBar);

		iconP1 = new HealthIcon(strumLinePlayer.character.json.name, true);
		iconP1.y = healthBar.y - 75;
		iconP1.cameras = [camHUD];
		add(iconP1);

		iconP2 = new HealthIcon(strumLine.character.json.name, false);
		iconP2.y = healthBar.y - 75;
		iconP2.cameras = [camHUD];
		add(iconP2);

		analog = new FlxAnalog(0, FlxG.height - 100);
		analog.cameras = [camHUD];
		analog.x += analog.base.width / 2;
		add(analog);

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

				if (!note.botNote)
					notesLeftForPlayer++;
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

		trace('It took around ${last - first} Seconds to load and parse the chart.');

		unspawnNotes.sort(Sort.sortByTime);
		super.create();

		strumLinePlayer.character.x += 800;

		for (index => value in strumLines)
		{
			add(value);
			if (value.character != null)
				add(value.character);
		}

		notes.cameras = [camHUD];
		add(notes);

		Conductor.songPosition = -200;
		// FlxTween.tween(Conductor, {songPosition: -50}, Conductor.crochet / 1000 * 4.5);

		startCountdown();
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

	public var sings:Array<String> = ["singLEFT", "singDOWN", "singUP", "singRIGHT"];

	var songTime:Float = 0;

	override public function update(elapsed:Float)
	{
		if (health > 2)
			health = 2;

		if (health < -0.00000000000001)
			health = 0;
		if (infoText != null)
		{
			infoText.text = 'Notes Left: $notesLeftForPlayer (Player)';
			infoText.text += '\nNotes Left: ${notes.members.length} (Spawned)';
			infoText.text += '\nAlive Notes: ${notes.countLiving() + 1} (Alive)';
			infoText.text += '\nDead Notes: ${notes.countDead() + 1} (Killed/Null)';
			infoText.text += '\n-----------------------------';

			infoText.text += '\nScore: $score';
			infoText.text += '\nCombo: $combo';
			infoText.text += '\nCombo Breaks: $combo_breaks';
			infoText.text += '\n-----------------------------';

			infoText.text += '\nHealth: $health';
		}

		for (index => value in strumLines)
		{
			value.playableStrumLine = index == controlledStrum;
		}

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

		updateIconsScale(iconP1);
		updateIconsScale(iconP2);
		//	iconP1.y = healthBar.y - iconP1.height / 2;

		var iconOffset:Int = 26;
		iconP1.x = healthBar.x
			+ (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01))
			+ (150 * iconP1.scale.x - 150) / 2
			- iconOffset;
		iconP2.x = healthBar.x
			+ (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01))
			- (150 * iconP2.scale.x) / 2
			- iconOffset * 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		keyShit(elapsed);

		// if (startedSong)
		// Conductor.songPosition = FlxG.sound.music.time;
		FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, Math.exp(-FlxG.elapsed * 9 * 1));
		camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, Math.exp(-FlxG.elapsed * 9 * 1));

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
				strumGroup.character.playAnim(sings[daNote.lane % sings.length], true);

				if (!daNote.isSustainNote)
					fuckingDestroy(daNote, notes);
			}
			if (daNote.isSustainNote && strumNote.sustainReduce)
				daNote.clipToStrumNote(strumNote);

			var daKill:Bool = !downScroll ? daNote.y <= strumNote.y - daNote.height : daNote.y >= strumNote.y + daNote.height * 2;
			if (daKill || daNote.tooLate)
			{
				if (!daNote.botNote && !daNote.wasGoodHit)
				{
					combo_breaks++;
					health -= 0.045;
					combo = 0;
				}

				fuckingDestroy(daNote, notes);
			}
		});

		curHealth = FlxMath.lerp(curHealth, health, .2 / (FlxG.updateFramerate / 60));
		healthBar.numDivisions = 9999;
	}

	function updateIconsScale(icon:HealthIcon)
	{
		var mult:Float = FlxMath.lerp(1, icon.scale.x, Math.exp(-FlxG.elapsed * 9 * 1));
		icon.scale.set(mult, mult);

		icon.updateHitbox();
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
			var strumLine:StrumLine = strumLines[controlledStrum];
			if (strumLine == null)
				return;
			var strum:StrumNote = strumLine.members[i % strumLine.length];

			notes.forEach(function(daNote:Note)
			{
				if (daNote.canBeHit && !daNote.wasHit && !daNote.isSustainNote && !daNote.botNote && daNote.lane == i && pressArray[i % strumLine.length])
				{
					daNote.wasHit = true;
					daNote.wasGoodHit = true;
					// strum = strumLinePlayer.members[daNote.lane];
					strum.playAnim('confirm', true);
					strumLine.character.playAnim(sings[daNote.lane], true);
					health += 0.025;
					combo++;

					if (notesLeftForPlayer > 0)
						notesLeftForPlayer--;

					var timing:Float = Math.abs(daNote.strumTime - Conductor.songPosition);
					var quantized:Int = Math.floor(timing / 5) * 5;
					score += 175 * (1 - Math.floor(quantized / Conductor.safeZoneOffset));

					fuckingDestroy(daNote, notes);
				}
				else if (daNote.canBeHit
					&& !daNote.wasHit
					&& daNote.isSustainNote
					&& !daNote.botNote
					&& daNote.lane == i
					&& holdArray[daNote.lane % strumLine.length])
				{
					daNote.wasHit = true;
					daNote.wasGoodHit = true;
					// strum = strumLinePlayer.members[daNote.lane];
					strum.playAnim('confirm', true);
					health += 0.025;
					strumLine.character.playAnim(sings[daNote.lane], true);

					// fuckingDestroy(daNote, notes);
				}
			});

			if (pressArray[i] && !(strum.animation.curAnim.name == 'confirm'))
				strum.playAnim('press', true);
			else if (releaseArray[i])
				strum.playAnim('static', false);
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

		if (SONG.sections[Math.floor(curStep / 16)] != null)
		{
			if (SONG.sections[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.sections[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM: ${SONG.sections[Math.floor(curStep / 16)].bpm}');
			}
			// else
			// Conductor.changeBPM(SONG.bpm);
		}

		if (startedCountdown || startedSong)
			notes.sort(FlxSort.byY, downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		if (curBeat % 4 == 0)
			zoomcam();

		iconP1.scale.set(1.2, 1.2);
		iconP2.scale.set(1.2, 1.2);
	}

	function zoomcam()
	{
		FlxG.camera.zoom += 0.03;
		camHUD.zoom += 0.05;
	}
}
