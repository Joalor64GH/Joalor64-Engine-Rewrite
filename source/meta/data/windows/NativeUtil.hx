package meta.data.windows;

class NativeUtil
{
	#if windows
	public static function enableDarkMode()
	{
		BuildFix.enableDarkMode();
	}
	#end
}

// fuck hxcpp
#if windows
@:buildXml('
<target id="haxe">
    <lib name="dwmapi.lib" if="windows" />
</target>
')
@:headerCode('#include <dwmapi.h>')
#end
private class BuildFix
{
	#if windows
	@:functionCode('
        int darkMode = 1;
        HWND window = GetActiveWindow();
        if (S_OK != DwmSetWindowAttribute(window, 19, &darkMode, sizeof(darkMode)))
            DwmSetWindowAttribute(window, 20, &darkMode, sizeof(darkMode));
        UpdateWindow(window);
    ')
	public static function enableDarkMode()
	{
	}
	#end
}