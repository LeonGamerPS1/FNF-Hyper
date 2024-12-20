package formats;

import haxe.Json;
import openfl.utils.Assets as OpenFLAssets;

using StringTools;

typedef MenuItems =
{
<<<<<<< HEAD
    var items:Array<MenuItem>;
=======
	var textSize:Null<Int>;
	var font:Null<String>;
	var items:Array<MenuItem>;
>>>>>>> 70c5d2d265889dbb709b0be3f1b9dea029c4e9a9
}

typedef MenuItem =
{
    var name:String;
    var TargetState:String;
}

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end

class MenuItemJSON {
    /**
	 * Parses a json file and returns a Typedef thing
	 * @param filename  Path to the file. (Only type the Filename and File extension as it defaults to "assets/data/" for the path shit).
	 * @return parsed json typedef ass
	 */
    public static function parseShit(filename:Dynamic):MenuItems {
        var rawShit:String = OpenFLAssets.getText("assets/data/" + filename.toString());
        while (!rawShit.endsWith("}"))
            rawShit = rawShit.substr(0, rawShit.length - 1);

        var parsedJson:MenuItems = cast Json.parse(rawShit);

        return parsedJson;
    }
}
