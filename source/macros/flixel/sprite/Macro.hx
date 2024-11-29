package macros.flixel.sprite;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr.Field;
#end

class Macro
{
	public static function FlxSprite()
	{
		#if macro
		var fields = Context.getBuildFields();

		var set_clipRect:Field = [for (field in fields) if (field.name == 'set_clipRect') field][0];
		var set_antialiasing:Field = [for (field in fields) if (field.name == 'set_antialiasing') field][0];

		switch (set_clipRect.kind)
		{
			case FFun(f):
				set_clipRect.kind = FFun({
					args: f.args,
					params: f.params,
					ret: f.ret,
					expr: macro
					{
						clipRect = rect;

						if (frames != null)
							frame = frames.frames[animation.frameIndex];

						return rect;
					}
				});
			default:
		}

		switch (set_antialiasing.kind)
		{
			case FFun(f):
				set_antialiasing.kind = FFun({
					args: f.args,
					params: f.params,
					ret: f.ret,
					expr: macro
					{
						value = false;

						return value;
					}
				});
			default:
		}

		return fields;
		#end
	}
}
