package;

#if desktop
import Discord.DiscordClient;
#end
import editors.ChartingState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
import flixel.system.FlxSound;
import openfl.utils.Assets as OpenFlAssets;
import WeekData;
#if MODS_ALLOWED
import sys.FileSystem;
#end
import flixel.addons.display.FlxBackdrop;

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	private static var curSelected:Int = 0;
	var curDifficulty:Int = -1;
	private static var lastDifficultyName:String = '';

	var scoreText:FlxText;
	var scoreText1:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	private var grpSongs:FlxTypedGroup<SusFont>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<FpIcon> = [];
	private var FpBoxArray:Array<FpBox> = [];

	var bg:FlxSprite;
	var starFG:FlxBackdrop;
	var starBG:FlxBackdrop;
	var intendedColor:Int;
	var colorTween:FlxTween;

	var red1:FlxSprite;
	var green1:FlxSprite;
	var sus1:FlxSprite;
	var black:FlxSprite;
	var fella1:FlxSprite;
	var yellow:FlxSprite;
	var white:FlxSprite;
	var wb:FlxSprite;
	var henry:FlxSprite;
	var maroon:FlxSprite;
	var gray:FlxSprite;
	var double1:FlxSprite;
	var cz:FlxSprite;
	var jorsawsee:FlxSprite;
	var bfi:FlxSprite;
	var tt:FlxSprite;
	var sus:FlxSprite;
	var infi:FlxSprite;
	var pink:FlxSprite;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
		
		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		for (i in 0...WeekData.weeksList.length) {
			if(weekIsLocked(WeekData.weeksList[i])) continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];

			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				var colors:Array<Int> = song[2];
				if(colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
			}
		}
		WeekData.loadTheFirstEnabledMod();

		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));
		for (i in 0...initSonglist.length)
		{
			if(initSonglist[i] != null && initSonglist[i].length > 0) {
				var songArray:Array<String> = initSonglist[i].split(":");
				addSong(songArray[0], 0, songArray[1], Std.parseInt(songArray[2]));
			}
		}

		var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('spacep'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.10;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		
		starFG = new FlxBackdrop(Paths.image('menu/starFG'), 1, 1, true, true);
		starFG.updateHitbox();
		starFG.antialiasing = true;
		starFG.scrollFactor.set();
		add(starFG);

		starBG = new FlxBackdrop(Paths.image('menu/starBG'), 1, 1, true, true);
		starBG.updateHitbox();
		starBG.antialiasing = true;
		starBG.scrollFactor.set();
		add(starBG);

		red1 = new FlxSprite(-10, -10).loadGraphic(Paths.image('freeplay/red-1'));
		red1.setGraphicSize(Std.int(red1.width * 1.05));
		red1.antialiasing = ClientPrefs.globalAntialiasing;
		add(red1);
		red1.alpha = 0.0;
		
		green1 = new FlxSprite(-10, -10).loadGraphic(Paths.image('freeplay/green-1'));
		green1.setGraphicSize(Std.int(green1.width * 1.05));
		green1.antialiasing = ClientPrefs.globalAntialiasing;
		add(green1);
		green1.alpha = 0.0;
		
		sus1 = new FlxSprite(-10, -10).loadGraphic(Paths.image('freeplay/sus-1'));
		sus1.setGraphicSize(Std.int(sus1.width * 1.05));
		sus1.antialiasing = ClientPrefs.globalAntialiasing;
		add(sus1);
		sus1.alpha = 0.0;
		
		black = new FlxSprite(-10, -10).loadGraphic(Paths.image('freeplay/black'));
		black.setGraphicSize(Std.int(black.width * 1.05));
		black.antialiasing = ClientPrefs.globalAntialiasing;
		add(black);
		black.alpha = 0.0;
		
		fella1 = new FlxSprite(-10, -10).loadGraphic(Paths.image('freeplay/fella-1'));
		fella1.setGraphicSize(Std.int(fella1.width * 1.05));
		fella1.antialiasing = ClientPrefs.globalAntialiasing;
		add(fella1);
		fella1.alpha = 0.0;
		
		yellow = new FlxSprite(-10, -10).loadGraphic(Paths.image('freeplay/yellow'));
		yellow.setGraphicSize(Std.int(yellow.width * 1.05));
		yellow.antialiasing = ClientPrefs.globalAntialiasing;
		add(yellow);
		yellow.alpha = 0.0;
		
		white = new FlxSprite(-10, -10).loadGraphic(Paths.image('freeplay/white'));
		white.setGraphicSize(Std.int(white.width * 1.05));
		white.antialiasing = ClientPrefs.globalAntialiasing;
		add(white);
		white.alpha = 0.0;
		
		wb = new FlxSprite(-10, -10).loadGraphic(Paths.image('freeplay/white-black'));
		wb.setGraphicSize(Std.int(wb.width * 1.05));
		wb.antialiasing = ClientPrefs.globalAntialiasing;
		add(wb);
		wb.alpha = 0.0;
		
		henry = new FlxSprite(-10, -10).loadGraphic(Paths.image('freeplay/henry'));
		henry.setGraphicSize(Std.int(henry.width * 1.05));
		henry.antialiasing = ClientPrefs.globalAntialiasing;
		add(henry);
		henry.alpha = 0.0;
		
		maroon = new FlxSprite(-10, -10).loadGraphic(Paths.image('freeplay/maroon'));
		maroon.setGraphicSize(Std.int(maroon.width * 1.05));
		maroon.antialiasing = ClientPrefs.globalAntialiasing;
		add(maroon);
		maroon.alpha = 0.0;
		
		gray = new FlxSprite(-10, -10).loadGraphic(Paths.image('freeplay/gray'));
		gray.setGraphicSize(Std.int(gray.width * 1.05));
		gray.antialiasing = ClientPrefs.globalAntialiasing;
		add(gray);
		maroon.alpha = 0.0;
		
		double1 = new FlxSprite(-10, -10).loadGraphic(Paths.image('freeplay/double-1'));
		double1.setGraphicSize(Std.int(double1.width * 1.05));
		double1.antialiasing = ClientPrefs.globalAntialiasing;
		add(double1);
		maroon.alpha = 0.0;
		
		cz = new FlxSprite(-10, -10).loadGraphic(Paths.image('freeplay/clowfoe-ziffy'));
		cz.setGraphicSize(Std.int(cz.width * 1.05));
		cz.antialiasing = ClientPrefs.globalAntialiasing;
		add(cz);
		cz.alpha = 0.0;

		jorsawsee = new FlxSprite(-10, -10).loadGraphic(Paths.image('freeplay/jorsawsee'));
		jorsawsee.setGraphicSize(Std.int(jorsawsee.width * 1.05));
		jorsawsee.antialiasing = ClientPrefs.globalAntialiasing;
		add(jorsawsee);
		jorsawsee.alpha = 0.0;
		
		bfi = new FlxSprite(-10, -10).loadGraphic(Paths.image('freeplay/bf-impostor'));
		bfi.setGraphicSize(Std.int(bfi.width * 1.05));
		bfi.antialiasing = ClientPrefs.globalAntialiasing;
		add(bfi);
		bfi.alpha = 0.0;

		tt = new FlxSprite(-10, -10).loadGraphic(Paths.image('freeplay/tt'));
		tt.setGraphicSize(Std.int(tt.width * 1.05));
		tt.antialiasing = ClientPrefs.globalAntialiasing;
		add(tt);
		tt.alpha = 0.0;
		
		sus = new FlxSprite(-10, -10).loadGraphic(Paths.image('freeplay/sus'));
		sus.setGraphicSize(Std.int(sus.width * 1.05));
		sus.antialiasing = ClientPrefs.globalAntialiasing;
		add(sus);
		sus.alpha = 0.0;
		
		infi = new FlxSprite(-10, -10).loadGraphic(Paths.image('freeplay/infi'));
		infi.setGraphicSize(Std.int(infi.width * 1.05));
		infi.antialiasing = ClientPrefs.globalAntialiasing;
		add(infi);
		infi.alpha = 0.0;
		
		pink = new FlxSprite(-10, -10).loadGraphic(Paths.image('freeplay/pink'));
		pink.setGraphicSize(Std.int(pink.width * 1.05));
		pink.antialiasing = ClientPrefs.globalAntialiasing;
		add(pink);
		pink.alpha = 0.0;

		var gradient:FlxSprite = new FlxSprite(0, 100).loadGraphic(Paths.image('menuGr'));
		gradient.scrollFactor.x = 0;
		gradient.scrollFactor.y = 0.10;
		gradient.setGraphicSize(Std.int(gradient.width * 1.1));
		gradient.updateHitbox();
		gradient.screenCenter(X);

		grpSongs = new FlxTypedGroup<SusFont>();

		for (i in 0...songs.length)
		{
			var songText:SusFont = new SusFont(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.antialiasing = ClientPrefs.globalAntialiasing;
			songText.targetY = i;
			
			switch(songs[i].week)
			{
				case 0: 
				{	
					var FreeplayBox:FpBox = new FpBox(0);
					FreeplayBox.setGraphicSize(Std.int(FreeplayBox.width * 1.1));
					FreeplayBox.sprTracker = songText;
					FpBoxArray.push(FreeplayBox);
					add(FreeplayBox);
				}
				case 1: 
				{	
					var FreeplayBox:FpBox = new FpBox(1);
					FreeplayBox.setGraphicSize(Std.int(FreeplayBox.width * 1.1));
					FreeplayBox.sprTracker = songText;
					FpBoxArray.push(FreeplayBox);
					add(FreeplayBox);
				}
				case 2: 
				{	
					var FreeplayBox:FpBox = new FpBox(2);
					FreeplayBox.setGraphicSize(Std.int(FreeplayBox.width * 1.1));
					FreeplayBox.sprTracker = songText;
					FpBoxArray.push(FreeplayBox);
					add(FreeplayBox);
				}
				case 3: 
				{	
					var FreeplayBox:FpBox = new FpBox(3);
					FreeplayBox.setGraphicSize(Std.int(FreeplayBox.width * 1.1));
					FreeplayBox.sprTracker = songText;
					FpBoxArray.push(FreeplayBox);
					add(FreeplayBox);
				}
				case 4: 
				{	
					var FreeplayBox:FpBox = new FpBox(4);
					FreeplayBox.setGraphicSize(Std.int(FreeplayBox.width * 1.1));
					FreeplayBox.sprTracker = songText;
					FpBoxArray.push(FreeplayBox);
					add(FreeplayBox);
				}
				case 5: 
				{	
					var FreeplayBox:FpBox = new FpBox(5);
					FreeplayBox.setGraphicSize(Std.int(FreeplayBox.width * 1.1));
					FreeplayBox.sprTracker = songText;
					FpBoxArray.push(FreeplayBox);
					add(FreeplayBox);
				}
				case 6: 
				{	
					var FreeplayBox:FpBox = new FpBox(6);
					FreeplayBox.setGraphicSize(Std.int(FreeplayBox.width * 1.1));
					FreeplayBox.sprTracker = songText;
					FpBoxArray.push(FreeplayBox);
					add(FreeplayBox);
				}
				case 7: 
				{	
					var FreeplayBox:FpBox = new FpBox(7);
					FreeplayBox.setGraphicSize(Std.int(FreeplayBox.width * 1.1));
					FreeplayBox.sprTracker = songText;
					FpBoxArray.push(FreeplayBox);
					add(FreeplayBox);
				}
				case 8: 
				{	
					var FreeplayBox:FpBox = new FpBox(8);
					FreeplayBox.setGraphicSize(Std.int(FreeplayBox.width * 1.1));
					FreeplayBox.sprTracker = songText;
					FpBoxArray.push(FreeplayBox);
					add(FreeplayBox);
				}
				case 9: 
				{	
					var FreeplayBox:FpBox = new FpBox(9);
					FreeplayBox.setGraphicSize(Std.int(FreeplayBox.width * 1.1));
					FreeplayBox.sprTracker = songText;
					FpBoxArray.push(FreeplayBox);
					add(FreeplayBox);
				}
				case 10: 
				{	
					var FreeplayBox:FpBox = new FpBox(10);
					FreeplayBox.setGraphicSize(Std.int(FreeplayBox.width * 1.1));
					FreeplayBox.sprTracker = songText;
					FpBoxArray.push(FreeplayBox);
					add(FreeplayBox);
				}
				case 11: 
				{	
					var FreeplayBox:FpBox = new FpBox(11);
					FreeplayBox.setGraphicSize(Std.int(FreeplayBox.width * 1.1));
					FreeplayBox.sprTracker = songText;
					FpBoxArray.push(FreeplayBox);
					add(FreeplayBox);
				}
				case 12: 
				{	
					var FreeplayBox:FpBox = new FpBox(12);
					FreeplayBox.setGraphicSize(Std.int(FreeplayBox.width * 1.1));
					FreeplayBox.sprTracker = songText;
					FpBoxArray.push(FreeplayBox);
					add(FreeplayBox);
				}
				case 13: 
				{	
					var FreeplayBox:FpBox = new FpBox(13);
					FreeplayBox.setGraphicSize(Std.int(FreeplayBox.width * 1.1));
					FreeplayBox.sprTracker = songText;
					FpBoxArray.push(FreeplayBox);
					add(FreeplayBox);
				}
				case 14: 
				{	
					var FreeplayBox:FpBox = new FpBox(14);
					FreeplayBox.setGraphicSize(Std.int(FreeplayBox.width * 1.1));
					FreeplayBox.sprTracker = songText;
					FpBoxArray.push(FreeplayBox);
					add(FreeplayBox);
				}
				case 15: 
				{	
					var FreeplayBox:FpBox = new FpBox(15);
					FreeplayBox.setGraphicSize(Std.int(FreeplayBox.width * 1.1));
					FreeplayBox.sprTracker = songText;
					FpBoxArray.push(FreeplayBox);
					add(FreeplayBox);
				}
				case 16: 
				{	
					var FreeplayBox:FpBox = new FpBox(16);
					FreeplayBox.setGraphicSize(Std.int(FreeplayBox.width * 1.1));
					FreeplayBox.sprTracker = songText;
					FpBoxArray.push(FreeplayBox);
					add(FreeplayBox);
				}
				case 17: 
				{	
					var FreeplayBox:FpBox = new FpBox(17);
					FreeplayBox.setGraphicSize(Std.int(FreeplayBox.width * 1.1));
					FreeplayBox.sprTracker = songText;
					FpBoxArray.push(FreeplayBox);
					add(FreeplayBox);
				}
				case 18: 
				{	
					var FreeplayBox:FpBox = new FpBox(18);
					FreeplayBox.setGraphicSize(Std.int(FreeplayBox.width * 1.1));
					FreeplayBox.sprTracker = songText;
					FpBoxArray.push(FreeplayBox);
					add(FreeplayBox);
				}
				case 19: 
				{	
					var FreeplayBox:FpBox = new FpBox(19);
					FreeplayBox.setGraphicSize(Std.int(FreeplayBox.width * 1.1));
					FreeplayBox.sprTracker = songText;
					FpBoxArray.push(FreeplayBox);
					add(FreeplayBox);
				}
				case 20: 
				{	
					var FreeplayBox:FpBox = new FpBox(20);
					FreeplayBox.setGraphicSize(Std.int(FreeplayBox.width * 1.1));
					FreeplayBox.sprTracker = songText;
					FpBoxArray.push(FreeplayBox);
					add(FreeplayBox);
				}
				case 21: 
				{	
					var FreeplayBox:FpBox = new FpBox(21);
					FreeplayBox.setGraphicSize(Std.int(FreeplayBox.width * 1.1));
					FreeplayBox.sprTracker = songText;
					FpBoxArray.push(FreeplayBox);
					add(FreeplayBox);
				}
				case 22: 
				{	
					var FreeplayBox:FpBox = new FpBox(22);
					FreeplayBox.setGraphicSize(Std.int(FreeplayBox.width * 1.1));
					FreeplayBox.sprTracker = songText;
					FpBoxArray.push(FreeplayBox);
					add(FreeplayBox);
				}
				case 23: 
				{	
					var FreeplayBox:FpBox = new FpBox(23);
					FreeplayBox.setGraphicSize(Std.int(FreeplayBox.width * 1.1));
					FreeplayBox.sprTracker = songText;
					FpBoxArray.push(FreeplayBox);
					add(FreeplayBox);
				}
				case 24: 
				{	
					var FreeplayBox:FpBox = new FpBox(24);
					FreeplayBox.setGraphicSize(Std.int(FreeplayBox.width * 1.1));
					FreeplayBox.sprTracker = songText;
					FpBoxArray.push(FreeplayBox);
					add(FreeplayBox);
				}
				case 25: 
				{	
					var FreeplayBox:FpBox = new FpBox(25);
					FreeplayBox.setGraphicSize(Std.int(FreeplayBox.width * 1.1));
					FreeplayBox.sprTracker = songText;
					FpBoxArray.push(FreeplayBox);
					add(FreeplayBox);
				}
				case 26: 
				{	
					var FreeplayBox:FpBox = new FpBox(26);
					FreeplayBox.setGraphicSize(Std.int(FreeplayBox.width * 1.1));
					FreeplayBox.sprTracker = songText;
					FpBoxArray.push(FreeplayBox);
					add(FreeplayBox);
				}
				case 27: 
				{	
					var FreeplayBox:FpBox = new FpBox(27);
					FreeplayBox.setGraphicSize(Std.int(FreeplayBox.width * 1.1));
					FreeplayBox.sprTracker = songText;
					FpBoxArray.push(FreeplayBox);
					add(FreeplayBox);
				}
				case 28: 
				{	
					var FreeplayBox:FpBox = new FpBox(28);
					FreeplayBox.setGraphicSize(Std.int(FreeplayBox.width * 1.1));
					FreeplayBox.sprTracker = songText;
					FpBoxArray.push(FreeplayBox);
					add(FreeplayBox);
				}
				case 29: 
				{	
					var FreeplayBox:FpBox = new FpBox(29);
					FreeplayBox.setGraphicSize(Std.int(FreeplayBox.width * 1.1));
					FreeplayBox.sprTracker = songText;
					FpBoxArray.push(FreeplayBox);
					add(FreeplayBox);
				}
				case 30: 
				{	
					var FreeplayBox:FpBox = new FpBox(30);
					FreeplayBox.setGraphicSize(Std.int(FreeplayBox.width * 1.1));
					FreeplayBox.sprTracker = songText;
					FpBoxArray.push(FreeplayBox);
					add(FreeplayBox);
				}
				case 31: 
				{	
					var FreeplayBox:FpBox = new FpBox(31);
					FreeplayBox.setGraphicSize(Std.int(FreeplayBox.width * 1.1));
					FreeplayBox.sprTracker = songText;
					FpBoxArray.push(FreeplayBox);
					add(FreeplayBox);
				}
				case 32: 
				{	
					var FreeplayBox:FpBox = new FpBox(32);
					FreeplayBox.setGraphicSize(Std.int(FreeplayBox.width * 1.1));
					FreeplayBox.sprTracker = songText;
					FpBoxArray.push(FreeplayBox);
					add(FreeplayBox);
				}
				case 33: 
				{	
					var FreeplayBox:FpBox = new FpBox(33);
					FreeplayBox.setGraphicSize(Std.int(FreeplayBox.width * 1.1));
					FreeplayBox.sprTracker = songText;
					FpBoxArray.push(FreeplayBox);
					add(FreeplayBox);
				}
				case 34: 
				{	
					var FreeplayBox:FpBox = new FpBox(34);
					FreeplayBox.setGraphicSize(Std.int(FreeplayBox.width * 1.1));
					FreeplayBox.sprTracker = songText;
					FpBoxArray.push(FreeplayBox);
					add(FreeplayBox);
				}
				case 35: 
				{	
					var FreeplayBox:FpBox = new FpBox(35);
					FreeplayBox.setGraphicSize(Std.int(FreeplayBox.width * 1.1));
					FreeplayBox.sprTracker = songText;
					FpBoxArray.push(FreeplayBox);
					add(FreeplayBox);
				}
				case 36: 
				{	
					var FreeplayBox:FpBox = new FpBox(36);
					FreeplayBox.setGraphicSize(Std.int(FreeplayBox.width * 1.1));
					FreeplayBox.sprTracker = songText;
					FpBoxArray.push(FreeplayBox);
					add(FreeplayBox);
				}
				case 37: 
				{	
					var FreeplayBox:FpBox = new FpBox(37);
					FreeplayBox.setGraphicSize(Std.int(FreeplayBox.width * 1.1));
					FreeplayBox.sprTracker = songText;
					FpBoxArray.push(FreeplayBox);
					add(FreeplayBox);
				}
				case 38: 
				{	
					var FreeplayBox:FpBox = new FpBox(38);
					FreeplayBox.setGraphicSize(Std.int(FreeplayBox.width * 1.1));
					FreeplayBox.sprTracker = songText;
					FpBoxArray.push(FreeplayBox);
					add(FreeplayBox);
				}
				case 39: 
				{	
					var FreeplayBox:FpBox = new FpBox(39);
					FreeplayBox.setGraphicSize(Std.int(FreeplayBox.width * 1.1));
					FreeplayBox.sprTracker = songText;
					FpBoxArray.push(FreeplayBox);
					add(FreeplayBox);
				}
				case 40: 
				{	
					var FreeplayBox:FpBox = new FpBox(40);
					FreeplayBox.setGraphicSize(Std.int(FreeplayBox.width * 1.1));
					FreeplayBox.sprTracker = songText;
					FpBoxArray.push(FreeplayBox);
					add(FreeplayBox);
				}
				case 41: 
				{	
					var FreeplayBox:FpBox = new FpBox(41);
					FreeplayBox.setGraphicSize(Std.int(FreeplayBox.width * 1.1));
					FreeplayBox.sprTracker = songText;
					FpBoxArray.push(FreeplayBox);
					add(FreeplayBox);
				}
			}
			
			grpSongs.add(songText);

			Paths.currentModDirectory = songs[i].folder;
			
			switch(songs[i].week)
			{
				case 0: 
				{	
					var icon:FpIcon = new FpIcon(songs[i].songCharacter, 0);
					icon.scale.set(0.7, 0.7);
					icon.sprTracker = songText;
					iconArray.push(icon);
					add(icon);
				}
				case 1: 
				{	
					var icon:FpIcon = new FpIcon(songs[i].songCharacter, 1);
					icon.scale.set(0.7, 0.7);
					icon.sprTracker = songText;
					iconArray.push(icon);
					add(icon);
				}
				case 2: 
				{	
					var icon:FpIcon = new FpIcon(songs[i].songCharacter, 2);
					icon.scale.set(0.7, 0.7);
					icon.sprTracker = songText;
					iconArray.push(icon);
					add(icon);
				}
				case 3: 
				{	
					var icon:FpIcon = new FpIcon(songs[i].songCharacter, 3);
					icon.scale.set(0.7, 0.7);
					icon.sprTracker = songText;
					iconArray.push(icon);
					add(icon);
				}
				case 4: 
				{	
					var icon:FpIcon = new FpIcon(songs[i].songCharacter, 4);
					icon.scale.set(0.7, 0.7);
					icon.sprTracker = songText;
					iconArray.push(icon);
					add(icon);
				}
				case 5: 
				{	
					var icon:FpIcon = new FpIcon(songs[i].songCharacter, 5);
					icon.scale.set(0.7, 0.7);
					icon.sprTracker = songText;
					iconArray.push(icon);
					add(icon);
				}
				case 6: 
				{	
					var icon:FpIcon = new FpIcon(songs[i].songCharacter, 6);
					icon.scale.set(0.7, 0.7);
					icon.sprTracker = songText;
					iconArray.push(icon);
					add(icon);
				}
				case 7: 
				{	
					var icon:FpIcon = new FpIcon(songs[i].songCharacter, 7);
					icon.scale.set(0.7, 0.7);
					icon.sprTracker = songText;
					iconArray.push(icon);
					add(icon);
				}
				case 8: 
				{	
					var icon:FpIcon = new FpIcon(songs[i].songCharacter, 8);
					icon.scale.set(0.7, 0.7);
					icon.sprTracker = songText;
					iconArray.push(icon);
					add(icon);
				}
				case 9: 
				{	
					var icon:FpIcon = new FpIcon(songs[i].songCharacter, 9);
					icon.scale.set(0.7, 0.7);
					icon.sprTracker = songText;
					iconArray.push(icon);
					add(icon);
				}
				case 10: 
				{	
					var icon:FpIcon = new FpIcon(songs[i].songCharacter, 10);
					icon.scale.set(0.7, 0.7);
					icon.sprTracker = songText;
					iconArray.push(icon);
					add(icon);
				}
				case 11: 
				{	
					var icon:FpIcon = new FpIcon(songs[i].songCharacter, 11);
					icon.scale.set(0.7, 0.7);
					icon.sprTracker = songText;
					iconArray.push(icon);
					add(icon);
				}
				case 12: 
				{	
					var icon:FpIcon = new FpIcon(songs[i].songCharacter, 12);
					icon.scale.set(0.7, 0.7);
					icon.sprTracker = songText;
					iconArray.push(icon);
					add(icon);
				}
				case 13: 
				{	
					var icon:FpIcon = new FpIcon(songs[i].songCharacter, 13);
					icon.scale.set(0.7, 0.7);
					icon.sprTracker = songText;
					iconArray.push(icon);
					add(icon);
				}
				case 14: 
				{	
					var icon:FpIcon = new FpIcon(songs[i].songCharacter, 14);
					icon.scale.set(0.7, 0.7);
					icon.sprTracker = songText;
					iconArray.push(icon);
					add(icon);
				}
				case 15: 
				{	
					var icon:FpIcon = new FpIcon(songs[i].songCharacter, 15);
					icon.scale.set(0.7, 0.7);
					icon.sprTracker = songText;
					iconArray.push(icon);
					add(icon);
				}
				case 16: 
				{	
					var icon:FpIcon = new FpIcon(songs[i].songCharacter, 16);
					icon.scale.set(0.7, 0.7);
					icon.sprTracker = songText;
					iconArray.push(icon);
					add(icon);
				}
				case 17: 
				{	
					var icon:FpIcon = new FpIcon(songs[i].songCharacter, 17);
					icon.scale.set(0.7, 0.7);
					icon.sprTracker = songText;
					iconArray.push(icon);
					add(icon);
				}
				case 18: 
				{	
					var icon:FpIcon = new FpIcon(songs[i].songCharacter, 18);
					icon.scale.set(0.7, 0.7);
					icon.sprTracker = songText;
					iconArray.push(icon);
					add(icon);
				}
				case 19: 
				{	
					var icon:FpIcon = new FpIcon(songs[i].songCharacter, 19);
					icon.scale.set(0.7, 0.7);
					icon.sprTracker = songText;
					iconArray.push(icon);
					add(icon);
				}
				case 20: 
				{	
					var icon:FpIcon = new FpIcon(songs[i].songCharacter, 20);
					icon.scale.set(0.7, 0.7);
					icon.sprTracker = songText;
					iconArray.push(icon);
					add(icon);
				}
				case 21: 
				{	
					var icon:FpIcon = new FpIcon(songs[i].songCharacter, 21);
					icon.scale.set(0.7, 0.7);
					icon.sprTracker = songText;
					iconArray.push(icon);
					add(icon);
				}
				case 22: 
				{	
					var icon:FpIcon = new FpIcon(songs[i].songCharacter, 22);
					icon.scale.set(0.7, 0.7);
					icon.sprTracker = songText;
					iconArray.push(icon);
					add(icon);
				}
				case 23: 
				{	
					var icon:FpIcon = new FpIcon(songs[i].songCharacter, 23);
					icon.scale.set(0.7, 0.7);
					icon.sprTracker = songText;
					iconArray.push(icon);
					add(icon);
				}
				case 24: 
				{	
					var icon:FpIcon = new FpIcon(songs[i].songCharacter, 24);
					icon.scale.set(0.7, 0.7);
					icon.sprTracker = songText;
					iconArray.push(icon);
					add(icon);
				}
				case 25: 
				{	
					var icon:FpIcon = new FpIcon(songs[i].songCharacter, 25);
					icon.scale.set(0.7, 0.7);
					icon.sprTracker = songText;
					iconArray.push(icon);
					add(icon);
				}
				case 26: 
				{	
					var icon:FpIcon = new FpIcon(songs[i].songCharacter, 26);
					icon.scale.set(0.7, 0.7);
					icon.sprTracker = songText;
					iconArray.push(icon);
					add(icon);
				}
				case 27: 
				{	
					var icon:FpIcon = new FpIcon(songs[i].songCharacter, 27);
					icon.scale.set(0.7, 0.7);
					icon.sprTracker = songText;
					iconArray.push(icon);
					add(icon);
				}
				case 28: 
				{	
					var icon:FpIcon = new FpIcon(songs[i].songCharacter, 28);
					icon.scale.set(0.7, 0.7);
					icon.sprTracker = songText;
					iconArray.push(icon);
					add(icon);
				}
				case 29: 
				{	
					var icon:FpIcon = new FpIcon(songs[i].songCharacter, 29);
					icon.scale.set(0.7, 0.7);
					icon.sprTracker = songText;
					iconArray.push(icon);
					add(icon);
				}
				case 30: 
				{	
					var icon:FpIcon = new FpIcon(songs[i].songCharacter, 30);
					icon.scale.set(0.7, 0.7);
					icon.sprTracker = songText;
					iconArray.push(icon);
					add(icon);
				}
				case 31: 
				{	
					var icon:FpIcon = new FpIcon(songs[i].songCharacter, 31);
					icon.scale.set(0.7, 0.7);
					icon.sprTracker = songText;
					iconArray.push(icon);
					add(icon);
				}
				case 32: 
				{	
					var icon:FpIcon = new FpIcon(songs[i].songCharacter, 32);
					icon.scale.set(0.7, 0.7);
					icon.sprTracker = songText;
					iconArray.push(icon);
					add(icon);
				}
				case 33: 
				{	
					var icon:FpIcon = new FpIcon(songs[i].songCharacter, 33);
					icon.scale.set(0.7, 0.7);
					icon.sprTracker = songText;
					iconArray.push(icon);
					add(icon);
				}
				case 34: 
				{	
					var icon:FpIcon = new FpIcon(songs[i].songCharacter, 34);
					icon.scale.set(0.7, 0.7);
					icon.sprTracker = songText;
					iconArray.push(icon);
					add(icon);
				}
				case 35: 
				{	
					var icon:FpIcon = new FpIcon(songs[i].songCharacter, 35);
					icon.scale.set(0.7, 0.7);
					icon.sprTracker = songText;
					iconArray.push(icon);
					add(icon);
				}
				case 36: 
				{	
					var icon:FpIcon = new FpIcon(songs[i].songCharacter, 36);
					icon.scale.set(0.7, 0.7);
					icon.sprTracker = songText;
					iconArray.push(icon);
					add(icon);
				}
				case 37: 
				{	
					var icon:FpIcon = new FpIcon(songs[i].songCharacter, 37);
					icon.scale.set(0.7, 0.7);
					icon.sprTracker = songText;
					iconArray.push(icon);
					add(icon);
				}
				case 38: 
				{	
					var icon:FpIcon = new FpIcon(songs[i].songCharacter, 38);
					icon.scale.set(0.7, 0.7);
					icon.sprTracker = songText;
					iconArray.push(icon);
					add(icon);
				}
				case 39: 
				{	
					var icon:FpIcon = new FpIcon(songs[i].songCharacter, 39);
					icon.scale.set(0.7, 0.7);
					icon.sprTracker = songText;
					iconArray.push(icon);
					add(icon);
				}
				case 40: 
				{	
					var icon:FpIcon = new FpIcon(songs[i].songCharacter, 40);
					icon.scale.set(0.7, 0.7);
					icon.sprTracker = songText;
					iconArray.push(icon);
					add(icon);
				}
				case 41: 
				{	
					var icon:FpIcon = new FpIcon(songs[i].songCharacter, 41);
					icon.scale.set(0.7, 0.7);
					icon.sprTracker = songText;
					iconArray.push(icon);
					add(icon);
				}
			}
		}
		add(grpSongs);
		
		WeekData.setDirectoryFromWeek();

		scoreText = new FlxText(FlxG.width * 0.7, 100, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		scoreText1 = new FlxText(scoreText.x + 270, scoreText.y + 30, 0, "", 32);
		scoreText1.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		diffText = new FlxText(scoreText.x + 265, scoreText.y + 60, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);
		add(scoreText1);

		if(curSelected >= songs.length) curSelected = 0;
		bg.color = songs[curSelected].color;
		intendedColor = bg.color;

		if(lastDifficultyName == '')
		{
			lastDifficultyName = CoolUtil.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficultyName)));
		
		changeSelection();
		changeDiff();
		
		var coolthing:FlxSprite = new FlxSprite(-100, -10).loadGraphic(Paths.image('freeplay/FreeplayThing'));
		coolthing.scrollFactor.set();
		coolthing.setGraphicSize(Std.int(coolthing.width * 1.1));
		coolthing.updateHitbox();
		add(coolthing);
		
		super.create();
	}

	override function closeSubState() {
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	/*public function addWeek(songs:Array<String>, weekNum:Int, weekColor:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);
			this.songs[this.songs.length-1].color = weekColor;

			if (songCharacters.length != 1)
				num++;
		}
	}*/

	var instPlaying:Int = -1;
	private static var vocals:FlxSound = null;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		grpSongs.forEach(function(spr:FlxSprite)
		{
			starFG.x -= 0.003;
			starBG.x -= 0.001;
		});
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, CoolUtil.boundTo(elapsed * 12, 0, 1));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(Highscore.floorDecimal(lerpRating * 100, 2)).split('.');
		if(ratingSplit.length < 2) { //No decimals, add an empty space
			ratingSplit.push('');
		}
		
		while(ratingSplit[1].length < 2) { //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';
		}

		scoreText.text = '' + lerpScore;
		scoreText1.text = '' + ratingSplit;
		
		positionHighscore();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;
		var space = FlxG.keys.justPressed.SPACE;
		var ctrl = FlxG.keys.justPressed.CONTROL;

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

		if(songs.length > 1)
		{
			if (upP)
			{
				changeSelection(-shiftMult);
				holdTime = 0;
			}
			if (downP)
			{
				changeSelection(shiftMult);
				holdTime = 0;
			}

			if(controls.UI_DOWN || controls.UI_UP)
			{
				var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
				holdTime += elapsed;
				var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

				if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
				{
					changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					changeDiff();
				}
			}
		}

		if (controls.UI_LEFT_P)
			changeDiff(-1);
		else if (controls.UI_RIGHT_P)
			changeDiff(1);
		else if (upP || downP) changeDiff();

		if (controls.BACK)
		{
			persistentUpdate = false;
			if(colorTween != null) {
				colorTween.cancel();
			}
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		if(ctrl)
		{
			persistentUpdate = false;
			openSubState(new GameplayChangersSubstate());
		}
		else if(space)
		{
			if(instPlaying != curSelected)
			{
				#if PRELOAD_ALL
				destroyFreeplayVocals();
				FlxG.sound.music.volume = 0;
				Paths.currentModDirectory = songs[curSelected].folder;
				var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
				PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
				if (PlayState.SONG.needsVoices)
					vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
				else
					vocals = new FlxSound();

				FlxG.sound.list.add(vocals);
				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.7);
				vocals.play();
				vocals.persist = true;
				vocals.looped = true;
				vocals.volume = 0.7;
				instPlaying = curSelected;
				#end
			}
		}

		else if (accepted)
		{
			persistentUpdate = false;
			var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
			var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
			/*#if MODS_ALLOWED
			if(!sys.FileSystem.exists(Paths.modsJson(songLowercase + '/' + poop)) && !sys.FileSystem.exists(Paths.json(songLowercase + '/' + poop))) {
			#else
			if(!OpenFlAssets.exists(Paths.json(songLowercase + '/' + poop))) {
			#end
				poop = songLowercase;
				curDifficulty = 1;
				trace('Couldnt find file');
			}*/
			trace(poop);

			PlayState.SONG = Song.loadFromJson(poop, songLowercase);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;

			trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
			if(colorTween != null) {
				colorTween.cancel();
			}
			
			if (FlxG.keys.pressed.SHIFT){
				LoadingState.loadAndSwitchState(new ChartingState());
			}else{
				LoadingState.loadAndSwitchState(new PlayState());
			}

			FlxG.sound.music.volume = 0;
					
			destroyFreeplayVocals();
		}
		else if(controls.RESET)
		{
			persistentUpdate = false;
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
		super.update(elapsed);
	}

	public static function destroyFreeplayVocals() {
		if(vocals != null) {
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficulties.length-1;
		if (curDifficulty >= CoolUtil.difficulties.length)
			curDifficulty = 0;

		lastDifficultyName = CoolUtil.difficulties[curDifficulty];

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		PlayState.storyDifficulty = curDifficulty;
		diffText.text = '< ' + CoolUtil.difficultyString() + ' >';
		positionHighscore();
	}

	var red1Tween:FlxTween;
	var green1Tween:FlxTween;
	var sus1Tween:FlxTween;
	var blackTween:FlxTween;
	var fella1Tween:FlxTween;
	var yellowTween:FlxTween;
	var whiteTween:FlxTween;
	var wbTween:FlxTween;
	var henryTween:FlxTween;
	var maroonTween:FlxTween;
	var grayTween:FlxTween;
	var double1Tween:FlxTween;
	var czTween:FlxTween;
	var jorsawseeTween:FlxTween;
	var bfiTween:FlxTween;
	var ttTween:FlxTween;
	var susTween:FlxTween;
	var infiTween:FlxTween;
	var pinkTween:FlxTween;

	function cancelTweens()
	{
		red1Tween.cancel();
		green1Tween.cancel();
		sus1Tween.cancel();
		blackTween.cancel();
		fella1Tween.cancel();
		yellowTween.cancel();
		whiteTween.cancel();
		wbTween.cancel();
		henryTween.cancel();
		maroonTween.cancel();
		grayTween.cancel();
		double1Tween.cancel();
		czTween.cancel();
		jorsawseeTween.cancel();
		bfiTween.cancel();
		ttTween.cancel();
		susTween.cancel();
		infiTween.cancel();
		pinkTween.cancel();
	}	

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;
			
		var newColor:Int = songs[curSelected].color;
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (i in 0...FpBoxArray.length)
		{
			FpBoxArray[i].alpha = 0.6;
		}

		FpBoxArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
		
		Paths.currentModDirectory = songs[curSelected].folder;
		PlayState.storyWeek = songs[curSelected].week;

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		var diffStr:String = WeekData.getCurrentWeek().difficulties;
		if(diffStr != null) diffStr = diffStr.trim(); //Fuck you HTML5

		if(diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if(diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if(diffs[i].length < 1) diffs.remove(diffs[i]);
				}
				--i;
			}

			if(diffs.length > 0 && diffs[0].length > 0)
			{
				CoolUtil.difficulties = diffs;
			}
		}
		
		if(CoolUtil.difficulties.contains(CoolUtil.defaultDifficulty))
		{
			curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(CoolUtil.defaultDifficulty)));
		}
		else
		{
			curDifficulty = 0;
		}

		var newPos:Int = CoolUtil.difficulties.indexOf(lastDifficultyName);
		//trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
		if(newPos > -1)
		{
			curDifficulty = newPos;
		}
		
		switch(songs[curSelected].week) 
		{
			case 0 | 1 | 2 | 38:  //sussus-moogus, sabotage, meltdown, cleaning
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}

				red1Tween = FlxTween.tween(red1,{x: -40}, 0.5 ,{ease: FlxEase.expoOut});
				green1Tween = FlxTween.tween(green1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				sus1Tween = FlxTween.tween(sus1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				blackTween = FlxTween.tween(black,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				fella1Tween = FlxTween.tween(fella1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				yellowTween = FlxTween.tween(yellow,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				whiteTween = FlxTween.tween(white,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				wbTween = FlxTween.tween(wb,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				henryTween = FlxTween.tween(henry,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				maroonTween = FlxTween.tween(maroon,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				grayTween = FlxTween.tween(gray,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				double1Tween = FlxTween.tween(double1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				czTween = FlxTween.tween(cz,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				jorsawseeTween = FlxTween.tween(jorsawsee,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				bfiTween = FlxTween.tween(bfi,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				ttTween = FlxTween.tween(tt,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				susTween = FlxTween.tween(sus,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				infiTween = FlxTween.tween(infi,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				pinkTween = FlxTween.tween(pink,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				
				red1.alpha = 1.0;
				green1.alpha = 0.0;
				sus1.alpha = 0.0;
				black.alpha = 0.0;
				fella1.alpha = 0.0;
				yellow.alpha = 0.0;
				white.alpha = 0.0;
				wb.alpha = 0.0;
				henry.alpha = 0.0;
				maroon.alpha = 0.0;
				gray.alpha = 0.0;
				double1.alpha = 0.0;
				cz.alpha = 0.0;
				jorsawsee.alpha = 0.0;
				bfi.alpha = 0.0;
				tt.alpha = 0.0;
				sus.alpha = 0.0;
				infi.alpha = 0.0;
				pink.alpha = 0.0;
			}
			case 3 | 4 | 5 | 6:  //sussus-toogus, lights-down, reactor, ejected
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}

				red1Tween = FlxTween.tween(red1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				green1Tween = FlxTween.tween(green1,{x: -40}, 0.5 ,{ease: FlxEase.expoOut});
				sus1Tween = FlxTween.tween(sus1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				blackTween = FlxTween.tween(black,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				fella1Tween = FlxTween.tween(fella1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				yellowTween = FlxTween.tween(yellow,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				whiteTween = FlxTween.tween(white,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				wbTween = FlxTween.tween(wb,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				henryTween = FlxTween.tween(henry,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				maroonTween = FlxTween.tween(maroon,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				grayTween = FlxTween.tween(gray,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				double1Tween = FlxTween.tween(double1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				czTween = FlxTween.tween(cz,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				jorsawseeTween = FlxTween.tween(jorsawsee,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				bfiTween = FlxTween.tween(bfi,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				ttTween = FlxTween.tween(tt,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				susTween = FlxTween.tween(sus,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				infiTween = FlxTween.tween(infi,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				pinkTween = FlxTween.tween(pink,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				
				red1.alpha = 0.0;
				green1.alpha = 1.0;
				sus1.alpha = 0.0;
				black.alpha = 0.0;
				fella1.alpha = 0.0;
				yellow.alpha = 0.0;
				white.alpha = 0.0;
				wb.alpha = 0.0;
				henry.alpha = 0.0;
				maroon.alpha = 0.0;
				gray.alpha = 0.0;
				double1.alpha = 0.0;
				cz.alpha = 0.0;
				jorsawsee.alpha = 0.0;
				bfi.alpha = 0.0;
				tt.alpha = 0.0;
				sus.alpha = 0.0;
				infi.alpha = 0.0;
				pink.alpha = 0.0;
			}
			case 7 | 8 | 9: //sussy-bussy, rivals, chewmate
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}

				red1Tween = FlxTween.tween(red1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				green1Tween = FlxTween.tween(green1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				sus1Tween = FlxTween.tween(sus1,{x: -40}, 0.5 ,{ease: FlxEase.expoOut});
				blackTween = FlxTween.tween(black,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				fella1Tween = FlxTween.tween(fella1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				yellowTween = FlxTween.tween(yellow,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				whiteTween = FlxTween.tween(white,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				wbTween = FlxTween.tween(wb,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				henryTween = FlxTween.tween(henry,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				maroonTween = FlxTween.tween(maroon,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				grayTween = FlxTween.tween(gray,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				double1Tween = FlxTween.tween(double1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				czTween = FlxTween.tween(cz,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				jorsawseeTween = FlxTween.tween(jorsawsee,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				bfiTween = FlxTween.tween(bfi,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				ttTween = FlxTween.tween(tt,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				susTween = FlxTween.tween(sus,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				infiTween = FlxTween.tween(infi,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				pinkTween = FlxTween.tween(pink,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				
				red1.alpha = 0.0;
				green1.alpha = 0.0;
				sus1.alpha = 1.0;
				black.alpha = 0.0;
				fella1.alpha = 0.0;
				yellow.alpha = 0.0;
				white.alpha = 0.0;
				wb.alpha = 0.0;
				henry.alpha = 0.0;
				maroon.alpha = 0.0;
				gray.alpha = 0.0;
				double1.alpha = 0.0;
				cz.alpha = 0.0;
				jorsawsee.alpha = 0.0;
				bfi.alpha = 0.0;
				tt.alpha = 0.0;
				sus.alpha = 0.0;
				infi.alpha = 0.0;
				pink.alpha = 0.0;
			}
			case 10 | 17 | 19: //defeat, danger, death-blow
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}
				
				red1Tween = FlxTween.tween(red1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				green1Tween = FlxTween.tween(green1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				sus1Tween = FlxTween.tween(sus1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				blackTween = FlxTween.tween(black,{x: -40}, 0.5 ,{ease: FlxEase.expoOut});
				fella1Tween = FlxTween.tween(fella1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				yellowTween = FlxTween.tween(yellow,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				whiteTween = FlxTween.tween(white,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				wbTween = FlxTween.tween(wb,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				henryTween = FlxTween.tween(henry,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				maroonTween = FlxTween.tween(maroon,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				grayTween = FlxTween.tween(gray,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				double1Tween = FlxTween.tween(double1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				czTween = FlxTween.tween(cz,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				jorsawseeTween = FlxTween.tween(jorsawsee,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				bfiTween = FlxTween.tween(bfi,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				ttTween = FlxTween.tween(tt,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				susTween = FlxTween.tween(sus,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				infiTween = FlxTween.tween(infi,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				pinkTween = FlxTween.tween(pink,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				
				red1.alpha = 0.0;
				green1.alpha = 0.0;
				sus1.alpha = 0.0;
				black.alpha = 1.0;
				fella1.alpha = 0.0;
				yellow.alpha = 0.0;
				white.alpha = 0.0;
				wb.alpha = 0.0;
				henry.alpha = 0.0;
				maroon.alpha = 0.0;
				gray.alpha = 0.0;
				double1.alpha = 0.0;
				cz.alpha = 0.0;
				jorsawsee.alpha = 0.0;
				bfi.alpha = 0.0;
				tt.alpha = 0.0;
				sus.alpha = 0.0;
				infi.alpha = 0.0;
				pink.alpha = 0.0;
			}
			case 11 | 12: //christmas, spookpostor
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}
				
				red1Tween = FlxTween.tween(red1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				green1Tween = FlxTween.tween(green1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				sus1Tween = FlxTween.tween(sus1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				blackTween = FlxTween.tween(black,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				fella1Tween = FlxTween.tween(fella1,{x: -40}, 0.5 ,{ease: FlxEase.expoOut});
				yellowTween = FlxTween.tween(yellow,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				whiteTween = FlxTween.tween(white,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				wbTween = FlxTween.tween(wb,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				henryTween = FlxTween.tween(henry,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				maroonTween = FlxTween.tween(maroon,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				grayTween = FlxTween.tween(gray,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				double1Tween = FlxTween.tween(double1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				czTween = FlxTween.tween(cz,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				jorsawseeTween = FlxTween.tween(jorsawsee,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				bfiTween = FlxTween.tween(bfi,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				ttTween = FlxTween.tween(tt,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				susTween = FlxTween.tween(sus,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				infiTween = FlxTween.tween(infi,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				pinkTween = FlxTween.tween(pink,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				
				red1.alpha = 0.0;
				green1.alpha = 0.0;
				sus1.alpha = 0.0;
				black.alpha = 0.0;
				fella1.alpha = 1.0;
				yellow.alpha = 0.0;
				white.alpha = 0.0;
				wb.alpha = 0.0;
				henry.alpha = 0.0;
				maroon.alpha = 0.0;
				gray.alpha = 0.0;
				double1.alpha = 0.0;
				cz.alpha = 0.0;
				jorsawsee.alpha = 0.0;
				bfi.alpha = 0.0;
				tt.alpha = 0.0;
				sus.alpha = 0.0;
				infi.alpha = 0.0;
				pink.alpha = 0.0;
			}
			case 13 | 14: //mando, d'low
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}
				
				red1Tween = FlxTween.tween(red1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				green1Tween = FlxTween.tween(green1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				sus1Tween = FlxTween.tween(sus1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				blackTween = FlxTween.tween(black,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				fella1Tween = FlxTween.tween(fella1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				yellowTween = FlxTween.tween(yellow,{x: -40}, 0.5 ,{ease: FlxEase.expoOut});
				whiteTween = FlxTween.tween(white,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				wbTween = FlxTween.tween(wb,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				henryTween = FlxTween.tween(henry,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				maroonTween = FlxTween.tween(maroon,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				grayTween = FlxTween.tween(gray,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				double1Tween = FlxTween.tween(double1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				czTween = FlxTween.tween(cz,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				jorsawseeTween = FlxTween.tween(jorsawsee,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				bfiTween = FlxTween.tween(bfi,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				ttTween = FlxTween.tween(tt,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				susTween = FlxTween.tween(sus,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				infiTween = FlxTween.tween(infi,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				pinkTween = FlxTween.tween(pink,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				
				red1.alpha = 0.0;
				green1.alpha = 0.0;
				sus1.alpha = 0.0;
				black.alpha = 0.0;
				fella1.alpha = 0.0;
				yellow.alpha = 1.0;
				white.alpha = 0.0;
				wb.alpha = 0.0;
				henry.alpha = 0.0;
				maroon.alpha = 0.0;
				gray.alpha = 0.0;
				double1.alpha = 0.0;
				cz.alpha = 0.0;
				jorsawsee.alpha = 0.0;
				bfi.alpha = 0.0;
				tt.alpha = 0.0;
				sus.alpha = 0.0;
				infi.alpha = 0.0;
				pink.alpha = 0.0;
			}
			case 15 | 16: //oversight, influence
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}
				
				red1Tween = FlxTween.tween(red1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				green1Tween = FlxTween.tween(green1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				sus1Tween = FlxTween.tween(sus1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				blackTween = FlxTween.tween(black,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				fella1Tween = FlxTween.tween(fella1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				yellowTween = FlxTween.tween(yellow,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				whiteTween = FlxTween.tween(white,{x: -40}, 0.5 ,{ease: FlxEase.expoOut});
				wbTween = FlxTween.tween(wb,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				henryTween = FlxTween.tween(henry,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				maroonTween = FlxTween.tween(maroon,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				grayTween = FlxTween.tween(gray,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				double1Tween = FlxTween.tween(double1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				czTween = FlxTween.tween(cz,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				jorsawseeTween = FlxTween.tween(jorsawsee,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				bfiTween = FlxTween.tween(bfi,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				ttTween = FlxTween.tween(tt,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				susTween = FlxTween.tween(sus,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				infiTween = FlxTween.tween(infi,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				pinkTween = FlxTween.tween(pink,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				
				red1.alpha = 0.0;
				green1.alpha = 0.0;
				sus1.alpha = 0.0;
				black.alpha = 0.0;
				fella1.alpha = 0.0;
				yellow.alpha = 0.0;
				white.alpha = 1.0;
				wb.alpha = 0.0;
				henry.alpha = 0.0;
				maroon.alpha = 0.0;
				gray.alpha = 0.0;
				double1.alpha = 0.0;
				cz.alpha = 0.0;
				jorsawsee.alpha = 0.0;
				bfi.alpha = 0.0;
				tt.alpha = 0.0;
				sus.alpha = 0.0;
				infi.alpha = 0.0;
				pink.alpha = 0.0;
			}
			case 18 | 30: //double-kill, drip
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}
				
				red1Tween = FlxTween.tween(red1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				green1Tween = FlxTween.tween(green1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				sus1Tween = FlxTween.tween(sus1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				blackTween = FlxTween.tween(black,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				fella1Tween = FlxTween.tween(fella1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				yellowTween = FlxTween.tween(yellow,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				whiteTween = FlxTween.tween(white,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				wbTween = FlxTween.tween(wb,{x: -40}, 0.5 ,{ease: FlxEase.expoOut});
				henryTween = FlxTween.tween(henry,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				maroonTween = FlxTween.tween(maroon,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				grayTween = FlxTween.tween(gray,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				double1Tween = FlxTween.tween(double1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				czTween = FlxTween.tween(cz,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				jorsawseeTween = FlxTween.tween(jorsawsee,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				bfiTween = FlxTween.tween(bfi,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				ttTween = FlxTween.tween(tt,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				susTween = FlxTween.tween(sus,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				infiTween = FlxTween.tween(infi,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				pinkTween = FlxTween.tween(pink,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				
				red1.alpha = 0.0;
				green1.alpha = 0.0;
				sus1.alpha = 0.0;
				black.alpha = 0.0;
				fella1.alpha = 0.0;
				yellow.alpha = 0.0;
				white.alpha = 0.0;
				wb.alpha = 1.0;
				henry.alpha = 0.0;
				maroon.alpha = 0.0;
				gray.alpha = 0.0;
				double1.alpha = 0.0;
				cz.alpha = 0.0;
				jorsawsee.alpha = 0.0;
				bfi.alpha = 0.0;
				tt.alpha = 0.0;
				sus.alpha = 0.0;
				infi.alpha = 0.0;
				pink.alpha = 0.0;
			}
			case 26 | 27: //titular, mission
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}
				
				red1Tween = FlxTween.tween(red1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				green1Tween = FlxTween.tween(green1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				sus1Tween = FlxTween.tween(sus1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				blackTween = FlxTween.tween(black,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				fella1Tween = FlxTween.tween(fella1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				yellowTween = FlxTween.tween(yellow,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				whiteTween = FlxTween.tween(white,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				wbTween = FlxTween.tween(wb,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				henryTween = FlxTween.tween(henry,{x: -40}, 0.5 ,{ease: FlxEase.expoOut});
				maroonTween = FlxTween.tween(maroon,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				grayTween = FlxTween.tween(gray,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				double1Tween = FlxTween.tween(double1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				czTween = FlxTween.tween(cz,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				jorsawseeTween = FlxTween.tween(jorsawsee,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				bfiTween = FlxTween.tween(bfi,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				ttTween = FlxTween.tween(tt,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				susTween = FlxTween.tween(sus,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				infiTween = FlxTween.tween(infi,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				pinkTween = FlxTween.tween(pink,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				
				red1.alpha = 0.0;
				green1.alpha = 0.0;
				sus1.alpha = 0.0;
				black.alpha = 0.0;
				fella1.alpha = 0.0;
				yellow.alpha = 0.0;
				white.alpha = 0.0;
				wb.alpha = 0.0;
				henry.alpha = 1.0;
				maroon.alpha = 0.0;
				gray.alpha = 0.0;
				double1.alpha = 0.0;
				cz.alpha = 0.0;
				jorsawsee.alpha = 0.0;
				bfi.alpha = 0.0;
				tt.alpha = 0.0;
				sus.alpha = 0.0;
				infi.alpha = 0.0;
				pink.alpha = 0.0;
			}
			case 24 | 40: //boiling-point, bad-time
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}
				
				red1Tween = FlxTween.tween(red1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				green1Tween = FlxTween.tween(green1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				sus1Tween = FlxTween.tween(sus1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				blackTween = FlxTween.tween(black,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				fella1Tween = FlxTween.tween(fella1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				yellowTween = FlxTween.tween(yellow,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				whiteTween = FlxTween.tween(white,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				wbTween = FlxTween.tween(wb,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				henryTween = FlxTween.tween(henry,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				maroonTween = FlxTween.tween(maroon,{x: -40}, 0.5 ,{ease: FlxEase.expoOut});
				grayTween = FlxTween.tween(gray,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				double1Tween = FlxTween.tween(double1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				czTween = FlxTween.tween(cz,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				jorsawseeTween = FlxTween.tween(jorsawsee,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				bfiTween = FlxTween.tween(bfi,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				ttTween = FlxTween.tween(tt,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				susTween = FlxTween.tween(sus,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				infiTween = FlxTween.tween(infi,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				pinkTween = FlxTween.tween(pink,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				
				red1.alpha = 0.0;
				green1.alpha = 0.0;
				sus1.alpha = 0.0;
				black.alpha = 0.0;
				fella1.alpha = 0.0;
				yellow.alpha = 0.0;
				white.alpha = 0.0;
				wb.alpha = 0.0;
				henry.alpha = 0.0;
				maroon.alpha = 1.0;
				gray.alpha = 0.0;
				double1.alpha = 0.0;
				cz.alpha = 0.0;
				jorsawsee.alpha = 0.0;
				bfi.alpha = 0.0;
				tt.alpha = 0.0;
				sus.alpha = 0.0;
				infi.alpha = 0.0;
				pink.alpha = 0.0;
			}
			case 20 | 21 | 22 | 23 | 41: //insane, blackout, nyctophobia, massacre, despair
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}
				
				red1Tween = FlxTween.tween(red1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				green1Tween = FlxTween.tween(green1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				sus1Tween = FlxTween.tween(sus1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				blackTween = FlxTween.tween(black,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				fella1Tween = FlxTween.tween(fella1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				yellowTween = FlxTween.tween(yellow,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				whiteTween = FlxTween.tween(white,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				wbTween = FlxTween.tween(wb,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				henryTween = FlxTween.tween(henry,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				maroonTween = FlxTween.tween(maroon,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				grayTween = FlxTween.tween(gray,{x: -40}, 0.5 ,{ease: FlxEase.expoOut});
				double1Tween = FlxTween.tween(double1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				czTween = FlxTween.tween(cz,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				jorsawseeTween = FlxTween.tween(jorsawsee,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				bfiTween = FlxTween.tween(bfi,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				ttTween = FlxTween.tween(tt,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				susTween = FlxTween.tween(sus,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				infiTween = FlxTween.tween(infi,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				pinkTween = FlxTween.tween(pink,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				
				red1.alpha = 0.0;
				green1.alpha = 0.0;
				sus1.alpha = 0.0;
				black.alpha = 0.0;
				fella1.alpha = 0.0;
				yellow.alpha = 0.0;
				white.alpha = 0.0;
				wb.alpha = 0.0;
				henry.alpha = 0.0;
				maroon.alpha = 0.0;
				gray.alpha = 1.0;
				double1.alpha = 0.0;
				cz.alpha = 0.0;
				jorsawsee.alpha = 0.0;
				bfi.alpha = 0.0;
				tt.alpha = 0.0;
				sus.alpha = 0.0;
				infi.alpha = 0.0;
				pink.alpha = 0.0;
			}
			case 28 | 29 | 34: //double-trouble, double-ejection, boing!
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}
				
				red1Tween = FlxTween.tween(red1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				green1Tween = FlxTween.tween(green1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				sus1Tween = FlxTween.tween(sus1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				blackTween = FlxTween.tween(black,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				fella1Tween = FlxTween.tween(fella1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				yellowTween = FlxTween.tween(yellow,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				whiteTween = FlxTween.tween(white,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				wbTween = FlxTween.tween(wb,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				henryTween = FlxTween.tween(henry,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				maroonTween = FlxTween.tween(maroon,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				grayTween = FlxTween.tween(gray,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				double1Tween = FlxTween.tween(double1,{x: -40}, 0.5 ,{ease: FlxEase.expoOut});
				czTween = FlxTween.tween(cz,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				jorsawseeTween = FlxTween.tween(jorsawsee,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				bfiTween = FlxTween.tween(bfi,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				ttTween = FlxTween.tween(tt,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				susTween = FlxTween.tween(sus,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				infiTween = FlxTween.tween(infi,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				pinkTween = FlxTween.tween(pink,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				
				red1.alpha = 0.0;
				green1.alpha = 0.0;
				sus1.alpha = 0.0;
				black.alpha = 0.0;
				fella1.alpha = 0.0;
				yellow.alpha = 0.0;
				white.alpha = 0.0;
				wb.alpha = 0.0;
				henry.alpha = 0.0;
				maroon.alpha = 0.0;
				gray.alpha = 0.0;
				double1.alpha = 1.0;
				cz.alpha = 0.0;
				jorsawsee.alpha = 0.0;
				bfi.alpha = 0.0;
				tt.alpha = 0.0;
				sus.alpha = 0.0;
				infi.alpha = 0.0;
				pink.alpha = 0.0;
			}
			case 31: //skinny-nuts
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}
				
				red1Tween = FlxTween.tween(red1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				green1Tween = FlxTween.tween(green1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				sus1Tween = FlxTween.tween(sus1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				blackTween = FlxTween.tween(black,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				fella1Tween = FlxTween.tween(fella1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				yellowTween = FlxTween.tween(yellow,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				whiteTween = FlxTween.tween(white,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				wbTween = FlxTween.tween(wb,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				henryTween = FlxTween.tween(henry,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				maroonTween = FlxTween.tween(maroon,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				grayTween = FlxTween.tween(gray,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				double1Tween = FlxTween.tween(double1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				czTween = FlxTween.tween(cz,{x: -40}, 0.5 ,{ease: FlxEase.expoOut});
				jorsawseeTween = FlxTween.tween(jorsawsee,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				bfiTween = FlxTween.tween(bfi,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				ttTween = FlxTween.tween(tt,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				susTween = FlxTween.tween(sus,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				infiTween = FlxTween.tween(infi,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				pinkTween = FlxTween.tween(pink,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				
				red1.alpha = 0.0;
				green1.alpha = 0.0;
				sus1.alpha = 0.0;
				black.alpha = 0.0;
				fella1.alpha = 0.0;
				yellow.alpha = 0.0;
				white.alpha = 0.0;
				wb.alpha = 0.0;
				henry.alpha = 0.0;
				maroon.alpha = 0.0;
				gray.alpha = 0.0;
				double1.alpha = 0.0;
				cz.alpha = 1.0;
				jorsawsee.alpha = 0.0;
				bfi.alpha = 0.0;
				tt.alpha = 0.0;
				sus.alpha = 0.0;
				infi.alpha = 0.0;
				pink.alpha = 0.0;
			}
			case 32: //jorsawsee
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}
				
				red1Tween = FlxTween.tween(red1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				green1Tween = FlxTween.tween(green1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				sus1Tween = FlxTween.tween(sus1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				blackTween = FlxTween.tween(black,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				fella1Tween = FlxTween.tween(fella1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				yellowTween = FlxTween.tween(yellow,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				whiteTween = FlxTween.tween(white,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				wbTween = FlxTween.tween(wb,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				henryTween = FlxTween.tween(henry,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				maroonTween = FlxTween.tween(maroon,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				grayTween = FlxTween.tween(gray,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				double1Tween = FlxTween.tween(double1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				czTween = FlxTween.tween(cz,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				jorsawseeTween = FlxTween.tween(jorsawsee,{x: -40}, 0.5 ,{ease: FlxEase.expoOut});
				bfiTween = FlxTween.tween(bfi,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				ttTween = FlxTween.tween(tt,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				susTween = FlxTween.tween(sus,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				infiTween = FlxTween.tween(infi,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				pinkTween = FlxTween.tween(pink,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				
				red1.alpha = 0.0;
				green1.alpha = 0.0;
				sus1.alpha = 0.0;
				black.alpha = 0.0;
				fella1.alpha = 0.0;
				yellow.alpha = 0.0;
				white.alpha = 0.0;
				wb.alpha = 0.0;
				henry.alpha = 0.0;
				maroon.alpha = 0.0;
				gray.alpha = 0.0;
				double1.alpha = 0.0;
				cz.alpha = 0.0;
				jorsawsee.alpha = 1.0;
				bfi.alpha = 0.0;
				tt.alpha = 0.0;
				sus.alpha = 0.0;
				infi.alpha = 0.0;
				pink.alpha = 0.0;
			}
			case 33: //bf-defeat
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}
				
				red1Tween = FlxTween.tween(red1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				green1Tween = FlxTween.tween(green1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				sus1Tween = FlxTween.tween(sus1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				blackTween = FlxTween.tween(black,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				fella1Tween = FlxTween.tween(fella1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				yellowTween = FlxTween.tween(yellow,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				whiteTween = FlxTween.tween(white,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				wbTween = FlxTween.tween(wb,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				henryTween = FlxTween.tween(henry,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				maroonTween = FlxTween.tween(maroon,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				grayTween = FlxTween.tween(gray,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				double1Tween = FlxTween.tween(double1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				czTween = FlxTween.tween(cz,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				jorsawseeTween = FlxTween.tween(jorsawsee,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				bfiTween = FlxTween.tween(bfi,{x: -40}, 0.5 ,{ease: FlxEase.expoOut});
				ttTween = FlxTween.tween(tt,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				susTween = FlxTween.tween(sus,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				infiTween = FlxTween.tween(infi,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				pinkTween = FlxTween.tween(pink,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				
				red1.alpha = 0.0;
				green1.alpha = 0.0;
				sus1.alpha = 0.0;
				black.alpha = 0.0;
				fella1.alpha = 0.0;
				yellow.alpha = 0.0;
				white.alpha = 0.0;
				wb.alpha = 0.0;
				henry.alpha = 0.0;
				maroon.alpha = 0.0;
				gray.alpha = 0.0;
				double1.alpha = 0.0;
				cz.alpha = 0.0;
				jorsawsee.alpha = 0.0;
				bfi.alpha = 1.0;
				tt.alpha = 0.0;
				sus.alpha = 0.0;
				infi.alpha = 0.0;
				pink.alpha = 0.0;
			}
			case 35: //triple-trouble
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}
				
				red1Tween = FlxTween.tween(red1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				green1Tween = FlxTween.tween(green1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				sus1Tween = FlxTween.tween(sus1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				blackTween = FlxTween.tween(black,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				fella1Tween = FlxTween.tween(fella1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				yellowTween = FlxTween.tween(yellow,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				whiteTween = FlxTween.tween(white,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				wbTween = FlxTween.tween(wb,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				henryTween = FlxTween.tween(henry,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				maroonTween = FlxTween.tween(maroon,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				grayTween = FlxTween.tween(gray,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				double1Tween = FlxTween.tween(double1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				czTween = FlxTween.tween(cz,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				jorsawseeTween = FlxTween.tween(jorsawsee,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				bfiTween = FlxTween.tween(bfi,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				ttTween = FlxTween.tween(tt,{x: -40}, 0.5 ,{ease: FlxEase.expoOut});
				susTween = FlxTween.tween(sus,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				infiTween = FlxTween.tween(infi,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				pinkTween = FlxTween.tween(pink,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				
				red1.alpha = 0.0;
				green1.alpha = 0.0;
				sus1.alpha = 0.0;
				black.alpha = 0.0;
				fella1.alpha = 0.0;
				yellow.alpha = 0.0;
				white.alpha = 0.0;
				wb.alpha = 0.0;
				henry.alpha = 0.0;
				maroon.alpha = 0.0;
				gray.alpha = 0.0;
				double1.alpha = 0.0;
				cz.alpha = 0.0;
				jorsawsee.alpha = 0.0;
				bfi.alpha = 0.0;
				tt.alpha = 1.0;
				sus.alpha = 0.0;
				infi.alpha = 0.0;
				pink.alpha = 0.0;
			}
			case 36: //monosus
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}
				
				red1Tween = FlxTween.tween(red1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				green1Tween = FlxTween.tween(green1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				sus1Tween = FlxTween.tween(sus1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				blackTween = FlxTween.tween(black,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				fella1Tween = FlxTween.tween(fella1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				yellowTween = FlxTween.tween(yellow,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				whiteTween = FlxTween.tween(white,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				wbTween = FlxTween.tween(wb,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				henryTween = FlxTween.tween(henry,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				maroonTween = FlxTween.tween(maroon,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				grayTween = FlxTween.tween(gray,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				double1Tween = FlxTween.tween(double1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				czTween = FlxTween.tween(cz,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				jorsawseeTween = FlxTween.tween(jorsawsee,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				bfiTween = FlxTween.tween(bfi,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				ttTween = FlxTween.tween(tt,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				susTween = FlxTween.tween(sus,{x: -40}, 0.5 ,{ease: FlxEase.expoOut});
				infiTween = FlxTween.tween(infi,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				pinkTween = FlxTween.tween(pink,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				
				red1.alpha = 0.0;
				green1.alpha = 0.0;
				sus1.alpha = 0.0;
				black.alpha = 0.0;
				fella1.alpha = 0.0;
				yellow.alpha = 0.0;
				white.alpha = 0.0;
				wb.alpha = 0.0;
				henry.alpha = 0.0;
				maroon.alpha = 0.0;
				gray.alpha = 0.0;
				double1.alpha = 0.0;
				cz.alpha = 0.0;
				jorsawsee.alpha = 0.0;
				bfi.alpha = 0.0;
				tt.alpha = 0.0;
				sus.alpha = 1.0;
				infi.alpha = 0.0;
				pink.alpha = 0.0;
			}
			case 37: //infi
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}
				
				red1Tween = FlxTween.tween(red1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				green1Tween = FlxTween.tween(green1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				sus1Tween = FlxTween.tween(sus1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				blackTween = FlxTween.tween(black,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				fella1Tween = FlxTween.tween(fella1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				yellowTween = FlxTween.tween(yellow,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				whiteTween = FlxTween.tween(white,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				wbTween = FlxTween.tween(wb,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				henryTween = FlxTween.tween(henry,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				maroonTween = FlxTween.tween(maroon,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				grayTween = FlxTween.tween(gray,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				double1Tween = FlxTween.tween(double1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				czTween = FlxTween.tween(cz,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				jorsawseeTween = FlxTween.tween(jorsawsee,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				bfiTween = FlxTween.tween(bfi,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				ttTween = FlxTween.tween(tt,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				susTween = FlxTween.tween(sus,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				infiTween = FlxTween.tween(infi,{x: -40}, 0.5 ,{ease: FlxEase.expoOut});
				pinkTween = FlxTween.tween(pink,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				
				red1.alpha = 0.0;
				green1.alpha = 0.0;
				sus1.alpha = 0.0;
				black.alpha = 0.0;
				fella1.alpha = 0.0;
				yellow.alpha = 0.0;
				white.alpha = 0.0;
				wb.alpha = 0.0;
				henry.alpha = 0.0;
				maroon.alpha = 0.0;
				gray.alpha = 0.0;
				double1.alpha = 0.0;
				cz.alpha = 0.0;
				jorsawsee.alpha = 0.0;
				bfi.alpha = 0.0;
				tt.alpha = 0.0;
				sus.alpha = 0.0;
				infi.alpha = 1.0;
				pink.alpha = 0.0;
			}
			case 25 | 39: //heartbroken, devil's-gambit
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}
				
				red1Tween = FlxTween.tween(red1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				green1Tween = FlxTween.tween(green1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				sus1Tween = FlxTween.tween(sus1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				blackTween = FlxTween.tween(black,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				fella1Tween = FlxTween.tween(fella1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				yellowTween = FlxTween.tween(yellow,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				whiteTween = FlxTween.tween(white,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				wbTween = FlxTween.tween(wb,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				henryTween = FlxTween.tween(henry,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				maroonTween = FlxTween.tween(maroon,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				grayTween = FlxTween.tween(gray,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				double1Tween = FlxTween.tween(double1,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				czTween = FlxTween.tween(cz,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				jorsawseeTween = FlxTween.tween(jorsawsee,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				bfiTween = FlxTween.tween(bfi,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				ttTween = FlxTween.tween(tt,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				susTween = FlxTween.tween(sus,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				infiTween = FlxTween.tween(infi,{x: -10}, 0.5 ,{ease: FlxEase.expoOut});
				pinkTween = FlxTween.tween(pink,{x: -40}, 0.5 ,{ease: FlxEase.expoOut});
				
				red1.alpha = 0.0;
				green1.alpha = 0.0;
				sus1.alpha = 0.0;
				black.alpha = 0.0;
				fella1.alpha = 0.0;
				yellow.alpha = 0.0;
				white.alpha = 0.0;
				wb.alpha = 0.0;
				henry.alpha = 0.0;
				maroon.alpha = 0.0;
				gray.alpha = 0.0;
				double1.alpha = 0.0;
				cz.alpha = 0.0;
				jorsawsee.alpha = 0.0;
				bfi.alpha = 0.0;
				tt.alpha = 0.0;
				sus.alpha = 0.0;
				infi.alpha = 0.0;
				pink.alpha = 1.0;
			}
		}
	}

	private function positionHighscore() {
		scoreText.x = FlxG.width - scoreText.width - 6;
		scoreText1.x = FlxG.width - scoreText1.width - 6;
		diffText.x = FlxG.width - diffText.width - 6;
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";

	public function new(song:String, week:Int, songCharacter:String, color:Int)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Paths.currentModDirectory;
		if(this.folder == null) this.folder = '';
	}
}