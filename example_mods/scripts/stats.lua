--[[
    Rating squares made by SameTheta!
    Credit me if you use it in a mod!
]]


--makes creating text easier
function createText(tag, text, width, x, y, size, align)
    makeLuaText(tag, text, width, x, y)
    setTextSize(tag, size)
    setTextAlignment(tag, align)
    addLuaText(tag)
end

--makes creating squares easier
function createSquare(tag, x, y, color)
    makeLuaSprite(tag, '', x, y)
    makeGraphic(tag, x, y, color)
    setObjectCamera(tag, 'camHUD')
    addLuaSprite(tag)
end

--universal vars
--fuck tables all my homies hate tables
ratingNames = {'sick', 'good', 'bad', 'shit'}

-- for the animations on goodNoteHit()
bSicks = 0
bGoods = 0
bBads = 0
bShits = 0

function getColorByRating(fRating)
    if fRating == 'sick' then
        return '97ffff'
    elseif fRating == 'good' then
        return '8ef496'
    elseif fRating == 'bad' then
        return 'dc7487'
    elseif fRating == 'shit' then
        return 'db1f42'
    end
end

function onCreatePost()
    isOnRight = true

    local squY = 175
    local BOX_SCALE = 0.8

    if middlescroll and isOnRight then
        UNIVERSAL_X = 315
    elseif middlescroll then
        UNIVERSAL_X = 875
    elseif isOnRight then
        UNIVERSAL_X = -5
    else
        UNIVERSAL_X = 1185
    end

    -- creates all the shit that dont change
    --[[ 
        squares = sick, good, bad, shit
        text = sickText/sickCounter, goodText/goodCounter badText/badCounter shitText/shitCounter
     ]]
    for k,v in pairs(ratingNames) do
        createSquare(v, 100, 100, '000000')
        createSquare(v.. 'BG', 100, 100, getColorByRating(v))
        createText(v.. 'Text', v, 100, UNIVERSAL_X, (squY + 15), 18, 'center')
        createText(v.. 'Counter', '0', 100, UNIVERSAL_X, (squY + 40), 33, 'center')

        setObjectOrder(v, 10)
        setObjectOrder(v.. 'BG', 11)
        --actual boxes
        setProperty(v .. '.x', UNIVERSAL_X)
        setProperty(v .. '.y', squY)
        setProperty(v .. '.alpha', 0.5)
        setProperty(v .. '.scale.x', BOX_SCALE); setProperty(v .. '.scale.y', BOX_SCALE)
        --bg boxes
        setProperty(v .. 'BG.x', UNIVERSAL_X)
        setProperty(v .. 'BG.y', squY)
        setProperty(v .. 'BG.alpha', 0)
        setProperty(v .. 'BG.scale.x', BOX_SCALE); setProperty(v .. 'BG.scale.y', BOX_SCALE)
        squY = squY + 90
    end

    sickY = getProperty('sickCounter.y')
    goodY = getProperty('goodCounter.y')
    badY = getProperty('badCounter.y')
    shitY = getProperty('shitCounter.y')
end

function goodNoteHit(id, noteData, noteType, isSustainNote)
    for q,b in pairs(ratingNames) do
        setTextString(b.. 'Counter', getProperty(b..'s'))
    end

    --this shit is so unoptimized i apologize to anyone seeing this
    if getProperty('sicks') > bSicks and not isSustainNote then
        setProperty('sickCounter.y', getProperty('sickCounter.y') - 10)
        doTweenY('sickCounterTween', 'sickCounter', sickY, 0.25, 'circOut')
        setProperty('sickBG.alpha', 1)
        doTweenAlpha('sickBGAlpha', 'sickBG', 0, 0.25, 'quadIn')
        bSicks = getProperty('sicks')
    end

    if getProperty('goods') > bGoods and not isSustainNote then
        setProperty('goodCounter.y', getProperty('goodCounter.y') - 10)
        doTweenY('goodCounterTween', 'goodCounter', goodY, 0.25, 'circOut')
        setProperty('goodBG.alpha', 1)
        doTweenAlpha('goodBGAlpha', 'goodBG', 0, 0.25, 'quadIn')
        bGoods = getProperty('goods')
    end

    if getProperty('bads') > bBads and not isSustainNote then
        setProperty('badCounter.y', getProperty('badCounter.y') - 10)
        doTweenY('badCounterTween', 'badCounter', badY, 0.25, 'circOut')
        setProperty('badBG.alpha', 1)
        doTweenAlpha('badBGAlpha', 'badBG', 0, 0.25, 'quadIn')
        bBads = getProperty('bads')
    end
    
    if getProperty('shits') > bShits and not isSustainNote then
        setProperty('shitCounter.y', getProperty('shitCounter.y') - 10)
        doTweenY('shitCounterTween', 'shitCounter', shitY, 0.25, 'circOut')
        setProperty('shitBG.alpha', 1)
        doTweenAlpha('shitAlpha', 'shitBG', 0, 0.25, 'quadIn')
        bShits = getProperty('shits')
    end
end