package states;

import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
<<<<<<< HEAD
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileCircle;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
=======
import flixel.FlxState;
import flixel.effects.FlxFlicker;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
>>>>>>> 70c5d2d265889dbb709b0be3f1b9dea029c4e9a9
import formats.MenuItemJSON;
import objects.AtlasSprite;

<<<<<<< HEAD
class TitleState extends MusicBeatState
{
	var menuBois:Array<FlxText> = [];
	var seste:Array<String> = [];
=======
class TitleState extends MusicBeatState {
	var menuBois:Array<FlxText>;
>>>>>>> 70c5d2d265889dbb709b0be3f1b9dea029c4e9a9
	var originalBffs:Array<MenuItem> = [];
	var states:Array<Class<FlxState>> = [];

	var curSelected:Int = 0;

	public var gf:AtlasSprite;

	override function create() {
		FlxG.sound.cache('assets/songs/bopeebo/Inst.ogg');
		FlxG.sound.playMusic('assets/songs/bopeebo/Inst.ogg', 0.5, true);
		gf = new AtlasSprite(200, 500);

		add(gf);

		menuBois = [];
		var parsey = MenuItemJSON.parseShit('menuItems.json');
		var items = parsey.items;
		var size:Int = parsey.textSize != null && !Math.isNaN(parsey.textSize) ? parsey.textSize : 10;

		originalBffs = items;

		for (i in 0...originalBffs.length) {
			var slicedMenuItem = originalBffs[i].name;
<<<<<<< HEAD
			seste.push(slicedMenuItem);
=======
			var slicedMenuState = originalBffs[i].TargetState;
>>>>>>> 70c5d2d265889dbb709b0be3f1b9dea029c4e9a9

			var text:FlxText = new FlxText(0, 0, 0, slicedMenuItem, size, false);
			text.setFormat(parsey.font, size);
			text.screenCenter();
			var previousText = menuBois[menuBois.length - 1] ?? text;
			text.y += previousText.size * i;
			menuBois.push(text);
			add(text);

<<<<<<< HEAD
		originalBffs = [];

=======
			var instance = Type.resolveClass(slicedMenuState);
			var state:Class<FlxState> = Type.createInstance(instance, []);
			states.push(state);
		}
		for (index => value in originalBffs)
		{
			originalBffs.remove(value);
		}
		originalBffs = null;
>>>>>>> 70c5d2d265889dbb709b0be3f1b9dea029c4e9a9
		#if cpp cpp.vm.Gc.run(true); #end

		super.create();

		var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileCircle);
		diamond.persist = true;
		diamond.destroyOnNoUse = false;

		FlxTransitionableState.defaultTransIn = new TransitionData(TILES, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
			new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
		FlxTransitionableState.defaultTransOut = new TransitionData(TILES, FlxColor.BLACK, 0.7, new FlxPoint(0, -2), {asset: diamond, width: 32, height: 32},
			new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		Conductor.songPosition = FlxG.sound.music.time;
		FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, Math.exp(-FlxG.elapsed * 9 * 1));

		var i = 0;

		if (curSelected > menuBois.length - 1)
			curSelected = 0;

		if (curSelected < 0)
			curSelected = menuBois.length - 1;
		for (text in menuBois) {
			var selected = i == curSelected;
			var selname:String = seste[curSelected];
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

			if (controls.ACCEPT)
			{
				switch (selname.toLowerCase())
				{
					case "play-state":
						FlxG.switchState(new PlayState());
						#if !html5 // ! crashes on html5!!!!!
						case 'gamejolt_login':
							openSubState(new logins.sub.states.gamejolt.Login());
						#end

					case "options":
						text.alpha = 0.3;
						openSubState(new OptionsMenu());
					default:
						if (selected)
						{
							FlxTween.color(text, 0.2, text.color, FlxColor.RED);
							FlxTween.shake(text, 0.05, 0.5, XY, {
								onComplete: (tween:FlxTween) ->
								{
									FlxTween.color(text, 0.4, text.color, FlxColor.WHITE);
								}
							});
						}
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

	override function beatHit()
	{
		FlxG.camera.zoom += 0.05;
	}
}
