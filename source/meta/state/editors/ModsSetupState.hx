package meta.state.editors;

import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUITabMenu;

typedef ModFolder = {
    var id:String;
    var name:String;
    var description:String;
    var restart:Bool;
    var runsGlobally:Bool;
    var color:Array<Int>;
}

class ModSetupTabs extends FlxUITabMenu
{
    var tabGroup:FlxUI;

    var modFolderInput:FlxUIInputText;
    var modIdInput:FlxUIInputText;
    var modNameInput:FlxUIInputText;
    var modDescInput:FlxUIInputText;

    var modColorInputR:FlxUIInputText;
    var modColorInputG:FlxUIInputText;
    var modColorInputB:FlxUIInputText;

    var createButton:FlxUIButton;

    var restartCheck:FlxUICheckBox;
    var globalCheck:FlxUICheckBox;

    var focusList:Array<FlxUIInputText> = [];

    var DEFAULT_MOD:ModFolder = {
        id: "name",
        name: "Name",
        description: "Description",
        restart: false,
        runsGlobally: false,
        color: [170, 0, 255]
    };

    public function getFocus():Bool
    {
        for (i in focusList) if (i.hasFocus) return true;
        return false;
    }

    static final invalidFolderCharacters:Array<String> = ["/", ":", "*", "?", '"', "<", ">", "|", "."];

    public function new()
    {
        super(null, [{name: "Setup Mod Folder", label: "Setup Mod Folder"}], true);

        screenCenter();
        setPosition(300, 250);

        resize(400, 400);

        selected_tab = 0;

        tabGroup = new FlxUI(null, this);
        tabGroup.name = "Setup Mod Folder";
        addGroup(tabGroup);

        final _sep:Int = 35;

        modFolderInput = new FlxUIInputText(25, 25, 350, "Folder");
        addToGroup(modFolderInput, "Mod Folder:", true);

        modIdInput = new FlxUIInputText(25, 25 + _sep, 350, "Name");
        addToGroup(modIdInput, "Mod ID:", true);

        modNameInput = new FlxUIInputText(25, 25 + _sep * 2, 350, "Name");
        addToGroup(modNameInput, "Mod Name:", true);

        modDescInput = new FlxUIInputText(25, 25 + _sep * 3, 350, "Description");
        modDescInput.lines = 999;
        addToGroup(modDescInput, "Mod Description:", true);

        modColorInputR = new FlxUIInputText(25, 25 + _sep * 4, 350, "0-255");
        addToGroup(modColorInputR, "Mod Color (Red):", true);

        modColorInputG = new FlxUIInputText(25, 25 + _sep * 5, 350, "0-255");
        addToGroup(modColorInputG, "Mod Color (Green):", true);

        modColorInputB = new FlxUIInputText(25, 25 + _sep * 6, 350, "0-255");
        addToGroup(modColorInputB, "Mod Color (Blue):", true);

        createButton = new FlxUIButton(310, 350, "Create Folder", () -> {
            final modFolder = modFolderInput.text;

            var keys:Array<String> = [];
            for (i in ModsSetupState.modFolderDirs.keys()) keys.push(i);
            if (keys.contains(modFolder))
            {
                FlxG.sound.play(Paths.sound('cancelMenu'));
                return; // invalid folder name
            }

            for (i in invalidFolderCharacters) {
                if (modFolder.contains(i) || modFolder.endsWith(".")) {
                    FlxG.sound.play(Paths.sound('cancelMenu'));
                    return; // invalid folder character
                }
            }

            var createFunc = () -> {
                ModsSetupState.setupModFolder(modFolder);

                var _jsonData = copyJson(DEFAULT_MOD);
                _jsonData.id = modIdInput.text;
                _jsonData.name = modNameInput.text;
                _jsonData.description = modDescInput.text;
                _jsonData.restart = restartCheck.checked;
                _jsonData.runsGlobally = globalCheck.checked;
                _jsonData.color = [Std.parseInt(modColorInputR.text), Std.parseInt(modColorInputG.text), Std.parseInt(modColorInputB.text)];

                var _jsonStr = Json.stringify(_jsonData, "\t");
                File.saveContent('mods/$modFolder/pack.json', _jsonStr);
                FlxG.sound.play(Paths.sound('confirmMenu'));
            }

            if (FileSystem.exists('mods/$modFolder')) {
                FlxG.state.openSubState(new Prompt("Mod folder $modFolder already exists!\nAre you sure you want tooverwrite this folder?", 
                    0, () -> {
                        createFunc();
                        FlxG.state.closeSubState();
                    }, () -> {
                        FlxG.state.closeSubState();
                    }));
            }
            else
                createFunc();
        });
        tabGroup.add(createButton);

        restartCheck = new FlxUICheckBox(25, 300, null, null, "Restart");
        restartCheck.checked = false;
        tabGroup.add(restartCheck);

        globalCheck = new FlxUICheckBox(25, 325, null, null, "Global Mod");
        globalCheck.checked = false;
        tabGroup.add(globalCheck);
    }

