package states;

import backend.*;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import openfl.system.System;
import states.Conductor.BPMChangeEvent;

class MusicBeatState extends FlxUIState
{
	private var curStep:Int = 0;
	private var curBeat:Int = 0;

    private var _desyncCount:Int = 0;

	private var loops:Int = 10;

	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create()
	{
		super.create();
	}

	override function update(elapsed:Float)
	{
		loops--;
		if(loops < 0)
		{
			loops = 10;
			#if cpp cpp.vm.Gc.run(true); #else System.gc(); #end
		}

		// everyStep();
		var oldStep:Int = curStep;

		Conductor.songPosition = FlxG.sound.music.time;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep >= 0)
			stepHit();

		super.update(elapsed);
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
	}

	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		// do literally nothing dumbass
	}
}
