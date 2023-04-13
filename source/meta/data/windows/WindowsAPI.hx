package meta.data.windows;

/**
 * THIS WAS MADE BY YOSHICRAFTER29!!! LMAO!!
 */
class WindowsAPI {
    @:dox(hide) public static function registerAudio() {
        #if windows
        native.WinAPI.registerAudio();
        #end
    }

    /**
     * Sets the window titlebar to dark mode (Windows 10 only)
     */
    public static function setDarkMode(enable:Bool) {
        #if windows
        native.WinAPI.setDarkMode(enable);
        #end
    }
}