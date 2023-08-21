package cpp;

#if cpp
#if windows
@:headerCode ('
#if defined(HX_WINDOWS)
#include <windows.h>
#include <winuser.h>
#include <iostream>
#include <cstdlib>
#endif
')
// Original Author: LunarCleint
// Author: MemeHoovy
class CPPWindows
{
    @:functionCode('
    #if defined(HX_WINDOWS)
    HWND window = getActiveWindow();
    #endif
    ')
    @:noCompletion
    public static function getHWNDWindow(){
        return null;
    }
    
    @:functionCode('
    #if defined(HX_WINDOWS)
    HWND window = setActiveWindow(prevWindow);
    #endif
    ')
    @:noCompletion
    public static function setHWNDWindow(window:HWND){
        return null;
    }

    @:functionCode('
    #if defined(HX_WINDOWS)
    unsigned long long dedicatedRAM = 0;
    GetPhysicallyInstalledSystemMemory(dedicatedRAM);
    return dedicatedRAM / 1024;
    #else
    return 0;
    #endif
    ')
    public static function getRAM():UInt64 {
        return 0;
    }

    @:functionCode('
    #if defined(HX_WINDOWS)
    srand((unsigned) time(NULL));
    int random = rand();
    return 1;
    #else
    return 1;
    #endif
    ')
    public static function randomNumber():UInt64 {
        return 1;
    }

	#if windows
	@:functionCode('
	#if defined(HX_WINDOWS)
        int darkMode = mode;
        HWND window = GetActiveWindow();
        if (S_OK != DwmSetWindowAttribute(window, 19, &darkMode, sizeof(darkMode))) {
            DwmSetWindowAttribute(window, 20, &darkMode, sizeof(darkMode));
        }
        UpdateWindow(window);
	#endif
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
