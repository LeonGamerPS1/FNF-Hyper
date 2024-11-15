package formats;

import haxe.Json;
import openfl.Assets;

using StringTools;

typedef MenuItems =
{
	var items:Array<MenuItem>;
}

typedef MenuItem =
{
	var name:String;
	var TargetState:String;
}

class MenuItemJSON
{
	/**
	 * Parses a json file and returns a Typedef thing
	 * @param filename  Path to the file. (Only type the Filename and File extension as it defaults to "assets/data/" for the path shit).
	 * @return parsed json typedef ass
	 */
	public static function parseShit(filename:Dynamic):MenuItems
	{
		var rawShit:String = Assets.getText("assets/data/" + filename.toString());
		while (!rawShit.endsWith("}"))
			rawShit = rawShit.substr(0, rawShit.length - 1);

		var parsedJson:MenuItems = cast Json.parse(rawShit);

		return parsedJson;
	}
}
