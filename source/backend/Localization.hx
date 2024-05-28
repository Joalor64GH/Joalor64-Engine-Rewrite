package backend;

#if openfl
import openfl.system.Capabilities;
#end

/**
 * A simple localization system.
 * Modified for Joalor64 Engine.
 * Please credit me if you use it!
 * @author Joalor64GH
 */

class Localization 
{
    private static var data:Map<String, Dynamic>;

    public static var currentLanguage:String;
    public static var DEFAULT_LANGUAGE:String = "en";

    private static final DEFAULT_DIR:String = "locales";
    public static var directory:String = DEFAULT_DIR;

    public static var systemLanguage(get, never):String;

    public static function get_systemLanguage() 
    {
        #if openfl
        return Capabilities.language; 
        #else
        return throw "This Variable is for OpenFl only!";
        #end
    }

    public static function loadLanguages():Bool
    {
        var allLoaded:Bool = true;

        data = new Map<String, Dynamic>();

        var foldersToCheck:Array<String> = [Paths.getPath('locales/')];

        #if MODS_ALLOWED
        foldersToCheck.insert(0, Paths.mods("locales/"));
        if (Mods.currentModDirectory != null && Mods.currentModDirectory.length > 0)
            foldersToCheck.insert(0, Paths.mods(Mods.currentModDirectory + "/locales/"));
        
        for (mod in Mods.getGlobalMods())
            foldersToCheck.insert(0, Paths.mods(mod + "/locales/"));
        #end

        for (folder in foldersToCheck) {
            var path:String = folder + "languagesList.txt";
            if (FileSystem.exists(path)) {
                var listContent:String = File.getContent(path);
                var languages:Array<String> = listContent.split('\n');

                for (language in languages) {
                    var languageData:Dynamic = loadLanguageData(language.trim());
                    if (languageData != null) {
                        trace("successfully loaded language: " + language + "!");
                        data.set(language, languageData);
                    } else {
                        trace("oh no! failed to load language: " + language + "!");
                        allLoaded = false;
                    }
                }
            }
        }

        return allLoaded;
    }

    private static function loadLanguageData(language:String):Dynamic
    {
        var jsonContent:String = null;
        var path:String = Paths.getPath('$directory/$language/languageData.json');

        #if MODS_ALLOWED
        var modPath:String = Paths.modFolders('$directory/$language/languageData.json');
        
        if (FileSystem.exists(modPath)) {
            jsonContent = File.getContent(modPath);
            currentLanguage = language;
        } else if (FileSystem.exists(path)) {
            jsonContent = File.getContent(path);
            currentLanguage = language;
        }
        #else
        if (FileSystem.exists(path)) {
            jsonContent = File.getContent(path);
            currentLanguage = language;
        }
        #end
        else {
            trace("oops! file not found for: " + language + "!");
            jsonContent = File.getContent(Paths.getPath(DEFAULT_DIR + "/" + DEFAULT_LANGUAGE + "/" + "languageData.json"));
            currentLanguage = DEFAULT_LANGUAGE;
        }

        return Json.parse(jsonContent);
    }

    public static function switchLanguage(newLanguage:String):Bool
    {
        if (newLanguage == currentLanguage) {
            trace("hey! you're already using the language: " + newLanguage);
            return true;
        }

        var languageData:Dynamic = loadLanguageData(newLanguage);

         if (languageData != null) {
            trace("yay! successfully loaded data for: " + newLanguage);
            currentLanguage = newLanguage;
            data.set(newLanguage, languageData);
            return true;
        } else {
            trace("whoops! failed to load data for: " + newLanguage);
            return false;
        }

        return false;
    }

    public static function get(key:String, ?language:String):String
    {
        var targetLanguage:String = language != null ? language : currentLanguage;
        var languageData = data.get(targetLanguage);
        final field:String = Reflect.field(languageData, key);

        if (data != null && data.exists(targetLanguage))
            if (languageData != null && Reflect.hasField(languageData, key))
                return field;

        return field != null ? field : 'missing key: $key';
    }

    public static function getLocalizedImage(path:String, ?lang:String):String
    {
        var target:String = lang != null ? lang : currentLanguage;

        var modFile:String = Paths.modFolders('locales/$target/images/$path.png');
        var defaultFile:String = Paths.getPath('locales/$target/images/$path.png');

        #if MODS_ALLOWED
        if (FileSystem.exists(modFile)) return modFile;
        else if (FileSystem.exists(defaultFile)) return defaultFile;
        #else
        if (FileSystem.exists(defaultFile)) return defaultFile;
        #end
        else return defaultFile;

        trace('oops! $path returned null!');
        return null;
    }

    public static function getLocalizedSound(path:String, ?lang:String):String
    {
        var target:String = lang != null ? lang : currentLanguage;
        return Paths.returnSoundPath('locales/$target/sounds', path);
    }
}

class Locale
{
    public var lang:String;
    public var code:String;

    public function new(lang:String, code:String)
    {
        this.lang = lang;
        this.code = code;
    }
}