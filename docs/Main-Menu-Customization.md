## How it Works
This allows for custom backgrounds, positions, and even colors.

## JSON Variables
* `enableReloadKey` - Allows you to use `R` to reload the main menu.
* `centerOptions` - Centers the options.
* `aligntoCenter` - Aligns the options to the center.
* `optionX` - X position of the options.
* `optionY` - Y position of the options.
* `bgX` - X position of the background.
* `bgY` - Y position of the background.
* `scaleX` - X scale of the options.
* `scaleY` - Y scale of the options.
* `backgroundStatic` - Normal background.
* `backgroundConfirm` - Background when an option is selected.
* `colorOnConfirm` - Background color when option is selected. Uses RGB values.
* `options` - Your options.
* `links` - Your custom links. Disabled for the time being.

**If any of the values are invalid, the default values will be used instead.**

## JSON Example
```json
{	
	"enableReloadKey":true,
	"centerOptions":false,
	"alignToCenter":false,
	"optionX":300,
	"optionY":300,
	"bgX":-80,
	"bgY":0,
	"scaleX":1,
	"scaleY":1,
	"backgroundStatic":"funkay",
	"backgroundConfirm":"funkay",
	"colorOnConfirm": [
		69,
		69,
		69
	],
	"options": [
		"story_mode",
		"freeplay",
		"awards",
		"options"
	],
	"links": [
		["discord", "https://discord.com/app"],
		["twitter", "https://twitter.com"]
	]
}
```

## In-Game Example
https://user-images.githubusercontent.com/99079926/221365443-40c470e8-ad34-4297-8ae1-881148f01e2b.mp4