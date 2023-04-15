package meta.data.native;

import meta.data.windows.WindowsAPI.MessageBoxIcon;
#if windows
@:buildXml('
<target id="haxe">
    <lib name="dwmapi.lib" if="windows" />
    <lib name="shell32.lib" if="windows" />
    <lib name="gdi32.lib" if="windows" />
    <lib name="ole32.lib" if="windows" />
    <lib name="uxtheme.lib" if="windows" />
</target>
')

// majority is taken from microsofts doc 
@:cppFileCode('
#include "mmdeviceapi.h"
#include "combaseapi.h"
#include <iostream>
#include <Windows.h>
#include <cstdio>
#include <tchar.h>
#include <dwmapi.h>
#include <winuser.h>
#include <Shlobj.h>
#include <wingdi.h>
#include <shellapi.h>
#include <uxtheme.h>

#define SAFE_RELEASE(punk)  \\
              if ((punk) != NULL)  \\
                { (punk)->Release(); (punk) = NULL; }

#ifndef DWMWA_USE_IMMERSIVE_DARK_MODE
#define DWMWA_USE_IMMERSIVE_DARK_MODE 20 // supported in Windows 11 (Build 22000 and higher)
#endif

static long lastDefId = 0;
')
@:dox(hide)
class WinAPI {
    @:functionCode('
        // This only works for 32 bit systems/platforms
        #if defined(__WIN32__)
        int darkMode = enable ? 1 : 0;
        HWND window = GetActiveWindow();
        if (S_OK != DwmSetWindowAttribute(window, DWMWA_USE_IMMERSIVE_DARK_MODE, 20, sizeof(darkMode))) {
            DwmSetWindowAttribute(window, DWMWA_USE_IMMERSIVE_DARK_MODE, 20, sizeof(darkMode));
        }
        #else
        return false;
        #endif
    ')
    public static function setDarkMode(enable:Bool) {
        #if HXCPP_M32
        return true;
        #else
        return false;
        #end
    }

    #if windows
    @:functionCode('
        MessageBox(GetActiveWindow(), message, caption, icon | MB_SETFOREGROUND);
    ')
    #end
    public static function showMessageBox(caption:String, message:String, icon:MessageBoxIcon = MSG_WARNING) {
        
    }
}
#end