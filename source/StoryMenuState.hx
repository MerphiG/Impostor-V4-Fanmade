package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;
import flixel.graphics.FlxGraphic;
import WeekData;

using StringTools;

class StoryMenuState extends MusicBeatState
{
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();

	var scoreText:FlxText;

	private static var lastDifficultyName:String = '';
	var curDifficulty:Int = 1;

	var txtWeekTitle:FlxText;
	var bgSprite:FlxSprite;

	private static var curWeek:Int = 0;

	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var polusWarehouse:FlxSprite;
	var polusRocks:FlxSprite;
	var polusHills:FlxSprite;
	var polusGround:FlxSprite;

	var reactor:FlxSprite;
	var baller:FlxSprite;

	var bgSky:FlxSprite;

	var effect:MosaicEffect;
	var effectTween:FlxTween;

	var defeatScroll:FlxSprite;

	function amongTimer()
	{
		new FlxTimer().start(FlxG.random.int(3, 7), function(tmr:FlxTimer)
		{
			var tex = Paths.getSparrowAtlas('amongRun');

			var walking:FlxSprite = new FlxSprite();
			walking.setGraphicSize(Std.int(walking.width * 0.2));
			walking.screenCenter(Y);
			walking.updateHitbox();
			walking.x -= walking.width;
			
			walking.frames = tex;
			walking.animation.addByPrefix('Walk', 'Walk', 24);
			walking.animation.play('Walk');
			add(walking);

			FlxTween.tween(walking,{x: FlxG.width}, FlxG.random.int(10, 20));

			amongTimer();
		});
	}

	var loadedWeeks:Array<WeekData> = [];

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		PlayState.isStoryMode = true;
		WeekData.reloadWeekFiles(true);
		if(curWeek >= WeekData.weeksList.length) curWeek = 0;
		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('spacep'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.10;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		polusGround = new FlxSprite(-406.63, 1169.29).loadGraphic(Paths.image('polusGround'));
		polusHills = new FlxSprite(-866.63, 873.62).loadGraphic(Paths.image('polusHills'));
		polusRocks = new FlxSprite(-641.06, 712.09).loadGraphic(Paths.image('polusrocks'));
		polusWarehouse = new FlxSprite(-320.84, 1220.92).loadGraphic(Paths.image('polusWarehouse'));
		polusGround.setGraphicSize(Std.int(polusGround.width * 0.7));
		polusHills.setGraphicSize(Std.int(polusHills.width * 0.7));
		polusRocks.setGraphicSize(Std.int(polusRocks.width * 0.7));
		polusWarehouse.setGraphicSize(Std.int(polusWarehouse.width * 0.7));
		add(polusRocks);
		add(polusHills);
		add(polusWarehouse);
		add(polusGround);

		baller = new FlxSprite(-505, 100).loadGraphic(Paths.image('reactorball'));
		baller.setGraphicSize(Std.int(baller.width * 0.3));
		add(baller);

		reactor = new FlxSprite(-2300, -400).loadGraphic(Paths.image('reactorroom'));
		reactor.setGraphicSize(Std.int(reactor.width * 0.3));
		add(reactor);

		bgSky = new FlxSprite(-500, 270).loadGraphic(Paths.image('tomong'));
		bgSky.scrollFactor.set(0.1, 0.1);
		bgSky.screenCenter();
		add(bgSky);
		bgSky.setGraphicSize(Std.int(bgSky.width * 5));
		bgSky.alpha = 0;

		effect = new MosaicEffect();
		bgSky.shader = effect.shader;

		defeatScroll = new FlxSprite(-100, 937).loadGraphic(Paths.image('defeatScroll'));
		defeatScroll.scrollFactor.x = 0;
		defeatScroll.scrollFactor.y = 0.10;
		defeatScroll.setGraphicSize(Std.int(defeatScroll.width * 1.1));
		defeatScroll.updateHitbox();
		defeatScroll.screenCenter();
		add(defeatScroll);

		var gradient:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('menuGr'));
		gradient.scrollFactor.x = 0;
		gradient.scrollFactor.y = 0.10;
		gradient.setGraphicSize(Std.int(gradient.width * 1.1));
		gradient.updateHitbox();
		gradient.screenCenter();
		add(gradient);

