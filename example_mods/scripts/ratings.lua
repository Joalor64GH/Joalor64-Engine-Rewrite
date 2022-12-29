function onCreate()
	--this makes the rating object
	
	makeAnimatedLuaSprite("ratings","ratings",0,0);
	addLuaSprite("ratings",true);
	setScrollFactor('ratings',0,0);
	setObjectCamera('ratings','hud');
	scaleObject('ratings',0.6,0.6);
	
	--animations, this adds animations to the rating object so it can actually change ratings
	
	addAnimationByPrefix('ratings','PLUS','PLUS',24,false);
	addAnimationByPrefix('ratings','S','S',24,false);
	addAnimationByPrefix('ratings','A','A',24,false);
	addAnimationByPrefix('ratings','B','B',24,false);
	addAnimationByPrefix('ratings','C','C',24,false);
	addAnimationByPrefix('ratings','D','D',24,false);
	addAnimationByPrefix('ratings','E','E',24,false);
	addAnimationByPrefix('ratings','F','F',24,false);
	addAnimationByPrefix('ratings','?','?',24,false);
	
	--plays the ? animation when there's no rating
	objectPlayAnimation('ratings','?',false)
	
end

--changes the rating, and it bops to the beat too
function onUpdate()
	--S+ rating code
    if rating >= 1 then
		function onBeatHit()
			if curBeat % 2 == 0 then
				objectPlayAnimation('ratings','PLUS',false)
		end
	end
	--S rating code
	
    elseif rating >= 0.98 then
		function onBeatHit()
			if curBeat % 2 == 0 then
				objectPlayAnimation('ratings','S',false)
		end
	end
	--A rating code
	
    elseif rating >= 0.90 then
		function onBeatHit()
			if curBeat % 2 == 0 then
				objectPlayAnimation('ratings','A',false)
		end
	end
	--B rating code
	
    elseif rating >= 0.80 then
		function onBeatHit()
			if curBeat % 2 == 0 then
				objectPlayAnimation('ratings','B',false)
		end
	end
	--C rating code
	
    elseif rating >= 0.70 then
		function onBeatHit()
			if curBeat % 2 == 0 then
				objectPlayAnimation('ratings','C',false)
		end
	end
	--D rating code
	
    elseif rating >= 0.50 then
		function onBeatHit()
			if curBeat % 2 == 0 then
				objectPlayAnimation('ratings','D',false)
		end
	end
	--E rating code
	
    elseif rating >= 0.21 then
		function onBeatHit()
			if curBeat % 2 == 0 then
				objectPlayAnimation('ratings','E',false)
		end
	end
	--F rating code
	
    elseif rating <= 0.20 and ratings.animation ~= '?' then
		function onBeatHit()
			if curBeat % 2 == 0 then
				objectPlayAnimation('ratings','F',false)
		end
	end
end
end
