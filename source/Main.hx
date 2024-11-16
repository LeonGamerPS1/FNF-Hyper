package;

import backend.PlayerSettings;
import flixel.FlxGame;
import flixel.util.FlxStringUtil;
import openfl.display.Sprite;
import openfl.system.System;
import openfl.text.TextField;
import openfl.text.TextFormat;
import states.TitleState;
#if gl_stats
import openfl.display._internal.stats.Context3DStats;
import openfl.display._internal.stats.DrawCallContext;
#end
#if flash
import openfl.Lib;
#end

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(0, 0, TitleState));
		PlayerSettings.init();
		var fps:FPES;
		fps = new FPES(10, 10, 0xFFFFFF);
		addChild(fps);
	}
}

/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class FPES extends TextField
{
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Int;

	@:noCompletion private var cacheCount:Int;
	@:noCompletion private var currentTime:Float;
	@:noCompletion private var times:Array<Float>;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		this.x = x;
		this.y = y;

		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat("_sans", 12, color);
		text = "FPS: ";

		cacheCount = 0;
		currentTime = 0;
		times = [];
		width = 99999999;

		#if flash
		addEventListener(Event.ENTER_FRAME, function(e)
		{
			var time = Lib.getTimer();
			__enterFrame(time - currentTime);
		});
		#end
	}

	// Event Handlers
	@:noCompletion
	private #if !flash override #end function __enterFrame(deltaTime:Float):Void
	{
		currentTime += deltaTime;
		times.push(currentTime);

		while (times[0] < currentTime - 1000)
		{
			times.shift();
		}

		var currentCount = times.length;
		currentFPS = Math.round((currentCount + cacheCount) / 2);

		if (currentCount != cacheCount /*&& visible*/)
		{
			text = "FPS: " + currentFPS;

			#if (gl_stats && !disable_cffi && (!html5 || !canvas))
			text += "\ntotalDC: " + Context3DStats.totalDrawCalls();
			text += "\nstageDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE);
			text += "\nstage3DDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE3D);
			#end
			text += '\n${traceMemoryUsage()}';
		}

		cacheCount = currentCount;
	}

	static function traceMemoryUsage()
	{
		#if (cpp)
		var usedMemory = cpp.vm.Gc.memUsage(); // Memory used by the application in bytes

		return "Memory Usage: " + FlxStringUtil.formatBytes(Std.parseFloat('$usedMemory'));
		#else
		return 'MEM: ${FlxStringUtil.formatBytes(Std.parseFloat('${System.totalMemory}'))}';
		#end
	}
}
