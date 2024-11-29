package cpp.native.win;

/**
 * A Collection of Native Windows CPP Utils.
 */
#if (windows && cpp)
@:buildXml('
<target id="haxe">
    <lib name="dwmapi.lib" if="windows" />
</target>
')
@:headerCode('
#include <Windows.h>
#include <cstdio>
#include <iostream>
#include <tchar.h>
#include <dwmapi.h>
#include <winuser.h>
')
#end
class WinNative
{
	/**
	 * Makes the Title-Bar of the windows **Dark** or *White*.
	 * @param darkBar 
	 */
	#if (windows && cpp)
	@:functionCode('
        HWND window = GetActiveWindow();
        int isDark = (darkBar ? 1 : 0);
        
        if (DwmSetWindowAttribute(window, 19, &isDark, sizeof(isDark)) != S_OK) {
            DwmSetWindowAttribute(window, 20, &isDark, sizeof(isDark));
        }
        UpdateWindow(window);
    ')
	#end
	public static function darkTitleBar(darkBar:Bool = false)
	{
		return;
	}
}
