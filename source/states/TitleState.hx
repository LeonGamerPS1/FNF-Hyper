package states;

import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import formats.MenuItemJSON;

class TitleState extends MusicBeatState
{
	var menuBois:Array<FlxText>;
	var originalBffs:Array<MenuItem> = [];

	var curSelected:Int = 0;

	override function create()
	{
		FlxG.sound.cache('assets/songs/bopeebo/Inst.ogg');
		FlxG.sound.playMusic('assets/songs/bopeebo/Inst.ogg', 0.5, true);

		menuBois = [];
		originalBffs = MenuItemJSON.parseShit('menuItems.json').items;

		for (i in 0...originalBffs.length)
		{
			var slicedMenuItem = originalBffs[i].name;

			var text:FlxText = new FlxText(0, 0, 0, slicedMenuItem, 10, false);
			text.screenCenter();
			var previousText = menuBois[menuBois.length - 1] ?? text;
			text.y += previousText.size * i;
			menuBois.push(text);
			add(text);
		}
		for (index => value in originalBffs)
		{
			originalBffs.remove(value);
		}
		originalBffs = null;
		#if cpp cpp.vm.Gc.run(true); #end

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var i = 0;

		if (curSelected > menuBois.length - 1)
			curSelected = 0;

		if (curSelected < 0)
			curSelected = menuBois.length - 1;
		for (text in menuBois)
		{
			var selected = i == curSelected;
			// var color = selected ? FlxColor.YELLOW : FlxColor.WHITE;

			// if (text.color != color)
			// text.color = color;
			text.alpha = selected ? 1 : 0.4;

			if (!text.isOnScreen(FlxG.camera) && text == menuBois[curSelected])
				FlxG.camera.follow(text, TOPDOWN);

			i++;
		}

		if (controls.DOWN_P)
			curSelected++;
		if (controls.UP_P)
			curSelected--;
	}

	override function destroy()
	{
		FlxG.sound.music.stop();
		FlxG.sound.music.time = 0;

		super.destroy();
		// FlxG.sound.music.destroy();
	}
}
