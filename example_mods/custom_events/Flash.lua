function onEvent(name, value1, value2)
	if getPropertyFromClass('ClientPrefs', 'flashing') == true then
		if name == 'Flash' then
			makeLuaSprite('flash', '', 0, 0);
			makeGraphic('flash',1920,1080,'ff3030')
			addLuaSprite('flash', true);
			setLuaSpriteScrollFactor('flash',0,0)
			setProperty('flash.scale.x',2)
			setProperty('flash.scale.y',2)
			setProperty('flash.alpha',0)
			setProperty('flash.alpha',0.5)
			doTweenAlpha('flTw','flash',0,0.4,'linear')
		end
	end
end