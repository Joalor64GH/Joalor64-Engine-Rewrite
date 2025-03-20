import sys.FileSystem;
import sys.io.File;
import haxe.Json;

typedef Library = {
    var name:String;
    var type:String;
    var version:String;
    var dir:String;
    var ref:String;
    var url:String;
}

class Main {
    public static function main():Void {
        if (!FileSystem.exists('.haxelib'))
            FileSystem.createDirectory('.haxelib');

        final json:Array<Library> = Json.parse(File.getContent('./haxelibs.json')).dependencies;

        for (lib in json) {
            switch (lib.type) {
                case "haxelib":
                    Sys.command('haxelib --quiet install ${lib.name} ${lib.version != null ? lib.version : ""}');
                case "git":
                    Sys.command('haxelib --quiet git ${lib.name} ${lib.url}');
                default:
                    Sys.println('Cannot resolve library of type "${lib.type}"');
            }
        }

        Sys.exit(0);
    }
}