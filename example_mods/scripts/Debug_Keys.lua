dancing = false
danced = false
canback = false
function onUpdatePost(elapsed)
	if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.F1') and not getProperty('startingSong') then
		endSong()
	elseif getPropertyFromClass('flixel.FlxG', 'keys.justPressed.F2') and not getProperty('startingSong') then
		setPropertyFromClass('Conductor', 'songPosition', getPropertyFromClass('Conductor', 'songPosition') + 10000) 
		setPropertyFromClass('flixel.FlxG', 'sound.music.time', getPropertyFromClass('Conductor', 'songPosition'))
		setProperty('vocals.time', getPropertyFromClass('Conductor', 'songPosition'))
		--debugPrint("Skipped 10 Seconds")
	elseif canback and getPropertyFromClass('flixel.FlxG', 'keys.justPressed.F3') and not getProperty('startingSong') then
		setPropertyFromClass('Conductor', 'songPosition', getPropertyFromClass('Conductor', 'songPosition') - 10000) 
		setPropertyFromClass('flixel.FlxG', 'sound.music.time', getPropertyFromClass('Conductor', 'songPosition'))
		setProperty('vocals.time', getPropertyFromClass('Conductor', 'songPosition'))
		dancing = true
		--debugPrint("Backed 10 Seconds")
		characterDance('gf')
		characterDance('boyfriend')
		characterDance('dad')
	elseif getPropertyFromClass('flixel.FlxG', 'keys.justPressed.F4') then
		if not getProperty('cpuControlled') then
			setProperty('cpuControlled', true)
			debugPrint("botPlay On")
			setProperty('botplayTxt.visible', true)
		else
			setProperty('cpuControlled', false)
			setProperty('botplayTxt.visible', false)
			debugPrint("botPlay Off")
		end
	elseif getPropertyFromClass('flixel.FlxG', 'keys.justPressed.F5') then
		setProperty('cameraSpeed', getProperty('cameraSpeed') + 0.5)
		debugPrint("cameraSpeed = ", getProperty('cameraSpeed'))
	elseif getPropertyFromClass('flixel.FlxG', 'keys.justPressed.F6') then
		setProperty('cameraSpeed', getProperty('cameraSpeed') - 0.5)
		debugPrint("cameraSpeed = ", getProperty('cameraSpeed'))
	elseif getPropertyFromClass('flixel.FlxG', 'keys.justPressed.F7') then
		debugPrint("scrollSpeed = ", getProperty('songSpeed'))
		setProperty('songSpeed', getProperty('songSpeed') + 0.1)
	elseif getPropertyFromClass('flixel.FlxG', 'keys.justPressed.F8') then
		debugPrint("scrollSpeed = ", getProperty('songSpeed'))
		setProperty('songSpeed', getProperty('songSpeed') - 0.1)
	elseif getPropertyFromClass('flixel.FlxG', 'keys.justPressed.F9') then
		setProperty('defaultCamZoom', getProperty('defaultCamZoom') + 0.1)
		doTweenZoom('c', 'camGame', getProperty('defaultCamZoom') + 0.01, 0.05, 'linear')
	elseif getPropertyFromClass('flixel.FlxG', 'keys.justPressed.F10') then
		setProperty('defaultCamZoom', getProperty('defaultCamZoom') - 0.1)
		doTweenZoom('c', 'camGame', getProperty('defaultCamZoom') - 0.01, 0.05, 'linear')
	end
end

function onStepHit()
	if dancing then
		if curStep % 4 == 0 then
			characterDance('gf')
			characterDance('boyfriend')
			characterDance('dad')
		end
	end
end

function goodNoteHit(id, direction, noteType, isSustainNote)
	dancing = false
	canback = true
end

function opponentNoteHit(id, direction, noteType, isSustainNote)
	dancing = false
	canback = true
end