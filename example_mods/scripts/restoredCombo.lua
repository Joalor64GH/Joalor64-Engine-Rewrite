-- combo script by stilic
-- credit if used please!
-- FUNCTIONS STOLEN FROM STACKOVERFLOW
function string.starts(str, start)
    return string.sub(str, 1, string.len(start)) == start
end
function string.split(str, sep)
    if sep == nil then sep = "%s" end
    local t = {}
    for str in string.gmatch(str, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

local count = 0

function goodNoteHit(id, direction, noteType, isSustainNote)
    if not hideHud and not isSustainNote and getProperty('combo') > 9 then
        count = count + 1

        -- lot of vars but shut up i know we need these
        local tag = 'combo' .. count
        local offset = getPropertyFromClass('ClientPrefs', 'comboOffset')

        local pixel = getPropertyFromClass('PlayState', 'isPixelStage')
        local pixelShitPart1 = ''
        local pixelShitPart2 = ''
        local scaleShit = 0.7
        local antialiasing = getPropertyFromClass('ClientPrefs',
                                                  'globalAntialiasing')
        if pixel then
            pixelShitPart1 = 'pixelUI/'
            pixelShitPart2 = '-pixel'
            scaleShit = getPropertyFromClass('PlayState', 'daPixelZoom') * 0.85
            antialiasing = false
        end

        -- pixel style is great too
        makeLuaSprite(tag, pixelShitPart1 .. 'combo' .. pixelShitPart2, 0, 0)
        scaleObject(tag, scaleShit, scaleShit)
        updateHitbox(tag)

        -- i wanted to put that after ratio var but psych don't let me do that
        screenCenter(tag, 'y')

        -- my brain told me to fix the offsets as fast as i can
        local ox = screenWidth * 0.35 + getProperty(tag .. '.width') / 4.1
        local oy = getProperty(tag .. '.y') + getProperty(tag .. '.height') /
                       1.45
        if pixel then
            ox = ox + 3
            oy = oy + 10
        else
            ox = ox - 14
            oy = oy / 1.2
        end
        setProperty(tag .. '.x', ox + offset[1])
        setProperty(tag .. '.y', oy - offset[2])

        -- box2d based??? dik
        setProperty(tag .. '.acceleration.y', 600)
        setProperty(tag .. '.velocity.y', getProperty(tag .. '.velocity.y') -
                        150 + math.random(1, 10))

        setProperty(tag .. '.antialiasing', antialiasing)
        setObjectCamera(tag, 'hud')
        addLuaSprite(tag)
        setObjectOrder(tag, getObjectOrder('strumLineNotes') - 1)

        -- fuck psych doesn't support startDelay so i use a timer instead
        runTimer(tag .. ',timer', crochet * 0.001)
    end
end

function onTimerCompleted(tag)
    if string.starts(tag, 'combo') then
        -- funni split moment
        local leObj = string.split(tag, ',')[1]
        doTweenAlpha(leObj .. ',tween', leObj, 0, 0.2, 'linear')
    end
end

function onTweenCompleted(tag)
    if string.starts(tag, 'combo') then
        removeLuaSprite(string.split(tag, ',')[1])
    end
end
