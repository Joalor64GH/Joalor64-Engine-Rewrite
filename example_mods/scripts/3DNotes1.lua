function onUpdate(elapsed)
	if getProperty('health') > 0.06 then
		if dadName == 'Barbu' then --replace the name for your character name
			for i=0,4,1 do
				setPropertyFromGroup('opponentStrums', i, 'texture', 'NOTE_assets_3D')
			end
			for i = 0, getProperty('unspawnNotes.length')-1 do
				if not getPropertyFromGroup('unspawnNotes', i, 'mustPress') then
					setPropertyFromGroup('unspawnNotes', i, 'texture', 'NOTE_assets_3D'); --Change texture
				end
			end
		end
	end
end