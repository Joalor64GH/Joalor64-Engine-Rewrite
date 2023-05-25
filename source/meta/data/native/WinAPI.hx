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
class WinAPI { // i have no idea how cpp works, but these functions don't affect any other platforms
    @:functionCode('
        #if defined(HX_WINDOWS) // makes it only work on Windows platforms
        int darkMode = enable ? 1 : 0;
        HWND window = GetActiveWindow();
        if (S_OK != DwmSetWindowAttribute(window, DWMWA_USE_IMMERSIVE_DARK_MODE, reinterpret_cast<LPCVOID>(&darkMode), sizeof(darkMode))) {
            DwmSetWindowAttribute(window, DWMWA_USE_IMMERSIVE_DARK_MODE, reinterpret_cast<LPCVOID>(&darkMode), sizeof(darkMode));
        }
        #else
        return false;
        #endif
    ')
    public static function setDarkMode(enable:Bool) {
        #if windows
        return true;
        #else
        return false;
        #end
    }

    #if windows
    @:functionCode('
        int result = MessageBox(GetActiveWindow(), message, caption, icon | MB_SETFOREGROUND);
    ')
    public static function showMessageBox(caption:String, message:String, icon:MessageBoxIcon = MSG_WARNING) {
        return switch (untyped __cpp__('result')){
            case idabort:
                3;
            case idcancel:
                2;
            case idcontinue:
                11;
            case idignore:
                5;
            case idno:
                7;
            case idok:
                1;
            case idretry:
                4;
            case idtryagain:
                10;
            case idyes:
                6;
            default:
                0;
        }
    }
    #end
}
#end