function onSongStart()
	
if getPropertyFromClass('PlayState', 'isPixelStage') == true then
		for i = 0, getProperty('unspawnNotes.length')-1 do
			setPropertyFromGroup('unspawnNotes', i, 'noteSplashTexture', 'pixelSplashes');
		end
		for i = 0, getProperty('grpNoteSplashes.length')-1 do
			setPropertyFromGroup('grpNoteSplashes', i, 'offset.x', '-50')
		end
end

end

--[[

for i = 0, getProperty('grpNoteSplashes.length')-1 do
        setPropertyFromGroup('grpNoteSplashes', i, 'offset.x', '-10')

]]--