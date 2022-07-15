function onCreate()
	for i = 0, getProperty('unspawnNotes.length')-1 do
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'Phantom Note' then
			setPropertyFromGroup('unspawnNotes', i, 'texture', 'tt/PhantomNote');
			setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', true)
			setPropertyFromGroup('unspawnNotes', i, 'hitHealth', '0');
		end
	end
end

local Draining = 0
local healthDrain = 0;
function goodNoteHit(id, noteData, noteType, isSustainNote)
	if noteType == 'Phantom Note' then
		setScore(score - 350)
		characterPlayAnim('boyfriend', 'hurt', true);
		healthDrain = healthDrain + crochet * 1.25;
		Draining = Draining + 0.1;
	end
end

function onUpdate(elapsed)
	if healthDrain > 0 then
		healthDrain = healthDrain - crochet * 0.15 * elapsed;
		Draining = Draining - 0.00625 * elapsed;
		setProperty('health', getProperty('health') - Draining * elapsed);
		if healthDrain < 0 then
			healthDrain = 0;
		end
		if Draining < 0 then
			Draining = 0;
		end
		if healthDrain == 0 then
			Draining = 0;
		end
	end
end