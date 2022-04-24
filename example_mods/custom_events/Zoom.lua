function onEvent(name, value1, value2)
    	if name == 'Zoom' then
		zoom = tonumber(value1);
        	doTweenZoom('asf', 'camGame', zoom, 2, 'cubeOut')
        	setProperty('defaultCamZoom', zoom)
    	end
end