package objects.characters;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import haxe.Json;
import openfl.Assets;

typedef CharacterData =
{
	var name:String;
	var flipX:Null<Bool>;
	var texture_path:String;
	var health_icon:String;
	var health_colors:Array<Float>;
	var animations:Array<AnimationData>;
	var scale:Null<Float>;
}

typedef AnimationData =
{
	var name:String;
	var prefix:String;
	var fps:Int;
	var looped:Bool;
	var OFFSET_X:Float;
	var OFFSET_Y:Float;
}

class GameCharacter extends FlxSprite
{
	public var offsetMap:Map<String, Array<Float>> = new Map<String, Array<Float>>();

	public var json:CharacterData;

	public function new(charName:String = "dad", isPlayer:Bool = false)
	{
		super(0, 0);

		if (Assets.exists('assets/images/characters/$charName/char.json'))
			json = parseShit('assets/images/characters/$charName/char.json');
		else
			json = fallback();

		loadTexture('assets/images/characters/$charName/${json.texture_path}');
		regenOffsets(isPlayer);

		//	trace(json.health_colors);
	}

	function loadTexture(s:String = "")
	{
		var tex = FlxAtlasFrames.fromSparrow('$s.png', '$s.xml');
		frames = tex;
	}

	function regenOffsets(isPlayer:Bool = false)
	{
		if (json == null)
			return;

		if (json.scale != null)
			scale.set(json.scale, json.scale);
		if (json.flipX != null)
			flipX = (json.flipX != isPlayer);

		updateHitbox();

		for (i in 0...json.animations.length)
		{
			var animationMeta = json.animations[i];
			animation.addByPrefix(animationMeta.name, animationMeta.prefix, animationMeta.fps, animationMeta.looped);
			offsetMap[animationMeta.name] = [animationMeta.OFFSET_X, animationMeta.OFFSET_Y];
			playAnim(animationMeta.name, true);
		}
		playAnim('idle');
	}

	public function playAnim(name:String, force:Bool = false)
	{
		animation.play(name, force, false, 0);
		if (offsetMap.exists(name))
			offset.set(offsetMap[name][0], offsetMap[name][1]);
		else
			offset.set(0, 0);
	}

	function parseShit(path:String):CharacterData
	{
		var rawJson = Assets.getText(path);

		var jsonData:CharacterData = Json.parse(rawJson);
		return cast jsonData;
	}

	function fallback():CharacterData
	{
		return {
			name: "unknown",
			texture_path: "default",
			health_icon: "default",
			health_colors: [255, 255, 255],
			animations: [],
			flipX: false,
			scale: 1.0
		};
	}
}