		scoreText = new FlxText(10, 10, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("VCR OSD Mono", 32);

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr.ttf"), 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		bgSprite = new FlxSprite(0, 56);
		bgSprite.antialiasing = ClientPrefs.globalAntialiasing;

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		var num:Int = 0;
		for (i in 0...WeekData.weeksList.length)
		{
			var weekFile:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var isLocked:Bool = weekIsLocked(WeekData.weeksList[i]);
			if(!isLocked || !weekFile.hiddenUntilUnlocked)
			{
				loadedWeeks.push(weekFile);
				WeekData.setDirectoryFromWeek(weekFile);
				var weekThing:MenuItem = new MenuItem(0, bgSprite.y + 396, WeekData.weeksList[i]);
				weekThing.y += ((weekThing.height + 20) * num);
				weekThing.targetY = num;
				grpWeekText.add(weekThing);

				weekThing.screenCenter(X);
				weekThing.antialiasing = ClientPrefs.globalAntialiasing;
				// weekThing.updateHitbox();

				// Needs an offset thingie
				if (isLocked)
				{
					var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
					lock.frames = ui_tex;
					lock.animation.addByPrefix('lock', 'lock');
					lock.animation.play('lock');
					lock.ID = i;
					lock.antialiasing = ClientPrefs.globalAntialiasing;
					grpLocks.add(lock);
				}
				num++;
			}
		}

		WeekData.setDirectoryFromWeek(loadedWeeks[0]);
		var charArray:Array<String> = loadedWeeks[0].weekCharacters;
		for (char in 0...3)
		{
			var weekCharacterThing:MenuCharacter = new MenuCharacter((FlxG.width * 0.25) * (1 + char) - 150, charArray[char]);
			weekCharacterThing.y += 70;
			grpWeekCharacters.add(weekCharacterThing);
		}

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		leftArrow = new FlxSprite(grpWeekText.members[0].x + grpWeekText.members[0].width + 10, grpWeekText.members[0].y + 10);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		leftArrow.antialiasing = ClientPrefs.globalAntialiasing;
		difficultySelectors.add(leftArrow);

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		if(lastDifficultyName == '')
		{
			lastDifficultyName = CoolUtil.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficultyName)));
		
		sprDifficulty = new FlxSprite(0, leftArrow.y);
		sprDifficulty.antialiasing = ClientPrefs.globalAntialiasing;
		difficultySelectors.add(sprDifficulty);

		rightArrow = new FlxSprite(leftArrow.x + 376, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		rightArrow.antialiasing = ClientPrefs.globalAntialiasing;
		difficultySelectors.add(rightArrow);

		add(bgSprite);
		add(grpWeekCharacters);

		var tracksSprite:FlxSprite = new FlxSprite(FlxG.width * 0.07, bgSprite.y + 425).loadGraphic(Paths.image('Menu_Tracks'));
		tracksSprite.antialiasing = ClientPrefs.globalAntialiasing;
		add(tracksSprite);

		txtTracklist = new FlxText(FlxG.width * 0.05, tracksSprite.y + 60, 0, "", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = rankText.font;
		txtTracklist.color = 0xFFffffff;
		add(txtTracklist);
		// add(rankText);
		add(scoreText);
		add(txtWeekTitle);

		changeWeek();
		changeDifficulty();

		super.create();
	}

	override function closeSubState() {
		persistentUpdate = true;
		changeWeek();
		super.closeSubState();
	}

	override function update(elapsed:Float)
	{
		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 30, 0, 1)));
		if(Math.abs(intendedScore - lerpScore) < 10) lerpScore = intendedScore;

		scoreText.text = "WEEK SCORE:" + lerpScore;

		// FlxG.watch.addQuick('font', scoreText.font);

		if (!movedBack && !selectedWeek)
		{
			var upP = controls.UI_UP_P;
			var downP = controls.UI_DOWN_P;
			if (upP)
			{
				changeWeek(-1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if (downP)
			{
				changeWeek(1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if (controls.UI_RIGHT)
				rightArrow.animation.play('press')
			else
				rightArrow.animation.play('idle');

			if (controls.UI_LEFT)
				leftArrow.animation.play('press');
			else
				leftArrow.animation.play('idle');

			if (controls.UI_RIGHT_P)
				changeDifficulty(1);
			else if (controls.UI_LEFT_P)
				changeDifficulty(-1);
			else if (upP || downP)
				changeDifficulty();

			if(FlxG.keys.justPressed.CONTROL)
			{
				persistentUpdate = false;
				openSubState(new GameplayChangersSubstate());
			}
			else if(controls.RESET)
			{
				persistentUpdate = false;
				openSubState(new ResetScoreSubState('', curDifficulty, '', curWeek));
				//FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			else if (controls.ACCEPT)
			{
				selectWeek();
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			MusicBeatState.switchState(new MainMenuState());
		}

		super.update(elapsed);

		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].y;
			lock.visible = (lock.y > FlxG.height / 2);
		});
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (!weekIsLocked(loadedWeeks[curWeek].fileName))
		{
			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));

				switch(curWeek)
				{
					case 0:
						grpWeekText.members[curWeek].startFlashing(0xFF3E1D60);
					case 1:
						grpWeekText.members[curWeek].startFlashing(0xFFE23100);
					case 2:
						grpWeekText.members[curWeek].startFlashing(0xFF4B6858);
					case 3:
						grpWeekText.members[curWeek].startFlashing(0xFF8C0800);
					case 4:
						grpWeekText.members[curWeek].startFlashing(0xFF3A7734);
					case 5:
						grpWeekText.members[curWeek].startFlashing(0xFF463F91);
					case 6:
						grpWeekText.members[curWeek].startFlashing(0xFF8E3E3E);
					case 7:
						grpWeekText.members[curWeek].startFlashing(0xFFAD4C81);
				}

				var bf:MenuCharacter = grpWeekCharacters.members[1];
				if(bf.character != '' && bf.hasConfirmAnimation) grpWeekCharacters.members[1].animation.play('confirm');
				stopspamming = true;
			}

			// We can't use Dynamic Array .copy() because that crashes HTML5, here's a workaround.
			var songArray:Array<String> = [];
			var leWeek:Array<Dynamic> = loadedWeeks[curWeek].songs;
			for (i in 0...leWeek.length) {
				songArray.push(leWeek[i][0]);
			}

			// Nevermind that's stupid lmao
			PlayState.storyPlaylist = songArray;
			PlayState.isStoryMode = true;
			selectedWeek = true;

			var diffic = CoolUtil.getDifficultyFilePath(curDifficulty);
			if(diffic == null) diffic = '';

			PlayState.storyDifficulty = curDifficulty;

			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
			PlayState.campaignScore = 0;
			PlayState.campaignMisses = 0;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState(), true);
				FreeplayState.destroyFreeplayVocals();
			});
		} else {
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}
	}

	var tweenDifficulty:FlxTween;
	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficulties.length-1;
		if (curDifficulty >= CoolUtil.difficulties.length)
			curDifficulty = 0;

		WeekData.setDirectoryFromWeek(loadedWeeks[curWeek]);

		var diff:String = CoolUtil.difficulties[curDifficulty];
		var newImage:FlxGraphic = Paths.image('menudifficulties/' + Paths.formatToSongPath(diff));
		//trace(Paths.currentModDirectory + ', menudifficulties/' + Paths.formatToSongPath(diff));

		if(sprDifficulty.graphic != newImage)
		{
			sprDifficulty.loadGraphic(newImage);
			sprDifficulty.x = leftArrow.x + 60;
			sprDifficulty.x += (308 - sprDifficulty.width) / 3;
			sprDifficulty.alpha = 0;
			sprDifficulty.y = leftArrow.y - 15;

			if(tweenDifficulty != null) tweenDifficulty.cancel();
			tweenDifficulty = FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07, {onComplete: function(twn:FlxTween)
			{
				tweenDifficulty = null;
			}});
		}
		lastDifficultyName = diff;

		#if !switch
		intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
		#end
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	var groundTween:FlxTween;
	var hillsTween:FlxTween;
	var rocksTween:FlxTween;
	var warehouseTween:FlxTween;
	var reactorTween:FlxTween;
	var ballerTween:FlxTween;
	var defeatTween:FlxTween;

	function cancelTweens()
	{
		groundTween.cancel();
		hillsTween.cancel();
		rocksTween.cancel();
		warehouseTween.cancel();
		reactorTween.cancel();
		ballerTween.cancel();
		defeatTween.cancel();
	}	

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= loadedWeeks.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = loadedWeeks.length - 1;

		var leWeek:WeekData = loadedWeeks[curWeek];
		WeekData.setDirectoryFromWeek(leWeek);

		var leName:String = leWeek.storyName;
		txtWeekTitle.text = leName.toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		var bullShit:Int = 0;

		var unlocked:Bool = !weekIsLocked(leWeek.fileName);
		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0) && unlocked)
				item.alpha = 1;
			else
				item.alpha = 0;
			bullShit++;
		}

		bgSprite.visible = true;
		var assetName:String = leWeek.weekBackground;
		if(assetName == null || assetName.length < 1) {
			bgSprite.visible = false;
		} else {
			bgSprite.loadGraphic(Paths.image('menubackgrounds/menu_' + assetName));
		}
		PlayState.storyWeek = curWeek;

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		var diffStr:String = WeekData.getCurrentWeek().difficulties;
		if(diffStr != null) diffStr = diffStr.trim(); //Fuck you HTML5
		difficultySelectors.visible = unlocked;

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
		updateText();
		
		for (i in 0...grpWeekText.members.length)
			{
				if(i > curWeek) {
					FlxTween.tween(grpWeekText.members[i], {alpha: 0.3}, 0.1, {ease: FlxEase.expoOut});
				}
				else if(i == curWeek) {
					FlxTween.tween(grpWeekText.members[i], {alpha: 1}, 0.1, {ease: FlxEase.expoOut});
				}
				else if(i < curWeek) {
					FlxTween.tween(grpWeekText.members[i], {alpha: 0}, 0.1, {ease: FlxEase.expoOut});
				}
			}
			
		switch(curWeek)
		{
			case 0: 
			{
				if(groundTween != null)
				{
					cancelTweens();
				}
				groundTween = FlxTween.tween(polusGround,{y: 169.29}, 0.5 ,{ease: FlxEase.expoOut});
				hillsTween = FlxTween.tween(polusHills,{y: -126.38}, 0.6 ,{ease: FlxEase.expoOut});
				rocksTween = FlxTween.tween(polusRocks,{y: -287.91}, 1 ,{ease: FlxEase.expoOut});
				warehouseTween = FlxTween.tween(polusWarehouse,{y: -220.92}, 0.8 ,{ease: FlxEase.expoOut});
				reactorTween = FlxTween.tween(reactor,{y: -400}, 0.6 ,{ease: FlxEase.expoIn});
				ballerTween = FlxTween.tween(baller,{y: 100}, 0.8 ,{ease: FlxEase.expoIn});
				defeatTween = FlxTween.tween(defeatScroll,{y: 937}, 3 ,{ease: FlxEase.expoOut});

				effectTween = FlxTween.num(MosaicEffect.DEFAULT_STRENGTH, 15, 0.5, {type: ONESHOT}, function(v)
				{
					effect.setStrength(v, v);
				});
				FlxTween.tween(bgSky, {alpha: 0}, 0.4, {ease: FlxEase.expoIn});

			}
			case 1:
			{
				if(groundTween != null)
				{
						cancelTweens();
				}
				groundTween = FlxTween.tween(polusGround,{y: 1169.29}, 0.5 ,{ease: FlxEase.expoIn});
				hillsTween = FlxTween.tween(polusHills,{y: 873.62}, 0.6 ,{ease: FlxEase.expoIn});
				rocksTween = FlxTween.tween(polusRocks,{y: 712.09}, 0.8 ,{ease: FlxEase.expoIn});
				warehouseTween = FlxTween.tween(polusWarehouse,{y: 1220.92}, 0.7 ,{ease: FlxEase.expoIn});
				reactorTween = FlxTween.tween(reactor,{y: -1400}, 0.6 ,{ease: FlxEase.expoOut});
				ballerTween = FlxTween.tween(baller,{y: -900}, 0.8 ,{ease: FlxEase.expoOut});
				defeatTween = FlxTween.tween(defeatScroll,{y: 937}, 3 ,{ease: FlxEase.expoOut});

				effectTween = FlxTween.num(MosaicEffect.DEFAULT_STRENGTH, 15, 0.5, {type: ONESHOT}, function(v)
				{
					effect.setStrength(v, v);
				});
				FlxTween.tween(bgSky, {alpha: 0}, 0.4, {ease: FlxEase.expoIn});

				var currentNuts:Int = 0; // i love testicle among s!

			}
			case 2:
			{
				if(groundTween != null)
				{
						cancelTweens();
				}
				groundTween = FlxTween.tween(polusGround,{y: 1169.29}, 0.5 ,{ease: FlxEase.expoIn});
				hillsTween = FlxTween.tween(polusHills,{y: 873.62}, 0.6 ,{ease: FlxEase.expoIn});
				rocksTween = FlxTween.tween(polusRocks,{y: 712.09}, 0.8 ,{ease: FlxEase.expoIn});
				warehouseTween = FlxTween.tween(polusWarehouse,{y: 1220.92}, 0.7 ,{ease: FlxEase.expoIn});
				reactorTween = FlxTween.tween(reactor,{y: -400}, 0.6 ,{ease: FlxEase.expoIn});
				ballerTween = FlxTween.tween(baller,{y: 100}, 0.8 ,{ease: FlxEase.expoIn});
				defeatTween = FlxTween.tween(defeatScroll,{y: 937}, 3 ,{ease: FlxEase.expoOut});

				effectTween = FlxTween.num(15, MosaicEffect.DEFAULT_STRENGTH, 0.5, {type: ONESHOT}, function(v)
				{
					effect.setStrength(v, v);
				});
				FlxTween.tween(bgSky, {alpha: 1}, 0.4, {ease: FlxEase.expoOut});
				
			}
			case 3:
			{
				if(groundTween != null)
				{
						cancelTweens();
				}
				groundTween = FlxTween.tween(polusGround,{y: 1169.29}, 0.5 ,{ease: FlxEase.expoIn});
				hillsTween = FlxTween.tween(polusHills,{y: 873.62}, 0.6 ,{ease: FlxEase.expoIn});
				rocksTween = FlxTween.tween(polusRocks,{y: 712.09}, 0.8 ,{ease: FlxEase.expoIn});
				warehouseTween = FlxTween.tween(polusWarehouse,{y: 1220.92}, 0.7 ,{ease: FlxEase.expoIn});
				reactorTween = FlxTween.tween(reactor,{y: -400}, 0.6 ,{ease: FlxEase.expoIn});
				ballerTween = FlxTween.tween(baller,{y: 100}, 0.8 ,{ease: FlxEase.expoIn});
				defeatTween = FlxTween.tween(defeatScroll,{y: -2050}, 3 ,{ease: FlxEase.expoOut});

				effectTween = FlxTween.num(MosaicEffect.DEFAULT_STRENGTH, 15, 0.5, {type: ONESHOT}, function(v)
				{
					effect.setStrength(v, v);
				});
				FlxTween.tween(bgSky, {alpha: 0}, 0.4, {ease: FlxEase.expoIn});
			}
			case 4 | 5 | 6 | 7:
			{
				if(groundTween != null)
				{
						cancelTweens();
				}
				groundTween = FlxTween.tween(polusGround,{y: 1169.29}, 0.5 ,{ease: FlxEase.expoIn});
				hillsTween = FlxTween.tween(polusHills,{y: 873.62}, 0.6 ,{ease: FlxEase.expoIn});
				rocksTween = FlxTween.tween(polusRocks,{y: 712.09}, 0.8 ,{ease: FlxEase.expoIn});
				warehouseTween = FlxTween.tween(polusWarehouse,{y: 1220.92}, 0.7 ,{ease: FlxEase.expoIn});
				reactorTween = FlxTween.tween(reactor,{y: -400}, 0.6 ,{ease: FlxEase.expoIn});
				ballerTween = FlxTween.tween(baller,{y: 100}, 0.8 ,{ease: FlxEase.expoIn});
				defeatTween = FlxTween.tween(defeatScroll,{y: 937}, 3 ,{ease: FlxEase.expoOut});

				effectTween = FlxTween.num(MosaicEffect.DEFAULT_STRENGTH, 15, 0.5, {type: ONESHOT}, function(v)
				{
					effect.setStrength(v, v);
				});
				FlxTween.tween(bgSky, {alpha: 0}, 0.4, {ease: FlxEase.expoIn});
			}
		}
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!weekCompleted.exists(leWeek.weekBefore) || !weekCompleted.get(leWeek.weekBefore)));
	}

	function updateText()
	{
		var weekArray:Array<String> = loadedWeeks[curWeek].weekCharacters;
		for (i in 0...grpWeekCharacters.length) {
			grpWeekCharacters.members[i].changeCharacter(weekArray[i]);
		}

		var leWeek:WeekData = loadedWeeks[curWeek];
		var stringThing:Array<String> = [];
		for (i in 0...leWeek.songs.length) {
			stringThing.push(leWeek.songs[i][0]);
		}

		txtTracklist.text = '';
		for (i in 0...stringThing.length)
		{
			txtTracklist.text += stringThing[i] + '\n';
		}

		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

		#if !switch
		intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
		#end
	}
}
