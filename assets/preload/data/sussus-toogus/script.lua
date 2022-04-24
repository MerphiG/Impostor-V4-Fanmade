IntroTextSize = 20
IntroSubTextSize = 20
IntroTagColor = '259F00'
IntroTagWidth = 15
Name = 'Sussus Toogus'
Author = 'EthanTheDoodler'
FanAuthor = ''
FanAuthorOn = false

function onCreate()
	makeLuaSprite('JukeBoxTag', 'empty', -375-IntroTagWidth, 35)
	makeGraphic('JukeBoxTag', 370+IntroTagWidth, 100, IntroTagColor)
	setObjectCamera('JukeBoxTag', 'other')
	addLuaSprite('JukeBoxTag', true)

	makeLuaSprite('JukeBox', 'empty', -375-IntroTagWidth, 35)
	makeGraphic('JukeBox', 370, 100, '000000')
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
	
	makeLuaText('JukeBoxSubText2', Author, 300, -305-IntroTagWidth, 70)
	setTextAlignment('JukeBoxSubText2', 'left')
	setObjectCamera('JukeBoxSubText2', 'other')
	setTextSize('JukeBoxSubText2', IntroSubTextSize)
	addLuaText('JukeBoxSubText2', true)
	
	makeLuaText('JukeBoxText3', 'Fanmade OST By:', 300, -305-IntroTagWidth, 100)
	setTextAlignment('JukeBoxText3', 'left')
	setObjectCamera('JukeBoxText3', 'other')
	setTextSize('JukeBoxText3', IntroTextSize)
	if FanAuthorOn == true then 
		addLuaText('JukeBoxText3')
	end
	
	makeLuaText('JukeBoxSubText3', FanAuthor, 300, -305-IntroTagWidth, 100)
	setTextAlignment('JukeBoxSubText3', 'left')
	setObjectCamera('JukeBoxSubText3', 'other')
	setTextSize('JukeBoxSubText3', IntroSubTextSize)
	if FanAuthorOn == true then 
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
	doTweenX('MoveInEight', 'JukeBoxSubText3', 195, 1, 'CircInOut')
	
	runTimer('JukeBoxWait', 3, 1)
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'JukeBoxWait' then
		doTweenX('MoveOutOne', 'JukeBoxTag', -520, 1.5, 'CircInOut')
		doTweenX('MoveOutTwo', 'JukeBox', -520, 1.5, 'CircInOut')
		doTweenX('MoveOutThree', 'JukeBoxText', -450, 1.5, 'CircInOut')
		doTweenX('MoveOutFour', 'JukeBoxSubText', -450, 1.5, 'CircInOut')
		doTweenX('MoveOutFive', 'JukeBoxText2', -450, 1.5, 'CircInOut')
		doTweenX('MoveOutSix', 'JukeBoxSubText2', -450, 1.5, 'CircInOut')
		doTweenX('MoveInSeven', 'JukeBoxText3', -450, 1.5, 'CircInOut')
		doTweenX('MoveInEight', 'JukeBoxSubText3', -450, 1.5, 'CircInOut')
	end
end