    function addToGroup(object:Dynamic, txt:String = "", focusPush:Bool = false) 
    {
        if (focusPush && object is FlxUIInputText) focusList.push(object);
        if (txt.length > 0) tabGroup.add(new FlxText(object.x, object.y - 15, txt));
        tabGroup.add(object);
    }

    function copyJson<T>(c:T):T
        return haxe.Unserializer.run(haxe.Serializer.run(c));
}

class ModsSetupState extends MusicBeatState
{
    var modTab:ModSetupTabs;

    override function create()
    {
        FlxG.mouse.visible = true;
        FlxG.sound.music.fadeIn(4, 0, 0.7);
		FlxG.sound.playMusic(Paths.music('breakfast'), 1);

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
        bg.scrollFactor.set();
        add(bg);

        modTab = new ModSetupTabs();
        add(modTab);

        super.create();
    }

    public static var modFolderDirs(default, never):Map<String, Array<String>> = [
        "achievements" => [],
        "gamechangers" => [],
        "options" => [],
        "scripts" => [],
        "shaders" => [],
        "videos" => [],
        "sounds" => [],
        "images" => ["achievements", "characters", "credits", "dialogue", "icons", "mainmenu", "menubackgrounds", "menucharacters", "menudifficulties", "storymenu"],
        "music" => [],
        "fonts" => [],
        "data" => [],
        "weeks" => [],
        "stages" => [],
        "songs" => [],
        "characters" => [],
        "notetypes" => [],
        "events" => [],
        "locales" => ["images", "sounds"],
        "_append" => ["data"]
    ];

    public static function setupModFolder(name:String)
    {
        for (k in modFolderDirs.keys())
        {
            var keyArr = modFolderDirs.get(k);
            createFolderWithTxt('$name/$k');
            for (i in keyArr) createFolderWithTxt('$name/$k/$i');
        }
    }

    static function createFolderWithTxt(path:String)
    {
        var pathParts = path.split("/");
        createFolder(path);
        File.saveContent('mods/$path/${pathParts[pathParts.length - 1]}-go-here.txt', "");
    }

    public static function createFolder(path:String, prefix:String = "mods/") 
    {
        var dirs = path.split("/");
        var lastDir = prefix;
        for (i in dirs) {
            final _ext = haxe.io.Path.extension(i);
            if (i == null || (_ext.length != 0 && !_ext.contains(" "))) continue;
            lastDir += '$i/';
            if (!FileSystem.exists(lastDir))
                FileSystem.createDirectory(lastDir);
        }
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (modTab.getFocus()) return;

        if (controls.BACK) 
        {
            FlxG.switchState(() -> new MasterEditorMenu());
            FlxG.sound.playMusic(Paths.music('freakyMenu'));
            FlxG.sound.play(Paths.sound('cancelMenu'));
            FlxG.mouse.visible = false;
        }
    }
}