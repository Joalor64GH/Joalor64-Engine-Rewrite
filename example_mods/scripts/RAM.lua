--CODE BY JUNIORNOVOA (THIS SAVED ME 700MB RAM ON LORE)

function onCreate()
	addHaxeLibrary('System', 'openfl.system')
	clearCache();
end

function onCreatePost()
	if getProperty('boyfriend.antialiasing') == true then --no point if antialiasing is off
		setProperty('boyfriend.antialiasing', getPropertyFromClass('meta.data.ClientPrefs', 'globalAntialiasing'));
	end

	if getProperty('dad.antialiasing') == true then --no point if antialiasing is off
		setProperty('dad.antialiasing', getPropertyFromClass('meta.data.ClientPrefs', 'globalAntialiasing'));
	end

	if getProperty('gf.antialiasing') == true then --no point if antialiasing is off
		setProperty('gf.antialiasing', getPropertyFromClass('meta.data.ClientPrefs', 'globalAntialiasing'));
	end
end

function onUpdate()
	--[[
	do nothing lmao
	--]]
end

function onEvent(tag, val1, val2)
	if tag == 'Change Character' then
		if getProperty('boyfriend.antialiasing') == true then --no point if antialiasing is off
			setProperty('boyfriend.antialiasing', getPropertyFromClass('meta.data.ClientPrefs', 'globalAntialiasing'));
		end
	
		if getProperty('dad.antialiasing') == true then --no point if antialiasing is off
			setProperty('dad.antialiasing', getPropertyFromClass('meta.data.ClientPrefs', 'globalAntialiasing'));
		end
	
		if getProperty('gf.antialiasing') == true then --no point if antialiasing is off
			setProperty('gf.antialiasing', getPropertyFromClass('meta.data.ClientPrefs', 'globalAntialiasing'));
		end
	end
end

function onGameOver()
	clearCache();
end

function onEndSong()
	clearCache();
end

function clearCache()
	runHaxeCode([[
		openfl.system.System.gc();
	]])
end