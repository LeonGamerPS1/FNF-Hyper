package states;

import backend.ClientSettings;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import objects.Checkbox;
import objects.OptionsText;

class OptionsMenu extends MusicBeatSubState
{
	public var options:Array<String> = ["downScroll", "middleScroll",]; // "middleScroll"];

	public var menuBois:FlxTypedGroup<OptionsText>;
	public var checkBoxes:FlxTypedGroup<Checkbox>;

	var bg:FlxBackdrop;

	public var curSelected:Int = 0;

	public var flxText:FlxText;

	public var camFollow:FlxObject;

	override function create():Void
	{
		super.create();

		camFollow = new FlxObject(0, 0);

		bg = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0xFFFFA9A9, FlxColor.BLACK));
		bg.alpha = 0.8;
		bg.velocity.set(40, 40);
		bg.scrollFactor.set();
		add(bg);

		menuBois = new FlxTypedGroup<OptionsText>();
		checkBoxes = new FlxTypedGroup<Checkbox>();

		for (i in 0...options.length)
		{
			var optionsName = options[i];

			var textyeah:OptionsText = new OptionsText(optionsName);
			checkBoxes.add(textyeah.attachedCheckbox);
			menuBois.add(textyeah);
			textyeah.attachedCheckbox.screenCenter();
			textyeah.attachedCheckbox.y += textyeah.attachedCheckbox.height * (i * 1.2);
			textyeah.attachedCheckbox.x = 100;
			textyeah.attachedCheckbox.x += 10 * i;
			textyeah.attachedCheckbox.checked = false;
			textyeah.attachedCheckbox.checked = Std.isOfType(Reflect.getProperty(ClientSettings.data, optionsName),
				Bool) ? Reflect.getProperty(ClientSettings.data, optionsName) : false;
		}

		add(checkBoxes);
		add(menuBois);

		flxText = new FlxText(0, 0, 0, "NULL", 15);
		flxText.y = FlxG.height - 50;
		add(flxText);

		changeSel(0);
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		flxText.text = 'Selected: $curSelected';

		if (controls.BACK)
			close();

		if (controls.DOWN_P)
			changeSel(1);
		if (controls.UP_P)
			changeSel(-1);

		var poyo = checkBoxes.members[curSelected];
		camFollow.x = FlxMath.lerp(poyo.x + 300, camFollow.x, Math.exp(-FlxG.elapsed * 9 * 1));
		camFollow.y = FlxMath.lerp(poyo.y, camFollow.y, Math.exp(-FlxG.elapsed * 9 * 1));
		FlxG.camera.follow(camFollow);
		var i = 0;
		menuBois.forEachAlive(function(e:OptionsText)
		{
			if (e.attachedCheckbox != poyo)
			{
				e.alpha = 0.5;
				e.attachedCheckbox.alpha = 0.5;
			}
			else
			{
				e.alpha = 1;
				poyo.alpha = 1;
				if (controls.ACCEPT)
				{
					Reflect.setField(ClientSettings.data, options[curSelected], poyo.checked);
					checkBoxes.members[curSelected].checked = !checkBoxes.members[curSelected].checked;

					trace(checkBoxes.members[curSelected].checked);
					ClientSettings.save();
				}
			}
			i++;
		});
	}

	function changeSel(sec:Int = 0)
	{
		curSelected += sec;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected > options.length - 1)
			curSelected = 0;
	}
}
