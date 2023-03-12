package cpp;

#if cpp
#if windows
@:headerCode ('
#include <windows.h>
#include <winuser.h>
#include <iostream>
#include <cstdlib>
')
// Original Author: LunarCleint
// Author: MemeHoovy
class CPPWindows
{
    @:functionCode('
    HWND window = getActiveWindow();
    ')
    @:noCompletion
    public static function getHWNDWindow(){
        return null;
    }
    
    @:functionCode('
    HWND daWindow;

    HWND window = setActiveWindow(prevWindow);
    ')
    @:noCompletion
    public static function setHWNDWindow(window:HWND){
        return null;
    }

    @:functionCode('
    unsigned long long dedicatedRAM = 0;
    GetPhysicallyInstalledSystemMemory(dedicatedRAM);
    return dedicatedRAM / 1024;
    ')
    public static function getRAM():UInt64 {
        return 0;
    }

    @:functionCode('
    srand((unsigned) time(NULL));
    int random = rand();
    return 1;
    ')
    public static function randomNumber():UInt64 {
        return 1;
    }

	#if windows
	@:functionCode('
        int darkMode = mode;
        HWND window = GetActiveWindow();
        if (S_OK != DwmSetWindowAttribute(window, 19, &darkMode, sizeof(darkMode))) {
            DwmSetWindowAttribute(window, 20, &darkMode, sizeof(darkMode));
        }
        UpdateWindow(window);
    ')
	@:noCompletion
	public static function _setWindowColorMode(mode:Int)
	{
	}

	public static function setWindowColorMode(mode:WindowColorMode)
	{
		var darkMode:Int = cast(mode, Int);

		if (darkMode > 1 || darkMode < 0)
		{
			trace("WindowColorMode Not Found...");

			return;
		}

		_setWindowColorMode(darkMode);
	}
}
#end
#end