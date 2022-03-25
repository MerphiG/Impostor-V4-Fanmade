package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import openfl.utils.Assets as OpenFlAssets;
import WeekData;
import lime.app.Application;
import openfl.utils.Future;
import openfl.media.Sound;
import flixel.system.FlxSound;

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	private static var curSelected:Int = 0;
	private static var curDifficulty:Int = 1;

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	private var grpSongs:FlxTypedGroup<SusFont>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	var bg:FlxSprite;
	var intendedColor:Int;
	var colorTween:FlxTween;
	
	var red1:FlxSprite;
	var red2:FlxSprite;
	var green1:FlxSprite;
	var green2:FlxSprite;
	var green3:FlxSprite;
	var green4:FlxSprite;
	var sus1:FlxSprite;
	var sus2:FlxSprite;
	var black:FlxSprite;
	var fella1:FlxSprite;
	var fella2:FlxSprite;
	var yellow:FlxSprite;
	var white:FlxSprite;
	var wb:FlxSprite;
	var henry:FlxSprite;
	var maroon:FlxSprite;
	var gray:FlxSprite;
	var double1:FlxSprite;
	var double2:FlxSprite;
	var cz:FlxSprite;
	var jorsawsee:FlxSprite;
	var betrayal:FlxSprite;
	var bfi:FlxSprite;

	override function create()
	{
		#if MODS_ALLOWED
		Paths.destroyLoadedImages();
		#end
		WeekData.reloadWeekFiles(false);
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		for (i in 0...WeekData.weeksList.length) {
			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];
			for (j in 0...leWeek.songs.length) {
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs) {
				var colors:Array<Int> = song[2];
				if(colors == null || colors.length < 3) {
					colors = [146, 113, 253];
				}
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
			}
		}
		WeekData.setDirectoryFromWeek();

		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));
		for (i in 0...initSonglist.length)
		{
			if(initSonglist[i] != null && initSonglist[i].length > 0) {
				var songArray:Array<String> = initSonglist[i].split(":");
				addSong(songArray[0], 0, songArray[1], Std.parseInt(songArray[2]));
			}
		}

		// LOAD MUSIC

		// LOAD CHARACTERS

		var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('spacep'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.10;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);


		red1 = new FlxSprite(-100, 0).loadGraphic(Paths.image('freeplay/red-1'));
		red1.setGraphicSize(Std.int(red1.width * 1.1));
		red1.antialiasing = ClientPrefs.globalAntialiasing;
		add(red1);
		
		red2 = new FlxSprite(-100, 0).loadGraphic(Paths.image('freeplay/red-2'));
		red2.setGraphicSize(Std.int(red2.width * 1.1));
		red2.antialiasing = ClientPrefs.globalAntialiasing;
		add(red2);
		
		green1 = new FlxSprite(-100, 0).loadGraphic(Paths.image('freeplay/green-1'));
		green1.setGraphicSize(Std.int(green1.width * 1.1));
		green1.antialiasing = ClientPrefs.globalAntialiasing;
		add(green1);

		green2 = new FlxSprite(-100, 0).loadGraphic(Paths.image('freeplay/green-2'));
		green2.setGraphicSize(Std.int(green2.width * 1.1));
		green2.antialiasing = ClientPrefs.globalAntialiasing;
		add(green2);
		
		green3 = new FlxSprite(-100, 0).loadGraphic(Paths.image('freeplay/green-3'));
		green3.setGraphicSize(Std.int(green3.width * 1.1));
		green3.antialiasing = ClientPrefs.globalAntialiasing;
		add(green3);
		
		green4 = new FlxSprite(-100, 0).loadGraphic(Paths.image('freeplay/green-4'));
		green4.setGraphicSize(Std.int(green4.width * 1.1));
		green4.antialiasing = ClientPrefs.globalAntialiasing;
		add(green4);
		
		sus1 = new FlxSprite(-100, 0).loadGraphic(Paths.image('freeplay/sus-1'));
		sus1.setGraphicSize(Std.int(sus1.width * 1.1));
		sus1.antialiasing = false;
		add(sus1);
		
		sus2 = new FlxSprite(-100, 0).loadGraphic(Paths.image('freeplay/sus-2'));
		sus2.setGraphicSize(Std.int(sus2.width * 1.1));
		sus2.antialiasing = false;
		add(sus2);
		
		black = new FlxSprite(-100, 0).loadGraphic(Paths.image('freeplay/black'));
		black.setGraphicSize(Std.int(black.width * 1.1));
		black.antialiasing = ClientPrefs.globalAntialiasing;
		add(black);
		
		fella1 = new FlxSprite(-100, 0).loadGraphic(Paths.image('freeplay/fella-1'));
		fella1.setGraphicSize(Std.int(fella1.width * 1.1));
		fella1.antialiasing = false;
		add(fella1);
		
		fella2 = new FlxSprite(-100, 0).loadGraphic(Paths.image('freeplay/fella-2'));
		fella2.setGraphicSize(Std.int(fella2.width * 1.1));
		fella2.antialiasing = false;
		add(fella2);
		
		yellow = new FlxSprite(-100, 0).loadGraphic(Paths.image('freeplay/yellow'));
		yellow.setGraphicSize(Std.int(yellow.width * 1.1));
		yellow.antialiasing = ClientPrefs.globalAntialiasing;
		add(yellow);
		
		white = new FlxSprite(-100, 0).loadGraphic(Paths.image('freeplay/white'));
		white.setGraphicSize(Std.int(white.width * 1.1));
		white.antialiasing = ClientPrefs.globalAntialiasing;
		add(white);
		
		wb = new FlxSprite(-100, 0).loadGraphic(Paths.image('freeplay/white-black'));
		wb.setGraphicSize(Std.int(wb.width * 1.1));
		wb.antialiasing = ClientPrefs.globalAntialiasing;
		add(wb);
		
		henry = new FlxSprite(-100, 0).loadGraphic(Paths.image('freeplay/henry'));
		henry.setGraphicSize(Std.int(henry.width * 1.1));
		henry.antialiasing = ClientPrefs.globalAntialiasing;
		add(henry);
		
		maroon = new FlxSprite(-100, 0).loadGraphic(Paths.image('freeplay/maroon'));
		maroon.setGraphicSize(Std.int(maroon.width * 1.1));
		maroon.antialiasing = ClientPrefs.globalAntialiasing;
		add(maroon);
		
		gray = new FlxSprite(-100, 0).loadGraphic(Paths.image('freeplay/gray'));
		gray.setGraphicSize(Std.int(gray.width * 1.1));
		gray.antialiasing = ClientPrefs.globalAntialiasing;
		add(gray);
		
		double1 = new FlxSprite(-100, 0).loadGraphic(Paths.image('freeplay/double-1'));
		double1.setGraphicSize(Std.int(double1.width * 1.1));
		double1.antialiasing = ClientPrefs.globalAntialiasing;
		add(double1);
		
		double2 = new FlxSprite(-100, 0).loadGraphic(Paths.image('freeplay/double-2'));
		double2.setGraphicSize(Std.int(double2.width * 1.1));
		double2.antialiasing = ClientPrefs.globalAntialiasing;
		add(double2);
		
		cz = new FlxSprite(-100, 0).loadGraphic(Paths.image('freeplay/clowfoe-ziffy'));
		cz.setGraphicSize(Std.int(cz.width * 1.1));
		cz.antialiasing = ClientPrefs.globalAntialiasing;
		add(cz);

		jorsawsee = new FlxSprite(-100, 0).loadGraphic(Paths.image('freeplay/jorsawsee'));
		jorsawsee.setGraphicSize(Std.int(jorsawsee.width * 1.1));
		jorsawsee.antialiasing = ClientPrefs.globalAntialiasing;
		add(jorsawsee);
		
		betrayal = new FlxSprite(-100, 0).loadGraphic(Paths.image('freeplay/betrayal'));
		betrayal.setGraphicSize(Std.int(betrayal.width * 1.1));
		betrayal.antialiasing = ClientPrefs.globalAntialiasing;
		add(betrayal);
		
		bfi = new FlxSprite(-100, 0).loadGraphic(Paths.image('freeplay/bf-impostor'));
		bfi.setGraphicSize(Std.int(bfi.width * 1.1));
		bfi.antialiasing = ClientPrefs.globalAntialiasing;
		add(bfi);

		var gradient:FlxSprite = new FlxSprite(0, 100).loadGraphic(Paths.image('menuGr'));
		gradient.scrollFactor.x = 0;
		gradient.scrollFactor.y = 0.10;
		gradient.setGraphicSize(Std.int(gradient.width * 1.1));
		gradient.updateHitbox();
		gradient.screenCenter(X);
		add(gradient);

		var freeplaybox:FlxSprite = new FlxSprite(20,5).loadGraphic(Paths.image('freeplay/freeplaybox'));
		freeplaybox.antialiasing = true;
		freeplaybox.setGraphicSize(Std.int(freeplaybox.width * 1.1));
		freeplaybox.updateHitbox();
		freeplaybox.scrollFactor.set();
		add(freeplaybox);

		grpSongs = new FlxTypedGroup<SusFont>();

		for (i in 0...songs.length)
		{
			var songText:SusFont = new SusFont(0, (70 * i) + 200, songs[i].songName, true);
			songText.setFormat(Paths.font("amogus.ttf"), 90, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songText.scale.set(0.7, 0.7);
			songText.borderSize = 2.0;
			songText.antialiasing = true;
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			Paths.currentModDirectory = songs[i].folder;
			
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.scale.set(0.7, 0.7);
			icon.sprTracker = songText;

			iconArray.push(icon);
			add(icon);
		}
		add(grpSongs);
		
		WeekData.setDirectoryFromWeek();

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		if(curSelected >= songs.length) curSelected = 0;
		bg.color = songs[curSelected].color;
		intendedColor = bg.color;
		changeSelection();
		changeDiff();

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);
		#if PRELOAD_ALL
		var leText:String = "Press SPACE to listen to this Song / Press RESET to Reset your Score and Accuracy.";
		#else
		var leText:String = "Press RESET to Reset your Score and Accuracy.";
		#end
		var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, 18);
		text.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, RIGHT);
		text.scrollFactor.set();
		add(text);
		super.create();
	}

	override function closeSubState() {
		changeSelection();
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
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
	override function update(elapsed:Float)
	{
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

		scoreText.text = 'PERSONAL BEST: ' + lerpScore + ' (' + Math.floor(lerpRating * 100) + '%)';
		positionHighscore();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;
		var space = FlxG.keys.justPressed.SPACE;

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

		if (upP)
		{
			changeSelection(-shiftMult);
		}
		if (downP)
		{
			changeSelection(shiftMult);
		}

		if (controls.UI_LEFT_P)
			changeDiff(-1);
		if (controls.UI_RIGHT_P)
			changeDiff(1);

		if (controls.BACK)
		{
			if(colorTween != null) {
				colorTween.cancel();
			}
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
			FlxG.sound.music.fadeIn(4, 0, 0.7);
			destroyFreeplayVocals();
		}

		#if PRELOAD_ALL
		if(space && instPlaying != curSelected)
		{
			destroyFreeplayVocals();
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
		}
		else #end if (accepted)
		{
			var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
			var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
			#if MODS_ALLOWED
			if(!sys.FileSystem.exists(Paths.modsJson(songLowercase + '/' + poop)) && !sys.FileSystem.exists(Paths.json(songLowercase + '/' + poop))) {
			#else
			if(!OpenFlAssets.exists(Paths.json(songLowercase + '/' + poop))) {
			#end
				poop = songLowercase;
				curDifficulty = 1;
				trace('Couldnt find file');
			}
			trace(poop);

			PlayState.SONG = Song.loadFromJson(poop, songLowercase);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;

			PlayState.storyWeek = songs[curSelected].week;
			trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
			if(colorTween != null) {
				colorTween.cancel();
			}
			LoadingState.loadAndSwitchState(new PlayState());

			FlxG.sound.music.volume = 0;
					
			destroyFreeplayVocals();
		}
		else if(controls.RESET)
		{
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
			curDifficulty = CoolUtil.difficultyStuff.length-1;
		if (curDifficulty >= CoolUtil.difficultyStuff.length)
			curDifficulty = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		PlayState.storyDifficulty = curDifficulty;
		diffText.text = '< ' + CoolUtil.difficultyString() + ' >';
		positionHighscore();
	}

	var red1Tween:FlxTween;
	var red2Tween:FlxTween;
	var green1Tween:FlxTween;
	var green2Tween:FlxTween;
	var green3Tween:FlxTween;
	var green4Tween:FlxTween;
	var sus1Tween:FlxTween;
	var sus2Tween:FlxTween;
	var blackTween:FlxTween;
	var fella1Tween:FlxTween;
	var fella2Tween:FlxTween;
	var yellowTween:FlxTween;
	var whiteTween:FlxTween;
	var wbTween:FlxTween;
	var henryTween:FlxTween;
	var maroonTween:FlxTween;
	var grayTween:FlxTween;
	var double1Tween:FlxTween;
	var double2Tween:FlxTween;
	var czTween:FlxTween;
	var jorsawseeTween:FlxTween;
	var betrayalTween:FlxTween;
	var bfiTween:FlxTween;

	function cancelTweens()
	{
		red1Tween.cancel();
		red2Tween.cancel();
		green1Tween.cancel();
		green2Tween.cancel();
		green3Tween.cancel();
		green4Tween.cancel();
		sus1Tween.cancel();
		sus2Tween.cancel();
		blackTween.cancel();
		fella1Tween.cancel();
		fella2Tween.cancel();
		yellowTween.cancel();
		whiteTween.cancel();
		wbTween.cancel();
		henryTween.cancel();
		maroonTween.cancel();
		grayTween.cancel();
		double1Tween.cancel();
		double2Tween.cancel();
		czTween.cancel();
		jorsawseeTween.cancel();
		betrayalTween.cancel();
		bfiTween.cancel();
	}	

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

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
			iconArray[i].alpha = 0;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
		changeDiff();
		Paths.currentModDirectory = songs[curSelected].folder;

	switch(songs[curSelected].week)
		{
			case 0: 
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}
				red1Tween = FlxTween.tween(red1,{y: 0}, 0.5 ,{ease: FlxEase.expoOut});
				red2Tween = FlxTween.tween(red2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green1Tween = FlxTween.tween(green1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green2Tween = FlxTween.tween(green2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green3Tween = FlxTween.tween(green3,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green4Tween = FlxTween.tween(green4,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus1Tween = FlxTween.tween(sus1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus2Tween = FlxTween.tween(sus2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				blackTween = FlxTween.tween(black,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella1Tween = FlxTween.tween(fella1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella2Tween = FlxTween.tween(fella2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				yellowTween = FlxTween.tween(yellow,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				whiteTween = FlxTween.tween(white,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				wbTween = FlxTween.tween(wb,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				henryTween = FlxTween.tween(henry,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				maroonTween = FlxTween.tween(maroon,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				grayTween = FlxTween.tween(gray,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double1Tween = FlxTween.tween(double1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double2Tween = FlxTween.tween(double2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				czTween = FlxTween.tween(cz,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				jorsawseeTween = FlxTween.tween(jorsawsee,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				betrayalTween = FlxTween.tween(betrayal,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				bfiTween = FlxTween.tween(bfi,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
			}
			case 1: 
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}
				red1Tween = FlxTween.tween(red1,{y: 0}, 0.5 ,{ease: FlxEase.expoOut});
				red2Tween = FlxTween.tween(red2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green1Tween = FlxTween.tween(green1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green2Tween = FlxTween.tween(green2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green3Tween = FlxTween.tween(green3,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green4Tween = FlxTween.tween(green4,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus1Tween = FlxTween.tween(sus1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus2Tween = FlxTween.tween(sus2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				blackTween = FlxTween.tween(black,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella1Tween = FlxTween.tween(fella1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella2Tween = FlxTween.tween(fella2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				yellowTween = FlxTween.tween(yellow,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				whiteTween = FlxTween.tween(white,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				wbTween = FlxTween.tween(wb,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				henryTween = FlxTween.tween(henry,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				maroonTween = FlxTween.tween(maroon,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				grayTween = FlxTween.tween(gray,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double1Tween = FlxTween.tween(double1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double2Tween = FlxTween.tween(double2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				czTween = FlxTween.tween(cz,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				jorsawseeTween = FlxTween.tween(jorsawsee,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				betrayalTween = FlxTween.tween(betrayal,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				bfiTween = FlxTween.tween(bfi,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
			}
			case 2: 
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}
				red1Tween = FlxTween.tween(red1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				red2Tween = FlxTween.tween(red2,{y: 0}, 0.5 ,{ease: FlxEase.expoOut});
				green1Tween = FlxTween.tween(green1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green2Tween = FlxTween.tween(green2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green3Tween = FlxTween.tween(green3,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green4Tween = FlxTween.tween(green4,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus1Tween = FlxTween.tween(sus1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus2Tween = FlxTween.tween(sus2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				blackTween = FlxTween.tween(black,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella1Tween = FlxTween.tween(fella1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella2Tween = FlxTween.tween(fella2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				yellowTween = FlxTween.tween(yellow,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				whiteTween = FlxTween.tween(white,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				wbTween = FlxTween.tween(wb,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				henryTween = FlxTween.tween(henry,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				maroonTween = FlxTween.tween(maroon,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				grayTween = FlxTween.tween(gray,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double1Tween = FlxTween.tween(double1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double2Tween = FlxTween.tween(double2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				czTween = FlxTween.tween(cz,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				jorsawseeTween = FlxTween.tween(jorsawsee,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				betrayalTween = FlxTween.tween(betrayal,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				bfiTween = FlxTween.tween(bfi,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
			}
			case 3: 
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}
				red1Tween = FlxTween.tween(red1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				red2Tween = FlxTween.tween(red2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green1Tween = FlxTween.tween(green1,{y: 0}, 0.5 ,{ease: FlxEase.expoOut});
				green2Tween = FlxTween.tween(green2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green3Tween = FlxTween.tween(green3,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green4Tween = FlxTween.tween(green4,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus1Tween = FlxTween.tween(sus1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus2Tween = FlxTween.tween(sus2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				blackTween = FlxTween.tween(black,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella1Tween = FlxTween.tween(fella1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella2Tween = FlxTween.tween(fella2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				yellowTween = FlxTween.tween(yellow,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				whiteTween = FlxTween.tween(white,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				wbTween = FlxTween.tween(wb,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				henryTween = FlxTween.tween(henry,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				maroonTween = FlxTween.tween(maroon,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				grayTween = FlxTween.tween(gray,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double1Tween = FlxTween.tween(double1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double2Tween = FlxTween.tween(double2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				czTween = FlxTween.tween(cz,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				jorsawseeTween = FlxTween.tween(jorsawsee,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				betrayalTween = FlxTween.tween(betrayal,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				bfiTween = FlxTween.tween(bfi,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
			}
			case 4: 
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}
				red1Tween = FlxTween.tween(red1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				red2Tween = FlxTween.tween(red2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green1Tween = FlxTween.tween(green1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green2Tween = FlxTween.tween(green2,{y: 0}, 0.5 ,{ease: FlxEase.expoOut});
				green3Tween = FlxTween.tween(green3,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green4Tween = FlxTween.tween(green4,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus1Tween = FlxTween.tween(sus1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus2Tween = FlxTween.tween(sus2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				blackTween = FlxTween.tween(black,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella1Tween = FlxTween.tween(fella1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella2Tween = FlxTween.tween(fella2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				yellowTween = FlxTween.tween(yellow,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				whiteTween = FlxTween.tween(white,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				wbTween = FlxTween.tween(wb,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				henryTween = FlxTween.tween(henry,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				maroonTween = FlxTween.tween(maroon,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				grayTween = FlxTween.tween(gray,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double1Tween = FlxTween.tween(double1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double2Tween = FlxTween.tween(double2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				czTween = FlxTween.tween(cz,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				jorsawseeTween = FlxTween.tween(jorsawsee,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				betrayalTween = FlxTween.tween(betrayal,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				bfiTween = FlxTween.tween(bfi,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
			}
			case 5: 
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}
				red1Tween = FlxTween.tween(red1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				red2Tween = FlxTween.tween(red2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green1Tween = FlxTween.tween(green1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green2Tween = FlxTween.tween(green2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green3Tween = FlxTween.tween(green3,{y: 0}, 0.5 ,{ease: FlxEase.expoOut});
				green4Tween = FlxTween.tween(green4,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus1Tween = FlxTween.tween(sus1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus2Tween = FlxTween.tween(sus2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				blackTween = FlxTween.tween(black,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella1Tween = FlxTween.tween(fella1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella2Tween = FlxTween.tween(fella2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				yellowTween = FlxTween.tween(yellow,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				whiteTween = FlxTween.tween(white,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				wbTween = FlxTween.tween(wb,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				henryTween = FlxTween.tween(henry,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				maroonTween = FlxTween.tween(maroon,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				grayTween = FlxTween.tween(gray,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double1Tween = FlxTween.tween(double1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double2Tween = FlxTween.tween(double2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				czTween = FlxTween.tween(cz,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				jorsawseeTween = FlxTween.tween(jorsawsee,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				betrayalTween = FlxTween.tween(betrayal,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				bfiTween = FlxTween.tween(bfi,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
			}
			case 6: 
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}
				red1Tween = FlxTween.tween(red1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				red2Tween = FlxTween.tween(red2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green1Tween = FlxTween.tween(green1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green2Tween = FlxTween.tween(green2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green3Tween = FlxTween.tween(green3,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green4Tween = FlxTween.tween(green4,{y: 0}, 0.5 ,{ease: FlxEase.expoOut});
				sus1Tween = FlxTween.tween(sus1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus2Tween = FlxTween.tween(sus2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				blackTween = FlxTween.tween(black,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella1Tween = FlxTween.tween(fella1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella2Tween = FlxTween.tween(fella2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				yellowTween = FlxTween.tween(yellow,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				whiteTween = FlxTween.tween(white,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				wbTween = FlxTween.tween(wb,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				henryTween = FlxTween.tween(henry,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				maroonTween = FlxTween.tween(maroon,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				grayTween = FlxTween.tween(gray,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double1Tween = FlxTween.tween(double1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double2Tween = FlxTween.tween(double2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				czTween = FlxTween.tween(cz,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				jorsawseeTween = FlxTween.tween(jorsawsee,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				betrayalTween = FlxTween.tween(betrayal,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				bfiTween = FlxTween.tween(bfi,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
			}
			case 7: 
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}
				red1Tween = FlxTween.tween(red1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				red2Tween = FlxTween.tween(red2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green1Tween = FlxTween.tween(green1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green2Tween = FlxTween.tween(green2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green3Tween = FlxTween.tween(green3,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green4Tween = FlxTween.tween(green4,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus1Tween = FlxTween.tween(sus1,{y: 0}, 0.5 ,{ease: FlxEase.expoOut});
				sus2Tween = FlxTween.tween(sus2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				blackTween = FlxTween.tween(black,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella1Tween = FlxTween.tween(fella1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella2Tween = FlxTween.tween(fella2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				yellowTween = FlxTween.tween(yellow,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				whiteTween = FlxTween.tween(white,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				wbTween = FlxTween.tween(wb,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				henryTween = FlxTween.tween(henry,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				maroonTween = FlxTween.tween(maroon,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				grayTween = FlxTween.tween(gray,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double1Tween = FlxTween.tween(double1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double2Tween = FlxTween.tween(double2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				czTween = FlxTween.tween(cz,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				jorsawseeTween = FlxTween.tween(jorsawsee,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				betrayalTween = FlxTween.tween(betrayal,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				bfiTween = FlxTween.tween(bfi,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
			}
			case 8: 
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}
				red1Tween = FlxTween.tween(red1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				red2Tween = FlxTween.tween(red2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green1Tween = FlxTween.tween(green1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green2Tween = FlxTween.tween(green2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green3Tween = FlxTween.tween(green3,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green4Tween = FlxTween.tween(green4,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus1Tween = FlxTween.tween(sus1,{y: 0}, 0.5 ,{ease: FlxEase.expoOut});
				sus2Tween = FlxTween.tween(sus2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				blackTween = FlxTween.tween(black,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella1Tween = FlxTween.tween(fella1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella2Tween = FlxTween.tween(fella2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				yellowTween = FlxTween.tween(yellow,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				whiteTween = FlxTween.tween(white,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				wbTween = FlxTween.tween(wb,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				henryTween = FlxTween.tween(henry,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				maroonTween = FlxTween.tween(maroon,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				grayTween = FlxTween.tween(gray,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double1Tween = FlxTween.tween(double1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double2Tween = FlxTween.tween(double2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				czTween = FlxTween.tween(cz,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				jorsawseeTween = FlxTween.tween(jorsawsee,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				betrayalTween = FlxTween.tween(betrayal,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				bfiTween = FlxTween.tween(bfi,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
			}
			case 9: 
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}
				red1Tween = FlxTween.tween(red1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				red2Tween = FlxTween.tween(red2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green1Tween = FlxTween.tween(green1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green2Tween = FlxTween.tween(green2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green3Tween = FlxTween.tween(green3,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green4Tween = FlxTween.tween(green4,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus1Tween = FlxTween.tween(sus1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus2Tween = FlxTween.tween(sus2,{y: 0}, 0.5 ,{ease: FlxEase.expoOut});
				blackTween = FlxTween.tween(black,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella1Tween = FlxTween.tween(fella1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella2Tween = FlxTween.tween(fella2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				yellowTween = FlxTween.tween(yellow,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				whiteTween = FlxTween.tween(white,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				wbTween = FlxTween.tween(wb,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				henryTween = FlxTween.tween(henry,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				maroonTween = FlxTween.tween(maroon,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				grayTween = FlxTween.tween(gray,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double1Tween = FlxTween.tween(double1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double2Tween = FlxTween.tween(double2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				czTween = FlxTween.tween(cz,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				jorsawseeTween = FlxTween.tween(jorsawsee,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				betrayalTween = FlxTween.tween(betrayal,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				bfiTween = FlxTween.tween(bfi,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
			}
			case 10: 
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}
				red1Tween = FlxTween.tween(red1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				red2Tween = FlxTween.tween(red2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green1Tween = FlxTween.tween(green1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green2Tween = FlxTween.tween(green2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green3Tween = FlxTween.tween(green3,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green4Tween = FlxTween.tween(green4,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus1Tween = FlxTween.tween(sus1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus2Tween = FlxTween.tween(sus2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				blackTween = FlxTween.tween(black,{y: 0}, 0.5 ,{ease: FlxEase.expoOut});
				fella1Tween = FlxTween.tween(fella1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella2Tween = FlxTween.tween(fella2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				yellowTween = FlxTween.tween(yellow,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				whiteTween = FlxTween.tween(white,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				wbTween = FlxTween.tween(wb,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				henryTween = FlxTween.tween(henry,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				maroonTween = FlxTween.tween(maroon,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				grayTween = FlxTween.tween(gray,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double1Tween = FlxTween.tween(double1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double2Tween = FlxTween.tween(double2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				czTween = FlxTween.tween(cz,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				jorsawseeTween = FlxTween.tween(jorsawsee,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				betrayalTween = FlxTween.tween(betrayal,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				bfiTween = FlxTween.tween(bfi,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
			}
			case 11: 
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}
				red1Tween = FlxTween.tween(red1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				red2Tween = FlxTween.tween(red2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green1Tween = FlxTween.tween(green1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green2Tween = FlxTween.tween(green2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green3Tween = FlxTween.tween(green3,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green4Tween = FlxTween.tween(green4,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus1Tween = FlxTween.tween(sus1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus2Tween = FlxTween.tween(sus2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				blackTween = FlxTween.tween(black,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella1Tween = FlxTween.tween(fella1,{y: 0}, 0.5 ,{ease: FlxEase.expoOut});
				fella2Tween = FlxTween.tween(fella2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				yellowTween = FlxTween.tween(yellow,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				whiteTween = FlxTween.tween(white,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				wbTween = FlxTween.tween(wb,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				henryTween = FlxTween.tween(henry,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				maroonTween = FlxTween.tween(maroon,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				grayTween = FlxTween.tween(gray,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double1Tween = FlxTween.tween(double1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double2Tween = FlxTween.tween(double2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				czTween = FlxTween.tween(cz,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				jorsawseeTween = FlxTween.tween(jorsawsee,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				betrayalTween = FlxTween.tween(betrayal,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				bfiTween = FlxTween.tween(bfi,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
			}
			case 12: 
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}
				red1Tween = FlxTween.tween(red1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				red2Tween = FlxTween.tween(red2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green1Tween = FlxTween.tween(green1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green2Tween = FlxTween.tween(green2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green3Tween = FlxTween.tween(green3,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green4Tween = FlxTween.tween(green4,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus1Tween = FlxTween.tween(sus1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus2Tween = FlxTween.tween(sus2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				blackTween = FlxTween.tween(black,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella1Tween = FlxTween.tween(fella1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella2Tween = FlxTween.tween(fella2,{y: 0}, 0.5 ,{ease: FlxEase.expoOut});
				yellowTween = FlxTween.tween(yellow,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				whiteTween = FlxTween.tween(white,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				wbTween = FlxTween.tween(wb,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				henryTween = FlxTween.tween(henry,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				maroonTween = FlxTween.tween(maroon,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				grayTween = FlxTween.tween(gray,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double1Tween = FlxTween.tween(double1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double2Tween = FlxTween.tween(double2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				czTween = FlxTween.tween(cz,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				jorsawseeTween = FlxTween.tween(jorsawsee,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				betrayalTween = FlxTween.tween(betrayal,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				bfiTween = FlxTween.tween(bfi,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
			}
			case 13: 
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}
				red1Tween = FlxTween.tween(red1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				red2Tween = FlxTween.tween(red2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green1Tween = FlxTween.tween(green1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green2Tween = FlxTween.tween(green2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green3Tween = FlxTween.tween(green3,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green4Tween = FlxTween.tween(green4,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus1Tween = FlxTween.tween(sus1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus2Tween = FlxTween.tween(sus2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				blackTween = FlxTween.tween(black,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella1Tween = FlxTween.tween(fella1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella2Tween = FlxTween.tween(fella2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				yellowTween = FlxTween.tween(yellow,{y: 0}, 0.5 ,{ease: FlxEase.expoOut});
				whiteTween = FlxTween.tween(white,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				wbTween = FlxTween.tween(wb,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				henryTween = FlxTween.tween(henry,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				maroonTween = FlxTween.tween(maroon,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				grayTween = FlxTween.tween(gray,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double1Tween = FlxTween.tween(double1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double2Tween = FlxTween.tween(double2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				czTween = FlxTween.tween(cz,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				jorsawseeTween = FlxTween.tween(jorsawsee,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				betrayalTween = FlxTween.tween(betrayal,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				bfiTween = FlxTween.tween(bfi,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
			}
			case 14: 
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}
				red1Tween = FlxTween.tween(red1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				red2Tween = FlxTween.tween(red2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green1Tween = FlxTween.tween(green1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green2Tween = FlxTween.tween(green2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green3Tween = FlxTween.tween(green3,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green4Tween = FlxTween.tween(green4,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus1Tween = FlxTween.tween(sus1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus2Tween = FlxTween.tween(sus2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				blackTween = FlxTween.tween(black,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella1Tween = FlxTween.tween(fella1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella2Tween = FlxTween.tween(fella2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				yellowTween = FlxTween.tween(yellow,{y: 0}, 0.5 ,{ease: FlxEase.expoOut});
				whiteTween = FlxTween.tween(white,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				wbTween = FlxTween.tween(wb,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				henryTween = FlxTween.tween(henry,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				maroonTween = FlxTween.tween(maroon,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				grayTween = FlxTween.tween(gray,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double1Tween = FlxTween.tween(double1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double2Tween = FlxTween.tween(double2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				czTween = FlxTween.tween(cz,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				jorsawseeTween = FlxTween.tween(jorsawsee,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				betrayalTween = FlxTween.tween(betrayal,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				bfiTween = FlxTween.tween(bfi,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
			}
			case 15: 
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}
				red1Tween = FlxTween.tween(red1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				red2Tween = FlxTween.tween(red2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green1Tween = FlxTween.tween(green1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green2Tween = FlxTween.tween(green2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green3Tween = FlxTween.tween(green3,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green4Tween = FlxTween.tween(green4,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus1Tween = FlxTween.tween(sus1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus2Tween = FlxTween.tween(sus2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				blackTween = FlxTween.tween(black,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella1Tween = FlxTween.tween(fella1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella2Tween = FlxTween.tween(fella2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				yellowTween = FlxTween.tween(yellow,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				whiteTween = FlxTween.tween(white,{y: 0}, 0.5 ,{ease: FlxEase.expoOut});
				wbTween = FlxTween.tween(wb,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				henryTween = FlxTween.tween(henry,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				maroonTween = FlxTween.tween(maroon,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				grayTween = FlxTween.tween(gray,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double1Tween = FlxTween.tween(double1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double2Tween = FlxTween.tween(double2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				czTween = FlxTween.tween(cz,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				jorsawseeTween = FlxTween.tween(jorsawsee,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				betrayalTween = FlxTween.tween(betrayal,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				bfiTween = FlxTween.tween(bfi,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
			}
			case 16: 
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}
				red1Tween = FlxTween.tween(red1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				red2Tween = FlxTween.tween(red2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green1Tween = FlxTween.tween(green1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green2Tween = FlxTween.tween(green2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green3Tween = FlxTween.tween(green3,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green4Tween = FlxTween.tween(green4,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus1Tween = FlxTween.tween(sus1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus2Tween = FlxTween.tween(sus2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				blackTween = FlxTween.tween(black,{y: 0}, 0.5 ,{ease: FlxEase.expoOut});
				fella1Tween = FlxTween.tween(fella1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella2Tween = FlxTween.tween(fella2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				yellowTween = FlxTween.tween(yellow,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				whiteTween = FlxTween.tween(white,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				wbTween = FlxTween.tween(wb,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				henryTween = FlxTween.tween(henry,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				maroonTween = FlxTween.tween(maroon,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				grayTween = FlxTween.tween(gray,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double1Tween = FlxTween.tween(double1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double2Tween = FlxTween.tween(double2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				czTween = FlxTween.tween(cz,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				jorsawseeTween = FlxTween.tween(jorsawsee,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				betrayalTween = FlxTween.tween(betrayal,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				bfiTween = FlxTween.tween(bfi,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
			}
			case 17: 
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}
				red1Tween = FlxTween.tween(red1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				red2Tween = FlxTween.tween(red2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green1Tween = FlxTween.tween(green1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green2Tween = FlxTween.tween(green2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green3Tween = FlxTween.tween(green3,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green4Tween = FlxTween.tween(green4,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus1Tween = FlxTween.tween(sus1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus2Tween = FlxTween.tween(sus2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				blackTween = FlxTween.tween(black,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella1Tween = FlxTween.tween(fella1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella2Tween = FlxTween.tween(fella2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				yellowTween = FlxTween.tween(yellow,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				whiteTween = FlxTween.tween(white,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				wbTween = FlxTween.tween(wb,{y: 0}, 0.5 ,{ease: FlxEase.expoOut});
				henryTween = FlxTween.tween(henry,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				maroonTween = FlxTween.tween(maroon,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				grayTween = FlxTween.tween(gray,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double1Tween = FlxTween.tween(double1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double2Tween = FlxTween.tween(double2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				czTween = FlxTween.tween(cz,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				jorsawseeTween = FlxTween.tween(jorsawsee,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				betrayalTween = FlxTween.tween(betrayal,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				bfiTween = FlxTween.tween(bfi,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
			}
			case 18: 
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}
				red1Tween = FlxTween.tween(red1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				red2Tween = FlxTween.tween(red2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green1Tween = FlxTween.tween(green1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green2Tween = FlxTween.tween(green2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green3Tween = FlxTween.tween(green3,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green4Tween = FlxTween.tween(green4,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus1Tween = FlxTween.tween(sus1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus2Tween = FlxTween.tween(sus2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				blackTween = FlxTween.tween(black,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella1Tween = FlxTween.tween(fella1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella2Tween = FlxTween.tween(fella2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				yellowTween = FlxTween.tween(yellow,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				whiteTween = FlxTween.tween(white,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				wbTween = FlxTween.tween(wb,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				henryTween = FlxTween.tween(henry,{y: 0}, 0.5 ,{ease: FlxEase.expoOut});
				maroonTween = FlxTween.tween(maroon,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				grayTween = FlxTween.tween(gray,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double1Tween = FlxTween.tween(double1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double2Tween = FlxTween.tween(double2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				czTween = FlxTween.tween(cz,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				jorsawseeTween = FlxTween.tween(jorsawsee,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				betrayalTween = FlxTween.tween(betrayal,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				bfiTween = FlxTween.tween(bfi,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
			}
			case 19: 
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}
				red1Tween = FlxTween.tween(red1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				red2Tween = FlxTween.tween(red2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green1Tween = FlxTween.tween(green1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green2Tween = FlxTween.tween(green2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green3Tween = FlxTween.tween(green3,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green4Tween = FlxTween.tween(green4,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus1Tween = FlxTween.tween(sus1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus2Tween = FlxTween.tween(sus2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				blackTween = FlxTween.tween(black,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella1Tween = FlxTween.tween(fella1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella2Tween = FlxTween.tween(fella2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				yellowTween = FlxTween.tween(yellow,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				whiteTween = FlxTween.tween(white,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				wbTween = FlxTween.tween(wb,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				henryTween = FlxTween.tween(henry,{y: 0}, 0.5 ,{ease: FlxEase.expoOut});
				maroonTween = FlxTween.tween(maroon,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				grayTween = FlxTween.tween(gray,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double1Tween = FlxTween.tween(double1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double2Tween = FlxTween.tween(double2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				czTween = FlxTween.tween(cz,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				jorsawseeTween = FlxTween.tween(jorsawsee,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				betrayalTween = FlxTween.tween(betrayal,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				bfiTween = FlxTween.tween(bfi,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
			}
			case 20: 
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}
				red1Tween = FlxTween.tween(red1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				red2Tween = FlxTween.tween(red2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green1Tween = FlxTween.tween(green1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green2Tween = FlxTween.tween(green2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green3Tween = FlxTween.tween(green3,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green4Tween = FlxTween.tween(green4,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus1Tween = FlxTween.tween(sus1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus2Tween = FlxTween.tween(sus2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				blackTween = FlxTween.tween(black,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella1Tween = FlxTween.tween(fella1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella2Tween = FlxTween.tween(fella2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				yellowTween = FlxTween.tween(yellow,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				whiteTween = FlxTween.tween(white,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				wbTween = FlxTween.tween(wb,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				henryTween = FlxTween.tween(henry,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				maroonTween = FlxTween.tween(maroon,{y: 0}, 0.5 ,{ease: FlxEase.expoOut});
				grayTween = FlxTween.tween(gray,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double1Tween = FlxTween.tween(double1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double2Tween = FlxTween.tween(double2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				czTween = FlxTween.tween(cz,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				jorsawseeTween = FlxTween.tween(jorsawsee,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				betrayalTween = FlxTween.tween(betrayal,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				bfiTween = FlxTween.tween(bfi,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
			}
			case 21: 
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}
				red1Tween = FlxTween.tween(red1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				red2Tween = FlxTween.tween(red2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green1Tween = FlxTween.tween(green1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green2Tween = FlxTween.tween(green2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green3Tween = FlxTween.tween(green3,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green4Tween = FlxTween.tween(green4,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus1Tween = FlxTween.tween(sus1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus2Tween = FlxTween.tween(sus2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				blackTween = FlxTween.tween(black,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella1Tween = FlxTween.tween(fella1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella2Tween = FlxTween.tween(fella2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				yellowTween = FlxTween.tween(yellow,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				whiteTween = FlxTween.tween(white,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				wbTween = FlxTween.tween(wb,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				henryTween = FlxTween.tween(henry,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				maroonTween = FlxTween.tween(maroon,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				grayTween = FlxTween.tween(gray,{y: 0}, 0.5 ,{ease: FlxEase.expoOut});
				double1Tween = FlxTween.tween(double1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double2Tween = FlxTween.tween(double2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				czTween = FlxTween.tween(cz,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				jorsawseeTween = FlxTween.tween(jorsawsee,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				betrayalTween = FlxTween.tween(betrayal,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				bfiTween = FlxTween.tween(bfi,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
			}
			case 22: 
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}
				red1Tween = FlxTween.tween(red1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				red2Tween = FlxTween.tween(red2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green1Tween = FlxTween.tween(green1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green2Tween = FlxTween.tween(green2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green3Tween = FlxTween.tween(green3,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green4Tween = FlxTween.tween(green4,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus1Tween = FlxTween.tween(sus1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus2Tween = FlxTween.tween(sus2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				blackTween = FlxTween.tween(black,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella1Tween = FlxTween.tween(fella1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella2Tween = FlxTween.tween(fella2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				yellowTween = FlxTween.tween(yellow,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				whiteTween = FlxTween.tween(white,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				wbTween = FlxTween.tween(wb,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				henryTween = FlxTween.tween(henry,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				maroonTween = FlxTween.tween(maroon,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				grayTween = FlxTween.tween(gray,{y: 0}, 0.5 ,{ease: FlxEase.expoOut});
				double1Tween = FlxTween.tween(double1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double2Tween = FlxTween.tween(double2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				czTween = FlxTween.tween(cz,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				jorsawseeTween = FlxTween.tween(jorsawsee,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				betrayalTween = FlxTween.tween(betrayal,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				bfiTween = FlxTween.tween(bfi,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
			}
			case 23: 
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}
				red1Tween = FlxTween.tween(red1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				red2Tween = FlxTween.tween(red2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green1Tween = FlxTween.tween(green1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green2Tween = FlxTween.tween(green2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green3Tween = FlxTween.tween(green3,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green4Tween = FlxTween.tween(green4,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus1Tween = FlxTween.tween(sus1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus2Tween = FlxTween.tween(sus2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				blackTween = FlxTween.tween(black,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella1Tween = FlxTween.tween(fella1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella2Tween = FlxTween.tween(fella2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				yellowTween = FlxTween.tween(yellow,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				whiteTween = FlxTween.tween(white,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				wbTween = FlxTween.tween(wb,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				henryTween = FlxTween.tween(henry,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				maroonTween = FlxTween.tween(maroon,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				grayTween = FlxTween.tween(gray,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double1Tween = FlxTween.tween(double1,{y: 0}, 0.5 ,{ease: FlxEase.expoOut});
				double2Tween = FlxTween.tween(double2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				czTween = FlxTween.tween(cz,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				jorsawseeTween = FlxTween.tween(jorsawsee,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				betrayalTween = FlxTween.tween(betrayal,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				bfiTween = FlxTween.tween(bfi,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
			}
			case 24: 
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}
				red1Tween = FlxTween.tween(red1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				red2Tween = FlxTween.tween(red2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green1Tween = FlxTween.tween(green1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green2Tween = FlxTween.tween(green2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green3Tween = FlxTween.tween(green3,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green4Tween = FlxTween.tween(green4,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus1Tween = FlxTween.tween(sus1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus2Tween = FlxTween.tween(sus2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				blackTween = FlxTween.tween(black,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella1Tween = FlxTween.tween(fella1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella2Tween = FlxTween.tween(fella2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				yellowTween = FlxTween.tween(yellow,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				whiteTween = FlxTween.tween(white,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				wbTween = FlxTween.tween(wb,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				henryTween = FlxTween.tween(henry,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				maroonTween = FlxTween.tween(maroon,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				grayTween = FlxTween.tween(gray,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double1Tween = FlxTween.tween(double1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double2Tween = FlxTween.tween(double2,{y: 0}, 0.5 ,{ease: FlxEase.expoOut});
				czTween = FlxTween.tween(cz,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				jorsawseeTween = FlxTween.tween(jorsawsee,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				betrayalTween = FlxTween.tween(betrayal,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				bfiTween = FlxTween.tween(bfi,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
			}
			case 25: 
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}
				red1Tween = FlxTween.tween(red1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				red2Tween = FlxTween.tween(red2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green1Tween = FlxTween.tween(green1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green2Tween = FlxTween.tween(green2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green3Tween = FlxTween.tween(green3,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green4Tween = FlxTween.tween(green4,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus1Tween = FlxTween.tween(sus1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus2Tween = FlxTween.tween(sus2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				blackTween = FlxTween.tween(black,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella1Tween = FlxTween.tween(fella1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella2Tween = FlxTween.tween(fella2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				yellowTween = FlxTween.tween(yellow,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				whiteTween = FlxTween.tween(white,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				wbTween = FlxTween.tween(wb,{y: 0}, 0.5 ,{ease: FlxEase.expoOut});
				henryTween = FlxTween.tween(henry,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				maroonTween = FlxTween.tween(maroon,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				grayTween = FlxTween.tween(gray,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double1Tween = FlxTween.tween(double1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double2Tween = FlxTween.tween(double2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				czTween = FlxTween.tween(cz,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				jorsawseeTween = FlxTween.tween(jorsawsee,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				betrayalTween = FlxTween.tween(betrayal,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				bfiTween = FlxTween.tween(bfi,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
			}
			case 26: 
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}
				red1Tween = FlxTween.tween(red1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				red2Tween = FlxTween.tween(red2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green1Tween = FlxTween.tween(green1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green2Tween = FlxTween.tween(green2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green3Tween = FlxTween.tween(green3,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green4Tween = FlxTween.tween(green4,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus1Tween = FlxTween.tween(sus1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus2Tween = FlxTween.tween(sus2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				blackTween = FlxTween.tween(black,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella1Tween = FlxTween.tween(fella1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella2Tween = FlxTween.tween(fella2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				yellowTween = FlxTween.tween(yellow,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				whiteTween = FlxTween.tween(white,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				wbTween = FlxTween.tween(wb,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				henryTween = FlxTween.tween(henry,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				maroonTween = FlxTween.tween(maroon,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				grayTween = FlxTween.tween(gray,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double1Tween = FlxTween.tween(double1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double2Tween = FlxTween.tween(double2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				czTween = FlxTween.tween(cz,{y: 0}, 0.5 ,{ease: FlxEase.expoOut});
				jorsawseeTween = FlxTween.tween(jorsawsee,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				betrayalTween = FlxTween.tween(betrayal,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				bfiTween = FlxTween.tween(bfi,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
			}
			case 27: 
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}
				red1Tween = FlxTween.tween(red1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				red2Tween = FlxTween.tween(red2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green1Tween = FlxTween.tween(green1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green2Tween = FlxTween.tween(green2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green3Tween = FlxTween.tween(green3,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green4Tween = FlxTween.tween(green4,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus1Tween = FlxTween.tween(sus1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus2Tween = FlxTween.tween(sus2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				blackTween = FlxTween.tween(black,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella1Tween = FlxTween.tween(fella1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella2Tween = FlxTween.tween(fella2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				yellowTween = FlxTween.tween(yellow,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				whiteTween = FlxTween.tween(white,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				wbTween = FlxTween.tween(wb,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				henryTween = FlxTween.tween(henry,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				maroonTween = FlxTween.tween(maroon,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				grayTween = FlxTween.tween(gray,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double1Tween = FlxTween.tween(double1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double2Tween = FlxTween.tween(double2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				czTween = FlxTween.tween(cz,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				jorsawseeTween = FlxTween.tween(jorsawsee,{y: 0}, 0.5 ,{ease: FlxEase.expoOut});
				betrayalTween = FlxTween.tween(betrayal,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				bfiTween = FlxTween.tween(bfi,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
			}
			case 28: 
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}
				red1Tween = FlxTween.tween(red1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				red2Tween = FlxTween.tween(red2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green1Tween = FlxTween.tween(green1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green2Tween = FlxTween.tween(green2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green3Tween = FlxTween.tween(green3,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green4Tween = FlxTween.tween(green4,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus1Tween = FlxTween.tween(sus1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus2Tween = FlxTween.tween(sus2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				blackTween = FlxTween.tween(black,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella1Tween = FlxTween.tween(fella1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella2Tween = FlxTween.tween(fella2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				yellowTween = FlxTween.tween(yellow,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				whiteTween = FlxTween.tween(white,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				wbTween = FlxTween.tween(wb,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				henryTween = FlxTween.tween(henry,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				maroonTween = FlxTween.tween(maroon,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				grayTween = FlxTween.tween(gray,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double1Tween = FlxTween.tween(double1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double2Tween = FlxTween.tween(double2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				czTween = FlxTween.tween(cz,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				jorsawseeTween = FlxTween.tween(jorsawsee,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				betrayalTween = FlxTween.tween(betrayal,{y: 0}, 0.5 ,{ease: FlxEase.expoOut});
				bfiTween = FlxTween.tween(bfi,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
			}
			case 29: 
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}
				red1Tween = FlxTween.tween(red1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				red2Tween = FlxTween.tween(red2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green1Tween = FlxTween.tween(green1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green2Tween = FlxTween.tween(green2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green3Tween = FlxTween.tween(green3,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green4Tween = FlxTween.tween(green4,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus1Tween = FlxTween.tween(sus1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus2Tween = FlxTween.tween(sus2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				blackTween = FlxTween.tween(black,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella1Tween = FlxTween.tween(fella1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella2Tween = FlxTween.tween(fella2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				yellowTween = FlxTween.tween(yellow,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				whiteTween = FlxTween.tween(white,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				wbTween = FlxTween.tween(wb,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				henryTween = FlxTween.tween(henry,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				maroonTween = FlxTween.tween(maroon,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				grayTween = FlxTween.tween(gray,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double1Tween = FlxTween.tween(double1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double2Tween = FlxTween.tween(double2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				czTween = FlxTween.tween(cz,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				jorsawseeTween = FlxTween.tween(jorsawsee,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				betrayalTween = FlxTween.tween(betrayal,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				bfiTween = FlxTween.tween(bfi,{y: 0}, 0.5 ,{ease: FlxEase.expoOut});
			}
			case 30: 
			{
				if(red1Tween != null)
				{
					cancelTweens();
				}
				red1Tween = FlxTween.tween(red1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				red2Tween = FlxTween.tween(red2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green1Tween = FlxTween.tween(green1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green2Tween = FlxTween.tween(green2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green3Tween = FlxTween.tween(green3,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				green4Tween = FlxTween.tween(green4,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus1Tween = FlxTween.tween(sus1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				sus2Tween = FlxTween.tween(sus2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				blackTween = FlxTween.tween(black,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella1Tween = FlxTween.tween(fella1,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				fella2Tween = FlxTween.tween(fella2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				yellowTween = FlxTween.tween(yellow,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				whiteTween = FlxTween.tween(white,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				wbTween = FlxTween.tween(wb,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				henryTween = FlxTween.tween(henry,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				maroonTween = FlxTween.tween(maroon,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				grayTween = FlxTween.tween(gray,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				double1Tween = FlxTween.tween(double1,{y: 0}, 0.5 ,{ease: FlxEase.expoOut});
				double2Tween = FlxTween.tween(double2,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				czTween = FlxTween.tween(cz,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				jorsawseeTween = FlxTween.tween(jorsawsee,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				betrayalTween = FlxTween.tween(betrayal,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
				bfiTween = FlxTween.tween(bfi,{y: 1000}, 0.5 ,{ease: FlxEase.expoIn});
			}
		}
	}
	private function positionHighscore() {
		scoreText.x = FlxG.width - scoreText.width - 6;

		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
		diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
		diffText.x -= diffText.width / 2;
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
