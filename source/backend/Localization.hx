package backend;

#if openfl
import openfl.system.Capabilities;
#end
import openfl.Assets;
import haxe.io.Path;

typedef ApplicationConfig = {
    var languages:Array<String>;
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

    public static var DEFAULT_LANGUAGE:String = "en-us";
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
        DEFAULT_LANGUAGE = config.default_language ?? "en-us";

        loadLanguages(config.languages);
        switchLanguage(DEFAULT_LANGUAGE);
    }

    public static function loadLanguages(languages:Array<String>):Bool
    {
        var allLoaded:Bool = true;

        data = new Map<String, Dynamic>();

        for (language in languages) {
            var languageData:Dynamic = loadLanguageData(language);
            data.set(language, languageData);
        }

        return allLoaded;
    }

    private static function loadLanguageData(language:String):Dynamic
    {
        var jsonContent:String;

        try {
            #if sys
            jsonContent = File.getContent(path(language));
            #else
            jsonContent = Assets.getText(path(language));
            #end
        } catch (e) {
            trace('file not found: $e');
            #if sys
            jsonContent = File.getContent(path(DEFAULT_LANGUAGE));
            #else
            jsonContent = Assets.getText(path(DEFAULT_LANGUAGE));
            #end
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

    private static function path(language:String) {
        var localDir = Path.join([directory, language + ".json"]);
        var path:String = Paths.getPath(localDir);
        return path; 
    }
}