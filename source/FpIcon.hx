package;

import flixel.FlxSprite;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class FpIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	private var char:String = '';
	public var SongNum:Float = 0;

	public function new(char:String = 'bf', SongNum:Float = 0)
	{
		super();
		changeIcon(char);
		this.SongNum = SongNum;
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (SongNum == 0) //sussus-moogus
			setPosition(sprTracker.x + sprTracker.width + -425, sprTracker.y - 10);
			
		if (SongNum == 1) //sabotage
			setPosition(sprTracker.x + sprTracker.width + -315, sprTracker.y - 10);
			
		if (SongNum == 2) //meltdown
			setPosition(sprTracker.x + sprTracker.width + -317, sprTracker.y - 10);
			
		if (SongNum == 3) //sussus-toogus
			setPosition(sprTracker.x + sprTracker.width + -420, sprTracker.y - 10);
			
		if (SongNum == 4) //lights-down
			setPosition(sprTracker.x + sprTracker.width + -387, sprTracker.y - 10);
			
		if (SongNum == 5) //reactor
			setPosition(sprTracker.x + sprTracker.width + -280, sprTracker.y - 10);
			
		if (SongNum == 6) //ejected
			setPosition(sprTracker.x + sprTracker.width + -275, sprTracker.y - 10);
			
		if (SongNum == 7) //sussy-bussy
			setPosition(sprTracker.x + sprTracker.width + -370, sprTracker.y - 10);
			
		if (SongNum == 8) //rivals
			setPosition(sprTracker.x + sprTracker.width + -252, sprTracker.y - 10);
			
		if (SongNum == 9) //chewmate
			setPosition(sprTracker.x + sprTracker.width + -320, sprTracker.y - 10);
			
		if (SongNum == 10) //defeat
			setPosition(sprTracker.x + sprTracker.width + -255, sprTracker.y - 20);
			
		if (SongNum == 11) //christmas
			setPosition(sprTracker.x + sprTracker.width + -325, sprTracker.y - 10);
			
		if (SongNum == 12) //spookpostor
			setPosition(sprTracker.x + sprTracker.width + -360, sprTracker.y - 10);
			
		if (SongNum == 13) //mando
			setPosition(sprTracker.x + sprTracker.width + -250, sprTracker.y - 13);
			
		if (SongNum == 14) //d'low
			setPosition(sprTracker.x + sprTracker.width + -237, sprTracker.y - 13);
			
		if (SongNum == 15) //oversight
			setPosition(sprTracker.x + sprTracker.width + -330, sprTracker.y - 15);
			
		if (SongNum == 16) //influence
			setPosition(sprTracker.x + sprTracker.width + -320, sprTracker.y - 15);
			
		if (SongNum == 17) //danger
			setPosition(sprTracker.x + sprTracker.width + -270, sprTracker.y - 20);
			
		if (SongNum == 18) //double-kill
			setPosition(sprTracker.x + sprTracker.width + -361, sprTracker.y - 10);
			
		if (SongNum == 19) //death-blow
			setPosition(sprTracker.x + sprTracker.width + -361, sprTracker.y - 20);
			
		if (SongNum == 20) //insane
			setPosition(sprTracker.x + sprTracker.width + -260, sprTracker.y - 8);
			
		if (SongNum == 21) //blackout
			setPosition(sprTracker.x + sprTracker.width + -307, sprTracker.y - 8);
			
		if (SongNum == 22) //nyctophobia
			setPosition(sprTracker.x + sprTracker.width + -375, sprTracker.y - 8);
			
		if (SongNum == 23) //massacre
			setPosition(sprTracker.x + sprTracker.width + -300, sprTracker.y - 8);
			
		if (SongNum == 24) //boiling-point
			setPosition(sprTracker.x + sprTracker.width + -412, sprTracker.y - 8);
			
		if (SongNum == 25) //heartbroken 
			setPosition(sprTracker.x + sprTracker.width + -375, sprTracker.y - 8);
			
		if (SongNum == 26) //titular
			setPosition(sprTracker.x + sprTracker.width + -272, sprTracker.y - 10);
			
		if (SongNum == 27) //mission
			setPosition(sprTracker.x + sprTracker.width + -280, sprTracker.y - 10);
			
		if (SongNum == 28) //double-trouble
			setPosition(sprTracker.x + sprTracker.width + -434, sprTracker.y - 10);
			
		if (SongNum == 29) //double-ejection
			setPosition(sprTracker.x + sprTracker.width + -455, sprTracker.y - 10);
			
		if (SongNum == 30) //drip
			setPosition(sprTracker.x + sprTracker.width + -205, sprTracker.y - 10);
			
		if (SongNum == 31) //skinny-nuts
			setPosition(sprTracker.x + sprTracker.width + -375, sprTracker.y - 12);
			
		if (SongNum == 32) //jorsawsee
			setPosition(sprTracker.x + sprTracker.width + -330, sprTracker.y - 12);
			
		if (SongNum == 33) //bf-defeat
			setPosition(sprTracker.x + sprTracker.width + -320, sprTracker.y - 7);
			
		if (SongNum == 34) //boing!
			setPosition(sprTracker.x + sprTracker.width + -275, sprTracker.y - 10);
			
		if (SongNum == 35) //triple-trouble
			setPosition(sprTracker.x + sprTracker.width + -409, sprTracker.y - 12);
			
		if (SongNum == 36) //monosus
			setPosition(sprTracker.x + sprTracker.width + -290, sprTracker.y - 10);
			
		if (SongNum == 37) //infi
			setPosition(sprTracker.x + sprTracker.width + -334, sprTracker.y - 10);
			
		if (SongNum == 38) //cleaning
			setPosition(sprTracker.x + sprTracker.width + -305, sprTracker.y - 10);
			
		if (SongNum == 39) //devil's-gambit
			setPosition(sprTracker.x + sprTracker.width + -430, sprTracker.y - 10);
			
		if (SongNum == 40) //bad-time
			setPosition(sprTracker.x + sprTracker.width + -305, sprTracker.y - 10);
			
		if (SongNum == 41) //despair
			setPosition(sprTracker.x + sprTracker.width + -270, sprTracker.y - 10);
	}

	private var iconOffsets:Array<Float> = [0, 0];
	public function changeIcon(char:String) {
		if(this.char != char) {
			var name:String = 'icons/' + char;
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-' + char;
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-face';
			var file:Dynamic = Paths.image(name);

			loadGraphic(file);
			loadGraphic(file, true, Math.floor(width / 2), Math.floor(height));
			iconOffsets[0] = (width - 150) / 2;
			iconOffsets[1] = (width - 150) / 2;
			updateHitbox();

			animation.add(char, [0, 1], 0, false);
			animation.play(char);
			this.char = char;

			antialiasing = ClientPrefs.globalAntialiasing;
			if(char.endsWith('-pixel')) {
				antialiasing = false;
			}
		}
	}

	override function updateHitbox()
	{
		super.updateHitbox();
		offset.x = iconOffsets[0];
		offset.y = iconOffsets[1];
	}
}
