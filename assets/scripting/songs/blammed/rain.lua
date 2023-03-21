function onCreate()
	makeAnimatedLuaSprite('rain', 'rain', 0, 0);
	setLuaSpriteScrollFactor('rain', 0.3, 0.3);
	scaleObject('rain', 0.85, 0.85);

	makeAnimatedLuaSprite('splash', 'splash', 0, 50);

	addLuaSprite('splash', false);
	addAnimationByPrefix('splash', 'loop', 'splash loop', 15, true);
	addLuaSprite('rain', true);
	addAnimationByPrefix('rain', 'loop', 'rain loop', 15, true);
end