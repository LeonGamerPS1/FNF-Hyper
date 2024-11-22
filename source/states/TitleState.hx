package states;

import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.FlxState;
import flixel.effects.FlxFlicker;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import formats.MenuItemJSON;

class TitleState extends MusicBeatState {
	var menuBois:Array<FlxText>;
	var originalBffs:Array<MenuItem> = [];
	var states:Array<Class<FlxState>> = [];

	var curSelected:Int = 0;

	override function create() {
		FlxG.sound.cache('assets/songs/bopeebo/Inst.ogg');
		FlxG.sound.playMusic('assets/songs/bopeebo/Inst.ogg', 0.5, true);

		menuBois = [];
		var parsey = MenuItemJSON.parseShit('menuItems.json');
		var items = parsey.items;
		var size:Int = parsey.textSize != null && !Math.isNaN(parsey.textSize) ? parsey.textSize : 10;

		originalBffs = items;

		for (i in 0...originalBffs.length) {
			var slicedMenuItem = originalBffs[i].name;
			var slicedMenuState = originalBffs[i].TargetState;

			var text:FlxText = new FlxText(0, 0, 0, slicedMenuItem, size, false);
			text.setFormat(parsey.font, size);
			text.screenCenter();
			var previousText = menuBois[menuBois.length - 1] ?? text;
			text.y += previousText.size * i;
			menuBois.push(text);
			add(text);

			var instance = Type.resolveClass(slicedMenuState);
			var state:Class<FlxState> = Type.createInstance(instance, []);
			states.push(state);
		}
		for (index => value in originalBffs)
			originalBffs.remove(value);

		trace(states);
		originalBffs = null;
		#if cpp cpp.vm.Gc.run(true); #end

		super.create();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		var i = 0;

		if (curSelected > menuBois.length - 1)
			curSelected = 0;

		if (curSelected < 0)
			curSelected = menuBois.length - 1;
		for (text in menuBois) {
			var selected = i == curSelected;
			// var color = selected ? FlxColor.YELLOW : FlxColor.WHITE;

			// if (text.color != color)
			// text.color = color;
			text.alpha = selected ? 1 : 0.4;

			if (!text.isOnScreen(FlxG.camera) && text == menuBois[curSelected])
				FlxG.camera.follow(text, FlxCameraFollowStyle.LOCKON);

			if (selected && !FlxFlicker.isFlickering(text)) {
				if (controls.ACCEPT) {
					FlxFlicker.flicker(text, 1, 0.06, true, true, function(Flicker:FlxFlicker) {
						for (index => value in menuBois) {
							FlxTween.tween(value.offset, {y: value.offset.y - 600}, 1.3 * index);
							FlxTween.tween(text.offset, {y: text.offset.y - 600}, 1.3 * index);
						}
					});
				}
			}

			i++;
		}

		if (controls.DOWN_P)
			curSelected++;
		if (controls.UP_P)
			curSelected--;
	}

	override function destroy() {
		FlxG.sound.music.stop();
		FlxG.sound.music.time = 0;

		super.destroy();
		// FlxG.sound.music.destroy();
	}
}
