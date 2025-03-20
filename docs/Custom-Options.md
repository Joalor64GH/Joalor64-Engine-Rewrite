# THIS PAGE IS OUTDATED!! REFER TO https://github.com/ShadowMario/FNF-PsychEngine/pull/12307

I don't have a lot of information on this, so I'll try my best to explain.

## Basic Explanation
Your custom options have to be stored in a `.json` file.

This is an example:
```json
{
	"name": "Modifier",
	"description": "This amplifies stuff.",
	"saveKey": "modifierCool",
	"type": "bool",
	"defaultValue": false,
        "options": null,
        "minValue": null,
	"maxValue": null,
	"changeValue": null,
        "scrollSpeed": null,
        "displayFormat": ""
}
```

## JSON Variables

* `name` - Obviously the name of the option.
* `description` - The description of the option.
* `saveKey` - The option's save tag.
* `type` - The variable type (e.g. `bool`, `int`).
* `defaultValue` - The default value of your option (e.g. `true`, `false`).
* `options` - This variable is used only if `type` is `string`. It just gives an option a bunch of other options.
* `minValue` - Minimum value.
* `maxValue` - Maximum value.
* `changeValue` - How much the value should change.
* `scrollSpeed` - The scroll speed for your option.
* `displayFormat` - How the data is displayed.

## More Information
If your custom option exists, it will be displayed in "Mod Options".

And it will be located in "Global".

If you make a mod and then put your custom option there, it will be displayed like this:
 
![](https://user-images.githubusercontent.com/99079926/219513712-632e3e7d-0c8a-4b80-a14e-2e98fae576a4.png?raw=true)