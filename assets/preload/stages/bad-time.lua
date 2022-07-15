function onCreate()
	if getPropertyFromClass('ClientPrefs', 'Optimization') == false then
		makeAnimatedLuaSprite('stage', 'nm/bad-time/Nightmare Sans Stage', -600, -300)
		addAnimationByPrefix('stage', 'idle', 'Normal instance 1', 24, true);
		addLuaSprite('stage', true)

		makeAnimatedLuaSprite( 'stage2', 'nm/bad-time/Nightmare Sans Stage', -600, -300)
		addAnimationByPrefix('stage2', 'idle', 'sdfs instance 1', 24, true);
		addLuaSprite('stage2', true)
		setProperty('stage2.visible', false)
	end
end


function onEvent(name,value1,value2)
	if name == 'Play Animation' then 
		
		if value1 == '2' then
			setProperty('stage.visible', false);
			setProperty('stage2.visible', true);
		end
		
		if value1 == '1' then
			setProperty('stage.visible', true);
			setProperty('stage2.visible', false);
		end
	end
end