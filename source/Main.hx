package;

import backend.ClientSettings;
import backend.PlayerSettings;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.addons.api.FlxGameJolt;
import flixel.util.FlxStringUtil;
import formats.OtherForm.LogonSaveFormat;
import haxe.ui.Toolkit;
import objects.*;
import openfl.text.TextField;
import openfl.text.TextFormat;

class Main extends openfl.display.Sprite
{
	public function new()
	{
		#if (windows && cpp)
		cpp.native.win.WinNative.darkTitleBar(true);
		#end

		// Toolkit.theme = 'dark';

		super();
		Toolkit.init();
		addChild(new FlxGame(0, 0, states.TitleState));

		PlayerSettings.init();
		#if flixel_addons
		var log:LogonSaveFormat = {Token: null, Username: null};
		if (FlxG.save.data.autoLogin == null)
		{
			GLogger.error('Save data for "autoLogin" not found. Saving and setting it to false..');
			FlxG.save.data.autoLogin = false;
		}
		if (FlxG.save.data.loginData == null)
		{
			GLogger.error('Save data for "loginData" not found. Saving a dummy variable to it...');
			FlxG.save.data.loginData = log;
		}
		else
			log = FlxG.save.data.loginData;

		ClientSettings.InitAndLoadSettings();

		GLogger.general(log);

		FlxGameJolt.init(943474, Constants.APIKEY, false);

		if (log.Token != null
			&& log.Username != null
			&& FlxG.save.data.autoLogin
			&& log.Token != "No token"
			&& log.Username != "No user")
			FlxGameJolt.authUser(log.Username, log.Token);
		#end
		var fps:FPES;
		fps = new FPES(10, 10, 0xFFFFFF);
		addChild(fps);
	}
}
