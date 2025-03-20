ToastCore is basically used for when you want to make an error/warning message appear.

It's actually incredibly simple.

Example:
```hx
case 'mods':
	if (ModCore.trackedMods != [])
		MusicBeatState.switchState(new ModsMenuState());
	else
		Main.toast.create('No Mods Installed!', 0xFFFFFF00, 'Please add mods to be able to access the menu!');
```
## Message Template
If you want to use it, simply copy-and-paste this text:
```hx
Main.toast.create('Title', 0xFFFFFF00, 'Description');
```