local allowCountdown = false
local xx = 420.95;
local yy = 313;
local xx2 = 952.9;
local yy2 = 350;
local ofs = 30;
local followchars = true;

IntroTextSize = 20
IntroSubTextSize = 20
IntroTagColor = '6109F9'
IntroTagWidth = 15
Name = 'Triple Trouble'
Author = 'MarStarBro, UpTaunt And Punkett'
Cover = 'Flopster'
CoverOn = true

function onCreate()
    addCharacterToList('maroon-tt', 'dad');
    addCharacterToList('black-tt1', 'dad');
    addCharacterToList('black-tt2', 'dad');
    addCharacterToList('gray-tt', 'dad');
    addCharacterToList('flippedBf', 'boyfriend');
    addCharacterToList('bf-perspectiveLeft', 'boyfriend');
    addCharacterToList('bf-perspectiveRight', 'boyfriend');
	
	makeLuaSprite('JukeBoxTag', 'empty', -535-IntroTagWidth, 35)
	makeGraphic('JukeBoxTag', 530+IntroTagWidth, 100, IntroTagColor)
	setObjectCamera('JukeBoxTag', 'other')
	addLuaSprite('JukeBoxTag', true)

	makeLuaSprite('JukeBox', 'empty', -535-IntroTagWidth, 35)
	makeGraphic('JukeBox', 530, 100, '000000')
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
	if dadName == 'pink-tt' then
		xx = 450
		yy = 650
	end
	if dadName == 'gray-tt' then
		xx = 450
		yy = 620
	end
	if dadName == 'maroon-tt' then
		xx = 1350
		yy = 620
	end
	if dadName == 'black-tt1' then
		xx = 500
		yy = 480
	end
	if dadName == 'black-tt2' then
		xx = 1250
		yy = 480
	end
	if boyfriendName == 'bf-tt' then
		xx2 = 725
		yy2 = 650
	end
	if boyfriendName == 'bf-perspectiveRight' then
		xx2 = 780
		yy2 = 500
	end
	if boyfriendName == 'bf-perspectiveLeft' then
		xx2 = 1000
		yy2 = 500
	end
	if boyfriendName == 'flippedBf' then
		xx2 = 1100
		yy2 = 650
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
            if getProperty('boyfriend.animation.curAnim.name') == 'idle-alt' then
                triggerEvent('Camera Follow Pos',xx2,yy2)
            end
            if getProperty('boyfriend.animation.curAnim.name') == 'idle' then
                triggerEvent('Camera Follow Pos',xx2,yy2)
            end
        end
    else
        triggerEvent('Camera Follow Pos','','')
    end
    
end