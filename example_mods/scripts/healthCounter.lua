local Counter_Size = 25 -- default: 25
local Position = 'up' -- positions: left, up, right

------------------------------------------------------------------------------------------

function onCreate()
	if not downscroll then
		if Position == 'right' then
			makeLuaText('counter',getProperty('healthBar.percent') .. '%',0,950,635)
			setTextSize('counter', Counter_Size)
			addLuaText('counter')
		elseif Position == 'up' then
			makeLuaText('counter',getProperty('healthBar.percent') .. '%',0,640,550)
			setTextSize('counter', Counter_Size)
			addLuaText('counter')
		elseif Position == 'left' then
			makeLuaText('counter',getProperty('healthBar.percent') .. '%',0,275,635)
			setTextSize('counter', Counter_Size)
			addLuaText('counter')
		end
	elseif downscroll then
		if Position == 'right' then
			makeLuaText('counter',getProperty('healthBar.percent') .. '%',0,950,70)
			setTextSize('counter', Counter_Size)
			addLuaText('counter')
		elseif Position == 'left' then
			makeLuaText('counter',getProperty('healthBar.percent') .. '%',0,275,70)
			setTextSize('counter', Counter_Size)
			addLuaText('counter')
		elseif Position == 'up' then
			makeLuaText('counter',getProperty('healthBar.percent') .. '%',0,640,10)
			setTextSize('counter', Counter_Size)
			addLuaText('counter')
		end
	end
end

function onUpdate()
	setTextString('counter',getProperty('healthBar.percent') .. '%')
end
