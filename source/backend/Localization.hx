package backend;

#if openfl
import openfl.system.Capabilities;
#end

typedef ApplicationConfig = {
    @:optional var directory:String;
    @:optional var default_language:String;
}

/**
 * A simple localization system.
 * Please credit me if you use it!
 * @author Joalor64GH
 */

class Localization 
{
    private static var data:Map<String, Dynamic>;

    private static var currentLanguage:String;
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

    public static function init(config:ApplicationConfig) 
    {
        directory = config.directory ?? "locales";
        DEFAULT_LANGUAGE = config.default_language ?? "en";

        loadLanguages();
        switchLanguage(DEFAULT_LANGUAGE);
    }

    public static function loadLanguages()
    {
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
                    data.set(language, languageData);
                }
            }
        }
    }

    private static function loadLanguageData(language:String):Dynamic
    {
        var jsonContent:String = null;
        var path:String = Paths.getPath('$directory/$language/languageData.json');

        #if MODS_ALLOWED
        var modPath:String = Paths.modFolders('$directory/$language/languageData.json');
        
        if (FileSystem.exists(modPath))
            jsonContent = File.getContent(modPath);
        else if (FileSystem.exists(path))
            jsonContent = File.getContent(path);
        #else
        if (FileSystem.exists(path))
            jsonContent = File.getContent(path);
        #end
        else {
            trace("oops! file not found for: " + language + "!");
            jsonContent = File.getContent(Paths.getPath(DEFAULT_DIR + "/" + DEFAULT_LANGUAGE + "/" + "languageData.json"));
            currentLanguage = DEFAULT_LANGUAGE;
        }

        return Json.parse(jsonContent);
    }

    public static function switchLanguage(newLanguage:String)
    {
        if (newLanguage == currentLanguage)
            return;

        var languageData:Dynamic = loadLanguageData(newLanguage);

        currentLanguage = newLanguage;
        data.set(newLanguage, languageData);
        trace('Language changed to $currentLanguage');
    }

    public static function get(key:String, ?language:String):String
    {
        var targetLanguage:String = language ?? currentLanguage;
        var languageData = data.get(targetLanguage);
        
        if (data == null) {
            trace("You haven't initialized the class!");
            return null;
        }

        if (data.exists(targetLanguage))
            if (Reflect.hasField(languageData, key))
                return Reflect.field(languageData, key);

        return null;
    }

    public static function getLocalizedImage(path:String, ?lang:String):String
    {
        var target:String = lang ?? currentLanguage;
        return Paths.getPath('locales/$target/images/$path.png');
    }

    public static function getLocalizedSound(path:String, ?lang:String):String
    {
        var target:String = lang ?? currentLanguage;
        return Paths.getPath('locales/$target/sounds/$path.${Paths.SOUND_EXT}');
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