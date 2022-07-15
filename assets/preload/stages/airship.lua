local xx = 840;
local yy = 625;
local ofs = 30;
local ofs2 = 30;
local xx2 = 1250;
local yy2 = 625;
local followchars = true;

function onCreate()
	if getPropertyFromClass('ClientPrefs', 'Optimization') == false then
		makeLuaSprite('floor', 'airship/airFloor', -100, -0);
		setScrollFactor('floor', 1, 1);
		scaleObject('floor', 1, 1);

		makeLuaSprite('cockPit', 'airship/airCockpit', -100, -0);
		setScrollFactor('cockPit', 1, 0.85);
		scaleObject('cockPit', 1, 1);

		makeLuaSprite('equipMent', 'airship/airEquipment', -100, -0);
		setScrollFactor('equipMent', 1, 1);
		scaleObject('equipMent', 1, 1);

		makeLuaSprite('glass', 'airship/airGlass', -100, -0);
		setScrollFactor('glass', 1, 1);
		scaleObject('glass', 1, 0.85);

		makeLuaSprite('map', 'airship/airMap', -100, -0);
		setScrollFactor('map', 1, 1);
		scaleObject('map', 1, 0.85);

		makeLuaSprite('clouds', 'airship/airClouds', -350, -350);
		setScrollFactor('clouds', sf, sf);
		scaleObject('clouds', 1, 1);

		makeLuaSprite('sky', 'airship/airSky', -100, -0);
		setScrollFactor('sky', 1, 1);
		scaleObject('sky', 1, 1);

		makeLuaSprite('light', 'airship/airLight', -100, -0);
		setScrollFactor('light', 1, 1);
		scaleObject('light', 1, 1);
		setProperty('light.alpha', 0.2)

		makeLuaSprite('yellow', 'airship/dead_yellow', -60, 810);
		setScrollFactor('yellow', 1, 1);
		scaleObject('yellow', 1.50, 1.50);
		
		addLuaSprite('sky', true);
		addLuaSprite('clouds', true);
		addLuaSprite('glass', true);
		addLuaSprite('map', true);
		addLuaSprite('cockPit', true);
		addLuaSprite('floor', true);
		addLuaSprite('equipMent', true);
		addLuaSprite('light', true);
		 
		if songName == "Oversight" or songName == "Influence" or songName == "Danger" or songName == "Death Blow" then
			addLuaSprite('yellow', true);
		end

		doTweenX('CloudyTweenX', 'clouds', -1000, 1500);
	end
end

function onUpdate()
    
	if followchars == true then
		
        if mustHitSection == false then

			if getProperty('dad.animation.curAnim.name') == 'singLEFT' then
                triggerEvent('Camera Follow Pos',xx-ofs,yy)
            end
            
			if getProperty('dad.animation.curAnim.name') == 'singRIGHT' then
                triggerEvent('Camera Follow Pos',xx+ofs,yy)
            end
            
			if getProperty('dad.animation.curAnim.name') == 'singUP' then
                triggerEvent('Camera Follow Pos',xx,yy-ofs)
            end
           
			if getProperty('dad.animation.curAnim.name') == 'singDOWN' then
                triggerEvent('Camera Follow Pos',xx,yy+ofs)
            end

            if getProperty('dad.animation.curAnim.name') == 'idle' then
                triggerEvent('Camera Follow Pos',xx,yy)
            end
		
        else
            
			if getProperty('boyfriend.animation.curAnim.name') == 'singLEFT' then
                triggerEvent('Camera Follow Pos',xx2-ofs2,yy2)
            end
            
			if getProperty('boyfriend.animation.curAnim.name') == 'singRIGHT' then
                triggerEvent('Camera Follow Pos',xx2+ofs2,yy2)
            end
            
			if getProperty('boyfriend.animation.curAnim.name') == 'singUP' then
                triggerEvent('Camera Follow Pos',xx2,yy2-ofs2)
            end
           
			if getProperty('boyfriend.animation.curAnim.name') == 'singDOWN' then
                triggerEvent('Camera Follow Pos',xx2,yy2+ofs2)
            end
			
			if getProperty('boyfriend.animation.curAnim.name') == 'singLEFTmiss' then
                triggerEvent('Camera Follow Pos',xx2-ofs2,yy2)
            end
            
			if getProperty('boyfriend.animation.curAnim.name') == 'singRIGHTmiss' then
                triggerEvent('Camera Follow Pos',xx2+ofs2,yy2)
            end
            
			if getProperty('boyfriend.animation.curAnim.name') == 'singUPmiss' then
                triggerEvent('Camera Follow Pos',xx2,yy2-ofs2)
            end
           
			if getProperty('boyfriend.animation.curAnim.name') == 'singDOWNmiss' then
                triggerEvent('Camera Follow Pos',xx2,yy2+ofs2)
            end

            if getProperty('boyfriend.animation.curAnim.name') == 'idle' then
                triggerEvent('Camera Follow Pos',xx2,yy2)
            end
		
        end
    
        triggerEvent('Camera Follow Pos','','')
    
	end
    
end