function onEvent(name, value1)
	if name == "Set Camera Zoom" then
        setProperty('defaultCamZoom',value1);
    end
end