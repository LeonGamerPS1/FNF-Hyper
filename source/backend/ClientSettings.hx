package backend;

import flixel.FlxG;

/**
 * Variables and stuff for the Save Data that the player can edit trough the Options Menu.
 */
@:structInit
class SaveData
{
	

	public var downScroll:Bool = false;
	public var middleScroll:Bool = false;


	public function new()
	{
	}
}

class ClientSettings
{
	public static var og:SaveData;
	public static var data:SaveData;

	public static function InitAndLoadSettings()
	{
		og = new SaveData();
		if (FlxG.save.data.settings == null)
		{
			GLogger.warning("Save Data not Found! Creating Save file...");
			FlxG.save.data.settings = og;
			data = og;
		}
		else
		{
			data = FlxG.save.data.settings;
			GLogger.success("Save data successfully loaded and set.");
		}
        save();
	}

	public static function save()
	{
		GLogger.warning("Save...");
		FlxG.save.data.settings = data;
	}
}
