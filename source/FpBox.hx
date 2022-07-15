package;

import flixel.FlxSprite;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class FpBox extends FlxSprite
{
	public var sprTracker:FlxSprite;
	public var box:String = '';
	public var SongNum:Float = 0;

	public function new(SongNum:Float = 0, box:String = 'FreeplayBox')
	{
		super();
		changeBox(box);
		this.SongNum = SongNum;
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (SongNum == 0) //sussus-moogus
			setPosition(sprTracker.x + sprTracker.width + -400, sprTracker.y - -10);
			
		if (SongNum == 1) //sabotage
			setPosition(sprTracker.x + sprTracker.width + -290, sprTracker.y - -10);
			
		if (SongNum == 2) //meltdown
			setPosition(sprTracker.x + sprTracker.width + -292, sprTracker.y - -10);
			
		if (SongNum == 3) //sussus-toogus
			setPosition(sprTracker.x + sprTracker.width + -395, sprTracker.y - -10);
			
		if (SongNum == 4) //lights-down
			setPosition(sprTracker.x + sprTracker.width + -362, sprTracker.y - -10);
			
		if (SongNum == 5) //reactor
			setPosition(sprTracker.x + sprTracker.width + -250, sprTracker.y - -10);
			
		if (SongNum == 6) //ejected
			setPosition(sprTracker.x + sprTracker.width + -245, sprTracker.y - -10);
			
		if (SongNum == 7) //sussy-bussy
			setPosition(sprTracker.x + sprTracker.width + -345, sprTracker.y - -10);
			
		if (SongNum == 8) //rivals
			setPosition(sprTracker.x + sprTracker.width + -227, sprTracker.y - -10);
			
		if (SongNum == 9) //chewmate
			setPosition(sprTracker.x + sprTracker.width + -290, sprTracker.y - -10);
			
		if (SongNum == 10) //defeat
			setPosition(sprTracker.x + sprTracker.width + -230, sprTracker.y - -10);
			
		if (SongNum == 11) //christmas
			setPosition(sprTracker.x + sprTracker.width + -295, sprTracker.y - -10);
			
		if (SongNum == 12) //spookpostor
			setPosition(sprTracker.x + sprTracker.width + -335, sprTracker.y - -10);
			
		if (SongNum == 13) //mando
			setPosition(sprTracker.x + sprTracker.width + -225, sprTracker.y - -10);
			
		if (SongNum == 14) //d'low
			setPosition(sprTracker.x + sprTracker.width + -212, sprTracker.y - -10);
			
		if (SongNum == 15) //oversight
			setPosition(sprTracker.x + sprTracker.width + -305, sprTracker.y - -10);
			
		if (SongNum == 16) //influence
			setPosition(sprTracker.x + sprTracker.width + -292, sprTracker.y - -10);
			
		if (SongNum == 17) //danger
			setPosition(sprTracker.x + sprTracker.width + -245, sprTracker.y - -10);
			
		if (SongNum == 18) //double-kill
			setPosition(sprTracker.x + sprTracker.width + -336, sprTracker.y - -10);
			
		if (SongNum == 19) //death-blow
			setPosition(sprTracker.x + sprTracker.width + -336, sprTracker.y - -10);
			
		if (SongNum == 20) //insane
			setPosition(sprTracker.x + sprTracker.width + -235, sprTracker.y - -10);
			
		if (SongNum == 21) //blackout
			setPosition(sprTracker.x + sprTracker.width + -282, sprTracker.y - -10);

		if (SongNum == 22) //nyctophobia
			setPosition(sprTracker.x + sprTracker.width + -350, sprTracker.y - -10);
			
		if (SongNum == 23) //massacre
			setPosition(sprTracker.x + sprTracker.width + -275, sprTracker.y - -10);
			
		if (SongNum == 24) //boiling-point
			setPosition(sprTracker.x + sprTracker.width + -387, sprTracker.y - -10);
			
		if (SongNum == 25) //heartbroken 
			setPosition(sprTracker.x + sprTracker.width + -350, sprTracker.y - -10);
			
		if (SongNum == 26) //titular
			setPosition(sprTracker.x + sprTracker.width + -247, sprTracker.y - -10);
			
		if (SongNum == 27) //mission
			setPosition(sprTracker.x + sprTracker.width + -255, sprTracker.y - -10);
			
		if (SongNum == 28) //double-trouble
			setPosition(sprTracker.x + sprTracker.width + -409, sprTracker.y - -10);
			
		if (SongNum == 29) //double-ejection
			setPosition(sprTracker.x + sprTracker.width + -428, sprTracker.y - -10);
			
		if (SongNum == 30) //drip
			setPosition(sprTracker.x + sprTracker.width + -180, sprTracker.y - -10);
			
		if (SongNum == 31) //skinny-nuts
			setPosition(sprTracker.x + sprTracker.width + -350, sprTracker.y - -10);
			
		if (SongNum == 32) //jorsawsee
			setPosition(sprTracker.x + sprTracker.width + -305, sprTracker.y - -10);
			
		if (SongNum == 33) //bf-defeat
			setPosition(sprTracker.x + sprTracker.width + -295, sprTracker.y - -10);
			
		if (SongNum == 34) //boing!
			setPosition(sprTracker.x + sprTracker.width + -250, sprTracker.y - -10);
			
		if (SongNum == 35) //triple-trouble
			setPosition(sprTracker.x + sprTracker.width + -384, sprTracker.y - -10);
			
		if (SongNum == 36) //monosus
			setPosition(sprTracker.x + sprTracker.width + -265, sprTracker.y - -10);
			
		if (SongNum == 37) //infi
			setPosition(sprTracker.x + sprTracker.width + -309, sprTracker.y - -10);
			
		if (SongNum == 38) //cleaning
			setPosition(sprTracker.x + sprTracker.width + -280, sprTracker.y - -10);
			
		if (SongNum == 39) //devil's-gambit
			setPosition(sprTracker.x + sprTracker.width + -400, sprTracker.y - -10);
			
		if (SongNum == 40) //bad-time
			setPosition(sprTracker.x + sprTracker.width + -280, sprTracker.y - -10);
			
		if (SongNum == 41) //despair
			setPosition(sprTracker.x + sprTracker.width + -245, sprTracker.y - -10);
	}

	private var iconOffsets:Array<Float> = [0, 0];
	
	public function changeBox(box:String) {
		if(this.box != box) {
			var name:String = 'freeplay/' + box;
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'freeplay/' + box;
			var file:Dynamic = Paths.image(name);

			loadGraphic(file);
			iconOffsets[0] = 0;
			iconOffsets[1] = 0;
			updateHitbox();

			animation.play(box);
			this.box = box;

			antialiasing = ClientPrefs.globalAntialiasing;
			
		}
	}

	override function updateHitbox()
	{
		super.updateHitbox();
		offset.x = iconOffsets[0];
		offset.y = iconOffsets[1];
	}

	public function getCharacter():String {
		return box;
	}
}
