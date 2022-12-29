local FreezeTime=false
local Stored=0

local HasBG = true
local BG_Color = '004FFF'
local Panel_Color = '004FFF'
local FontSize=65
local MiscFontSize = 65
local ScoreFontSize = 100

local CounterMoveInTime = 0.5

local BestCombo = 0
local ComboCount = 0

local Rank='F'

function onCreate()
	
	makeLuaSprite('GradientFadeIn', 'EndScreenGradient', 0, 0)
	makeLuaSprite('ColorBgSlider', 'EndScreenBG', 3280, 0)
	makeLuaSprite('PanelSlider', 'EndScreenPanel', -2000, 0)
	makeLuaSprite('Vicotory', 'EndScreen_Vicotory', 0, -720)
	
	makeLuaSprite('RatingsSick', 'EndRatings_Sick', -1000, 144*0)
	makeLuaSprite('RatingsGood', 'EndRatings_Good', -1000, 144*1)
	makeLuaSprite('RatingsBad', 'EndRatings_Bad', -1000, 144*2)
	makeLuaSprite('RatingsShit', 'EndRatings_Shit', -1000, 144*3)
	makeLuaSprite('RatingsMiss', 'EndRatings_Miss', -1000, 144*4)
	
	setProperty('GradientFadeIn.alpha', 0)
	setProperty('ColorBgSlider.color', getColorFromHex(BG_Color))
	setProperty('PanelSlider.color', getColorFromHex(Panel_Color))
	
	setObjectCamera('GradientFadeIn', 'other')
	setObjectCamera('ColorBgSlider', 'other')
	setObjectCamera('PanelSlider', 'other')
	setObjectCamera('Vicotory', 'other')
	
	setObjectCamera('RatingsSick', 'other')
	setObjectCamera('RatingsGood', 'other')
	setObjectCamera('RatingsBad', 'other')
	setObjectCamera('RatingsShit', 'other')
	setObjectCamera('RatingsMiss', 'other')
	
	
	if HasBG==true then
		addLuaSprite('ColorBgSlider',true)
	end
	addLuaSprite('GradientFadeIn',true)
	addLuaSprite('PanelSlider',true)
	addLuaSprite('RatingsSick',true)
	addLuaSprite('RatingsGood',true)
	addLuaSprite('RatingsBad',true)
	addLuaSprite('RatingsShit',true)
	addLuaSprite('RatingsMiss',true)
	
	addLuaSprite('Vicotory',true)

	--note 2 self: the text goes at 300x
	makeLuaText('EndScreen_Score', 'Text', 500, 700, -500)
	makeLuaText('EndScreen_Sick', 'Text', 500, -1000, 144-FontSize)
	makeLuaText('EndScreen_Good', 'Text', 500, -1000, (144*2)-FontSize)
	makeLuaText('EndScreen_Bad', 'Text', 500, -1000, (144*3)-FontSize)
	makeLuaText('EndScreen_Shit', 'Text', 500, -1000, (144*4)-FontSize)
	makeLuaText('EndScreen_Miss', 'Text', 500, -1000, (144*5)-FontSize)
	
	setObjectCamera('EndScreen_Score', 'other')
	setObjectCamera('EndScreen_Sick', 'other')
	setObjectCamera('EndScreen_Good', 'other')
	setObjectCamera('EndScreen_Bad', 'other')
	setObjectCamera('EndScreen_Shit', 'other')
	setObjectCamera('EndScreen_Miss', 'other')
	
	setTextAlignment('EndScreen_Score', 'center')
	setTextAlignment('EndScreen_Sick', 'left')
	setTextAlignment('EndScreen_Good', 'left')
	setTextAlignment('EndScreen_Bad', 'left')
	setTextAlignment('EndScreen_Shit', 'left')
	setTextAlignment('EndScreen_Miss', 'left')
	
	setTextSize('EndScreen_Score', ScoreFontSize)
	setTextSize('EndScreen_Sick', FontSize)
	setTextSize('EndScreen_Good', FontSize)
	setTextSize('EndScreen_Bad', FontSize)
	setTextSize('EndScreen_Shit', FontSize)
	setTextSize('EndScreen_Miss', FontSize)

	addLuaText('EndScreen_Score')
	addLuaText('EndScreen_Sick')
	addLuaText('EndScreen_Good')
	addLuaText('EndScreen_Bad')
	addLuaText('EndScreen_Shit')
	addLuaText('EndScreen_Miss')
	
	makeLuaText('EndPromptThing', 'Press [SPACE] to Continue', 500, 700, 1000)
	setObjectCamera('EndPromptThing', 'other')
	setTextAlignment('EndPromptThing', 'center')
	setTextSize('EndPromptThing', MiscFontSize)
	addLuaText('EndPromptThing')
	
	makeLuaText('BestComboText', 'BestCombo-'..BestCombo, 500, 700, -500)
	setObjectCamera('BestComboText', 'other')
	setTextAlignment('BestComboText', 'center')
	setTextSize('BestComboText', MiscFontSize)
	addLuaText('BestComboText')
end

function onStepHit()
	if getPropertyFromClass('flixel.FlxG', 'sound.music.time') >= songLength-1000  then --checks if theres 1 second left in the song
		triggerEvent('Play Animation', 'RatingScreen','')
		SeenRatingScreen=true
	end
end

