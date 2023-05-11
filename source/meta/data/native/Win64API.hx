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

static long lastDefId = 0;
')
@:dox(hide)
class Win64API {
    @:functionCode('
        int darkMode = enable ? 1 : 0;
        HWND window = GetActiveWindow();
        if (S_OK != DwmSetWindowAttribute(window, 19, &darkMode, sizeof(darkMode))) {
            DwmSetWindowAttribute(window, 20, &darkMode, sizeof(darkMode));
        }
    ')
    public static function setDarkMode(enable:Bool) {}

    #if windows
    @:functionCode('
        MessageBox(GetActiveWindow(), message, caption, icon | MB_SETFOREGROUND);
    ')
    #end
    public static function showMessageBox(caption:String, message:String, icon:MessageBoxIcon = MSG_WARNING) {
        
    }
}
#end