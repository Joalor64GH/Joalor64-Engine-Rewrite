package system;

class PlatformUtil
{
    public static function getPlatform():String
    {
        #if windows
        return 'windows';
        #elseif linux
        return 'linux';
        #elseif mac
        return 'mac';
        #elseif neko
        return 'neko';
        #elseif html5
        return 'browser';
        #elseif android
        return 'android';
        #elseif hl
        return 'hl';
        #elseif ios
        return 'ios';
        #elseif flash
        return 'flash';
        #else
        return 'unknown';
        #end
    }
}