package logins.sub.states.gamejolt;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.api.FlxGameJolt;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUICheckBox;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import formats.OtherForm.LogonSaveFormat;
import haxe.ui.components.CheckBox;
import haxe.ui.containers.VBox;
import haxe.ui.events.MouseEvent;
import lime.system.System;
import objects.Checkbox;
import states.MusicBeatSubState;

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:inheritDoc
class Login extends MusicBeatSubState
{
	var bg:FlxBackdrop;

	var title_box:FlxText;
	var inputBox:FlxInputText;

	var title_boxToken:FlxText;
	var inputBoxToken:FlxInputText;

	var Confirm:FlxButton;

	public static var canEnter:Bool = true;

	public var logonui:LogonUI;

	var autoLogin:Checkbox;

	override function create()
	{
		super.create();


		bg = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
		bg.velocity.set(40, 40);
		bg.alpha = 0;
		add(bg);

		bg.angle = 2;
		bg.alpha = 0;
		FlxTween.tween(bg, {
			alpha: 1,
			"scale.x": 0.5,
			"scale.y": 0.5,
			angle: 0
		}, 1, {ease: FlxEase.sineInOut, onComplete: onComplete});
	}

	private function onComplete(tween:FlxTween)
	{
		inputBox = new FlxInputText(0, 0, 200);
		inputBox.setFormat('assets/fonts/vcr.ttf', 15, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		inputBox.screenCenter();
		add(inputBox);

		title_box = new FlxText(inputBox.x, inputBox.y + 25, 0, 'Username: ');
		title_box.setFormat('assets/fonts/vcr.ttf', 15, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK, true);
		title_box.screenCenter();
		title_box.y -= title_box.size;
		add(title_box);

		inputBoxToken = new FlxInputText(0, 0, 200);
		inputBoxToken.setFormat('assets/fonts/vcr.ttf', 15, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		inputBoxToken.screenCenter();
		inputBoxToken.y = inputBox.y + 70;
		add(inputBoxToken);

		title_boxToken = new FlxText(inputBoxToken.x, inputBox.y + 25, 0, 'Token: ');
		title_boxToken.setFormat('assets/fonts/vcr.ttf', 15, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK, true);
		title_boxToken.y = inputBoxToken.y;
		title_boxToken.screenCenter(X);
		title_boxToken.y -= title_box.size;
		add(title_boxToken);

		Confirm = new FlxButton(0, 0, 'Log-In', function()
		{
			if (!FlxGameJolt.initialized)
				FlxGameJolt.authUser(inputBox.text, inputBoxToken.text, onloginAttempt);
		});

		Confirm.screenCenter(X);
		Confirm.y = title_boxToken.y + 50;
		add(Confirm);

		autoLogin = new Checkbox(0, 0);
		autoLogin.onClick = () -> FlxG.save.data.autoLogin = autoLogin.checked;
		add(autoLogin);

		var txt = new FlxText(autoLogin.x + 50, autoLogin.y, 0, 'Auto-Login');
		txt.setFormat('assets/fonts/vcr.ttf', 15, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK, true);

		add(title_boxToken);
	}

	public override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if (controls.BACK)
			onCompleteOut();
	}

	private function onCompleteOut(?tween:FlxTween)
	{
		FlxTween.cancelTweensOf(bg);
		close();
		FlxG.camera.flash(FlxColor.BLACK);
	}

	function onloginAttempt(isSuccessful:Bool)
	{
		if (isSuccessful)
		{
			onCompleteOut();
		}
		addGayText(isSuccessful);
	}

	function addGayText(shouldNotFail:Bool)
	{
		var result = shouldNotFail != false ? ' Yo, ${FlxGameJolt.username}!\n ' +
			"You're all set to  drop some beats. Let’s jam!" : "Uh-oh, wrong move! Check your username and token, \nthen hit retry. Don’t let the\nbeat drop on this!";

		var text:FlxText = new FlxText(0, 0, 0, result, 13);

		text.setFormat('assets/fonts/vcr.ttf', 15, shouldNotFail ? FlxColor.LIME : FlxColor.RED, LEFT, OUTLINE, FlxColor.BLACK);
		text.screenCenter();
		text.x -= 350;
		add(text);

		var yes:LogonSaveFormat;
		yes = {Username: FlxGameJolt.username, Token: FlxGameJolt.usertoken};
		FlxG.save.data.loginData = yes;

		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			FlxTween.tween(text, {alpha: 0}, 1, {
				ease: FlxEase.sineInOut,
				onComplete: (tween:FlxTween) ->
				{
					text.kill();
					remove(text);
					text.destroy();
				}
			});
		});
	}
}

@:build(haxe.ui.ComponentBuilder.build("assets/ui/log/in.xml"))
@:inheritDoc
@:keep
class LogonUI extends VBox
{
	public function new()
	{
		super();
	}
}
