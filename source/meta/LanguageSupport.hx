package meta;

import flixel.FlxG;
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class LanguageSupport {
    static var langs:Array<Array<String>> = [
        ["en", "English"]
    ];

    public static function refreshLangs() {
        langs = [ ["en", "English"] ];
        #if MODS_ALLOWED
        var directories:Array<String> = Paths.getModDirectories();
        for (dir in directories) {
            var target:String = haxe.io.Path.join([Paths.mods(), dir]) + '/data/langs.txt';
            if (FileSystem.exists(target)) {
                var content:String = File.getContent(target);
                var lines:Array<String> = content.split('\n');
                for (line in lines) {
                    var split:Array<String> = line.split("|"); //<langcode>|<Language name>
                    if (split.length < 2) continue;
                    langs.push([split[0].trim(), split[1].trim()]);
                }
            }
        }
        #else
        var target:String = haxe.io.Path.join([Paths.getPreloadPath()]) + '/data/langs.txt';
        if (FileSystem.exists(target)) {
            var content:String = File.getContent(target);
            var lines:Array<String> = content.split('\n');
            for (line in lines) {
                var split:Array<String> = line.split("|"); //<langcode>|<Language name>
                if (split.length < 2) continue;
                langs.push([split[0].trim(), split[1].trim()]);
            }
        }
        #end
    }

    public static function currentLangCode():String {
        if (!Reflect.hasField(FlxG.save.data, 'lang')) {
            FlxG.save.data.lang = langs[0][0];
        }
        for (lang in langs) {
            if (lang[0] == FlxG.save.data.lang) {
                return lang[0];
            }
        }
        return langs[0][0];
    }

    public static function currentLangName() {
        var lang = currentLangCode();
        return getLangName(lang);
    }

    public static function currentLangExt():String {
        var lang = currentLangCode();
        if (lang == langs[0][0]) { //No ext used for default language
            return "";
        } else {
            return "." + lang;
        }
    }

    public static function getLangName(lang:String) {
        var langName = null;
        for (entry in langs) {
            if (entry[0] == lang) {
                langName = entry[1];
                break;
            }
        }
        return langName;
    }

    public static function languageSwitch() {
        var lang = currentLangCode();
        var i = 0, next = 0;
        for (entry in langs) {
            if (entry[0] == lang) {
                if (i == langs.length - 1) next = 0;
                else next = i + 1;
                break;
            }
            i++;
        }
        FlxG.save.data.lang = langs[next][0];
    }
}