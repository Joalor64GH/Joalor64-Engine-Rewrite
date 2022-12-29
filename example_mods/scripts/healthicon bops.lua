local angleshit = -1

function onBeatHit()
	if getProperty('curBeat') % 1 == 0 then
			setProperty('iconP1.angle',angleshit*30)
			setProperty('iconP2.angle',angleshit*-30)
			doTweenAngle('hr', 'iconP1', 0, 0.5, 'circOut')
			doTweenAngle('hrr', 'iconP2', 0, 0.5, 'circOut')
	    end
	if getProperty('curBeat') % 2 == 0 then
			setProperty('iconP1.angle',angleshit*-30)
			setProperty('iconP2.angle',angleshit*30)
			doTweenAngle('hr', 'iconP1', 0, 0.5, 'circOut')
			doTweenAngle('hrr', 'iconP2', 0, 0.5, 'circOut')
		end
end

