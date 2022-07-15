local t = 0
local s = 0

function onCreate()
	if getPropertyFromClass('ClientPrefs', 'Optimization') == false then
		makeAnimatedLuaSprite('static', 'tt/Phase3Static', 0, 0)
		addAnimationByPrefix('static', 'flash', 'Phase3Static instance 1', 24, false)
		setGraphicSize('static', getProperty('static.width') * 4)
		setProperty('static.alpha', 0.3)
		setProperty('static.visible', false)
		addLuaSprite('static', true)
		setObjectCamera('static', 'other')
		
		makeLuaSprite('bg', 'tt/Glitch', -621, -365)
		addLuaSprite('bg', true)
		setGraphicSize('bg', getProperty('bg.width') * 1.2)
		
		makeAnimatedLuaSprite('daSTAT', 'tt/daSTAT', 0, 0)
		addAnimationByPrefix('daSTAT', 'STAT', 'staticFLASH', 24, true)
		scaleObject('daSTAT', 4, 4)
		setObjectCamera('daSTAT', 'other')
		setProperty('daSTAT.alpha', 0.3)
		setProperty('daSTAT.visible', false)
		addLuaSprite('daSTAT', true)	
	end
	
	makeAnimatedLuaSprite('plasticShit', 'tt/NewTitleMenuBG', -500, -400)
	addAnimationByPrefix('plasticShit', 'ImGonnaDie', 'TitleMenuSSBG instance 1', 24, true)
	setProperty('plasticShit.visible', false)
	addLuaSprite('plasticShit', true)
	scaleObject('plasticShit', 6.5, 5)
	
	if getPropertyFromClass('ClientPrefs', 'Optimization') == false then
		makeLuaSprite('trees1', 'tt/Trees', -607, -401)
		addLuaSprite('trees1', true)
		setScrollFactor('trees1', 0.95, 1)
		setGraphicSize('trees1', getProperty('trees1.width') * 1.2)

		makeLuaSprite('trees2', 'tt/Trees2', -623, -410)
		setGraphicSize('trees2', getProperty('trees2.width') * 1.2)
		addLuaSprite('trees2', true)

		makeLuaSprite('grass', 'tt/Grass', -630, -266)
		addLuaSprite('grass', true)
		setGraphicSize('grass', getProperty('grass.width') * 1.2)
	end
end

function onCreatePost()
    setProperty('gf.alpha', 0);
    triggerEvent('Opponent Notes Left Side', 'a', 's')
end

function onSongStart()
	if getPropertyFromClass('ClientPrefs', 'Optimization') == false then
		setProperty('static.visible', true)
	end
end

function onUpdate(elapsed)
	if getPropertyFromClass('ClientPrefs', 'Optimization') == false then
		if getProperty('static.animation.curAnim.finished') and getProperty('static.animation.curAnim.name') == 'flash' then
			setProperty('static.alpha', 0)
		else
			setProperty('static.alpha', 0.7)
		end
	end
end