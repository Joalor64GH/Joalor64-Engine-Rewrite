function onCreate()
	-- backterrain shit
	makeLuaSprite('sky', 'stages/hills/hills_sky', -600, -600);
	setLuaSpriteScrollFactor('sky', 1, 1);
	
	addLuaSprite('sky', false);
	scaleLuaSprite('sky',1.5,1.5);

    makeLuaSprite('stars', 'stages/hills/hills_stars', -600, -600);
	setLuaSpriteScrollFactor('stars', 1, 1);
	
	addLuaSprite('stars', false);
	scaleLuaSprite('stars',1.5,1.5);

	makeLuaSprite('clouds', 'stages/hills/hills_clouds', -600, -600);
	setLuaSpriteScrollFactor('clouds', 1, 1);
	
	addLuaSprite('clouds', false);
	scaleLuaSprite('clouds',1.5,1.5);

    makeLuaSprite('terrain', 'stages/hills/hills', -600, -600);
	setLuaSpriteScrollFactor('terrain', 1, 1);
	
	addLuaSprite('terrain', false);
	scaleLuaSprite('terrain',1.5,1.5);

	makeLuaSprite('ground', 'stages/hills/hills_ground', -600, -600);
	setLuaSpriteScrollFactor('ground', 1, 1);
	
	addLuaSprite('ground', false);
	scaleLuaSprite('ground',1.5,1.5);

end

function onMoveCamera(focus)
    if focus == 'dad' then
        setProperty('camFollow.y', getProperty('camFollow.y') -50);
        setProperty('camFollow.x', getProperty('camFollow.x') +200);
    elseif focus == 'boyfriend' then
        setProperty('camFollow.y', getProperty('camFollow.y') -200);
        setProperty('camFollow.x', getProperty('camFollow.x') -300);
    end
end