package meta.data.windows;

import meta.data.native.WinAPI;

/**
 * Class for Windows-only functions, such as transparent windows, message boxes, and more.
 * Does not have any effect on other platforms.
 */
class WindowsAPI {
    /**
     * Sets the window titlebar to dark mode (Windows 10 only)
     */
    public static function setDarkMode(enable:Bool) {
        #if windows
        WinAPI.setDarkMode(enable);
        #end
    }

    /**
     * Shows a message box
     */
    public static function showMessageBox(caption:String, message:String, icon:MessageBoxIcon = MSG_WARNING) {
        #if windows
        WinAPI.showMessageBox(caption, message, icon);
        #else
        lime.app.Application.current.window.alert(message, caption);
        #end
    }
}

@:enum abstract MessageBoxIcon(Int) {
    var MSG_ERROR:MessageBoxIcon = 0x00000010;
    var MSG_QUESTION:MessageBoxIcon = 0x00000020;
    var MSG_WARNING:MessageBoxIcon = 0x00000030;
    var MSG_INFORMATION:MessageBoxIcon = 0x00000040;
}