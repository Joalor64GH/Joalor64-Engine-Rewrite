package meta.data.windows;

import meta.data.native.WinAPI;

/**
 * THIS WAS MADE BY YOSHICRAFTER29!!! LMAO!!
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
}