function onEvent(name, value1, value2)
	-- event note triggered
	-- triggerEvent() does not call this function!!
	if name == 'Play Animation' and value1 == 'RatingScreen' then
	
		StoreTime()
		FreezeTime=true
		playMusic('breakfast', 0.3, true)
		setProperty('boyfriend.stunned', true)
		
		doTweenAlpha('EndFadeIn', 'GradientFadeIn', 1, 1, 'circInOut')
		doTweenX('PanelSlideIn', 'PanelSlider', 0, 1, 'circInOut')
		doTweenX('BgSlideIn', 'ColorBgSlider', 0, 1, 'circInOut')
		doTweenAlpha('BgFadeIn', 'ColorBgSlider', 1, 1, 'circInOut')
		doTweenY('VicotoryScroll', 'Vicotory', 0, 1, 'circInOut')
		
		runTimer('CountSick', 0.1, 10)
		runTimer('CountScore', 6, 1)
		
		setTextString('EndScreen_Score', getProperty('songScore'))
		doTweenY('ScoreScrollY', 'EndScreen_Score', 115, 1, 'circInOut')
		doTweenX('ScoreScrollX', 'EndScreen_Score', 700, 1, 'circInOut')
		
		setTextString('BestComboText', 'BestCombo:'..'\n'..BestCombo)
		doTweenY('BestComboScrollY', 'BestComboText', 200, 1, 'circInOut')
		doTweenX('BestComboScrollX', 'BestComboText', 700, 1, 'circInOut')
		
		GrabRatings()
		makeLuaSprite('RankThingy', 'Ranking_'..Rank, 2000, 350)
		setObjectCamera('RankThingy', 'other')
		addLuaSprite('RankThingy', true)
		doTweenX('RankMoveIn', 'RankThingy', 800, 0.5, 'circInOut')
		
	end
	-- print('Event triggered: ', name, value1, value2);
end

local FunniArrayOne={'Sick', 'Good', 'Bad', 'Shit', 'Miss'}
local FunniArrayTwo={'sicks', 'goods', 'bads', 'shits', 'songMisses'}
local Type = 1
function onTimerCompleted(tag, loops, loopsLeft)
	-- A loop from a timer you called has been completed, value "tag" is it's tag
	-- loops = how many loops it will have done when it ends completely
	-- loopsLeft = how many are remaining
	if tag == 'Count'..FunniArrayOne[Type] then
		playSound('scrollMenu', 0.35)
		if loopsLeft==1 then
			doTweenX(FunniArrayOne[Type]..'Slide', 'Ratings'..FunniArrayOne[Type], 0, CounterMoveInTime, 'circInOut')
			setTextString('EndScreen_'..FunniArrayOne[Type], getProperty(FunniArrayTwo[Type]))
			doTweenX(FunniArrayOne[Type]..'TextSlide', 'EndScreen_'..FunniArrayOne[Type], 300, CounterMoveInTime, 'circInOut')
			playSound('confirmMenu',0.35)
			cancelTimer('Count'..FunniArrayOne[Type])
			Type=Type+1
			runTimer('Count'..FunniArrayOne[Type], 0.1, 10)
			
			if tag == 'CountMiss' then
				
			end
		end
	end
end

function StoreTime()
	-- Stores the time
	Stored = getPropertyFromClass('flixel.FlxG', 'sound.music.time')
	setPropertyFromClass('flixel.FlxG', 'sound.music.volume',1)
	setProperty('vocals.volume',1)
end

function onUpdate()
	if FreezeTime==true then
		setPropertyFromClass('Conductor', 'songPosition',Stored)
		setPropertyFromClass('flixel.FlxG', 'sound.music.time',Stored)
		setProperty('vocals.time',Stored)
		setPropertyFromClass('flixel.FlxG', 'sound.music.volume',0)
		setProperty('vocals.volume',0)
	end
	if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.SPACE') and FreezeTime==true then
		FreezeTime=false
		SeenRatingScreen=true
		playSound('dialogueClose',0.35)
		endSong()
	end
end

function GrabRatings()
	if rating == 1 then
		Rank='S'
	elseif rating >= 0.9 and rating < 1 then
		Rank='A'
	elseif rating >= 0.8 and rating < 0.9 then
		Rank='B'
	elseif rating >= 0.7 and rating < 0.8 then
		Rank='C'
	elseif rating >= 0.6 and rating < 0.7 then
		Rank='D'
	elseif rating >= 0.5 and rating < 0.6 then
		Rank='F'
	end
end

function goodNoteHit(id, direction, noteType, isSustainNote)
	-- Function called when you hit a note (after note hit calculations)
	-- id: The note member id, you can get whatever variable you want from this note, example: "getPropertyFromGroup('notes', id, 'strumTime')"
	-- noteData: 0 = Left, 1 = Down, 2 = Up, 3 = Right
	-- noteType: The note type string/tag
	-- isSustainNote: If it's a hold note, can be either true or false
	if not isSustainNote then
		ComboCount=ComboCount+1
	end
	if ComboCount > BestCombo then
		BestCombo=ComboCount
	end
end

function noteMissPress(direction)
	-- Called after the note press miss calculations
	-- Player pressed a button, but there was no note to hit (ghost miss)
	ComboCount=0
end

function noteMiss(id, direction, noteType, isSustainNote)
	-- Called after the note miss calculations
	-- Player missed a note by letting it go offscreen
	ComboCount=0
end