function onCreate()
	if getPropertyFromClass('ClientPrefs', 'Optimization') == false then
		makeAnimatedLuaSprite( 'rojo', 'nm/devil-gambit/CUpheqdshid', 0, 0);
		addAnimationByPrefix('rojo', 'idle', 'Cupheadshit_gif instance 1', 24, true);
		setGraphicSize('rojo',1280,721)
		setObjectCamera('rojo','camHud')
		updateHitbox('rojo')
		addLuaSprite('rojo', true)
		objectPlayAnimation('rojo', 'idle', true);

		makeLuaSprite('stage', 'nm/devil-gambit/nightmarecupbg', -600, -300)
		addLuaSprite('stage', true)
			setProperty("stage.scale.x", 2.0);
			setProperty("stage.scale.y", 2.0);

		makeAnimatedLuaSprite( 'stage2', 'nm/devil-gambit/NMClight', -800, -100)
		addAnimationByPrefix('stage2', 'idle', 'rgrrr instance 1', 24, true);
		addLuaSprite('stage2', true)
		objectPlayAnimation('stage2', 'idle', true);
	end
end