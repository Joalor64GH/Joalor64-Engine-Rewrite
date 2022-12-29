function onUpdate()
        
        getPropertyFromClass('flixel.input', 'FlxKey') --Basically lets the script figure out what button you are pressing.
    
        if keyJustPressed('space') then --self explanatory 
        triggerEvent('Play Animation', 'hey', 'BF') 
        
        --characterPlayAnim('boyfriend', 'hey', true);         --This one works as well but whenever I pressed space it would cancel the animation midway sometimes.
        --boyfriend.specialAnim = true;
	--boyfriend.heyTimer = time;
        end
end