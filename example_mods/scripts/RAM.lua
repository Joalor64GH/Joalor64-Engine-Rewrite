--CODE BY JUNIORNOVOA (THIS SAVED ME 700MB RAM ON LORE)

function onCreate()
	addHaxeLibrary('System', 'openfl.system')
	clearCache();
end

function onCreatePost()
	if getProperty('boyfriend.antialiasing') == true then --no point if antialiasing is off
		setProperty('boyfriend.antialiasing', getPropertyFromClass('ClientPrefs', 'globalAntialiasing'));
	end

	if getProperty('dad.antialiasing') == true then --no point if antialiasing is off
		setProperty('dad.antialiasing', getPropertyFromClass('ClientPrefs', 'globalAntialiasing'));
	end

	if getProperty('gf.antialiasing') == true then --no point if antialiasing is off
		setProperty('gf.antialiasing', getPropertyFromClass('ClientPrefs', 'globalAntialiasing'));
	end
end

function onUpdate()
	--[[
	if getProperty('boyfriend.antialiasing') == true then --no point if antialiasing is off
		setProperty('boyfriend.antialiasing', getPropertyFromClass('ClientPrefs', 'globalAntialiasing'));
	end
	
	if getProperty('dad.antialiasing') == true then --no point if antialiasing is off
		setProperty('dad.antialiasing', getPropertyFromClass('ClientPrefs', 'globalAntialiasing'));
	end
	
	if getProperty('gf.antialiasing') == true then --no point if antialiasing is off
		setProperty('gf.antialiasing', getPropertyFromClass('ClientPrefs', 'globalAntialiasing'));
	end
	
	for i = 0, 4, 1 do --actually causes framerate drop + not needed
		if getPropertyFromGroup('playerStrums', i, 'antialiasing') == true then --no point if antialiasing is off
			setPropertyFromGroup('playerStrums', i, 'antialiasing', getPropertyFromClass('ClientPrefs', 'globalAntialiasing'))
			playerDones[i] = true;
		end

		if getPropertyFromGroup('opponentStrums', i, 'antialiasing') == true then --no point if antialiasing is off
			setPropertyFromGroup('opponentStrums', i, 'antialiasing', getPropertyFromClass('ClientPrefs', 'globalAntialiasing'))
			opponentDones[i] = true;
		end
	end

	for i = 0, getProperty('notes.length') -1 do
		if getPropertyFromGroup('notes', i, 'antialiasing') == true then --no point if antialiasing is off
			setPropertyFromGroup('notes', i, 'antialiasing', getPropertyFromClass('ClientPrefs', 'globalAntialiasing'))
		end
	end

	for i = 0, getProperty('unspawnNotes.length') -1 do
		if getPropertyFromGroup('unspawnNotes', i, 'antialiasing') == true then --no point if antialiasing is off
			setPropertyFromGroup('unspawnNotes', i, 'antialiasing', getPropertyFromClass('ClientPrefs', 'globalAntialiasing'))
		end
	end
	--]]
end

function onEvent(tag, val1, val2)
	if tag == 'Change Character' then
		if getProperty('boyfriend.antialiasing') == true then --no point if antialiasing is off
			setProperty('boyfriend.antialiasing', getPropertyFromClass('ClientPrefs', 'globalAntialiasing'));
		end
	
		if getProperty('dad.antialiasing') == true then --no point if antialiasing is off
			setProperty('dad.antialiasing', getPropertyFromClass('ClientPrefs', 'globalAntialiasing'));
		end
	
		if getProperty('gf.antialiasing') == true then --no point if antialiasing is off
			setProperty('gf.antialiasing', getPropertyFromClass('ClientPrefs', 'globalAntialiasing'));
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