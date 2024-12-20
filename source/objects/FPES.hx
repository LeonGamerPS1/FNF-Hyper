package objects;

/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
import flixel.util.FlxStringUtil;
import openfl.system.System;
import openfl.text.Font;
import openfl.text.TextField;
import openfl.text.TextFormat;

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:font('assets/fonts/vcr.ttf') class VCR_OSD_Mono extends Font
{
}

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
		defaultTextFormat = new TextFormat("VCR OSD Mono", 15, color, true, false, false, null, null, LEFT, null, null, null, null);
    

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
