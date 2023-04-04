function onCreate()
	setPropertyFromClass("openfl.Lib", "application.window.title", "Friday Night Funkin': Joalor64 Engine Rewritten - NOW PLAYING: " .. (songName))
end
function onDestroy()
	setPropertyFromClass("openfl.Lib", "application.window.title", "Friday Night Funkin': Joalor64 Engine Rewritten")
end
