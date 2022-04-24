function onEvent(name, value1, value2)
    	if name == 'bg on off' then
		state = tonumber(value1);
		if state == 0 then
			setProperty('plasticShit.visible', true)
		end
		if state == 1 then
			setProperty('plasticShit.visible', false)
		end
    	end
end