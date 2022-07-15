local xx = 350;
local yy = 250;
local xx2 = 350;
local yy2 = 250;
local ofs = 35;
local followchars = true;
local del = 0;
local del2 = 0;

IntroTextSize = 20
IntroSubTextSize = 20
IntroTagColor = 'FF2348'
IntroTagWidth = 15
Name = 'Bad Time'
Author = 'Tenzubushi'
Cover = 'Flopster'
CoverOn = true

function onCreate()
	makeLuaSprite('JukeBoxTag', 'empty', -535-IntroTagWidth, 35)
	makeGraphic('JukeBoxTag', 300+IntroTagWidth, 100, IntroTagColor)
	setObjectCamera('JukeBoxTag', 'other')
	addLuaSprite('JukeBoxTag', true)

	makeLuaSprite('JukeBox', 'empty', -535-IntroTagWidth, 35)
	makeGraphic('JukeBox', 300, 100, '000000')
	setObjectCamera('JukeBox', 'other')
	addLuaSprite('JukeBox', true)
	
	makeLuaText('JukeBoxText', 'Now Playing:', 300, -305-IntroTagWidth, 40)
	setTextAlignment('JukeBoxText', 'left')
	setObjectCamera('JukeBoxText', 'other')
	setTextSize('JukeBoxText', IntroTextSize)
	addLuaText('JukeBoxText', true)
	
	makeLuaText('JukeBoxSubText', Name, 300, -305-IntroTagWidth, 40)
	setTextAlignment('JukeBoxSubText', 'left')
	setObjectCamera('JukeBoxSubText', 'other')
	setTextSize('JukeBoxSubText', IntroSubTextSize)
	addLuaText('JukeBoxSubText', true)
	
	makeLuaText('JukeBoxText2', 'Composer:', 300, -305-IntroTagWidth, 70)
	setTextAlignment('JukeBoxText2', 'left')
	setObjectCamera('JukeBoxText2', 'other')
	setTextSize('JukeBoxText2', IntroTextSize)
	addLuaText('JukeBoxText2', true)
	
	makeLuaText('JukeBoxSubText2', Author, 380, -375-IntroTagWidth, 70)
	setTextAlignment('JukeBoxSubText2', 'left')
	setObjectCamera('JukeBoxSubText2', 'other')
	setTextSize('JukeBoxSubText2', IntroSubTextSize)
	addLuaText('JukeBoxSubText2', true)
	
	makeLuaText('JukeBoxText3', 'Cover By:', 300, -305-IntroTagWidth, 100)
	setTextAlignment('JukeBoxText3', 'left')
	setObjectCamera('JukeBoxText3', 'other')
	setTextSize('JukeBoxText3', IntroTextSize)
	if CoverOn == true then 
		addLuaText('JukeBoxText3')
	end
	
	makeLuaText('JukeBoxSubText3', Cover, 300, -305-IntroTagWidth, 100)
	setTextAlignment('JukeBoxSubText3', 'left')
	setObjectCamera('JukeBoxSubText3', 'other')
	setTextSize('JukeBoxSubText3', IntroSubTextSize)
	if CoverOn == true then 
		addLuaText('JukeBoxSubText3')
	end
end

function onSongStart()
	doTweenX('MoveInOne', 'JukeBoxTag', 0, 1, 'CircInOut')
	doTweenX('MoveInTwo', 'JukeBox', 0, 1, 'CircInOut')
	doTweenX('MoveInThree', 'JukeBoxText', 10, 1, 'CircInOut')
	doTweenX('MoveInFour', 'JukeBoxSubText', 160, 1, 'CircInOut')
	doTweenX('MoveInFive', 'JukeBoxText2', 10, 1, 'CircInOut')
	doTweenX('MoveInSix', 'JukeBoxSubText2', 120, 1, 'CircInOut')
	doTweenX('MoveInSeven', 'JukeBoxText3', 10, 1, 'CircInOut')
	doTweenX('MoveInEight', 'JukeBoxSubText3', 120, 1, 'CircInOut')
	
	runTimer('JukeBoxWait', 3, 1)
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'JukeBoxWait' then
		doTweenX('MoveOutOne', 'JukeBoxTag', -590, 1.5, 'CircInOut')
		doTweenX('MoveOutTwo', 'JukeBox', -590, 1.5, 'CircInOut')
		doTweenX('MoveOutThree', 'JukeBoxText', -450, 1.5, 'CircInOut')
		doTweenX('MoveOutFour', 'JukeBoxSubText', -450, 1.5, 'CircInOut')
		doTweenX('MoveOutFive', 'JukeBoxText2', -450, 1.5, 'CircInOut')
		doTweenX('MoveOutSix', 'JukeBoxSubText2', -450, 1.5, 'CircInOut')
		doTweenX('MoveInSeven', 'JukeBoxText3', -450, 1.5, 'CircInOut')
		doTweenX('MoveInEight', 'JukeBoxSubText3', -450, 1.5, 'CircInOut')
	end
end

function onUpdate()
	if del > 0 then
		del = del - 1
	end
	if del2 > 0 then
		del2 = del2 - 1
	end
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
            if getProperty('dad.animation.curAnim.name') == 'singLEFT-alt' then
                triggerEvent('Camera Follow Pos',xx-ofs,yy)
            end
            if getProperty('dad.animation.curAnim.name') == 'singRIGHT-alt' then
                triggerEvent('Camera Follow Pos',xx+ofs,yy)
            end
            if getProperty('dad.animation.curAnim.name') == 'singUP-alt' then
                triggerEvent('Camera Follow Pos',xx,yy-ofs)
            end
            if getProperty('dad.animation.curAnim.name') == 'singDOWN-alt' then
                triggerEvent('Camera Follow Pos',xx,yy+ofs)
            end
            if getProperty('dad.animation.curAnim.name') == 'idle-alt' then
                triggerEvent('Camera Follow Pos',xx,yy)
            end
            if getProperty('dad.animation.curAnim.name') == 'idle' then
                triggerEvent('Camera Follow Pos',xx,yy)
            end
        else

            if getProperty('boyfriend.animation.curAnim.name') == 'singLEFT' then
                triggerEvent('Camera Follow Pos',xx2-ofs,yy2)
            end
            if getProperty('boyfriend.animation.curAnim.name') == 'singRIGHT' then
                triggerEvent('Camera Follow Pos',xx2+ofs,yy2)
            end
            if getProperty('boyfriend.animation.curAnim.name') == 'singUP' then
                triggerEvent('Camera Follow Pos',xx2,yy2-ofs)
            end
            if getProperty('boyfriend.animation.curAnim.name') == 'singDOWN' then
                triggerEvent('Camera Follow Pos',xx2,yy2+ofs)
            end
	    if getProperty('boyfriend.animation.curAnim.name') == 'idle' then
                triggerEvent('Camera Follow Pos',xx2,yy2)
            end
        end
    else
        triggerEvent('Camera Follow Pos','','')
    end
    
end

function opponentNoteHit()
       cameraShake('game', 0.01, 0.3)


       health = getProperty('health')
    if getProperty('health') > 0.075 then
       setProperty('health', health- 0.024);
	end
end


