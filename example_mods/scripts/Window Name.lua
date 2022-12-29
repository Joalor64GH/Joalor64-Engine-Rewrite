function onCreate()
	setPropertyFromClass("openfl.Lib", "application.window.title", "Friday Night Funkin': Joalor64 Engine Rewritten - NOW PLAYING: " .. (songName))
end
function onDestroy()
	setPropertyFromClass("openfl.Lib", "application.window.title", "Friday Night Funkin': Joalor64 Engine Rewritten")
end
function onCreatePost()
	if songName == 'Too Slow Encore' then
		if difficulty == 0 then
			setPropertyFromClass("openfl.Lib", "application.window.title", "Now Playing Too Slow Encore - Baby")
		elseif difficulty == 1 then
			setPropertyFromClass("openfl.Lib", "application.window.title", "Now Playing Too Slow Encore - Hardnt")
		elseif difficulty == 2 then
			setPropertyFromClass("openfl.Lib", "application.window.title", "Now Playing Too Slow Encore - Encore")
		elseif difficulty == 3 then
			setPropertyFromClass("openfl.Lib", "application.window.title", "Now Playing Too Slow Encore - Flipped")
		elseif difficulty == 4 then
			setPropertyFromClass("openfl.Lib", "application.window.title", "Now Playing Too Slow Encore - New")
		end
	end
end