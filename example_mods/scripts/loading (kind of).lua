--[[
This doesn't work on Week 6 (and cutscenes in general), I've been trying to fix it for a while and I'm starting to get ticked off.
I'm coming close to deleting it altogether.
]]

local bg = 'loadingBG' -- don't touch this

local allowCountdown = false

function onStartCountdown() -- No countdown yet
    if not allowCountdown then
	    return Function_Stop
	end

	if allowCountdown then
	    return Function_Continue
	end
end

function onCreatePost() -- sprite loading
	if weekRaw ~= 6 or weekRaw ~= 7 then
		makeLuaSprite('loadingBG', 'loadingscreen/'..bg, 0, 0)
		runTimer('fadeTimer', 3.0, 1)

		addLuaSprite('loadingBG', true)
		setObjectCamera('loadingBG', 'camOther')
	end
end

function onTimerCompleted(tag) -- bye bye loading screen
    if tag == 'fadeTimer' then
	    doTweenAlpha('delete', 'loadingBG', 0, 0.5, 'backIn')
		allowCountdown = true
		startCountdown()
	end
end

function onTweenCompleted(tag) -- everything goes bye bye
    if tag == 'delete' then
	    removeLuaSprite('loadingBG', true)
	end
end