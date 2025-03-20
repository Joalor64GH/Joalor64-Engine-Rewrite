To make a custom achievement, you'll need a `.json` and `.lua` file.

This is an example for `.json`:
```json
{
	"name": "Road to Ten Million",
	"desc": "Gain 10 Million scores in total.",
	"save_tag": "ten_million",
	"hidden": false,
	"clearAchievements": true,
        "week_nomiss": null,
        "lua_code": null,
	"global": null,
	"index": -1,
        "song": ""
}
```
And this is an example for `.lua` (optional):
```lua
function onUpdate(elapsed) 
  if getProperty("songScore") >= 10000000 then
    giveAchievement("ten_million")
   -- will return "Unlocked Achievement ten_million" if this achievement is not unlocked
   -- if it is already unlocked, it will return "Achievement ten_million is already unlocked!"
   -- if the achievement does not exist, it will return "Achievement ten_million does not exist"
  end
end
```
## JSON
Main Variables:

**(ALL OF THESE VARIABLES ARE IGNORED IF `global` IS NOT NULL!)**

* `name` - Obviously the name of the achievement.
* `desc` - The description for your achievement.
* `save_tag` - The save tag of the achievement. Also the file name of the achievement's icon.
* `hidden` - The visibility of your achievement. Remains invisible until it's unlocked if it's `true`.
* `index` - If this variable is null or `-1`, it'll get added to end of the achievements.
* `song` - If this variable is not null, your achievement will only be unlockable in that specific song.

Optional Variables:

**(WARNING: THESE VARIABLES ARE DANGEROUS AND UNSTABLE. USE CAREFULLY.)**

* `clearAchievements` - Clears all of the achievements if true. **(SHOULD BE USED ONLY ONCE IN A MODPACK.)**
* `global` - This is the most dangerous one. If you want to set global, remember that all of the other variables will be ignored.

If `global` is not null, it replaces ALL of the achievements. So a `.json` file with the `global` variable should be like this:
```json
{
	"name": "",
	"desc": "",
	"save_tag": "",
	"hidden": false,
	"clearAchievements": false,
	"index": null,
        "song": null,
        "global":  [
            ["Road to Ten Million", "Gain 10 Million scores in total.", "ten_million", false],
            ["Road to a Billion", "Gain 1 Billion scores in total.", "one_billion", false]
        ]
}
```

This way, achievements gets replaced with `global`. First element is name, second is description.

Third is the save tag and icon file name, fourth is visibility.

**JUST LIKE `clearAchievements`, `global` SHOULD BE ONLY USED ONCE IN A MODPACK.**
* `week_nomiss` - The week name, just put the file name of the week to it to make a "No miss" achievement.

`week_nomiss` should always end with "nomiss"! For example, if your week name is "week8" and you want
to make a beating week with no misses achievement, just write "week8_nomiss" in `week_nomiss`!

* `lua_code` - The code of the achievement. If you don't want to create a `.lua` file, just put your code in it! `lua_code` is ignored if `global` is set.

## LUA
For lua, it's nothing special, though there are some differences.

Just use `giveAchievement(Achievement's save tag)` to unlock the achievement.

If the achievement is already unlocked or the achievement doesn't exist or the `.lua` script is not an achievement script, `giveAchievement` is ignored.

## Examples

### Using `clearAchievements`
![](https://user-images.githubusercontent.com/114953508/195986967-ef650d52-b814-49c0-aaab-033986ec461c.png)

### Without `clearAchievements`
![](https://user-images.githubusercontent.com/114953508/195987407-e29c40ef-0f14-4f04-aec4-6b7f22228fa3.png)

### When `index` is 0
![](https://user-images.githubusercontent.com/114953508/195987438-7890aa70-464c-47cc-8f3f-e8e6a31b9b69.png)

### Using `global`
![](https://user-images.githubusercontent.com/114953508/195987496-076c5682-f4f9-4b26-8b88-828b5d5832a3.png)
