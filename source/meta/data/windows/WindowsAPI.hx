package meta.data.windows;

#if windows
@:buildXml('
    <target id="haxe">
        <lib name="dwmapi.lib" if="windows" />
    </target>
    ')
@:cppFileCode('
    #include <Windows.h>
    #include <cstdio>
    #include <iostream>
    #include <tchar.h>
    #include <dwmapi.h>
    #include <winuser.h>

    #ifndef DWMWA_USE_IMMERSIVE_DARK_MODE
    #define DWMWA_USE_IMMERSIVE_DARK_MODE 20 // support for windows 11
    #endif
    ')
@:dox(hide)
class WindowsAPI
{
    @:functionCode('
        int darkMode = enable ? 1 : 0;
        HWND window = GetActiveWindow();
        if (S_OK != DwmSetWindowAttribute(window, DWMWA_USE_IMMERSIVE_DARK_MODE, reinterpret_cast<LPCVOID>(&darkMode), sizeof(darkMode)))
            DwmSetWindowAttribute(window, DWMWA_USE_IMMERSIVE_DARK_MODE, reinterpret_cast<LPCVOID>(&darkMode), sizeof(darkMode));
    ')
    public static function setDarkMode(enable:Bool) {}

    public static function darkMode(enable:Bool)
    {
        setDarkMode(enable);
        Application.current.window.borderless = true;
        Application.current.window.borderless = false;
    }

    @:functionCode('
        int result = MessageBox(GetActiveWindow(), message, caption, icon | MB_SETFOREGROUND);
    ')
    public static function showMessageBox(caption:String, message:String, icon:MessageBoxIcon = MSG_WARNING) {}

    public static function messageBox(caption:String, message:String, icon:MessageBoxIcon = MSG_WARNING)
    {
        showMessageBox(caption, message, icon);
    }

    @:functionCode('
    HWND window = getActiveWindow();
    ')
    public static function getHWNDWindow(){
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
}

@:enum abstract MessageBoxIcon(Int) {
    var MSG_ERROR:MessageBoxIcon = 0x00000010;
    var MSG_QUESTION:MessageBoxIcon = 0x00000020;
    var MSG_WARNING:MessageBoxIcon = 0x00000030;
    var MSG_INFORMATION:MessageBoxIcon = 0x00000040;
}
#end