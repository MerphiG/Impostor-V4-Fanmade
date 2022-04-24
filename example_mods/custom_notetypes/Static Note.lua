function onCreate()
    	makeAnimatedLuaSprite('missStatic', 'tt/hitStatic', 0, 0)
    	addAnimationByPrefix('missStatic', 'missed', 'staticANIMATION', 24, false)
    	setGraphicSize('missStatic', 1366, 768) --getProperty('missStatic.width') * 4
    	setProperty('missStatic.alpha', 0.7)
    	setProperty('missStatic.visible', false)
    	addLuaSprite('missStatic', true)
    	setObjectCamera('missStatic', 'other')

	for i = 0, getProperty('unspawnNotes.length')-1 do
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'Static Note' then
			setPropertyFromGroup('unspawnNotes', i, 'texture', 'tt/STATIC_assets');
			setPropertyFromGroup('unspawnNotes', i, 'hitCausesMiss', false);
		end
	end
end

function noteMiss(id, noteData, noteType, isSustainNote)
	if noteType == 'Static Note' then
        	playSound('hitStatic1')
		objectPlayAnimation('missStatic', 'missed', true)
	end
end

function onStepHit()
	if curStep == 1 then
    		setProperty('missStatic.visible', true)
	end
end

function onUpdate(elapsed)
    if getProperty('missStatic.animation.curAnim.finished') and getProperty('missStatic.animation.curAnim.name') == 'missed' then
        setProperty('missStatic.alpha', 0)
    else
        setProperty('missStatic.alpha', 0.9)
    end
end