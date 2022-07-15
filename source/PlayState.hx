package;

import flixel.addons.display.FlxBackdrop;
import flixel.graphics.FlxGraphic;
#if desktop
import Discord.DiscordClient;
#end
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.Lib;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.BitmapFilter;
import openfl.utils.Assets as OpenFlAssets;
import editors.ChartingState;
import editors.CharacterEditorState;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import Note.EventNote;
import openfl.events.KeyboardEvent;
import flixel.util.FlxSave;
import Achievements;
import StageData;
import FunkinLua;
import DialogueBoxPsych;
#if sys
import sys.FileSystem;
#end

using StringTools;

class PlayState extends MusicBeatState
{
	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;

	public static var ratingStuff:Array<Dynamic> = [
		['Amogus', 0.2], //From 0% to 19%
		['Shit', 0.4], //From 20% to 39%
		['Bad', 0.5], //From 40% to 49%
		['Bruh', 0.6], //From 50% to 59%
		['Meh', 0.69], //From 60% to 68%
		['Nice', 0.7], //69%
		['Good', 0.8], //From 70% to 79%
		['Great', 0.9], //From 80% to 89%
		['Sick!', 1], //From 90% to 99%
		['Perfect!!', 1] //The value on this one isn't used actually, since Perfect is always "1"
	];
	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartSprites:Map<String, ModchartSprite> = new Map<String, ModchartSprite>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	public var modchartTexts:Map<String, ModchartText> = new Map<String, ModchartText>();
	public var modchartSaves:Map<String, FlxSave> = new Map<String, FlxSave>();
	//event variables
	private var isCameraOnForcedPos:Bool = false;
	#if (haxe >= "4.0.0")
	public var boyfriendMap:Map<String, Boyfriend> = new Map();
	public var dadMap:Map<String, Character> = new Map();
	public var gfMap:Map<String, Character> = new Map();
	#else
	public var boyfriendMap:Map<String, Boyfriend> = new Map<String, Boyfriend>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	#end

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var songSpeedTween:FlxTween;
	public var songSpeed(default, set):Float = 1;
	public var songSpeedType:String = "multiplicative";
	public var noteKillOffset:Float = 350;
	
	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;
	public static var curStage:String = '';
	public static var isPixelStage:Bool = false;
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	public var vocals:FlxSound;

	public var dad:Character = null;
	public var gf:Character = null;
	public var boyfriend:Boyfriend = null;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<EventNote> = [];

	private var strumLine:FlxSprite;

	//Handles the new epic mega sexy cam code that i've done
	private var camFollow:FlxPoint;
	private var camFollowPos:FlxObject;
	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public var camZooming:Bool = false;
	private var curSong:String = "";

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var maxHealth:Float = 0;
	public var combo:Int = 0;

	private var healthBarBG:AttachedSprite;
	public var healthBar:FlxBar;
	var songPercent:Float = 0;

	private var timeBarBG:AttachedSprite;
	public var timeBar:FlxBar;
	
	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;
	
	private var generatedMusic:Bool = false;
	public var endingSong:Bool = false;
	public var startingSong:Bool = false;
	private var updateTime:Bool = true;
	public static var changedDifficulty:Bool = false;
	public static var chartingMode:Bool = false;

	//Gameplay settings
	public var healthGain:Float = 1;
	public var healthLoss:Float = 1;
	public var instakillOnMiss:Bool = false;
	public var cpuControlled:Bool = false;
	public var practiceMode:Bool = false;

	public var botplaySine:Float = 0;
	public var botplayTxt:FlxText;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;
	public var cameraSpeed:Float = 1;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	var dialogueJson:DialogueFile = null;

	var halloweenBG:BGSprite;
	var halloweenWhite:BGSprite;

	var phillyCityLights:FlxTypedGroup<BGSprite>;
	var phillyTrain:BGSprite;
	var blammedLightsBlack:ModchartSprite;
	var blammedLightsBlackTween:FlxTween;
	var phillyCityLightsEvent:FlxTypedGroup<BGSprite>;
	var phillyCityLightsEventTween:FlxTween;
	var trainSound:FlxSound;

	var limoKillingState:Int = 0;
	var limo:BGSprite;
	var limoMetalPole:BGSprite;
	var limoLight:BGSprite;
	var limoCorpse:BGSprite;
	var limoCorpseTwo:BGSprite;
	var bgLimo:BGSprite;
	var grpLimoParticles:FlxTypedGroup<BGSprite>;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:BGSprite;

	var upperBoppers:BGSprite;
	var bottomBoppers:BGSprite;
	var santa:BGSprite;
	var heyTimer:Float;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();
	var bgGhouls:BGSprite;

	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var scoreTxt:FlxText;
	var timeTxt:FlxText;
	var scoreTxtTween:FlxTween;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;

	public var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;
	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public var inCutscene:Bool = false;
	public var skipCountdown:Bool = false;
	var songLength:Float = 0;

	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	//Achievement shit
	var keysPressed:Array<Bool> = [];
	var boyfriendIdleTime:Float = 0.0;
	var boyfriendIdled:Bool = false;

	// Lua shit
	public static var instance:PlayState;
	public var luaArray:Array<FunkinLua> = [];
	private var luaDebugGroup:FlxTypedGroup<DebugLuaText>;
	public var introSoundsSuffix:String = '';
	public var introSpritesSuffix:String = '';

	// Debug buttons
	private var debugKeysChart:Array<FlxKey>;
	private var debugKeysCharacter:Array<FlxKey>;
	
	// Less laggy controls
	private var keysArray:Array<Dynamic>;

	var bgDark:FlxSprite;
	var machineDark:FlxSprite;
	var lightsOutSprite:FlxSprite;
	var amogus:FlxSprite;
	var dripster:FlxSprite;
	var yellow:FlxSprite;
	var brown:FlxSprite;
	var orb:FlxSprite = new FlxSprite();
	var deadBF:FlxSprite;
	var dark:FlxSprite;
	var cloudScroll:FlxTypedGroup<FlxSprite>;
	var farClouds:FlxTypedGroup<FlxSprite>;
	var middleBuildings:Array<FlxSprite>;
	var rightBuildings:Array<FlxSprite>;
	var leftBuildings:Array<FlxSprite>;
	var fgCloud:FlxSprite;
	var speedLines:FlxBackdrop;
	var stageFront2:FlxSprite;
	var stageFront3:FlxSprite;
	var stageFront2Dark:FlxSprite;
	var stageFront3Dark:FlxSprite;
	var miraGradient:FlxSprite;
	var bfStartpos:FlxPoint;
	var dadStartpos:FlxPoint;
	var gfStartpos:FlxPoint;
	private var lockedCam:Bool = false;
	var speedPass:Array<Float> = [11000, 11000, 11000, 11000];
	var farSpeedPass:Array<Float> = [11000, 11000, 11000, 11000, 11000, 11000, 11000];
	var ass2:FlxSprite;
	var _cb = 0;
	var crowd:FlxSprite = new FlxSprite();
	var snow:FlxSprite;
	var unowning:Bool = false;
	var jumpScare:FlxSprite;
	public var celebiLayer:FlxTypedGroup<FlxSprite>;
	var cameraCentered:Bool = false;
	public var showCountdown:Bool = true;
	var isMonoDead:Bool = false;
	var blacksquare:FlxSprite;
	var blackthing:FlxSprite;
	var grd:FlxSprite;
	var sus:FlxSprite;
	var coolthingiguess:FlxSprite;
	var coolfire:FlxSprite;
	var firelight:FlxSprite;
	var fireappears:FlxSprite;
	var blackScreen:FlxSprite;
	var eyeShine:FlxSprite;
	var ejectedBoom:FlxSprite;
	var devils:String = "devil's-gambit";
	var usedPractice:Bool = (ClientPrefs.getGameplaySetting('practice', false) || ClientPrefs.getGameplaySetting('botplay', false));
	var dlow:String = "d'low";
	
	override public function create()
	{
		Paths.clearStoredMemory();

		// for lua
		instance = this;
		
		debugKeysChart = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));
		debugKeysCharacter = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_2'));
		Achievements.loadAchievements();

		keysArray = [
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_left')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_down')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_up')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_right'))
		];

		// For the "Just the Two of Us" achievement
		for (i in 0...keysArray.length)
		{
			keysPressed.push(false);
		}

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// Gameplay settings
		healthGain = ClientPrefs.getGameplaySetting('healthgain', 1);
		healthLoss = ClientPrefs.getGameplaySetting('healthloss', 1);
		instakillOnMiss = ClientPrefs.getGameplaySetting('instakill', false);
		practiceMode = ClientPrefs.getGameplaySetting('practice', false);
		cpuControlled = ClientPrefs.getGameplaySetting('botplay', false);

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camOther);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		FlxCamera.defaultCameras = [camGame];
		CustomFadeTransition.nextCamera = camOther;
		//FlxG.cameras.setDefaultDrawTarget(camGame, true);

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		#if desktop
		storyDifficultyText = CoolUtil.difficulties[storyDifficulty];

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: " + WeekData.getCurrentWeek().weekName;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end

		GameOverSubstate.resetVariables();
		var songName:String = Paths.formatToSongPath(SONG.song);

		curStage = PlayState.SONG.stage;
		//trace('stage is: ' + curStage);
		if(PlayState.SONG.stage == null || PlayState.SONG.stage.length < 1) {
			switch (songName)
			{
				default:
					curStage = 'stage';
			}
		}

		var stageData:StageFile = StageData.getStageFile(curStage);
		if(stageData == null) { //Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = {
				directory: "",
				defaultZoom: 0.9,
				isPixelStage: false,
			
				boyfriend: [770, 100],
				girlfriend: [400, 130],
				opponent: [100, 100],
				hide_girlfriend: false,
			
				camera_boyfriend: [0, 0],
				camera_opponent: [0, 0],
				camera_girlfriend: [0, 0],
				camera_speed: 1
			};
		}

		defaultCamZoom = stageData.defaultZoom;
		isPixelStage = stageData.isPixelStage;
		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];

		if(stageData.camera_speed != null)
			cameraSpeed = stageData.camera_speed;

		boyfriendCameraOffset = stageData.camera_boyfriend;
		if(boyfriendCameraOffset == null) //Fucks sake should have done it since the start :rolling_eyes:
			boyfriendCameraOffset = [0, 0];

		opponentCameraOffset = stageData.camera_opponent;
		if(opponentCameraOffset == null)
			opponentCameraOffset = [0, 0];
		
		girlfriendCameraOffset = stageData.camera_girlfriend;
		if(girlfriendCameraOffset == null)
			girlfriendCameraOffset = [0, 0];

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);

		switch (curStage)
			{
			case 'stage':
				var bg:BGSprite = new BGSprite('stageback', -600, -200, 0.9, 0.9);
				add(bg);

				var stageFront:BGSprite = new BGSprite('stagefront', -650, 600, 0.9, 0.9);
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				add(stageFront);

				if(!ClientPrefs.lowQuality) {
					var stageLight:BGSprite = new BGSprite('stage_light', -125, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					add(stageLight);
					var stageLight:BGSprite = new BGSprite('stage_light', 1225, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					stageLight.flipX = true;
					add(stageLight);

					var stageCurtains:BGSprite = new BGSprite('stagecurtains', -500, -300, 1.3, 1.3);
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					add(stageCurtains);
				}
				case 'toogus':
								if (!ClientPrefs.Optimization)
								{	
								var bg:FlxSprite = new FlxSprite(0,50).loadGraphic(Paths.image('Mira'));
								bg.setGraphicSize(Std.int(bg.width * 1.4));
								bg.antialiasing = true;
								bg.scrollFactor.set(1, 1);
								bg.active = false;
								add(bg);

								bgDark = new FlxSprite(0,50).loadGraphic(Paths.image('MiraDark'));
								bgDark.setGraphicSize(Std.int(bgDark.width * 1.4));
								bgDark.antialiasing = true;
								bgDark.scrollFactor.set(1, 1);
								bgDark.active = false;
								bgDark.alpha = 0;
								add(bgDark);

								var stageFront:FlxSprite = new FlxSprite(1000, 150).loadGraphic(Paths.image('vending_machine'));
								stageFront.updateHitbox();
								stageFront.antialiasing = true;
								stageFront.scrollFactor.set(1, 1);
								stageFront.active = false;
								add(stageFront);

								machineDark = new FlxSprite(1000, 150).loadGraphic(Paths.image('vending_machineDark'));
								machineDark.updateHitbox();
								machineDark.antialiasing = true;
								machineDark.scrollFactor.set(1, 1);
								machineDark.active = false;
								machineDark.alpha = 0;
								add(machineDark);
								
								var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
								stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
								stageCurtains.updateHitbox();
								stageCurtains.antialiasing = true;
								stageCurtains.scrollFactor.set(1.3, 1.3);
								stageCurtains.active = false;
								}
								
								if (!ClientPrefs.Optimization)
								{	
								stageFront2 = new FlxSprite(-850, 800).loadGraphic(Paths.image('table'));
								stageFront2.updateHitbox();
								stageFront2.antialiasing = true;
								stageFront2.scrollFactor.set(1, 1);
								stageFront2.setGraphicSize(Std.int(stageFront2.width * 1.6));

								stageFront3 = new FlxSprite(1600, 800).loadGraphic(Paths.image('table'));
								stageFront3.updateHitbox();
								stageFront3.antialiasing = true;
								stageFront3.scrollFactor.set(1, 1);
								stageFront3.setGraphicSize(Std.int(stageFront3.width * 1.6));
								stageFront3.flipX = true;
								add(stageFront2);
								add(stageFront3);

								stageFront2Dark = new FlxSprite(-850, 800).loadGraphic(Paths.image('tableDark'));
								stageFront2Dark.updateHitbox();
								stageFront2Dark.antialiasing = true;
								stageFront2Dark.scrollFactor.set(1, 1);
								stageFront2Dark.setGraphicSize(Std.int(stageFront2Dark.width * 1.6));
								stageFront2Dark.alpha = 0;

								stageFront3Dark = new FlxSprite(1600, 800).loadGraphic(Paths.image('tableDark'));
								stageFront3Dark.updateHitbox();
								stageFront3Dark.antialiasing = true;
								stageFront3Dark.scrollFactor.set(1, 1);
								stageFront3Dark.setGraphicSize(Std.int(stageFront3Dark.width * 1.6));
								stageFront3Dark.flipX = true;
								stageFront3Dark.alpha = 0;
								add(stageFront2Dark);
								add(stageFront3Dark);
								}
								miraGradient = new FlxSprite(0,50).loadGraphic(Paths.image('MiraGradient'));
								miraGradient.setGraphicSize(Std.int(miraGradient.width * 1.4));
								miraGradient.antialiasing = true;
								miraGradient.scrollFactor.set(1, 1);
								miraGradient.active = false;
								miraGradient.alpha = 0;
								add(miraGradient);
								
								lightsOutSprite = new FlxSprite(0,50).loadGraphic(Paths.image('lightsOutSprite'));
								lightsOutSprite.setGraphicSize(Std.int(lightsOutSprite.width * 1.4));
								lightsOutSprite.antialiasing = true;
								lightsOutSprite.scrollFactor.set(1, 1);
								lightsOutSprite.active = false;
								lightsOutSprite.alpha = 0;
					case 'reactor':
								if (!ClientPrefs.Optimization)
								{	
								var bg:FlxSprite = new FlxSprite(-2300,-1700).loadGraphic(Paths.image('reactor/reactor background'));
								bg.setGraphicSize(Std.int(bg.width * 0.7));
								bg.antialiasing = true;
								bg.scrollFactor.set(1, 1);
								bg.active = false;
								add(bg);

								yellow = new FlxSprite(-400, 150);
								yellow.frames = Paths.getSparrowAtlas('reactor/susBoppers');
								yellow.animation.addByPrefix('bop', 'yellow sus', 24, false);
								yellow.animation.play('bop');
								yellow.setGraphicSize(Std.int(yellow.width * 0.7));
								yellow.antialiasing = true;
								yellow.scrollFactor.set(1, 1);
								yellow.active = true;
								add(yellow);

								var pillar1:FlxSprite = new FlxSprite(-2300,-1700).loadGraphic(Paths.image('reactor/back pillars'));
								pillar1.setGraphicSize(Std.int(pillar1.width * 0.7));
								pillar1.antialiasing = true;
								pillar1.scrollFactor.set(1, 1);
								pillar1.active = false;
								add(pillar1);

								dripster = new FlxSprite(1375, 150);
								dripster.frames = Paths.getSparrowAtlas('reactor/susBoppers');
								dripster.animation.addByPrefix('bop', 'blue sus', 24, false);
								dripster.animation.play('bop');
								dripster.setGraphicSize(Std.int(dripster.width * 0.7));
								dripster.antialiasing = true;
								dripster.scrollFactor.set(1, 1);
								dripster.active = true;
								add(dripster);

								var pillar2:FlxSprite = new FlxSprite(-2300,-1700).loadGraphic(Paths.image('reactor/middle pillars'));
								pillar2.setGraphicSize(Std.int(pillar2.width * 0.7));
								pillar2.antialiasing = true;
								pillar2.scrollFactor.set(1, 1);
								pillar2.active = false;
								add(pillar2);

								amogus = new FlxSprite(1670, 250);
								amogus.frames = Paths.getSparrowAtlas('reactor/susBoppers');
								amogus.animation.addByPrefix('bop', 'white sus', 24, false);
								amogus.animation.play('bop');
								amogus.setGraphicSize(Std.int(amogus.width * 0.7));
								amogus.antialiasing = true;
								amogus.scrollFactor.set(1, 1);
								amogus.active = true;
								add(amogus);

								brown = new FlxSprite(-850, 190);
								brown.frames = Paths.getSparrowAtlas('reactor/susBoppers');
								brown.animation.addByPrefix('bop', 'brown sus', 24, false);
								brown.animation.play('bop');
								brown.setGraphicSize(Std.int(brown.width * 0.7));
								brown.antialiasing = true;
								brown.scrollFactor.set(1, 1);
								brown.active = true;
								add(brown);

								var pillar3:FlxSprite = new FlxSprite(-2300,-1700).loadGraphic(Paths.image('reactor/front pillars'));
								pillar3.setGraphicSize(Std.int(pillar3.width * 0.7));
								pillar3.antialiasing = true;
								pillar3.scrollFactor.set(1, 1);
								pillar3.active = false;
								add(pillar3);
								}
								
								orb = new FlxSprite(-460,-1300).loadGraphic(Paths.image('reactor/ball of big ol energy'));
								orb.setGraphicSize(Std.int(orb.width * 0.7));
								orb.antialiasing = true;
								orb.scrollFactor.set(1, 1);
								orb.active = false;
								add(orb);
								
								if (!ClientPrefs.Optimization)
								{	
								var cranes:FlxSprite = new FlxSprite(-735, -1500).loadGraphic(Paths.image('reactor/upper cranes'));
								cranes.setGraphicSize(Std.int(cranes.width * 0.7));
								cranes.antialiasing = true;
								cranes.scrollFactor.set(1, 1);
								cranes.active = false;
								add(cranes);

								var console1:FlxSprite = new FlxSprite(-260,150).loadGraphic(Paths.image('reactor/center console'));
								console1.setGraphicSize(Std.int(console1.width * 0.7));
								console1.antialiasing = true;
								console1.scrollFactor.set(1, 1);
								console1.active = false;
								add(console1);

								var console2:FlxSprite = new FlxSprite(-1380,450).loadGraphic(Paths.image('reactor/side console'));
								console2.setGraphicSize(Std.int(console2.width * 0.7));
								console2.antialiasing = true;
								console2.scrollFactor.set(1, 1);
								console2.active = false;
								add(console2);
								}																		
					case 'polus':
		 						if (!ClientPrefs.Optimization)
								{	
								var sky:FlxSprite = new FlxSprite(-834.3, -620.5).loadGraphic(Paths.image('polus/polusSky'));
								sky.antialiasing = true;
								sky.scrollFactor.set(0.5, 0.5);
								sky.active = false;
								add(sky);		
				
								var rocks:FlxSprite = new FlxSprite(-915.8, -411.3).loadGraphic(Paths.image('polus/polusrocks'));
								rocks.updateHitbox();
								rocks.antialiasing = true;
								rocks.scrollFactor.set(0.6, 0.6);
								rocks.active = false;
								add(rocks);	
								
								var hills:FlxSprite = new FlxSprite(-1238.05, -180.55).loadGraphic(Paths.image('polus/polusHills'));
								hills.updateHitbox();
								hills.antialiasing = true;
								hills.scrollFactor.set(0.9, 0.9);
								hills.active = false;
								add(hills);

								var warehouse:FlxSprite = new FlxSprite(-458.35, -315.6).loadGraphic(Paths.image('polus/polusWarehouse'));
								warehouse.updateHitbox();
								warehouse.antialiasing = true;
								warehouse.scrollFactor.set(0.9, 0.9);
								warehouse.active = false;
								add(warehouse);

								var crowd:FlxSprite = new FlxSprite(-280.5, 240.8);
								crowd.frames = Paths.getSparrowAtlas('polus/CrowdBop');
								crowd.animation.addByPrefix('CrowdBop', 'CrowdBop', 24);
								crowd.animation.play('CrowdBop');
								crowd.scrollFactor.set(1, 1);
								crowd.antialiasing = true;
								crowd.updateHitbox();
								crowd.scale.set(1.5, 1.5);
								if(SONG.song.toLowerCase() == 'meltdown') {
									GameOverSubstate.characterName = 'bfg';
									add(crowd);
								}
								
								var ground:FlxSprite = new FlxSprite(-580.9, 241.85).loadGraphic(Paths.image('polus/polusGround'));
								ground.updateHitbox();
								ground.antialiasing = true;
								ground.scrollFactor.set(1, 1);
								ground.active = false;
								add(ground);
								
								var snow2:FlxSprite = new FlxSprite(-350, -400);
								snow2.frames = Paths.getSparrowAtlas('polus-maroon/snow');
								snow2.animation.addByPrefix('snow2', 'snow', 24);
								snow2.animation.play('snow2');
								snow2.antialiasing = true;
								snow2.scale.set(1.3, 1.3);
								add(snow2);
								}
								deadBF = new FlxSprite(532.95, 465.95).loadGraphic(Paths.image('polus/bfdead'));
								deadBF.antialiasing = true;
								deadBF.scrollFactor.set(1, 1);
								deadBF.updateHitbox();	
								
								coolthingiguess = new FlxSprite(-600,-400).loadGraphic(Paths.image('yes'));
								coolthingiguess.setGraphicSize(Std.int(coolthingiguess.width * 1.0));
								coolthingiguess.antialiasing = true;
								coolthingiguess.scrollFactor.set(1, 1);
								coolthingiguess.alpha = 0;								
					case 'polus-dt':
		 						if (!ClientPrefs.Optimization)
								{	
								var sky:FlxSprite = new FlxSprite(-834.3, -620.5).loadGraphic(Paths.image('polus/polusSky'));
								sky.antialiasing = true;
								sky.scrollFactor.set(0.5, 0.5);
								sky.active = false;
								add(sky);		
				
								var rocks:FlxSprite = new FlxSprite(-915.8, -411.3).loadGraphic(Paths.image('polus/polusrocks'));
								rocks.updateHitbox();
								rocks.antialiasing = true;
								rocks.scrollFactor.set(0.6, 0.6);
								rocks.active = false;
								add(rocks);	
								
								var hills:FlxSprite = new FlxSprite(-1238.05, -180.55).loadGraphic(Paths.image('polus/polusHills'));
								hills.updateHitbox();
								hills.antialiasing = true;
								hills.scrollFactor.set(0.9, 0.9);
								hills.active = false;
								add(hills);

								var warehouse:FlxSprite = new FlxSprite(-458.35, -315.6).loadGraphic(Paths.image('polus/polusWarehouse'));
								warehouse.updateHitbox();
								warehouse.antialiasing = true;
								warehouse.scrollFactor.set(0.9, 0.9);
								warehouse.active = false;
								add(warehouse);
								
								var ground:FlxSprite = new FlxSprite(-580.9, 241.85).loadGraphic(Paths.image('polus/polusGround'));
								ground.updateHitbox();
								ground.antialiasing = true;
								ground.scrollFactor.set(1, 1);
								ground.active = false;
								add(ground);
								
								var snow3:FlxSprite = new FlxSprite(-350, -400);
								snow3.frames = Paths.getSparrowAtlas('polus-maroon/snow');
								snow3.animation.addByPrefix('snow3', 'snow', 24);
								snow3.animation.play('snow3');
								snow3.antialiasing = true;
								snow3.scale.set(1.3, 1.3);
								add(snow3);
								}							
					case 'ejected':
								GameOverSubstate.deathSoundName = 'loss_ejected';
								GameOverSubstate.characterName = 'bf-fall';
								if (!ClientPrefs.Optimization)
								{	
								cloudScroll = new FlxTypedGroup<FlxSprite>();
								farClouds = new FlxTypedGroup<FlxSprite>();
								var sky:FlxSprite = new FlxSprite(-2372.25, -4181.7).loadGraphic(Paths.image('ejected/sky'));
								sky.antialiasing = true;
								sky.updateHitbox();
								sky.scrollFactor.set(0, 0);			
								add(sky);

								fgCloud = new FlxSprite(-2660.4, -402).loadGraphic(Paths.image('ejected/fgClouds'));
								fgCloud.antialiasing = true;
								fgCloud.updateHitbox();
								fgCloud.scrollFactor.set(0.2, 0.2);
								add(fgCloud);

								for(i in 0...farClouds.members.length) {
									add(farClouds.members[i]);
								}
								add(farClouds);

								rightBuildings = [];
								leftBuildings = [];
								middleBuildings = [];
								for(i in 0...2) {
									var rightBuilding = new FlxSprite(1022.3, -390.45);
									rightBuilding.frames = Paths.getSparrowAtlas('ejected/buildingSheet');
									rightBuilding.animation.addByPrefix('1', 'BuildingB1', 24, false);
									rightBuilding.animation.addByPrefix('2', 'BuildingB2', 24, false);
									rightBuilding.animation.play('1');
									rightBuilding.antialiasing = true;
									rightBuilding.updateHitbox();
									rightBuilding.scrollFactor.set(0.5, 0.5);
									add(rightBuilding);
									rightBuildings.push(rightBuilding);
								}
								
								for(i in 0...2) {
									var middleBuilding = new FlxSprite(-76.15, 1398.5);
									middleBuilding.frames = Paths.getSparrowAtlas('ejected/buildingSheet');
									middleBuilding.animation.addByPrefix('1', 'BuildingA1', 24, false);
									middleBuilding.animation.addByPrefix('2', 'BuildingA2', 24, false);
									middleBuilding.animation.play('1');
									middleBuilding.antialiasing = true;
									middleBuilding.updateHitbox();
									middleBuilding.scrollFactor.set(0.5, 0.5);
									add(middleBuilding);
									middleBuildings.push(middleBuilding);
								}
								
								for(i in 0...2) {
									var leftBuilding = new FlxSprite(-1099.3, 7286.55);
									leftBuilding.frames = Paths.getSparrowAtlas('ejected/buildingSheet');
									leftBuilding.animation.addByPrefix('1', 'BuildingB1', 24, false);
									leftBuilding.animation.addByPrefix('2', 'BuildingB2', 24, false);
									leftBuilding.animation.play('1');
									leftBuilding.antialiasing = true;
									leftBuilding.updateHitbox();
									leftBuilding.scrollFactor.set(0.5, 0.5);
									add(leftBuilding);
									leftBuildings.push(leftBuilding);
								}

								rightBuildings[0].y = 6803.1;
								middleBuildings[0].y = 8570.5;
								leftBuildings[0].y = 14050.2;

								for(i in 0...3) {
									var newCloud:FlxSprite = new FlxSprite();
									newCloud.frames = Paths.getSparrowAtlas('ejected/scrollingClouds');
									newCloud.animation.addByPrefix('idle', 'Cloud' + i, 24, false);
									newCloud.animation.play('idle');
									newCloud.updateHitbox();
									newCloud.alpha = 1;
									
									switch(i) {
										case 0:
											newCloud.setPosition(-9.65, -224.35);
											newCloud.scrollFactor.set(0.8, 0.8);
										case 1:
											newCloud.setPosition(-1342.85, -350.45);
											newCloud.scrollFactor.set(0.6, 0.6);
										case 2:
											newCloud.setPosition(1784.65, -957.05);
											newCloud.scrollFactor.set(1.3, 1.3);
										case 3:
											newCloud.setPosition(-2217.45, -1377.65);
											newCloud.scrollFactor.set(1, 1);
									}
									cloudScroll.add(newCloud);								
								}
								add(cloudScroll);
								
								for(i in 0...7) {
									var newCloud:FlxSprite = new FlxSprite();
									newCloud.frames = Paths.getSparrowAtlas('ejected/scrollingClouds');
									newCloud.animation.addByPrefix('idle', 'Cloud' + i, 24, false);
									newCloud.animation.play('idle');
									newCloud.updateHitbox();
									newCloud.alpha = 0.5;
									
									switch(i) {
										case 0:
											newCloud.setPosition(-1308, -1039.9);
										case 1:
											newCloud.setPosition(464.3, -890.5);
										case 2:
											newCloud.setPosition(2458.45, -1085.85);
										case 3:
											newCloud.setPosition(-666.95, -172.05);
										case 4:
											newCloud.setPosition(-1616.6, 1016.95);
										case 5:
											newCloud.setPosition(1714.25, 200.45);
										case 6:
											newCloud.setPosition(-167.05, 710.25);
									}
									farClouds.add(newCloud);								
								}
								speedLines = new FlxBackdrop(Paths.image('ejected/speedLines'), 1, 1, true, true);
								speedLines.antialiasing = true;
								speedLines.updateHitbox();
								speedLines.scrollFactor.set(1.3, 1.3);
								speedLines.alpha = 0.3;		
								for(i in 0...cloudScroll.members.length) {
									add(cloudScroll.members[i]);
								}
								add(cloudScroll);
								add(speedLines);
								}
								
								blackScreen = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 5), Std.int(FlxG.height * 5), FlxColor.BLACK);
								blackScreen.scrollFactor.set();
								blackScreen.screenCenter();
								blackScreen.alpha = 0;

								eyeShine = new FlxSprite(0, 0);
								eyeShine.antialiasing = true;
								eyeShine.frames = Paths.getSparrowAtlas('ejected/eye_shine_thing');
								eyeShine.animation.addByPrefix('idle', 'eye shine thing lol instance 1', 24, false);
								eyeShine.animation.play('idle');
								eyeShine.updateHitbox();
								eyeShine.scrollFactor.set();
								eyeShine.screenCenter();
								eyeShine.x -= 500;
								eyeShine.alpha = 0;
								
								ejectedBoom = new FlxSprite();
								ejectedBoom.frames = Paths.getSparrowAtlas('ejected/explosion');
								ejectedBoom.animation.addByPrefix('KABOOM', 'The instance 1', 24, false);
								ejectedBoom.updateHitbox();
								ejectedBoom.scrollFactor.set();
								ejectedBoom.screenCenter();
								ejectedBoom.scale.set(2, 2);
								ejectedBoom.animation.play('KABOOM');
								ejectedBoom.alpha = 0;
								
					case 'sussy':
						introSoundsSuffix = '-sus';
						GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
						GameOverSubstate.characterName = 'bf-pixel-dead';
						
						var bgSky = new FlxSprite().loadGraphic(Paths.image('sus/sky'));
						bgSky.scrollFactor.set(0, 0);
						add(bgSky);

						var repositionShit = -200;

						var bgStage:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('sus/stage'));
						bgStage.scrollFactor.set(0.95, 0.95);
						add(bgStage);

						var widShit = Std.int(bgSky.width * 6);

						bgSky.setGraphicSize(widShit);
						bgStage.setGraphicSize(widShit);

						bgSky.updateHitbox();
						bgStage.updateHitbox();	
						
					case 'airship_henry':
						var airship_1:FlxSprite = new FlxSprite(0, 100).loadGraphic(Paths.image('airship/airship_1'));		
						airship_1.setGraphicSize(Std.int(airship_1.width * 1.35));
						airship_1.antialiasing = true;
						add(airship_1);
						
					case 'airship-dk': //Big thanks Nes
						
					case 'defeat':
						var defeat:FlxSprite = new FlxSprite(0, 100).loadGraphic(Paths.image('defeatfnf'));		
						defeat.setGraphicSize(Std.int(defeat.width * 2));
						defeat.scrollFactor.set(1,1);
						defeat.antialiasing = true;
						add(defeat);
						
					case 'lounge':
						var lounge:BGSprite = new BGSprite('lounge', -455, -100);
						lounge.setGraphicSize(Std.int(lounge.width * 1.00));
						add(lounge);
						
					case 'polus-maroon': //Big thanks Nes
						if (!ClientPrefs.Optimization) 
						{	
							var skyBlack:FlxSprite = new FlxSprite(-400, -1800).loadGraphic(Paths.image('polus-maroon/lololo'));
							skyBlack.scrollFactor.set(1.025, 1.025);
							skyBlack.scale.set(0.87, 0.87);
							skyBlack.antialiasing = true;
							add(skyBlack);
							
							var sky:FlxSprite = new FlxSprite(-400, -195).loadGraphic(Paths.image('polus-maroon/polusSky'));
							sky.scrollFactor.set(1.025, 1.025);
							sky.scale.set(0.87, 0.87);
							sky.antialiasing = true;
							add(sky);
						
							var hills:FlxSprite = new FlxSprite(-400, -230).loadGraphic(Paths.image('polus-maroon/polusHills'));
							hills.scrollFactor.set(0.8, 0.94);
							hills.scale.set(0.87, 0.87);
							hills.antialiasing = true;
							add(hills);
							
							var maguma:FlxSprite = new FlxSprite(-400, -120).loadGraphic(Paths.image('polus-maroon/polusMaguma'));
							maguma.scrollFactor.set(0.8, 0.94);
							maguma.scale.set(0.87, 0.87);
							maguma.antialiasing = true;
							add(maguma);
						
							var glass:FlxSprite = new FlxSprite(-400, -100).loadGraphic(Paths.image('polus-maroon/polusGlass'));
							glass.scrollFactor.set(0.95, 0.95);
							glass.scale.set(0.87, 0.87);
							glass.antialiasing = true;
							add(glass);
						
							sus = new FlxSprite(348.5, 676);
							sus.frames = Paths.getSparrowAtlas('polus-maroon/sus');
							sus.animation.addByPrefix('sus', 'sus', 24, false);
							sus.scrollFactor.set(0.95, 0.95);
							sus.scale.set(0.88, 0.88);
							sus.antialiasing = true;
							add(sus);
							
							var house:FlxSprite = new FlxSprite(-400, -100).loadGraphic(Paths.image('polus-maroon/polusHouselol'));
							house.scrollFactor.set(0.95, 0.95);
							house.scale.set(0.87, 0.87);
							house.antialiasing = true;
							add(house);
							
							var field:FlxSprite = new FlxSprite(-400, -50).loadGraphic(Paths.image('polus-maroon/polusField'));
							field.scrollFactor.set(1, 1);
							field.scale.set(0.87, 0.87);
							field.antialiasing = true;
							add(field);
							
							snow = new FlxSprite(300, 400);
							snow.frames = Paths.getSparrowAtlas('polus-maroon/snow');
							snow.animation.addByPrefix('snow', 'snow', 24);
							snow.animation.play('snow');
							snow.antialiasing = true;
							snow.scale.set(1.3, 1.3);
						}
					case 'skinny-nuts':
						GameOverSubstate.characterName = 'clowfoe';
						GameOverSubstate.deathSoundName = 'justnothing';
						
					case 'gray':
						var gbg:FlxSprite = new FlxSprite(-510, -200).loadGraphic(Paths.image('sussy-polus'));
						gbg.setGraphicSize(Std.int(gbg.width * 1));
						gbg.antialiasing = true;
						add(gbg);
						
						grd = new FlxSprite(0,50).loadGraphic(Paths.image('grd'));
						grd.setGraphicSize(Std.int(grd.width * 1.8));
						grd.antialiasing = true;
						grd.scrollFactor.set(1, 1);
					
						blackthing = new FlxSprite(-250,50).loadGraphic(Paths.image('lightsOutSprite'));
						blackthing.setGraphicSize(Std.int(blackthing.width * 2));
						blackthing.scrollFactor.set(1, 1);
						blackthing.alpha = 0.50;
					
						firelight = new FlxSprite(-250,50).loadGraphic(Paths.image('fire_light'));
						firelight.setGraphicSize(Std.int(firelight.width * 2));
						firelight.scrollFactor.set(1, 1);
						firelight.alpha = 0;
				
						coolfire = new FlxSprite(-500, 750);
						coolfire.frames = Paths.getSparrowAtlas('fire');
						coolfire.animation.addByPrefix('fire', 'fire', 24);
						coolfire.setGraphicSize(Std.int(grd.width * 2.5));
						coolfire.animation.play('fire');
						coolfire.antialiasing = true;
						coolfire.alpha = 0.0;

						fireappears = new FlxSprite(0,0).loadGraphic(Paths.image('fire_appears'));
						fireappears.setGraphicSize(Std.int(fireappears.width * 1));
						fireappears.scrollFactor.set(1, 1);
						fireappears.alpha = 0;

					case 'spook':
						var space:FlxSprite = new FlxSprite(110, 1350).loadGraphic(Paths.image('spook/space'));
						space.setGraphicSize(Std.int(space.width * 3));
						space.antialiasing = false;
						add(space);
						
						var spook:FlxSprite = new FlxSprite(110, 1350).loadGraphic(Paths.image('spook/bg1'));
						spook.setGraphicSize(Std.int(spook.width * 3));
						spook.antialiasing = false;
						add(spook);
						
						var amoguses:FlxSprite = new FlxSprite(110, 1350);
						amoguses.frames = Paths.getSparrowAtlas('spook/people');
						amoguses.animation.addByPrefix('sus', 'the guys', 24);
						amoguses.animation.play('sus');
						amoguses.antialiasing = false;
						amoguses.scale.set(3.0, 3.0);
						add(amoguses);
						
						var bonfire:FlxSprite = new FlxSprite(110, 1350);
						bonfire.frames = Paths.getSparrowAtlas('spook/stockingFire');
						bonfire.animation.addByPrefix('fire', 'stocking fire', 24);
						bonfire.animation.play('fire');
						bonfire.antialiasing = false;
						bonfire.scale.set(3.0, 3.0);
						add(bonfire);
						
					case 'stageSpook':
						var space:FlxSprite = new FlxSprite(110, 1350).loadGraphic(Paths.image('spook/space'));
						space.setGraphicSize(Std.int(space.width * 3));
						space.antialiasing = false;
						add(space);
						
						var spook:FlxSprite = new FlxSprite(110, 1350).loadGraphic(Paths.image('spook/bg2'));
						spook.setGraphicSize(Std.int(spook.width * 3));
						spook.antialiasing = false;
						add(spook);
						
						var amoguses:FlxSprite = new FlxSprite(110, 1350);
						amoguses.frames = Paths.getSparrowAtlas('spook/people');
						amoguses.animation.addByPrefix('sus', 'the guys', 24);
						amoguses.animation.play('sus');
						amoguses.antialiasing = false;
						amoguses.scale.set(3.0, 3.0);
						add(amoguses);
						
						dark = new FlxSprite(110, 1350).loadGraphic(Paths.image('spook/dark'));
						dark.setGraphicSize(Std.int(dark.width * 6));
						dark.antialiasing = false;
						
					case 'airship': //Big thanks Nes
						
					case 'sus':
						showCountdown = false;
						FlxG.sound.play(Paths.sound('ImDead' + FlxG.random.int(1, 7), 'shared'), 1);
						new FlxTimer().start(2, function(tmr:FlxTimer)
						{
							startCountdown();
						});
						blacksquare = new FlxSprite(0,50).loadGraphic(Paths.image('lightsOutSprite'));
						blacksquare.setGraphicSize(Std.int(blacksquare.width * 1.4));
						blacksquare.antialiasing = true;
						blacksquare.scrollFactor.set(1, 1);
						blacksquare.active = false;
						blacksquare.alpha = 0;
						
					case 'infi':
						GameOverSubstate.characterName = 'bf-infi';
						
						if (!ClientPrefs.Optimization)
						{	
						var whitebg:FlxSprite = new FlxSprite(-246,-181).loadGraphic(Paths.image('infi/whitebg'));
						whitebg.antialiasing = true;
						var mountains:FlxSprite = new FlxSprite(-120,-86).loadGraphic(Paths.image('infi/mountains'));			
						mountains.scrollFactor.set(0.5,0.5);
						mountains.antialiasing = true;
						
						var housesmoke:FlxSprite = new FlxSprite(382,-225);
						housesmoke.frames = Paths.getSparrowAtlas('infi/house');
						housesmoke.animation.addByPrefix('house', 'house', 24, true);
						housesmoke.animation.play('house');
						housesmoke.antialiasing = true;
						housesmoke.scrollFactor.set(0.9,0.9);

						var ground:FlxSprite = new FlxSprite(-220,475).loadGraphic(Paths.image('infi/base'));
						ground.antialiasing = true;
						
						add(whitebg);
						add(mountains);									
						add(housesmoke);																									
						add(ground);	
						}
				}

		if(isPixelStage) {
			introSoundsSuffix = '-pixel';
		}
		
		if(curStage == 'spooky') {
			add(halloweenWhite);
		}

		#if LUA_ALLOWED
		luaDebugGroup = new FlxTypedGroup<DebugLuaText>();
		luaDebugGroup.cameras = [camOther];
		add(luaDebugGroup);
		#end
		
		if(curStage == 'sonicExeP3') {
			introSoundsSuffix = '-nothing';
			introSpritesSuffix = '-nothing';
		}
		
		if(curStage == 'philly') {
			phillyCityLightsEvent = new FlxTypedGroup<BGSprite>();
			for (i in 0...5)
			{
				var light:BGSprite = new BGSprite('philly/win' + i, -10, 0, 0.3, 0.3);
				light.visible = false;
				light.setGraphicSize(Std.int(light.width * 0.85));
				light.updateHitbox();
				phillyCityLightsEvent.add(light);
			}
		}

		if (SONG.song.toLowerCase() == 'boing!') {
			GameOverSubstate.characterName = 'impostordeath';
			GameOverSubstate.deathSoundName = 'kill';
			GameOverSubstate.loopSoundName = 'death';
			GameOverSubstate.endSoundName = 'revive';
		}

		// "GLOBAL" SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('scripts/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('scripts/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/scripts/'));
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end
		

		// STAGE SCRIPTS
		#if (MODS_ALLOWED && LUA_ALLOWED)
		var doPush:Bool = false;
		var luaFile:String = 'stages/' + curStage + '.lua';
		if(FileSystem.exists(Paths.modFolders(luaFile))) {
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		} else {
			luaFile = Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}

		if(doPush) 
			luaArray.push(new FunkinLua(luaFile));
		#end

		if(!modchartSprites.exists('blammedLightsBlack')) { //Creates blammed light black fade in case you didn't make your own
			blammedLightsBlack = new ModchartSprite(FlxG.width * -0.5, FlxG.height * -0.5);
			blammedLightsBlack.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
			var position:Int = members.indexOf(gfGroup);
			if(members.indexOf(boyfriendGroup) < position) {
				position = members.indexOf(boyfriendGroup);
			} else if(members.indexOf(dadGroup) < position) {
				position = members.indexOf(dadGroup);
			}
			insert(position, blammedLightsBlack);

			blammedLightsBlack.wasAdded = true;
			modchartSprites.set('blammedLightsBlack', blammedLightsBlack);
		}
		if(curStage == 'philly') insert(members.indexOf(blammedLightsBlack) + 1, phillyCityLightsEvent);
		blammedLightsBlack = modchartSprites.get('blammedLightsBlack');
		blammedLightsBlack.alpha = 0.0;

		var gfVersion:String = SONG.gfVersion;
		if(gfVersion == null || gfVersion.length < 1) {
			switch (curStage)
			{
				case 'limo':
					gfVersion = 'gf-car';
				case 'mall' | 'mallEvil':
					gfVersion = 'gf-christmas';
				case 'school' | 'schoolEvil':
					gfVersion = 'gf-pixel';
				default:
					gfVersion = 'gf';
			}
			SONG.gfVersion = gfVersion; //Fix for the Chart Editor
		}

		if (!stageData.hide_girlfriend)
		{
			gf = new Character(0, 0, gfVersion);
			startCharacterPos(gf);
			gf.scrollFactor.set(0.95, 0.95);
			gfGroup.add(gf);
			startCharacterLua(gf.curCharacter);
		}

		dad = new Character(0, 0, SONG.player2);
		startCharacterPos(dad, true);
		dadGroup.add(dad);
		startCharacterLua(dad.curCharacter);
		
		boyfriend = new Boyfriend(0, 0, SONG.player1);
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);
		startCharacterLua(boyfriend.curCharacter);
		
		var camPos:FlxPoint = new FlxPoint(girlfriendCameraOffset[0], girlfriendCameraOffset[1]);
		if(gf != null)
		{
			camPos.x += gf.getGraphicMidpoint().x + gf.cameraPosition[0];
			camPos.y += gf.getGraphicMidpoint().y + gf.cameraPosition[1];
		}

		if(dad.curCharacter.startsWith('gf')) {
			dad.setPosition(GF_X, GF_Y);
			if(gf != null)
				gf.visible = false;
		}

		if(curStage == "ejected")
		{
		bfStartpos = new FlxPoint(boyfriend.x, boyfriend.y);
		gfStartpos = new FlxPoint(gf.x, gf.y);
		dadStartpos = new FlxPoint(dad.x, dad.y);
		}
		
		if(curStage == "defeat") {
			add(gfGroup);
			add(boyfriendGroup);
			add(dadGroup);
		} else {
			if (SONG.song.toLowerCase() == 'danger') {
				add(dadGroup);
				add(gfGroup);
				add(boyfriendGroup);
			} else {
				add(gfGroup);
				if (SONG.song.toLowerCase() == 'meltdown') {
					add(deadBF);
				}
				if (SONG.song.toLowerCase() == 'monosus') {
					celebiLayer = new FlxTypedGroup<FlxSprite>();
					add(celebiLayer);
				}
				if (SONG.song.toLowerCase() == 'lights-down') {
					add(lightsOutSprite);
				}
				if (SONG.song.toLowerCase() == 'cleaning') {
					add(coolthingiguess);
				}
				add(dadGroup);
				add(boyfriendGroup);
			}
		}

		if (SONG.song.toLowerCase() == 'spookpostor') {
			add(dark);
		}
		
		if (curStage == "polus-maroon") {
			add(snow);
		}
		
		if (curStage == "gray") {
			add(grd);
			add(blackthing);
			add(firelight);
			add(coolfire);
			add(fireappears);
		}

		switch(curStage)
		{
			case 'limo':
				resetFastCar();
				insert(members.indexOf(gfGroup) - 1, fastCar);
			
			case 'schoolEvil':
				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069); //nice
				insert(members.indexOf(dadGroup) - 1, evilTrail);
		}

		var file:String = Paths.json(songName + '/dialogue'); //Checks for json/Psych Engine dialogue
		if (OpenFlAssets.exists(file)) {
			dialogueJson = DialogueBoxPsych.parseDialogue(file);
		}

		var file:String = Paths.txt(songName + '/' + songName + 'Dialogue'); //Checks for vanilla/Senpai dialogue
		if (OpenFlAssets.exists(file)) {
			dialogue = CoolUtil.coolTextFile(file);
		}
		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;
		doof.nextDialogueThing = startNextDialogue;
		doof.skipDialogueThing = skipDialogue;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);
		if(ClientPrefs.downScroll) strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();

		if(!ClientPrefs.middleScroll) {
			var showTime:Bool = (ClientPrefs.timeBarType != 'Disabled');
			timeTxt = new FlxText(100, 20, 400, "", 32);
			timeTxt.setFormat(Paths.font("vcr.ttf"), 15, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			timeTxt.scrollFactor.set();
			timeTxt.alpha = 0;
			timeTxt.borderSize = 1;
			timeTxt.visible = showTime;
			if(ClientPrefs.downScroll) timeTxt.y = FlxG.height - 35;

			if(ClientPrefs.timeBarType == 'Song Name')
			{
				timeTxt.text = SONG.song;
			}
			updateTime = showTime;

			timeBarBG = new AttachedSprite('timeBar');
			timeBarBG.x = timeTxt.x + -20;
			timeBarBG.y = timeTxt.y;
			timeBarBG.scrollFactor.set();
			timeBarBG.alpha = 0;
			timeBarBG.visible = showTime;
			timeBarBG.xAdd = -4;
			timeBarBG.yAdd = -4;
			
			timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
				'songPercent', 0, 1);
			timeBar.scrollFactor.set();
			timeBar.createFilledBar(0xFF2F372A, 0xFF47BD55);
			timeBar.numDivisions = 800; //How much lag this causes?? Should i tone it down to idk, 400 or 200?
			timeBar.alpha = 0;
			timeBar.visible = showTime;
			add(timeBar);
			add(timeBarBG);
			add(timeTxt);
			timeBarBG.sprTracker = timeBar;
		} else {
			var showTime:Bool = (ClientPrefs.timeBarType != 'Disabled');
			timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 245, 20, 400, "", 32);
			timeTxt.setFormat(Paths.font("vcr.ttf"), 15, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			timeTxt.scrollFactor.set();
			timeTxt.alpha = 0;
			timeTxt.borderSize = 1;
			timeTxt.visible = showTime;
			if(ClientPrefs.downScroll) timeTxt.y = FlxG.height - 35;

			if(ClientPrefs.timeBarType == 'Song Name')
			{
				timeTxt.text = SONG.song;
			}
			updateTime = showTime;

			timeBarBG = new AttachedSprite('timeBar');
			timeBarBG.x = timeTxt.x - 55;
			timeBarBG.y = timeTxt.y;
			timeBarBG.scrollFactor.set();
			timeBarBG.alpha = 0;
			timeBarBG.visible = showTime;
			timeBarBG.xAdd = -4;
			timeBarBG.yAdd = -4;
			
			timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
				'songPercent', 0, 1);
			timeBar.scrollFactor.set();
			timeBar.createFilledBar(0xFF2F372A, 0xFF47BD55);
			timeBar.numDivisions = 800; //How much lag this causes?? Should i tone it down to idk, 400 or 200?
			timeBar.alpha = 0;
			timeBar.visible = showTime;
			add(timeBar);
			add(timeBarBG);
			add(timeTxt);
			timeBarBG.sprTracker = timeBar;
		}
	
		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);
		add(grpNoteSplashes);

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0;

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

		// startCountdown();

		generateSong(SONG.song);
		#if LUA_ALLOWED
		for (notetype in noteTypeMap.keys())
		{
			var luaToLoad:String = Paths.modFolders('custom_notetypes/' + notetype + '.lua');
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			else
			{
				luaToLoad = Paths.getPreloadPath('custom_notetypes/' + notetype + '.lua');
				if(FileSystem.exists(luaToLoad))
				{
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
		}
		for (event in eventPushedMap.keys())
		{
			var luaToLoad:String = Paths.modFolders('custom_events/' + event + '.lua');
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			else
			{
				luaToLoad = Paths.getPreloadPath('custom_events/' + event + '.lua');
				if(FileSystem.exists(luaToLoad))
				{
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
		}
		#end
		noteTypeMap.clear();
		noteTypeMap = null;
		eventPushedMap.clear();
		eventPushedMap = null;

		// After all characters being loaded, it makes then invisible 0.01s later so that the player won't freeze when you change characters
		// add(strumLine);

		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);

		snapCamFollowToPos(camPos.x, camPos.y);
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		if (prevCamFollowPos != null)
		{
			camFollowPos = prevCamFollowPos;
			prevCamFollowPos = null;
		}
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;
		moveCameraSection(0);

		ass2 = new FlxSprite(0, FlxG.height * 1).loadGraphic(Paths.image('vignette')); 
		ass2.scrollFactor.set();
		ass2.screenCenter();
		if (curSong == 'reactor')
		{
			add(ass2);
		}

		healthBarBG = new AttachedSprite('healthBar');
		healthBarBG.y = FlxG.height * 0.89;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.visible = !ClientPrefs.hideHud;
		healthBarBG.xAdd = -4;
		healthBarBG.yAdd = -4;
		if (SONG.song.toLowerCase() != 'defeat' && SONG.song.toLowerCase() != 'bf defeat') {
			add(healthBarBG);
		}
		if(ClientPrefs.downScroll) healthBarBG.y = 0.11 * FlxG.height;

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.visible = !ClientPrefs.hideHud;
		healthBar.alpha = ClientPrefs.healthBarAlpha;
		if (SONG.song.toLowerCase() != 'defeat' && SONG.song.toLowerCase() != 'bf defeat') {
			add(healthBar);
		}
		healthBarBG.sprTracker = healthBar;

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - 75;
		iconP1.visible = !ClientPrefs.hideHud;
		iconP1.alpha = ClientPrefs.healthBarAlpha;
		add(iconP1);

		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.y = healthBar.y - 75;
		iconP2.visible = !ClientPrefs.hideHud;
		iconP2.alpha = ClientPrefs.healthBarAlpha;
		add(iconP2);
		reloadHealthBarColors();

		scoreTxt = new FlxText(0, healthBarBG.y + 36, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.visible = !ClientPrefs.hideHud;
		add(scoreTxt);

		botplayTxt = new FlxText(400, timeBarBG.y + 55, FlxG.width - 800, "BOTPLAY", 32);
		botplayTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled;
		add(botplayTxt);
		if(ClientPrefs.downScroll) {
			botplayTxt.y = timeBarBG.y - 78;
		}

		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		botplayTxt.cameras = [camHUD];
		timeBar.cameras = [camHUD];
		timeBarBG.cameras = [camHUD];
		timeTxt.cameras = [camHUD];
		doof.cameras = [camHUD];
		
		if (curStage == "gray") {
			grd.cameras = [camHUD];
			blackthing.cameras = [camHUD];
			fireappears.cameras = [camHUD];
		}

		switch (SONG.song.toLowerCase()) {
			case 'monosus':
				healthBar.alpha = 0;
				healthBarBG.alpha = 0;
				iconP1.alpha = 0;
				iconP2.alpha = 0;
				scoreTxt.alpha = 0;
				timeBar.alpha = 0;
				timeBarBG.alpha = 0;
				timeTxt.alpha = 0;
				dad.visible = false;
			
				jumpScare = new FlxSprite().loadGraphic(Paths.image('sus/jumpscare'));
				jumpScare.setGraphicSize(Std.int(FlxG.width * jumpscareSizeInterval), Std.int(FlxG.height * jumpscareSizeInterval));
				jumpScare.updateHitbox();
				jumpScare.screenCenter();
				add(jumpScare);

				jumpScare.setGraphicSize(Std.int(FlxG.width * jumpscareSizeInterval), Std.int(FlxG.height * jumpscareSizeInterval));
				jumpScare.updateHitbox();
				jumpScare.screenCenter();

				jumpScare.visible = false;
				jumpScare.cameras = [camHUD];
				
				add(blacksquare);
				blacksquare.cameras = [camHUD];
		} 

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		// SONG SPECIFIC SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('data/' + Paths.formatToSongPath(SONG.song) + '/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('data/' + Paths.formatToSongPath(SONG.song) + '/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/data/' + Paths.formatToSongPath(SONG.song) + '/'));
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end
		
		var daSong:String = Paths.formatToSongPath(curSong);
		if (isStoryMode)
		{
			switch (daSong)
			{
				case 'sussus-moogus':					
					startDialogue(dialogueJson);				
				case 'sabotage':
					startDialogue(dialogueJson);	
				case 'meltdown':
					startDialogue(dialogueJson);	
				case 'sussus-toogus':
					startDialogue(dialogueJson);	
				case 'lights-down':
					startDialogue(dialogueJson);
				case 'reactor':
					startDialogue(dialogueJson);					
				case 'ejected':
					blackScreen.alpha = 1;
					add(blackScreen);
					snapCamFollowToPos(gf.getMidpoint().x, gf.getMidpoint().y - 1000);

					camHUD.visible = false;
					inCutscene = true;
					lockedCam = true;
					defaultCamZoom = 0.8;
					FlxG.camera.zoom = 0.8;			
					
					new FlxTimer().start(2, function(shine:FlxTimer) {
						eyeShine.alpha = 1;
						add(eyeShine);
						FlxG.sound.play(Paths.sound('explosion'));
						new FlxTimer().start(1, function(tmr:FlxTimer)
						{						
							FlxG.camera.focusOn(camFollow);
							ejectedBoom.alpha = 1;
							add(ejectedBoom);						
	
							new FlxTimer().start(0.7, function(tmr2:FlxTimer)
							{							
								blackScreen.destroy();	
								FlxTween.tween(FlxG.camera, {zoom: 0.45}, 2, {ease:FlxEase.quadInOut});
								FlxTween.tween(camFollow, {y: dad.getMidpoint().y}, 2, {ease: FlxEase.quadInOut});			
							});
	
							new FlxTimer().start(1.5, function(tmr3:FlxTimer)
							{							
								ejectedBoom.destroy();					
							});
	
							new FlxTimer().start(3, function(tmr2:FlxTimer)
							{						
								defaultCamZoom = 0.45;
								camHUD.visible = true;	
								lockedCam = false;
								inCutscene = false;
								startCountdown();				
							});
						});
					});
				default:
					startCountdown();
			}
			seenCutscene = true;
		}
		else
		{
			startCountdown();
		}
		RecalculateRating();

		//PRECACHING MISS SOUNDS BECAUSE I THINK THEY CAN LAG PEOPLE AND FUCK THEM UP IDK HOW HAXE WORKS
		if(ClientPrefs.hitsoundVolume > 0) CoolUtil.precacheSound('hitsound');
		CoolUtil.precacheSound('missnote1');
		CoolUtil.precacheSound('missnote2');
		CoolUtil.precacheSound('missnote3');
		CoolUtil.precacheMusic('breakfast');

		#if desktop
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		#end

		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}

		Conductor.safeZoneOffset = (ClientPrefs.safeFrames / 60) * 1000;
		callOnLuas('onCreatePost', []);
		
		super.create();
		Paths.clearUnusedMemory();
		CustomFadeTransition.nextCamera = camOther;
	}
	function set_songSpeed(value:Float):Float
	{
		if(generatedMusic)
		{
			var ratio:Float = value / songSpeed; //funny word huh
			for (note in notes)
			{
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
				{
					note.scale.y *= ratio;
					note.updateHitbox();
				}
			}
			for (note in unspawnNotes)
			{
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
				{
					note.scale.y *= ratio;
					note.updateHitbox();
				}
			}
		}
		songSpeed = value;
		noteKillOffset = 350 / songSpeed;
		return value;
	}

	public function addTextToDebug(text:String) {
		#if LUA_ALLOWED
		luaDebugGroup.forEachAlive(function(spr:DebugLuaText) {
			spr.y += 20;
		});

		if(luaDebugGroup.members.length > 34) {
			var blah = luaDebugGroup.members[34];
			blah.destroy();
			luaDebugGroup.remove(blah);
		}
		luaDebugGroup.insert(0, new DebugLuaText(text, luaDebugGroup));
		#end
	}

	public function reloadHealthBarColors() {
		healthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
			FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
			
		healthBar.updateBar();
	}

	public function addCharacterToList(newCharacter:String, type:Int) {
		switch(type) {
			case 0:
				if(!boyfriendMap.exists(newCharacter)) {
					var newBoyfriend:Boyfriend = new Boyfriend(0, 0, newCharacter);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
					startCharacterLua(newBoyfriend.curCharacter);
				}

			case 1:
				if(!dadMap.exists(newCharacter)) {
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
					startCharacterLua(newDad.curCharacter);
				}

			case 2:
				if(gf != null && !gfMap.exists(newCharacter)) {
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
					startCharacterLua(newGf.curCharacter);
				}
		}
	}

	function startCharacterLua(name:String)
	{
		#if LUA_ALLOWED
		var doPush:Bool = false;
		var luaFile:String = 'characters/' + name + '.lua';
		if(FileSystem.exists(Paths.modFolders(luaFile))) {
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		} else {
			luaFile = Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}
		
		if(doPush)
		{
			for (lua in luaArray)
			{
				if(lua.scriptName == luaFile) return;
			}
			luaArray.push(new FunkinLua(luaFile));
		}
		#end
	}
	
	function startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		if(gfCheck && char.curCharacter.startsWith('gf')) { //IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
			char.danceEveryNumBeats = 2;
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	var dialogueCount:Int = 0;
	public var psychDialogue:DialogueBoxPsych;
	//You don't have to add a song, just saying. You can just do "startDialogue(dialogueJson);" and it should work
	public function startDialogue(dialogueFile:DialogueFile, ?song:String = null):Void
	{
		// TO DO: Make this more flexible, maybe?
		if(psychDialogue != null) return;

		if(dialogueFile.dialogue.length > 0) {
			inCutscene = true;
			CoolUtil.precacheSound('dialogue');
			CoolUtil.precacheSound('dialogueClose');
			psychDialogue = new DialogueBoxPsych(dialogueFile, song);
			psychDialogue.scrollFactor.set();
			if(endingSong) {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					endSong();
				}
			} else {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					startCountdown();
				}
			}
			psychDialogue.nextDialogueThing = startNextDialogue;
			psychDialogue.skipDialogueThing = skipDialogue;
			psychDialogue.cameras = [camHUD];
			add(psychDialogue);
		} else {
			FlxG.log.warn('Your dialogue file is badly formatted!');
			if(endingSong) {
				endSong();
			} else {
				startCountdown();
			}
		}
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		inCutscene = true;
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();
		senpaiEvil.x += 300;

		var songName:String = Paths.formatToSongPath(SONG.song);
		if (songName == 'roses' || songName == 'thorns')
		{
			remove(black);

			if (songName == 'thorns')
			{
				add(red);
				camHUD.visible = false;
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					if (Paths.formatToSongPath(SONG.song) == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
										camHUD.visible = true;
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	function susIntro(?dialogueBox:DialogueBox):Void
		{
			FlxG.camera.fade(FlxColor.BLACK, 2, true, function()
			{
				if (dialogueBox != null)
					{
						inCutscene = true;
						add(dialogueBox);
					}
					else
						startCountdown();
			}, true);
		}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	// For being able to mess with the sprites on Lua
	public var countdownReady:FlxSprite;
	public var countdownSet:FlxSprite;
	public var countdownGo:FlxSprite;
	public static var startOnTime:Float = 0;

	public function startCountdown():Void
	{
		if(startedCountdown) {
			callOnLuas('onStartCountdown', []);
			return;
		}

		inCutscene = false;
		var ret:Dynamic = callOnLuas('onStartCountdown', []);
		if(ret != FunkinLua.Function_Stop) {
			if (skipCountdown || startOnTime > 0) skipArrowStartTween = true;
			generateStaticArrows(0);
			generateStaticArrows(1);
			for (i in 0...playerStrums.length) {
				setOnLuas('defaultPlayerStrumX' + i, playerStrums.members[i].x);
				setOnLuas('defaultPlayerStrumY' + i, playerStrums.members[i].y);
			}
			for (i in 0...opponentStrums.length) {
				setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
				setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
				//if(ClientPrefs.middleScroll) opponentStrums.members[i].visible = false;
			}

			startedCountdown = true;
			Conductor.songPosition = 0;
			Conductor.songPosition -= Conductor.crochet * 5;
			setOnLuas('startedCountdown', true);
			callOnLuas('onCountdownStarted', []);

			var swagCounter:Int = 0;

			if (skipCountdown || startOnTime > 0) {
				clearNotesBefore(startOnTime);
				setSongTime(startOnTime - 500);
				return;
			}

			startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
			{
				if (gf != null && tmr.loopsLeft % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && !gf.stunned && gf.animation.curAnim.name != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
				{
					gf.dance();
				}
				if (tmr.loopsLeft % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
				{
					boyfriend.dance();
				}
				if (tmr.loopsLeft % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
				{
					dad.dance();
				}

				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				introAssets.set('default', [
					('ready' + introSpritesSuffix),
					('set' + introSpritesSuffix),
					('go' + introSpritesSuffix)
                ]);
				introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

				var introAlts:Array<String> = introAssets.get('default');
				var antialias:Bool = ClientPrefs.globalAntialiasing;
				if(isPixelStage) {
					introAlts = introAssets.get('pixel');
					antialias = false;
				}

				// head bopping for bg characters on Mall
				if(curStage == 'mall') {
					if(!ClientPrefs.lowQuality)
						upperBoppers.dance(true);
	
					bottomBoppers.dance(true);
					santa.dance(true);
				}
				if (showCountdown) {
					switch (swagCounter)
					{
						case 0:
							FlxG.sound.play(Paths.sound('intro3' + introSoundsSuffix), 0.6);
						case 1:
							countdownReady = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
							countdownReady.scrollFactor.set();
							countdownReady.updateHitbox();

							if (PlayState.isPixelStage)
								countdownReady.setGraphicSize(Std.int(countdownReady.width * daPixelZoom));

							countdownReady.screenCenter();
							countdownReady.antialiasing = antialias;
							add(countdownReady);
							FlxTween.tween(countdownReady, {/*y: countdownReady.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									remove(countdownReady);
									countdownReady.destroy();
								}
							});
							FlxG.sound.play(Paths.sound('intro2' + introSoundsSuffix), 0.6);
						case 2:
							countdownSet = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
							countdownSet.scrollFactor.set();

							if (PlayState.isPixelStage)
								countdownSet.setGraphicSize(Std.int(countdownSet.width * daPixelZoom));

							countdownSet.screenCenter();
							countdownSet.antialiasing = antialias;
							add(countdownSet);
							FlxTween.tween(countdownSet, {/*y: countdownSet.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									remove(countdownSet);
									countdownSet.destroy();
								}
							});
							FlxG.sound.play(Paths.sound('intro1' + introSoundsSuffix), 0.6);
						case 3:
							countdownGo = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
							countdownGo.scrollFactor.set();

							if (PlayState.isPixelStage)
								countdownGo.setGraphicSize(Std.int(countdownGo.width * daPixelZoom));

							countdownGo.updateHitbox();

							countdownGo.screenCenter();
							countdownGo.antialiasing = antialias;
							add(countdownGo);
							FlxTween.tween(countdownGo, {/*y: countdownGo.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									remove(countdownGo);
									countdownGo.destroy();
								}
							});
							FlxG.sound.play(Paths.sound('introGo' + introSoundsSuffix), 0.6);
						case 4:
					}
				}
				
				notes.forEachAlive(function(note:Note) {
					note.copyAlpha = false;
					note.alpha = note.multAlpha;
					if(ClientPrefs.middleScroll && !note.mustPress) {
						note.alpha *= 0.5;
					}
				});
				callOnLuas('onCountdownTick', [swagCounter]);

				swagCounter += 1;
				// generateSong('fresh');
			}, 5);
		}
	}

	public function clearNotesBefore(time:Float)
	{
		var i:Int = unspawnNotes.length - 1;
		while (i >= 0) {
			var daNote:Note = unspawnNotes[i];
			if(daNote.strumTime - 500 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				unspawnNotes.remove(daNote);
				daNote.destroy();
			}
			--i;
		}

		i = notes.length - 1;
		while (i >= 0) {
			var daNote:Note = notes.members[i];
			if(daNote.strumTime - 500 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				notes.remove(daNote, true);
				daNote.destroy();
			}
			--i;
		}
	}

	public function setSongTime(time:Float)
	{
		if(time < 0) time = 0;

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.time = time;
		FlxG.sound.music.play();

		vocals.time = time;
		vocals.play();
		Conductor.songPosition = time;
	}

	function startNextDialogue() {
		dialogueCount++;
		callOnLuas('onNextDialogue', [dialogueCount]);
	}

	function skipDialogue() {
		callOnLuas('onSkipDialogue', [dialogueCount]);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.onComplete = onSongComplete;
		vocals.play();

		if (SONG.song.toLowerCase() == 'monosus') {
			dad.animation.play('spawn', true);
			dad.visible = true;
		}

		if(startOnTime > 0)
		{
			setSongTime(startOnTime - 500);
		}

		if(paused) {
			//trace('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			vocals.pause();
		}

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		if (SONG.song.toLowerCase() != 'monosus') {
			FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
			FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		}
		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength);
		#end
		setOnLuas('songLength', songLength);
		callOnLuas('onSongStart', []);
	}

	var debugNum:Int = 0;
	private var noteTypeMap:Map<String, Bool> = new Map<String, Bool>();
	private var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();
	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());
		songSpeedType = ClientPrefs.getGameplaySetting('scrolltype','multiplicative');

		switch(songSpeedType)
		{
			case "multiplicative":
				songSpeed = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1);
			case "constant":
				songSpeed = ClientPrefs.getGameplaySetting('scrollspeed', 1);
		}
		
		var songData = SONG;
		Conductor.changeBPM(songData.bpm);
		
		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.song)));

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		var songName:String = Paths.formatToSongPath(SONG.song);
		var file:String = Paths.json(songName + '/events');
		#if sys
		if (FileSystem.exists(Paths.modsJson(songName + '/events')) || FileSystem.exists(file)) {
		#else
		if (OpenFlAssets.exists(file)) {
		#end
			var eventsData:Array<Dynamic> = Song.loadFromJson('events', songName).events;
			for (event in eventsData) //Event Notes
			{
				for (i in 0...event[1].length)
				{
					var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
					var subEvent:EventNote = {
						strumTime: newEventNote[0] + ClientPrefs.noteOffset,
						event: newEventNote[1],
						value1: newEventNote[2],
						value2: newEventNote[3]
					};
					subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
					eventNotes.push(subEvent);
					eventPushed(subEvent);
				}
			}
		}

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.mustPress = gottaHitNote;
				swagNote.sustainLength = songNotes[2];
				swagNote.gfNote = (section.gfSection && (songNotes[1]<4));
				swagNote.noteType = songNotes[3];
				if(!Std.isOfType(songNotes[3], String)) swagNote.noteType = editors.ChartingState.noteTypeList[songNotes[3]]; //Backward compatibility + compatibility with Week 7 charts
				
				swagNote.scrollFactor.set();

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				var floorSus:Int = Math.floor(susLength);
				if(floorSus > 0) {
					for (susNote in 0...floorSus+1)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(songSpeed, 2)), daNoteData, oldNote, true);
						sustainNote.mustPress = gottaHitNote;
						sustainNote.gfNote = (section.gfSection && (songNotes[1]<4));
						sustainNote.noteType = swagNote.noteType;
						sustainNote.scrollFactor.set();
						unspawnNotes.push(sustainNote);

						if (sustainNote.mustPress)
						{
							sustainNote.x += FlxG.width / 2; // general offset
						}
						else if(ClientPrefs.middleScroll)
						{
							sustainNote.x += 310;
							if(daNoteData > 1) //Up and Right
							{
								sustainNote.x += FlxG.width / 2 + 25;
							}
						}
					}
				}

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else if(ClientPrefs.middleScroll)
				{
					swagNote.x += 310;
					if(daNoteData > 1) //Up and Right
					{
						swagNote.x += FlxG.width / 2 + 25;
					}
				}

				if(!noteTypeMap.exists(swagNote.noteType)) {
					noteTypeMap.set(swagNote.noteType, true);
				}
			}
			daBeats += 1;
		}
		for (event in songData.events) //Event Notes
		{
			for (i in 0...event[1].length)
			{
				var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
				var subEvent:EventNote = {
					strumTime: newEventNote[0] + ClientPrefs.noteOffset,
					event: newEventNote[1],
					value1: newEventNote[2],
					value2: newEventNote[3]
				};
				subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
				eventNotes.push(subEvent);
				eventPushed(subEvent);
			}
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);
		if(eventNotes.length > 1) { //No need to sort if there's a single one or none at all
			eventNotes.sort(sortByTime);
		}
		checkEventNote();
		generatedMusic = true;
	}

	function eventPushed(event:EventNote) {
		switch(event.event) {
			case 'Change Character':
				var charType:Int = 0;
				switch(event.value1.toLowerCase()) {
					case 'gf' | 'girlfriend' | '1':
						charType = 2;
					case 'dad' | 'opponent' | '0':
						charType = 1;
					default:
						charType = Std.parseInt(event.value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				var newCharacter:String = event.value2;
				addCharacterToList(newCharacter, charType);
		}

		if(!eventPushedMap.exists(event.event)) {
			eventPushedMap.set(event.event, true);
		}
	}

	function eventNoteEarlyTrigger(event:EventNote):Float {
		var returnedValue:Float = callOnLuas('eventEarlyTrigger', [event.event]);
		if(returnedValue != 0) {
			return returnedValue;
		}

		switch(event.event) {
			case 'Kill Henchmen': //Better timing so that the kill sound matches the beat intended
				return 280; //Plays 280ms before the actual position
		}
		return 0;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByTime(Obj1:EventNote, Obj2:EventNote):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	public var skipArrowStartTween:Bool = false; //for lua
	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var targetAlpha:Float = 1;
			if (player < 1 && ClientPrefs.middleScroll) targetAlpha = 0.35;

			var babyArrow:StrumNote = new StrumNote(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, strumLine.y, i, player);
			babyArrow.downScroll = ClientPrefs.downScroll;
			if (!isStoryMode && !skipArrowStartTween)
			{
				//babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {/*y: babyArrow.y + 10,*/ alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}
			else
			{
				babyArrow.alpha = targetAlpha;
			}

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}
			else
			{
				if(ClientPrefs.middleScroll)
				{
					babyArrow.x += 310;
					if(i > 1) { //Up and Right
						babyArrow.x += FlxG.width / 2 + 25;
					}
				}
				opponentStrums.add(babyArrow);
			}

			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = false;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = false;
			if (songSpeedTween != null)
				songSpeedTween.active = false;

			if(blammedLightsBlackTween != null)
				blammedLightsBlackTween.active = false;
			if(phillyCityLightsEventTween != null)
				phillyCityLightsEventTween.active = false;

			if(carTimer != null) carTimer.active = false;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = false;
				}
			}

			for (tween in modchartTweens) {
				tween.active = false;
			}
			for (timer in modchartTimers) {
				timer.active = false;
			}
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = true;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = true;
			if (songSpeedTween != null)
				songSpeedTween.active = true;

			if(blammedLightsBlackTween != null)
				blammedLightsBlackTween.active = true;
			if(phillyCityLightsEventTween != null)
				phillyCityLightsEventTween.active = true;
			
			if(carTimer != null) carTimer.active = true;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = true;
				}
			}
			
			for (tween in modchartTweens) {
				tween.active = true;
			}
			for (timer in modchartTimers) {
				timer.active = true;
			}
			paused = false;
			callOnLuas('onResume', []);

			#if desktop
			if (startTimer != null && startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			}
		}
		#end

		super.onFocus();
	}
	
	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if (isMonoDead) {
			Conductor.songPosition = 0;
			return;
		} 
		if(finishTimer != null) return;

		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	public var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var limoSpeed:Float = 0;

	public var tweeningChar:Bool = false;

	function startUnown(timer:Int = 15, word:String = ''):Void {
		canPause = false;
		unowning = true;
		persistentUpdate = true;
		persistentDraw = true;
		var realTimer = timer;
		var unownState = new SusSubState(realTimer, word);
		unownState.win = wonUnown;
		unownState.lose = die;
		unownState.cameras = [camHUD];
		FlxG.autoPause = false;
		openSubState(unownState);
	}
	
	public function wonUnown():Void {
		canPause = true;
		unowning = false;
	}

	override public function update(elapsed:Float)
	{	
		callOnLuas('onUpdate', [elapsed]);

		if(curStage == "ejected")
		{
			if(!inCutscene)
				camGame.shake(0.002, 0.1);

			if(!tweeningChar && !inCutscene)
			{
				tweeningChar = true;
				FlxTween.tween(boyfriend, {x: FlxG.random.float(bfStartpos.x - 15, bfStartpos.x + 15), y: FlxG.random.float(bfStartpos.y - 15, bfStartpos.y + 15)}, 0.4, {
					ease: FlxEase.smoothStepInOut,
					onComplete: function(twn:FlxTween)
					{
						tweeningChar = false;
					}
				});
				FlxTween.tween(gf, {x: FlxG.random.float(gfStartpos.x - 10, gfStartpos.x + 10), y: FlxG.random.float(gfStartpos.y - 10, gfStartpos.y + 10)}, 0.4, {
					ease: FlxEase.smoothStepInOut});
				FlxTween.tween(dad, {x: FlxG.random.float(dadStartpos.x - 15, dadStartpos.x + 15), y: FlxG.random.float(dadStartpos.y - 15, dadStartpos.y + 15)}, 0.4, {
					ease: FlxEase.smoothStepInOut});
			}
		}

		switch (curStage)
		{
			case 'ejected':
			if (!ClientPrefs.Optimization)
			{	
				if(cloudScroll.members.length == 3) {
					for(i in 0...cloudScroll.members.length) {					
						cloudScroll.members[i].y -= speedPass[i] / (cast(Lib.current.getChildAt(0), Main)).getFPS();
						if(cloudScroll.members[i].y < -1789.65) {
							//im not using flxbackdrops so this is how we're doing things today
							var randomScale = FlxG.random.float(1.5, 2.2);
							var randomScroll = FlxG.random.float(1, 1.3);

							speedPass[i] = FlxG.random.float(9000, 11000);

							cloudScroll.members[i].scale.set(randomScale, randomScale);
							cloudScroll.members[i].scrollFactor.set(randomScroll, randomScroll);
							cloudScroll.members[i].x = FlxG.random.float(-3578.95, 3259.6);
							cloudScroll.members[i].y = 2196.15;
						}
					}
				}
				if(farClouds.members.length == 7) {
					for(i in 0...farClouds.members.length) {					
						farClouds.members[i].y -= farSpeedPass[i] / (cast(Lib.current.getChildAt(0), Main)).getFPS();
						if(farClouds.members[i].y < -1614) {
							var randomScale = FlxG.random.float(0.2, 0.5);
							var randomScroll = FlxG.random.float(0.2, 0.4);

							farSpeedPass[i] = FlxG.random.float(9000, 11000);

							farClouds.members[i].scale.set(randomScale, randomScale);
							farClouds.members[i].scrollFactor.set(randomScroll, randomScroll);
							farClouds.members[i].x = FlxG.random.float(-2737.85, 3485.4);
							farClouds.members[i].y = 1738.6;
						}
					}
				}		
				if(leftBuildings.length > 0) {
					for(i in 0...leftBuildings.length) {
						leftBuildings[i].y = middleBuildings[i].y + 5888;
					}
				}
				if(middleBuildings.length > 0) {
					for(i in 0...middleBuildings.length) {
						if(middleBuildings[i].y < -11759.9) {
							middleBuildings[i].y = 3190.5;
							middleBuildings[i].animation.play(FlxG.random.bool(50) ? '1' : '2');
						}			
						middleBuildings[i].y -= 9000 / (cast(Lib.current.getChildAt(0), Main)).getFPS();
					}
				}
				if(rightBuildings.length > 0) {
					for(i in 0...rightBuildings.length) {
						rightBuildings[i].y = leftBuildings[i].y;
					}
				}
				speedLines.y -= 9000 / (cast(Lib.current.getChildAt(0), Main)).getFPS();
				if(fgCloud != null) {
					fgCloud.y -= 0.01;
				}
			}
			case 'schoolEvil':
				if(!ClientPrefs.lowQuality && bgGhouls.animation.curAnim.finished) {
					bgGhouls.visible = false;
				}
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed * 1.5;
			case 'limo':
				if(!ClientPrefs.lowQuality) {
					grpLimoParticles.forEach(function(spr:BGSprite) {
						if(spr.animation.curAnim.finished) {
							spr.kill();
							grpLimoParticles.remove(spr, true);
							spr.destroy();
						}
					});

					switch(limoKillingState) {
						case 1:
							limoMetalPole.x += 5000 * elapsed;
							limoLight.x = limoMetalPole.x - 180;
							limoCorpse.x = limoLight.x - 50;
							limoCorpseTwo.x = limoLight.x + 35;

							var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
							for (i in 0...dancers.length) {
								if(dancers[i].x < FlxG.width * 1.5 && limoLight.x > (370 * i) + 130) {
									switch(i) {
										case 0 | 3:
											if(i == 0) FlxG.sound.play(Paths.sound('dancerdeath'), 0.5);

											var diffStr:String = i == 3 ? ' 2 ' : ' ';
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 200, dancers[i].y, 0.4, 0.4, ['hench leg spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 160, dancers[i].y + 200, 0.4, 0.4, ['hench arm spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x, dancers[i].y + 50, 0.4, 0.4, ['hench head spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);

											var particle:BGSprite = new BGSprite('gore/stupidBlood', dancers[i].x - 110, dancers[i].y + 20, 0.4, 0.4, ['blood'], false);
											particle.flipX = true;
											particle.angle = -57.5;
											grpLimoParticles.add(particle);
										case 1:
											limoCorpse.visible = true;
										case 2:
											limoCorpseTwo.visible = true;
									} //Note: Nobody cares about the fifth dancer because he is mostly hidden offscreen :(
									dancers[i].x += FlxG.width * 2;
								}
							}

							if(limoMetalPole.x > FlxG.width * 2) {
								resetLimoKill();
								limoSpeed = 800;
								limoKillingState = 2;
							}

						case 2:
							limoSpeed -= 4000 * elapsed;
							bgLimo.x -= limoSpeed * elapsed;
							if(bgLimo.x > FlxG.width * 1.5) {
								limoSpeed = 3000;
								limoKillingState = 3;
							}

						case 3:
							limoSpeed -= 2000 * elapsed;
							if(limoSpeed < 1000) limoSpeed = 1000;

							bgLimo.x -= limoSpeed * elapsed;
							if(bgLimo.x < -275) {
								limoKillingState = 4;
								limoSpeed = 800;
							}

						case 4:
							bgLimo.x = FlxMath.lerp(bgLimo.x, -150, CoolUtil.boundTo(elapsed * 9, 0, 1));
							if(Math.round(bgLimo.x) == -150) {
								bgLimo.x = -150;
								limoKillingState = 0;
							}
					}

					if(limoKillingState > 2) {
						var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
						for (i in 0...dancers.length) {
							dancers[i].x = (370 * i) + bgLimo.x + 280;
						}
					}
				}
			case 'mall':
				if(heyTimer > 0) {
					heyTimer -= elapsed;
					if(heyTimer <= 0) {
						bottomBoppers.dance(true);
						heyTimer = 0;
					}
				}
		}

		if(curSong == 'Reactor') {
			if(orb != null) {
				orb.scale.x = FlxMath.lerp(0.7, orb.scale.x, 0.90);
				orb.scale.y = FlxMath.lerp(0.7, orb.scale.y, 0.90);
				orb.alpha = FlxMath.lerp(0.96, orb.alpha, 0.90);
				ass2.alpha = FlxMath.lerp(1, ass2.alpha, 0.90);
			}
		}

		if(!inCutscene) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4 * cameraSpeed, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
			if(!startingSong && !endingSong && boyfriend.animation.curAnim.name.startsWith('idle')) {
				boyfriendIdleTime += elapsed;
				if(boyfriendIdleTime >= 0.15) { // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some playerss
					boyfriendIdled = true;
				}
			} else {
				boyfriendIdleTime = 0;
			}
		}

		super.update(elapsed);

		if(ratingName == '?') {
			scoreTxt.text = 'Score: ' + songScore + ' | Misses: ' + songMisses + ' | Rating: ' + ratingName;
		} else {
			scoreTxt.text = 'Score: ' + songScore + ' | Misses: ' + songMisses + ' | Rating: ' + ratingName + ' (' + Highscore.floorDecimal(ratingPercent * 100, 2) + '%)' + ' - ' + ratingFC;//peeps wanted no integer rating
		}

		if(botplayTxt.visible) {
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}

		if (controls.PAUSE && startedCountdown && canPause)
		{
			var ret:Dynamic = callOnLuas('onPause', []);
			if(ret != FunkinLua.Function_Stop) {
				persistentUpdate = false;
				persistentDraw = true;
				paused = true;

				// 1 / 1000 chance for Gitaroo Man easter egg
				/*if (FlxG.random.bool(0.1))
				{
					// gitaroo man easter egg
					cancelMusicFadeTween();
					MusicBeatState.switchState(new GitarooPause());
				}
				else {*/
				if(FlxG.sound.music != null) {
					FlxG.sound.music.pause();
					vocals.pause();
				}
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				//}
		
				#if desktop
				DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
				#end
			}
		}

		if (FlxG.keys.anyJustPressed(debugKeysChart) && !endingSong && !inCutscene)
		{
			openChartEditor();
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		var mult:Float = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		iconP1.scale.set(mult, mult);
		iconP1.updateHitbox();

		var mult:Float = FlxMath.lerp(1, iconP2.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		iconP2.scale.set(mult, mult);
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		if (SONG.song.toLowerCase() != 'defeat' && SONG.song.toLowerCase() != 'bf defeat') {
		    iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		    iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);
		} else {
			iconP1.x = (FlxG.width / 2) - iconOffset;
			iconP2.x = (FlxG.width / 2) - (iconP2.width - iconOffset);
		}

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20 && SONG.song.toLowerCase() != 'defeat' && SONG.song.toLowerCase() != 'bf defeat')
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		if (FlxG.keys.anyJustPressed(debugKeysCharacter) && !endingSong && !inCutscene) {
			persistentUpdate = false;
			paused = true;
			cancelMusicFadeTween();
			MusicBeatState.switchState(new CharacterEditorState(SONG.player2));
		}

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}

				if(updateTime) {
					var curTime:Float = Conductor.songPosition - ClientPrefs.noteOffset;
					if(curTime < 0) curTime = 0;
					songPercent = (curTime / songLength);

					var songCalc:Float = (songLength - curTime);
					if(ClientPrefs.timeBarType == 'Time Elapsed') songCalc = curTime;

					var secondsTotal:Int = Math.floor(songCalc / 1000);
					if(secondsTotal < 0) secondsTotal = 0;

					if(ClientPrefs.timeBarType != 'Song Name')
						timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		// RESET = Quick Game Over Screen
		if (!ClientPrefs.noReset && controls.RESET && !inCutscene && !endingSong && !unowning)
		{
			health = 0;
			trace("RESET = True");
		}
		doDeathCheck();

		if (unspawnNotes[0] != null)
		{
			var time:Float = 3000;//shit be werid on 4:3
			if(songSpeed < 1) time /= songSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			if (!inCutscene) {
				if(!cpuControlled) {
					keyShit();
				} else if(boyfriend.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss')) {
					boyfriend.dance();
					//boyfriend.animation.curAnim.finish();
				}
			}

			var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
			notes.forEachAlive(function(daNote:Note)
			{
				var strumGroup:FlxTypedGroup<StrumNote> = playerStrums;
				if(!daNote.mustPress) strumGroup = opponentStrums;

				var strumX:Float = strumGroup.members[daNote.noteData].x;
				var strumY:Float = strumGroup.members[daNote.noteData].y;
				var strumAngle:Float = strumGroup.members[daNote.noteData].angle;
				var strumDirection:Float = strumGroup.members[daNote.noteData].direction;
				var strumAlpha:Float = strumGroup.members[daNote.noteData].alpha;
				var strumScroll:Bool = strumGroup.members[daNote.noteData].downScroll;

				strumX += daNote.offsetX;
				strumY += daNote.offsetY;
				strumAngle += daNote.offsetAngle;
				strumAlpha *= daNote.multAlpha;

				if (strumScroll) //Downscroll
				{
					//daNote.y = (strumY + 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
					daNote.distance = (0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
				}
				else //Upscroll
				{
					//daNote.y = (strumY - 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
					daNote.distance = (-0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
				}

				var angleDir = strumDirection * Math.PI / 180;
				if (daNote.copyAngle)
					daNote.angle = strumDirection - 90 + strumAngle;

				if(daNote.copyAlpha)
					daNote.alpha = strumAlpha;
				
				if(daNote.copyX)
					daNote.x = strumX + Math.cos(angleDir) * daNote.distance;

				if(daNote.copyY)
				{
					daNote.y = strumY + Math.sin(angleDir) * daNote.distance;

					//Jesus fuck this took me so much mother fucking time AAAAAAAAAA
					if(strumScroll && daNote.isSustainNote)
					{
						if (daNote.animation.curAnim.name.endsWith('end')) {
							daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * songSpeed + (46 * (songSpeed - 1));
							daNote.y -= 46 * (1 - (fakeCrochet / 600)) * songSpeed;
							if(PlayState.isPixelStage) {
								daNote.y += 8 + (6 - daNote.originalHeightForCalcs) * PlayState.daPixelZoom;
							} else {
								daNote.y -= 19;
							}
						} 
						daNote.y += (Note.swagWidth / 2) - (60.5 * (songSpeed - 1));
						daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (songSpeed - 1);
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
				{
					opponentNoteHit(daNote);
				}

				if(daNote.mustPress && cpuControlled) {
					if(daNote.isSustainNote) {
						if(daNote.canBeHit) {
							goodNoteHit(daNote);
						}
					} else if(daNote.strumTime <= Conductor.songPosition || (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress)) {
						goodNoteHit(daNote);
					}
				}
				
				var center:Float = strumY + Note.swagWidth / 2;
				if(strumGroup.members[daNote.noteData].sustainReduce && daNote.isSustainNote && (daNote.mustPress || !daNote.ignoreNote) &&
					(!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
				{
					if (strumScroll)
					{
						if(daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center)
						{
							var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
							swagRect.height = (center - daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;

							daNote.clipRect = swagRect;
						}
					}
					else
					{
						if (daNote.y + daNote.offset.y * daNote.scale.y <= center)
						{
							var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
							swagRect.y = (center - daNote.y) / daNote.scale.y;
							swagRect.height -= swagRect.y;

							daNote.clipRect = swagRect;
						}
					}
				}

				// Kill extremely late notes and cause misses
				if (Conductor.songPosition > noteKillOffset + daNote.strumTime)
				{
					if (daNote.mustPress && !cpuControlled &&!daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit)) {
						noteMiss(daNote);
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}
		checkEventNote();
		
		if(curSong == "Defeat" && songMisses > 0 && camHUD.visible  && !practiceMode)
		{
			camOther.visible = false;
			camHUD.visible = false;
			inCutscene = true;
			canPause = false;
			camZooming = false;
			startedCountdown = false;
			generatedMusic = false;

			vocals.stop();

			#if desktop
			DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			#end

			snapCamFollowToPos(dad.getMidpoint().x - 400, dad.getMidpoint().y - 210);	
			dad.playAnim('death');

			dad.stunned = true;

			FlxG.sound.play(Paths.sound('black-death'));
			
			FlxTween.tween(FlxG.camera, {zoom: 1.2}, 1.5, {ease: FlxEase.circOut});

			GameOverSubstate.characterName = 'bf-defeat-death';
			GameOverSubstate.deathSoundName = 'loss-defeat';
			GameOverSubstate.loopSoundName = 'gameOverEmpty';
			GameOverSubstate.endSoundName = 'gameOverEndEmpty';

			if(FlxG.random.bool(5)) {
			GameOverSubstate.characterName = 'bf-defeat-secret';
			GameOverSubstate.deathSoundName = 'no-balls';
			}
			
			new FlxTimer().start(0.6, function(tmr:FlxTimer)
			{
				boyfriend.stunned = true;

				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				boyfriend.setPosition(dad.getMidpoint().x - 610, dad.getMidpoint().y - 370);

				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x - boyfriend.positionArray[0], boyfriend.getScreenPosition().y - boyfriend.positionArray[1], camFollowPos.x, camFollowPos.y));
			});
		}
		
		if(curSong == "BF Defeat" && songMisses > 0 && camHUD.visible  && !practiceMode)
		{
			camOther.visible = false;
			camHUD.visible = false;
			inCutscene = true;
			canPause = false;
			camZooming = false;
			startedCountdown = false;
			generatedMusic = false;

			vocals.stop();

			#if desktop
			DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			#end

			snapCamFollowToPos(dad.getMidpoint().x - 400, dad.getMidpoint().y - 210);	

			dad.stunned = true;
			
			FlxTween.tween(FlxG.camera, {zoom: 1.2}, 1.5, {ease: FlxEase.circOut});

			GameOverSubstate.characterName = 'bf-impostor-death';
			GameOverSubstate.deathSoundName = 'loss-defeat';
			GameOverSubstate.loopSoundName = 'gameOverEmpty';
			GameOverSubstate.endSoundName = 'gameOverEndEmpty';

			if(FlxG.random.bool(5)) {
			GameOverSubstate.characterName = 'bf-impostor-secret';
			GameOverSubstate.deathSoundName = 'no-balls';
			}
			
			new FlxTimer().start(0.6, function(tmr:FlxTimer)
			{
				boyfriend.stunned = true;

				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				boyfriend.setPosition(dad.getMidpoint().x - 610, dad.getMidpoint().y - 370);

				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x - boyfriend.positionArray[0], boyfriend.getScreenPosition().y - boyfriend.positionArray[1], camFollowPos.x, camFollowPos.y));
			});
		}
		
		#if debug
		if(!endingSong && !startingSong) {
			if (FlxG.keys.justPressed.ONE) {
				KillNotes();
				FlxG.sound.music.onComplete();
			}
			if(FlxG.keys.justPressed.TWO) { //Go 10 seconds into the future :O
				setSongTime(Conductor.songPosition + 10000);
				clearNotesBefore(Conductor.songPosition);
			}
		}
		#end

		setOnLuas('cameraX', camFollowPos.x);
		setOnLuas('cameraY', camFollowPos.y);
		setOnLuas('botPlay', cpuControlled);
		callOnLuas('onUpdatePost', [elapsed]);
	}

	function openChartEditor()
	{
		persistentUpdate = false;
		paused = true;
		cancelMusicFadeTween();
		MusicBeatState.switchState(new ChartingState());
		chartingMode = true;

		#if desktop
		DiscordClient.changePresence("Chart Editor", null, null, true);
		#end
	}

	public var isDead:Bool = false;
	
	public function die():Void {
		if (SONG.song.toLowerCase() == 'monosus') {
			boyfriend.stunned = true;
			deathCounter++;
			
			paused = true;
			FlxG.sound.music.volume = 0;
			PlayState.instance.vocals.volume = 0;

			dad.debugMode = true;
			dad.playAnim('despawn', true);
			dad.animation.finishCallback = function (name:String) {
				remove(dad);
			}
			FlxTween.tween(blacksquare, {alpha: 1}, 1, {ease: FlxEase.linear});
			new FlxTimer().start(2, function(shine:FlxTimer) {
				isMonoDead = true;
				PauseSubState.restartSong(true);
			});
			
			isDead = true;
		} else {
			var ret:Dynamic = callOnLuas('onGameOver', []);
			if(ret != FunkinLua.Function_Stop) {
				boyfriend.stunned = true;
				deathCounter++;

				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				persistentUpdate = false;
				persistentDraw = false;
				for (tween in modchartTweens) {
					tween.active = true;
				}
				for (timer in modchartTimers) {
					timer.active = true;
				}
				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x - boyfriend.positionArray[0], boyfriend.getScreenPosition().y - boyfriend.positionArray[1], camFollowPos.x, camFollowPos.y));

				// MusicBeatState.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				
				#if desktop
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
				#end
				isDead = true;
			}
		}
	}
	function doDeathCheck(?skipHealthCheck:Bool = false) {
		if ((skipHealthCheck && instakillOnMiss) || health <= maxHealth && !practiceMode && !isDead)
		{
			die();
			return true;
		}
		return false;
	}

	public function checkEventNote() {
		while(eventNotes.length > 0) {
			var leStrumTime:Float = eventNotes[0].strumTime;
			if(Conductor.songPosition < leStrumTime) {
				break;
			}

			var value1:String = '';
			if(eventNotes[0].value1 != null)
				value1 = eventNotes[0].value1;

			var value2:String = '';
			if(eventNotes[0].value2 != null)
				value2 = eventNotes[0].value2;

			triggerEventNote(eventNotes[0].event, value1, value2);
			eventNotes.shift();
		}
	}

	public function getControl(key:String) {
		var pressed:Bool = Reflect.getProperty(controls, key);
		//trace('Control result: ' + pressed);
		return pressed;
	}

	public function triggerEventNote(eventName:String, value1:String, value2:String) {
		switch(eventName) {
			case 'Hey!':
				var value:Int = 2;
				switch(value1.toLowerCase().trim()) {
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				var time:Float = Std.parseFloat(value2);
				if(Math.isNaN(time) || time <= 0) time = 0.6;

				if(value != 0) {
					if(dad.curCharacter.startsWith('gf')) { //Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = time;
					} else if (gf != null) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = time;
					}

					if(curStage == 'mall') {
						bottomBoppers.animation.play('hey', true);
						heyTimer = time;
					}
				}
				if(value != 1) {
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = time;
				}

			case 'Set GF Speed':
				var value:Int = Std.parseInt(value1);
				if(Math.isNaN(value) || value < 1) value = 1;
				gfSpeed = value;

			case 'Blammed Lights':
				var lightId:Int = Std.parseInt(value1);
				if(Math.isNaN(lightId)) lightId = 0;

				var chars:Array<Character> = [boyfriend, gf, dad];
				if(lightId > 0 && curLightEvent != lightId) {
					if(lightId > 5) lightId = FlxG.random.int(1, 5, [curLightEvent]);

					var color:Int = 0xffffffff;
					switch(lightId) {
						case 1: //Blue
							color = 0xff31a2fd;
						case 2: //Green
							color = 0xff31fd8c;
						case 3: //Pink
							color = 0xfff794f7;
						case 4: //Red
							color = 0xfff96d63;
						case 5: //Orange
							color = 0xfffba633;
					}
					curLightEvent = lightId;

					if(blammedLightsBlack.alpha == 0) {
						if(blammedLightsBlackTween != null) {
							blammedLightsBlackTween.cancel();
						}
						blammedLightsBlackTween = FlxTween.tween(blammedLightsBlack, {alpha: 1}, 1, {ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween) {
								blammedLightsBlackTween = null;
							}
						});

						for (char in chars) {
							if(char.colorTween != null) {
								char.colorTween.cancel();
							}
							char.colorTween = FlxTween.color(char, 1, FlxColor.WHITE, color, {onComplete: function(twn:FlxTween) {
								char.colorTween = null;
							}, ease: FlxEase.quadInOut});
						}
					} else {
						if(blammedLightsBlackTween != null) {
							blammedLightsBlackTween.cancel();
						}
						blammedLightsBlackTween = null;
						blammedLightsBlack.alpha = 1;

						for (char in chars) {
							if(char.colorTween != null) {
								char.colorTween.cancel();
							}
							char.colorTween = null;
						}
						dad.color = color;
						boyfriend.color = color;
						if (gf != null)
							gf.color = color;
					}
					
					if(curStage == 'philly') {
						if(phillyCityLightsEvent != null) {
							phillyCityLightsEvent.forEach(function(spr:BGSprite) {
								spr.visible = false;
							});
							phillyCityLightsEvent.members[lightId - 1].visible = true;
							phillyCityLightsEvent.members[lightId - 1].alpha = 1;
						}
					}
				} else {
					if(blammedLightsBlack.alpha != 0) {
						if(blammedLightsBlackTween != null) {
							blammedLightsBlackTween.cancel();
						}
						blammedLightsBlackTween = FlxTween.tween(blammedLightsBlack, {alpha: 0}, 1, {ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween) {
								blammedLightsBlackTween = null;
							}
						});
					}

					if(curStage == 'philly') {
						phillyCityLights.forEach(function(spr:BGSprite) {
							spr.visible = false;
						});
						phillyCityLightsEvent.forEach(function(spr:BGSprite) {
							spr.visible = false;
						});

						var memb:FlxSprite = phillyCityLightsEvent.members[curLightEvent - 1];
						if(memb != null) {
							memb.visible = true;
							memb.alpha = 1;
							if(phillyCityLightsEventTween != null)
								phillyCityLightsEventTween.cancel();

							phillyCityLightsEventTween = FlxTween.tween(memb, {alpha: 0}, 1, {onComplete: function(twn:FlxTween) {
								phillyCityLightsEventTween = null;
							}, ease: FlxEase.quadInOut});
						}
					}

					for (char in chars) {
						if(char.colorTween != null) {
							char.colorTween.cancel();
						}
						char.colorTween = FlxTween.color(char, 1, char.color, FlxColor.WHITE, {onComplete: function(twn:FlxTween) {
							char.colorTween = null;
						}, ease: FlxEase.quadInOut});
					}

					curLight = 0;
					curLightEvent = 0;
				}

			case 'Kill Henchmen':
				killHenchmen();

			case 'Add Camera Zoom':
				if(ClientPrefs.camZooms && FlxG.camera.zoom < 1.35) {
					var camZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);
					if(Math.isNaN(camZoom)) camZoom = 0.015;
					if(Math.isNaN(hudZoom)) hudZoom = 0.03;

					FlxG.camera.zoom += camZoom;
					camHUD.zoom += hudZoom;
				}

			case 'Trigger BG Ghouls':
				if(curStage == 'schoolEvil' && !ClientPrefs.lowQuality) {
					bgGhouls.dance(true);
					bgGhouls.visible = true;
				}

			case 'Play Animation':
				//trace('Anim to play: ' + value1);
				var char:Character = dad;
				switch(value2.toLowerCase().trim()) {
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						var val2:Int = Std.parseInt(value2);
						if(Math.isNaN(val2)) val2 = 0;
		
						switch(val2) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.playAnim(value1, true);
					char.specialAnim = true;
				}

			case 'Camera Follow Pos':
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 0;
				if(Math.isNaN(val2)) val2 = 0;

				isCameraOnForcedPos = false;
				if(!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2))) {
					camFollow.x = val1;
					camFollow.y = val2;
					isCameraOnForcedPos = true;
				}

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch(value1.toLowerCase()) {
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);
						if(Math.isNaN(val)) val = 0;

						switch(val) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.idleSuffix = value2;
					char.recalculateDanceIdle();
				}

			case 'Screen Shake':
				var valuesArray:Array<String> = [value1, value2];
				var targetsArray:Array<FlxCamera> = [camGame, camHUD];
				for (i in 0...targetsArray.length) {
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = 0;
					var intensity:Float = 0;
					if(split[0] != null) duration = Std.parseFloat(split[0].trim());
					if(split[1] != null) intensity = Std.parseFloat(split[1].trim());
					if(Math.isNaN(duration)) duration = 0;
					if(Math.isNaN(intensity)) intensity = 0;

					if(duration > 0 && intensity != 0) {
						targetsArray[i].shake(intensity, duration);
					}
				}


			case 'Change Character':
				var charType:Int = 0;
				switch(value1) {
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				switch(charType) {
					case 0:
						if(boyfriend.curCharacter != value2) {
							if(!boyfriendMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = boyfriend.alpha;
							boyfriend.alpha = 0.00001;
							boyfriend = boyfriendMap.get(value2);
							boyfriend.alpha = lastAlpha;
							iconP1.changeIcon(boyfriend.healthIcon);
						}
						setOnLuas('boyfriendName', boyfriend.curCharacter);

					case 1:
						if(dad.curCharacter != value2) {
							if(!dadMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf');
							var lastAlpha:Float = dad.alpha;
							dad.alpha = 0.00001;
							dad = dadMap.get(value2);
							if(!dad.curCharacter.startsWith('gf')) {
								if(wasGf && gf != null) {
									gf.visible = true;
								}
							} else if(gf != null) {
								gf.visible = false;
							}
							dad.alpha = lastAlpha;
							iconP2.changeIcon(dad.healthIcon);
						}
						setOnLuas('dadName', dad.curCharacter);

					case 2:
						if(gf != null)
						{
							if(gf.curCharacter != value2)
							{
								if(!gfMap.exists(value2))
								{
									addCharacterToList(value2, charType);
								}

								var lastAlpha:Float = gf.alpha;
								gf.alpha = 0.00001;
								gf = gfMap.get(value2);
								gf.alpha = lastAlpha;
							}
							setOnLuas('gfName', gf.curCharacter);
						}
				}
				reloadHealthBarColors();
			
			case 'BG Freaks Expression':
				if(bgGirls != null) bgGirls.swapDanceType();
			
			case 'Partial Lights OUT On':
				PartialLightsOUTOn();
				
			case 'Partial Lights OUT Off':
				PartialLightsOUTOff();
				
			case 'Lights OUT On':
				LightsOUTOn();
				
			case 'Lights OUT Off':
				LightsOUTOff();
				
			case 'Unown':
				startUnown(Std.parseInt(value1), value2);
				
			case 'Celebi':
				doCelebi(Std.parseFloat(value1));

			case 'Center Camera':
				cameraCentered = !cameraCentered;
			
			case 'Jumpscare':
				jumpscare(Std.parseFloat(value1), Std.parseFloat(value2));
				
			case 'For Cleaning Song':	
				var Alpha:Float = Std.parseFloat(value1);
				var Time:Float = Std.parseFloat(value2);
				FlxTween.tween(coolthingiguess, {alpha: Alpha}, Time, {type: FlxTweenType.ONESHOT, ease: FlxEase.quadInOut});
				
			case 'HP, Time and Info':	
				var Alpha:Float = Std.parseFloat(value1);
				var Time:Float = Std.parseFloat(value2);
				FlxTween.tween(healthBar, {alpha: Alpha}, Time, {type: FlxTweenType.ONESHOT, ease: FlxEase.quadInOut});
				FlxTween.tween(healthBarBG, {alpha: Alpha}, Time, {type: FlxTweenType.ONESHOT, ease: FlxEase.quadInOut});
				FlxTween.tween(iconP1, {alpha: Alpha}, Time, {type: FlxTweenType.ONESHOT, ease: FlxEase.quadInOut});
				FlxTween.tween(iconP2, {alpha: Alpha}, Time, {type: FlxTweenType.ONESHOT, ease: FlxEase.quadInOut});
				FlxTween.tween(scoreTxt, {alpha: Alpha}, Time, {type: FlxTweenType.ONESHOT, ease: FlxEase.quadInOut});
				FlxTween.tween(timeBar, {alpha: Alpha}, Time, {type: FlxTweenType.ONESHOT, ease: FlxEase.quadInOut});
				FlxTween.tween(timeBarBG, {alpha: Alpha}, Time, {type: FlxTweenType.ONESHOT, ease: FlxEase.quadInOut});
				FlxTween.tween(timeTxt, {alpha: Alpha}, Time, {type: FlxTweenType.ONESHOT, ease: FlxEase.quadInOut});
				
			case 'Notes Alpha':	
				var Alpha:Float = Std.parseFloat(value1);
				var Time:Float = Std.parseFloat(value2);
				strumLineNotes.forEach(function(spr:StrumNote)
				{
					FlxTween.tween(spr, {alpha: Alpha}, Time, {type: FlxTweenType.ONESHOT, ease: FlxEase.quadInOut});
				}); 
				
			case 'Blackout Fire On':	
				var Time:Float = Std.parseFloat(value1);
				FlxTween.tween(coolfire, {alpha: 1}, Time, {type: FlxTweenType.ONESHOT, ease: FlxEase.quadInOut});
				FlxTween.tween(blackthing, {alpha: 0}, Time, {type: FlxTweenType.ONESHOT, ease: FlxEase.quadInOut});
				FlxTween.tween(grd, {alpha: 0}, Time, {type: FlxTweenType.ONESHOT, ease: FlxEase.quadInOut});
				FlxTween.tween(firelight, {alpha: 0.25}, Time, {type: FlxTweenType.ONESHOT, ease: FlxEase.quadInOut});
				
			case 'Blackout Fire Off':	
				var Time:Float = Std.parseFloat(value1);
				FlxTween.tween(coolfire, {alpha: 0}, Time, {type: FlxTweenType.ONESHOT, ease: FlxEase.quadInOut});
				FlxTween.tween(blackthing, {alpha: 0.5}, Time, {type: FlxTweenType.ONESHOT, ease: FlxEase.quadInOut});
				FlxTween.tween(grd, {alpha: 1}, Time, {type: FlxTweenType.ONESHOT, ease: FlxEase.quadInOut});
				FlxTween.tween(firelight, {alpha: 0}, Time, {type: FlxTweenType.ONESHOT, ease: FlxEase.quadInOut});
			
			case 'Blackout Fire Appears':	
				var Alpha:Float = Std.parseFloat(value1);
				var Time:Float = Std.parseFloat(value2);
				FlxTween.tween(fireappears, {alpha: Alpha}, Time, {type: FlxTweenType.ONESHOT, ease: FlxEase.quadInOut});

			case 'Change Scroll Speed':
				if (songSpeedType == "constant")
					return;
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 1;
				if(Math.isNaN(val2)) val2 = 0;

				var newValue:Float = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1) * val1;

				if(val2 <= 0)
				{
					songSpeed = newValue;
				}
				else
				{
					songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, val2, {ease: FlxEase.linear, onComplete:
						function (twn:FlxTween)
						{
							songSpeedTween = null;
						}
					});
				}
		}
		callOnLuas('onEvent', [eventName, value1, value2]);
	}

	var jumpscareSizeInterval:Float = 1.625;

	function jumpscare(chance:Float, duration:Float) {
		var outOfTen:Float = Std.random(10);
		if (outOfTen <= ((!Math.isNaN(chance)) ? chance : 4)) {
			jumpScare.visible = true;
			camHUD.shake(0.0125 * (jumpscareSizeInterval / 2), (((!Math.isNaN(duration)) ? duration : 1) * Conductor.stepCrochet) / 1000, 
				function(){
					jumpScare.visible = false;
					jumpscareSizeInterval += 0.125;
					jumpScare.setGraphicSize(Std.int(FlxG.width * jumpscareSizeInterval), Std.int(FlxG.height * jumpscareSizeInterval));
					jumpScare.updateHitbox();
					jumpScare.screenCenter();
				}, true
			);
		}
	}

	function doCelebi(newMax:Float):Void {
			maxHealth = newMax;
			remove(healthBar);
			healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8) - Std.int(healthBar.width * (maxHealth / 2)) , Std.int(healthBarBG.height - 8), this,
				'health', maxHealth, 2);
			healthBar.scrollFactor.set();
			healthBar.visible = !ClientPrefs.hideHud;
			remove(iconP1);
			remove(iconP2);
			add(healthBar);
			add(iconP1);
			add(iconP2);
			healthBar.cameras = [camHUD];
			reloadHealthBarColors();
	
			var celebi:FlxSprite = new FlxSprite(0 + FlxG.random.int(-150, -300), 0 + FlxG.random.int(-200, 200));
			celebi.frames = Paths.getSparrowAtlas('sus/sussy');
			celebi.animation.addByPrefix('sus', 'Sussy', 24, false);
			celebi.animation.play('sus');
			celebi.animation.finishCallback = function (name:String) {
				celebiLayer.remove(celebi);
				celebi.animation.finishCallback = null;
			};
			celebiLayer.add(celebi);
		}

	function moveCameraSection(?id:Int = 0):Void {
		if(SONG.notes[id] == null) return;

		if (gf != null && SONG.notes[id].gfSection)
		{
			camFollow.set(gf.getMidpoint().x, gf.getMidpoint().y);
			camFollow.x += gf.cameraPosition[0] + girlfriendCameraOffset[0];
			camFollow.y += gf.cameraPosition[1] + girlfriendCameraOffset[1];
			tweenCamIn();
			callOnLuas('onMoveCamera', ['gf']);
			return;
		}

		if (!SONG.notes[id].mustHitSection)
		{
			moveCamera(true);
			callOnLuas('onMoveCamera', ['dad']);
		}
		else
		{
			moveCamera(false);
			callOnLuas('onMoveCamera', ['boyfriend']);
		}
	}

	var cameraTwn:FlxTween;
	var resizeCamera:Float = 0;
	public function moveCamera(isDad:Bool)
	{
		if (cameraCentered) {
			resizeCamera = -0.3;
			camFollow.x = (((dad.getMidpoint().x + 150 + dad.cameraPosition[0]) + (boyfriend.getMidpoint().x - 100 + boyfriend.cameraPosition[0])) / 2);
		} else {
			resizeCamera = 0;
			if(isDad)
			{
				camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
				camFollow.x += dad.cameraPosition[0] + opponentCameraOffset[0];
				camFollow.y += dad.cameraPosition[1] + opponentCameraOffset[1];
				tweenCamIn();
			}
			else
			{
				camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
				camFollow.x -= boyfriend.cameraPosition[0] - boyfriendCameraOffset[0];
				camFollow.y += boyfriend.cameraPosition[1] + boyfriendCameraOffset[1];
			}
		}
	}

	function tweenCamIn() {
		if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1.3) {
			cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
				function (twn:FlxTween) {
					cameraTwn = null;
				}
			});
		}
	}

	function snapCamFollowToPos(x:Float, y:Float) {
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	//Any way to do this without using a different function? kinda dumb
	private function onSongComplete()
	{
		finishSong(false);
	}
	public function finishSong(?ignoreNoteOffset:Bool = false):Void
	{
		var finishCallback:Void->Void = endSong; //In case you want to change it in a specific song.

		updateTime = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		vocals.pause();
		if(ClientPrefs.noteOffset <= 0 || ignoreNoteOffset) {
			finishCallback();
		} else {
			finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer) {
				finishCallback();
			});
		}
	}

	public var transitioning = false;
	public function endSong():Void
	{
		//Should kill you if you tried to cheat
		if(!startingSong) {
			notes.forEach(function(daNote:Note) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			});
			for (daNote in unspawnNotes) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			}

			if(doDeathCheck()) {
				return;
			}
		}
		
		if(Paths.formatToSongPath(SONG.song) == 'sussus-moogus' && !usedPractice && isStoryMode) {
			ClientPrefs.SussusMoogusSongComplete = true;
			ClientPrefs.saveSettings();
		}
		if(Paths.formatToSongPath(SONG.song) == 'sabotage' && !usedPractice && isStoryMode) {
			ClientPrefs.SabotageSongComplete = true;
			ClientPrefs.saveSettings();
		}
		if(Paths.formatToSongPath(SONG.song) == 'meltdown' && !usedPractice && isStoryMode) {
			ClientPrefs.MeltdownSongComplete = true;
			ClientPrefs.saveSettings();
		}
		
		if(Paths.formatToSongPath(SONG.song) == 'sussus-toogus' && !usedPractice && isStoryMode) {
			ClientPrefs.SussusToogusSongComplete = true;
			ClientPrefs.saveSettings();
		}
		if(Paths.formatToSongPath(SONG.song) == 'lights-down' && !usedPractice && isStoryMode) {
			ClientPrefs.LightsDownSongComplete = true;
			ClientPrefs.saveSettings();
		}
		if(Paths.formatToSongPath(SONG.song) == 'reactor' && !usedPractice && isStoryMode) {
			ClientPrefs.ReactorSongComplete = true;
			ClientPrefs.saveSettings();
		}
		if(Paths.formatToSongPath(SONG.song) == 'ejected' && !usedPractice && isStoryMode) {
			ClientPrefs.EjectedSongComplete = true;
			ClientPrefs.saveSettings();
		}
		
		if(Paths.formatToSongPath(SONG.song) == 'sussy-bussy' && !usedPractice && isStoryMode) {
			ClientPrefs.SussyBussySongComplete = true;
			ClientPrefs.saveSettings();
		}
		if(Paths.formatToSongPath(SONG.song) == 'rivals' && !usedPractice && isStoryMode) {
			ClientPrefs.RivalsSongComplete = true;
			ClientPrefs.saveSettings();
		}
		if(Paths.formatToSongPath(SONG.song) == 'chewmate' && !usedPractice && isStoryMode) {
			ClientPrefs.ChewmateSongComplete = true;
			ClientPrefs.saveSettings();
		}
		
		if(Paths.formatToSongPath(SONG.song) == 'defeat' && !usedPractice && isStoryMode) {
			ClientPrefs.DefeatSongComplete = true;
			ClientPrefs.saveSettings();
		}

		if(Paths.formatToSongPath(SONG.song) == 'mando' && !usedPractice && isStoryMode) {
			ClientPrefs.MandoSongComplete = true;
			ClientPrefs.saveSettings();
		}
		if(Paths.formatToSongPath(SONG.song) == dlow && !usedPractice && isStoryMode) {
			ClientPrefs.DLowSongComplete = true;
			ClientPrefs.saveSettings();
		}
		if(Paths.formatToSongPath(SONG.song) == 'oversight' && !usedPractice && isStoryMode) {
			ClientPrefs.OversightSongComplete = true;
			ClientPrefs.saveSettings();
		}
		if(Paths.formatToSongPath(SONG.song) == 'influence' && !usedPractice && isStoryMode) {
			ClientPrefs.InfluenceSongComplete = true;
			ClientPrefs.saveSettings();
		}
		if(Paths.formatToSongPath(SONG.song) == 'danger' && !usedPractice && isStoryMode) {
			ClientPrefs.DangerSongComplete = true;
			ClientPrefs.saveSettings();
		}
		if(Paths.formatToSongPath(SONG.song) == 'double-kill' && !usedPractice && isStoryMode) {
			ClientPrefs.DoubleKillSongComplete = true;
			ClientPrefs.saveSettings();
		}
		if(Paths.formatToSongPath(SONG.song) == 'death-blow' && !usedPractice && isStoryMode) {
			ClientPrefs.DeathBlowSongComplete = true;
			ClientPrefs.saveSettings();
		}

		if(Paths.formatToSongPath(SONG.song) == 'insane' && !usedPractice && isStoryMode) {
			ClientPrefs.InsaneSongComplete = true;
			ClientPrefs.saveSettings();
		}
		if(Paths.formatToSongPath(SONG.song) == 'blackout' && !usedPractice && isStoryMode) {
			ClientPrefs.BlackoutSongComplete = true;
			ClientPrefs.saveSettings();
		}
		if(Paths.formatToSongPath(SONG.song) == 'nyctophobia' && !usedPractice && isStoryMode) {
			ClientPrefs.NyctophobiaSongComplete = true;
			ClientPrefs.saveSettings();
		}
		if(Paths.formatToSongPath(SONG.song) == 'massacre' && !usedPractice && isStoryMode) {
			ClientPrefs.MassacreSongComplete = true;
			ClientPrefs.saveSettings();
		}

		if(Paths.formatToSongPath(SONG.song) == 'boiling-point' && !usedPractice && isStoryMode) {
			ClientPrefs.BoilingPointSongComplete = true;
			ClientPrefs.saveSettings();
		}

		if(Paths.formatToSongPath(SONG.song) == 'heartbroken' && !usedPractice && isStoryMode) {
			ClientPrefs.HeartbrokenSongComplete = true;
			ClientPrefs.saveSettings();
		}

		if(Paths.formatToSongPath(SONG.song) == 'christmas' && !usedPractice) {
			ClientPrefs.ChristmasSongComplete = true;
			ClientPrefs.saveSettings();
		}
		if(Paths.formatToSongPath(SONG.song) == 'spookpostor' && !usedPractice) {
			ClientPrefs.SpookpostorSongComplete = true;
			ClientPrefs.saveSettings();
		}
		
		if(Paths.formatToSongPath(SONG.song) == 'titular' && !usedPractice) {
			ClientPrefs.TitularSongComplete = true;
			ClientPrefs.saveSettings();
		}
		if(Paths.formatToSongPath(SONG.song) == 'mission' && !usedPractice) {
			ClientPrefs.MissionSongComplete = true;
			ClientPrefs.saveSettings();
		}
		
		if(Paths.formatToSongPath(SONG.song) == 'double-trouble' && !usedPractice) {
			ClientPrefs.DoubleTroubleSongComplete = true;
			ClientPrefs.saveSettings();
		}
		if(Paths.formatToSongPath(SONG.song) == 'double-ejection' && !usedPractice) {
			ClientPrefs.DoubleEjectionSongComplete = true;
			ClientPrefs.saveSettings();
		}
		if(Paths.formatToSongPath(SONG.song) == 'boing!' && !usedPractice) {
			ClientPrefs.BoingSongComplete = true;
			ClientPrefs.saveSettings();
		}

		if(Paths.formatToSongPath(SONG.song) == 'drip' && !usedPractice) {
			ClientPrefs.DripSongComplete = true;
			ClientPrefs.saveSettings();
		}

		if(Paths.formatToSongPath(SONG.song) == 'skinny-nuts' && !usedPractice) {
			ClientPrefs.SkinnyNutsSongComplete = true;
			ClientPrefs.saveSettings();
		}

		if(Paths.formatToSongPath(SONG.song) == 'jorsawsee' && !usedPractice) {
			ClientPrefs.JorsawseeSongComplete = true;
			ClientPrefs.saveSettings();
		}

		if(Paths.formatToSongPath(SONG.song) == 'triple-trouble' && !usedPractice) {
			ClientPrefs.TripleTroubleSongComplete = true;
			ClientPrefs.saveSettings();
		}

		if(Paths.formatToSongPath(SONG.song) == 'monosus' && !usedPractice) {
			ClientPrefs.MonosusSongComplete = true;
			ClientPrefs.saveSettings();
		}

		if(Paths.formatToSongPath(SONG.song) == 'infinikill' && !usedPractice) {
			ClientPrefs.InfinikillSongComplete = true;
			ClientPrefs.saveSettings();
		}

		if(Paths.formatToSongPath(SONG.song) == 'cleaning' && !usedPractice) {
			ClientPrefs.CleaningSongComplete = true;
			ClientPrefs.saveSettings();
		}

		if(Paths.formatToSongPath(SONG.song) == devils && !usedPractice) {
			ClientPrefs.DevilsGambitSongComplete = true;
			ClientPrefs.saveSettings();
		}
		if(Paths.formatToSongPath(SONG.song) == 'bad-time' && !usedPractice) {
			ClientPrefs.BadTimeSongComplete = true;
			ClientPrefs.saveSettings();
		}
		if(Paths.formatToSongPath(SONG.song) == 'despair' && !usedPractice) {
			ClientPrefs.DespairSongComplete = true;
			ClientPrefs.saveSettings();
		}
		
		timeBarBG.visible = false;
		timeBar.visible = false;
		timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		updateTime = false;

		deathCounter = 0;
		seenCutscene = false;

		#if ACHIEVEMENTS_ALLOWED
		if(achievementObj != null) {
			return;
		} else {
			var achieve:String = checkForAchievement();

			if(achieve != null) {
				startAchievement(achieve);
				return;
			}
		}
		#end

		
		#if LUA_ALLOWED
		var ret:Dynamic = callOnLuas('onEndSong', []);
		#else
		var ret:Dynamic = FunkinLua.Function_Continue;
		#end

		if(ret != FunkinLua.Function_Stop && !transitioning) {
			if (SONG.validScore)
			{
				#if !switch
				var percent:Float = ratingPercent;
				if(Math.isNaN(percent)) percent = 0;
				Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent);
				#end
			}

			if (chartingMode)
			{
				openChartEditor();
				return;
			}

			if (isStoryMode)
			{
				campaignScore += songScore;
				campaignMisses += songMisses;

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					FlxG.sound.playMusic(Paths.music('freakyMenu'));

					cancelMusicFadeTween();
					if(FlxTransitionableState.skipNextTransIn) {
						CustomFadeTransition.nextCamera = null;
					}
					MusicBeatState.switchState(new StoryMenuState());

					// if ()
					if(!ClientPrefs.getGameplaySetting('practice', false) && !ClientPrefs.getGameplaySetting('botplay', false)) {
						StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);

						if (SONG.validScore)
						{
							Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);
						}

						FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
						FlxG.save.flush();
					}
					changedDifficulty = false;
				}
				else
				{
					var difficulty:String = CoolUtil.getDifficultyFilePath();

					trace('LOADING NEXT SONG');
					trace(Paths.formatToSongPath(PlayState.storyPlaylist[0]) + difficulty);

					var winterHorrorlandNext = (Paths.formatToSongPath(SONG.song) == "eggnog");
					if (winterHorrorlandNext)
					{
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;

						FlxG.sound.play(Paths.sound('Lights_Shut_off'));
					}

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;

					prevCamFollow = camFollow;
					prevCamFollowPos = camFollowPos;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					if(winterHorrorlandNext) {
						new FlxTimer().start(1.5, function(tmr:FlxTimer) {
							cancelMusicFadeTween();
							LoadingState.loadAndSwitchState(new PlayState());
						});
					} else {
						cancelMusicFadeTween();
						LoadingState.loadAndSwitchState(new PlayState());
					}
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');
				cancelMusicFadeTween();
				if(FlxTransitionableState.skipNextTransIn) {
					CustomFadeTransition.nextCamera = null;
				}
				MusicBeatState.switchState(new FreeplayState());
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				changedDifficulty = false;
			}
			transitioning = true;
		}
	}

	#if ACHIEVEMENTS_ALLOWED
	var achievementObj:AchievementObject = null;
	function startAchievement(achieve:String) {
		achievementObj = new AchievementObject(achieve, camOther);
		achievementObj.onFinish = achievementEnd;
		add(achievementObj);
		trace('Giving achievement ' + achieve);
	}
	function achievementEnd():Void
	{
		achievementObj = null;
		if(endingSong && !inCutscene) {
			endSong();
		}
	}
	#end

	public function KillNotes() {
		while(notes.length > 0) {
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	public var totalPlayed:Int = 0;
	public var totalNotesHit:Float = 0.0;

	public var showCombo:Bool = true;
	public var showRating:Bool = true;

	private function popUpScore(note:Note = null):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + ClientPrefs.ratingOffset);
		//trace(noteDiff, ' ' + Math.abs(note.strumTime - Conductor.songPosition));

		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.35;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		//tryna do MS based judgment due to popular demand
		var daRating:String = Conductor.judgeNote(note, noteDiff);

		switch (daRating)
		{
			case "shit": // shit
				totalNotesHit += 0;
				note.ratingMod = 0;
				score = 50;
				if(!note.ratingDisabled) shits++;
			case "bad": // bad
				totalNotesHit += 0.5;
				note.ratingMod = 0.5;
				score = 100;
				if(!note.ratingDisabled) bads++;
			case "good": // good
				totalNotesHit += 0.75;
				note.ratingMod = 0.75;
				score = 200;
				if(!note.ratingDisabled) goods++;
			case "sick": // sick
				totalNotesHit += 1;
				note.ratingMod = 1;
				if(!note.ratingDisabled) sicks++;
		}
		note.rating = daRating;

		if(daRating == 'sick' && !note.noteSplashDisabled)
		{
			spawnNoteSplashOnNote(note);
		}

		if(!practiceMode && !cpuControlled) {
			songScore += score;
			if(!note.ratingDisabled)
			{
				songHits++;
				totalPlayed++;
				RecalculateRating();
			}

			if(ClientPrefs.scoreZoom)
			{
				if(scoreTxtTween != null) {
					scoreTxtTween.cancel();
				}
				scoreTxt.scale.x = 1.075;
				scoreTxt.scale.y = 1.075;
				scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
					onComplete: function(twn:FlxTween) {
						scoreTxtTween = null;
					}
				});
			}
		}

		/* if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
		 */

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (PlayState.isPixelStage)
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
		rating.cameras = [camHUD];
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);
		rating.visible = (!ClientPrefs.hideHud && showRating);
		rating.x += ClientPrefs.comboOffset[0];
		rating.y -= ClientPrefs.comboOffset[1];

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.cameras = [camHUD];
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;
		comboSpr.visible = (!ClientPrefs.hideHud && showCombo);
		comboSpr.x += ClientPrefs.comboOffset[0];
		comboSpr.y -= ClientPrefs.comboOffset[1];


		comboSpr.velocity.x += FlxG.random.int(1, 10);
		insert(members.indexOf(strumLineNotes), rating);

		if (!PlayState.isPixelStage)
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = ClientPrefs.globalAntialiasing;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = ClientPrefs.globalAntialiasing;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.85));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.85));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		if(combo >= 1000) {
			seperatedScore.push(Math.floor(combo / 1000) % 10);
		}
		seperatedScore.push(Math.floor(combo / 100) % 10);
		seperatedScore.push(Math.floor(combo / 10) % 10);
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.cameras = [camHUD];
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			numScore.x += ClientPrefs.comboOffset[2];
			numScore.y -= ClientPrefs.comboOffset[3];

			if (!PlayState.isPixelStage)
			{
				numScore.antialiasing = ClientPrefs.globalAntialiasing;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);
			numScore.visible = !ClientPrefs.hideHud;

			//if (combo >= 10 || combo == 0)
				insert(members.indexOf(strumLineNotes), numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}
		/* 
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});
	}

	private function onKeyPress(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		//trace('Pressed: ' + eventKey);

		if (!cpuControlled && !paused && key > -1 && (FlxG.keys.checkStatus(eventKey, JUST_PRESSED) || ClientPrefs.controllerMode))
		{
			if(!boyfriend.stunned && generatedMusic && !endingSong)
			{
				//more accurate hit time for the ratings?
				var lastTime:Float = Conductor.songPosition;
				Conductor.songPosition = FlxG.sound.music.time;

				var canMiss:Bool = !ClientPrefs.ghostTapping;

				// heavily based on my own code LOL if it aint broke dont fix it
				var pressNotes:Array<Note> = [];
				//var notesDatas:Array<Int> = [];
				var notesStopped:Bool = false;

				var sortedNotesList:Array<Note> = [];
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote)
					{
						if(daNote.noteData == key)
						{
							sortedNotesList.push(daNote);
							//notesDatas.push(daNote.noteData);
						}
						canMiss = true;
					}
				});
				sortedNotesList.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

				if (sortedNotesList.length > 0) {
					for (epicNote in sortedNotesList)
					{
						for (doubleNote in pressNotes) {
							if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 1) {
								doubleNote.kill();
								notes.remove(doubleNote, true);
								doubleNote.destroy();
							} else
								notesStopped = true;
						}
							
						// eee jack detection before was not super good
						if (!notesStopped) {
							goodNoteHit(epicNote);
							pressNotes.push(epicNote);
						}

					}
				}
				else if (canMiss) {
					noteMissPress(key);
					callOnLuas('noteMissPress', [key]);
				}

				// I dunno what you need this for but here you go
				//									- Shubs

				// Shubs, this is for the "Just the Two of Us" achievement lol
				//									- Shadow Mario
				keysPressed[key] = true;

				//more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
				Conductor.songPosition = lastTime;
			}

			var spr:StrumNote = playerStrums.members[key];
			if(spr != null && spr.animation.curAnim.name != 'confirm')
			{
				spr.playAnim('pressed');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyPress', [key]);
		}
		//trace('pressed: ' + controlArray);
	}
	
	private function onKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		if(!cpuControlled && !paused && key > -1)
		{
			var spr:StrumNote = playerStrums.members[key];
			if(spr != null)
			{
				spr.playAnim('static');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyRelease', [key]);
		}
		//trace('released: ' + controlArray);
	}

	private function getKeyFromEvent(key:FlxKey):Int
	{
		if(key != NONE)
		{
			for (i in 0...keysArray.length)
			{
				for (j in 0...keysArray[i].length)
				{
					if(key == keysArray[i][j])
					{
						return i;
					}
				}
			}
		}
		return -1;
	}

	// Hold notes
	private function keyShit():Void
	{
		// HOLDING
		var up = controls.NOTE_UP;
		var right = controls.NOTE_RIGHT;
		var down = controls.NOTE_DOWN;
		var left = controls.NOTE_LEFT;
		var controlHoldArray:Array<Bool> = [left, down, up, right];
		
		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode)
		{
			var controlArray:Array<Bool> = [controls.NOTE_LEFT_P, controls.NOTE_DOWN_P, controls.NOTE_UP_P, controls.NOTE_RIGHT_P];
			if(controlArray.contains(true))
			{
				for (i in 0...controlArray.length)
				{
					if(controlArray[i])
						onKeyPress(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, -1, keysArray[i][0]));
				}
			}
		}

		// FlxG.watch.addQuick('asdfa', upP);
		if (!boyfriend.stunned && generatedMusic)
		{
			// rewritten inputs???
			notes.forEachAlive(function(daNote:Note)
			{
				// hold note functions
				if (daNote.isSustainNote && controlHoldArray[daNote.noteData] && daNote.canBeHit 
				&& daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit) {
					goodNoteHit(daNote);
				}
			});

			if (controlHoldArray.contains(true) && !endingSong) {
				#if ACHIEVEMENTS_ALLOWED
				var achieve:String = checkForAchievement(['oversinging']);
				if (achieve != null) {
					startAchievement(achieve);
				}
				#end
			}
			else if (boyfriend.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.dance();
				//boyfriend.animation.curAnim.finish();
			}
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode)
		{
			var controlArray:Array<Bool> = [controls.NOTE_LEFT_R, controls.NOTE_DOWN_R, controls.NOTE_UP_R, controls.NOTE_RIGHT_R];
			if(controlArray.contains(true))
			{
				for (i in 0...controlArray.length)
				{
					if(controlArray[i])
						onKeyRelease(new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, -1, keysArray[i][0]));
				}
			}
		}
	}

	function noteMiss(daNote:Note):Void { //You didn't hit the key and let it go offscreen, also used by Hurt Notes
		//Dupe note remove
		notes.forEachAlive(function(note:Note) {
			if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 1) {
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});
		combo = 0;

		health -= daNote.missHealth * healthLoss;
		if(instakillOnMiss)
		{
			vocals.volume = 0;
			doDeathCheck(true);
		}

		//For testing purposes
		//trace(daNote.missHealth);
		songMisses++;
		vocals.volume = 0;
		if(!practiceMode) songScore -= 10;
		
		totalPlayed++;
		RecalculateRating();

		var char:Character = boyfriend;
		if(daNote.gfNote) {
			char = gf;
		}

		if(char != null && char.hasMissAnimations)
		{
			var daAlt = '';
			if(daNote.noteType == 'Alt Animation') daAlt = '-alt';

			var animToPlay:String = singAnimations[Std.int(Math.abs(daNote.noteData))] + 'miss' + daAlt;
			char.playAnim(animToPlay, true);
		}

		callOnLuas('noteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
	}

	function noteMissPress(direction:Int = 1):Void //You pressed a key when there was no notes to press for this key
	{
		if (!boyfriend.stunned)
		{
			health -= 0.05 * healthLoss;
			if(instakillOnMiss)
			{
				vocals.volume = 0;
				doDeathCheck(true);
			}

			if(ClientPrefs.ghostTapping) return;

			if (combo > 5 && gf != null && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			if(!practiceMode) songScore -= 10;
			if(!endingSong) {
				songMisses++;
			}
			totalPlayed++;
			RecalculateRating();

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			/*boyfriend.stunned = true;

			// get stunned for 1/60 of a second, makes you able to
			new FlxTimer().start(1 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});*/

			if(boyfriend.hasMissAnimations) {
				boyfriend.playAnim(singAnimations[Std.int(Math.abs(direction))] + 'miss', true);
			}
			vocals.volume = 0;
		}
	}

	function opponentNoteHit(note:Note):Void
	{
		if (Paths.formatToSongPath(SONG.song) != 'tutorial')
			camZooming = true;

		if(note.noteType == 'Hey!' && dad.animOffsets.exists('hey')) {
			dad.playAnim('hey', true);
			dad.specialAnim = true;
			dad.heyTimer = 0.6;
		} else if(!note.noAnimation) {
			var altAnim:String = "";

			var curSection:Int = Math.floor(curStep / 16);
			if (SONG.notes[curSection] != null)
			{
				if (SONG.notes[curSection].altAnim || note.noteType == 'Alt Animation') {
					altAnim = '-alt';
				}
			}

			var char:Character = dad;
			var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))] + altAnim;
			if(note.gfNote) {
				char = gf;
			}

			if(char != null)
			{
				char.playAnim(animToPlay, true);
				char.holdTimer = 0;
			}
		}

		if (SONG.needsVoices)
			vocals.volume = 1;

		var time:Float = 0.15;
		if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
			time += 0.15;
		}
		StrumPlayAnim(true, Std.int(Math.abs(note.noteData)) % 4, time);
		note.hitByOpponent = true;

		callOnLuas('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);

		if (!note.isSustainNote)
		{
			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if (ClientPrefs.hitsoundVolume > 0 && !note.hitsoundDisabled)
			{
				FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.hitsoundVolume);
			}

			if(cpuControlled && (note.ignoreNote || note.hitCausesMiss)) return;

			if(note.hitCausesMiss) {
				noteMiss(note);
				if(!note.noteSplashDisabled && !note.isSustainNote) {
					spawnNoteSplashOnNote(note);
				}

				switch(note.noteType) {
					case 'Hurt Note': //Hurt note
						if(boyfriend.animation.getByName('hurt') != null) {
							boyfriend.playAnim('hurt', true);
							boyfriend.specialAnim = true;
						}
				}
				
				note.wasGoodHit = true;
				if (!note.isSustainNote)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
				return;
			}

			if (!note.isSustainNote)
			{
				combo += 1;
				popUpScore(note);
				if(combo > 9999) combo = 9999;
			}
			health += note.hitHealth * healthGain;

			if(!note.noAnimation) {
				var daAlt = '';
				if(note.noteType == 'Alt Animation') daAlt = '-alt';
	
				var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))];

				if(note.gfNote) 
				{
					if(gf != null)
					{
						gf.playAnim(animToPlay + daAlt, true);
						gf.holdTimer = 0;
					}
				}
				else
				{
					boyfriend.playAnim(animToPlay + daAlt, true);
					boyfriend.holdTimer = 0;
				}

				if(note.noteType == 'Hey!') {
					if(boyfriend.animOffsets.exists('hey')) {
						boyfriend.playAnim('hey', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = 0.6;
					}
	
					if(gf != null && gf.animOffsets.exists('cheer')) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = 0.6;
					}
				}
			}

			if(cpuControlled) {
				var time:Float = 0.15;
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
					time += 0.15;
				}
				StrumPlayAnim(false, Std.int(Math.abs(note.noteData)) % 4, time);
			} else {
				playerStrums.forEach(function(spr:StrumNote)
				{
					if (Math.abs(note.noteData) == spr.ID)
					{
						spr.playAnim('confirm', true);
					}
				});
			}
			note.wasGoodHit = true;
			vocals.volume = 1;

			var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
			var leData:Int = Math.round(Math.abs(note.noteData));
			var leType:String = note.noteType;
			callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	function spawnNoteSplashOnNote(note:Note) {
		if(ClientPrefs.noteSplashes && note != null) {
			var strum:StrumNote = playerStrums.members[note.noteData];
			if(strum != null) {
				spawnNoteSplash(strum.x, strum.y, note.noteData, note);
			}
		}
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null) {
		var skin:String = 'noteSplashes';
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;
		
		var hue:Float = ClientPrefs.arrowHSV[data % 4][0] / 360;
		var sat:Float = ClientPrefs.arrowHSV[data % 4][1] / 100;
		var brt:Float = ClientPrefs.arrowHSV[data % 4][2] / 100;
		if(note != null) {
			skin = note.noteSplashTexture;
			hue = note.noteSplashHue;
			sat = note.noteSplashSat;
			brt = note.noteSplashBrt;
		}

		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data, skin, hue, sat, brt);
		grpNoteSplashes.add(splash);
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	var carTimer:FlxTimer;
	function fastCarDrive()
	{
		//trace('Car drive');
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		carTimer = new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
			carTimer = null;
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			if (gf != null)
			{
				gf.playAnim('hairBlow');
				gf.specialAnim = true;
			}
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		if(gf != null)
		{
			gf.danced = false; //Sets head to the correct position once the animation ends
			gf.playAnim('hairFall');
			gf.specialAnim = true;
		}
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		if(!ClientPrefs.lowQuality) halloweenBG.animation.play('halloweem bg lightning strike');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		if(boyfriend.animOffsets.exists('scared')) {
			boyfriend.playAnim('scared', true);
		}

		if(gf != null && gf.animOffsets.exists('scared')) {
			gf.playAnim('scared', true);
		}

		if(ClientPrefs.camZooms) {
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;

			if(!camZooming) { //Just a way for preventing it to be permanently zoomed until Skid & Pump hits a note
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.5);
				FlxTween.tween(camHUD, {zoom: 1}, 0.5);
			}
		}

		if(ClientPrefs.flashing) {
			halloweenWhite.alpha = 0.4;
			FlxTween.tween(halloweenWhite, {alpha: 0.5}, 0.075);
			FlxTween.tween(halloweenWhite, {alpha: 0}, 0.25, {startDelay: 0.15});
		}
	}

	function killHenchmen():Void
	{
		if(!ClientPrefs.lowQuality && ClientPrefs.violence && curStage == 'limo') {
			if(limoKillingState < 1) {
				limoMetalPole.x = -400;
				limoMetalPole.visible = true;
				limoLight.visible = true;
				limoCorpse.visible = false;
				limoCorpseTwo.visible = false;
				limoKillingState = 1;

				#if ACHIEVEMENTS_ALLOWED
				Achievements.henchmenDeath++;
				FlxG.save.data.henchmenDeath = Achievements.henchmenDeath;
				var achieve:String = checkForAchievement(['roadkill_enthusiast']);
				if (achieve != null) {
					startAchievement(achieve);
				} else {
					FlxG.save.flush();
				}
				FlxG.log.add('Deaths: ' + Achievements.henchmenDeath);
				#end
			}
		}
	}

	function resetLimoKill():Void
	{
		if(curStage == 'limo') {
			limoMetalPole.x = -500;
			limoMetalPole.visible = false;
			limoLight.x = -500;
			limoLight.visible = false;
			limoCorpse.x = -500;
			limoCorpse.visible = false;
			limoCorpseTwo.x = -500;
			limoCorpseTwo.visible = false;
		}
	}

	private var preventLuaRemove:Bool = false;
	override function destroy() {
		preventLuaRemove = true;
		for (i in 0...luaArray.length) {
			luaArray[i].call('onDestroy', []);
			luaArray[i].stop();
		}
		luaArray = [];

		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}
		super.destroy();
	}

	public static function cancelMusicFadeTween() {
		if(FlxG.sound.music.fadeTween != null) {
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	public function removeLua(lua:FunkinLua) {
		if(luaArray != null && !preventLuaRemove) {
			luaArray.remove(lua);
		}
	}

	var lastStepHit:Int = -1;
	override function stepHit()
	{
		super.stepHit();
		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > 20
			|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > 20))
		{
			resyncVocals();
		}

		if(curStep == lastStepHit) {
			return;
		}

		lastStepHit = curStep;
		setOnLuas('curStep', curStep);
		callOnLuas('onStepHit', []);
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	var lastBeatHit:Int = -1;
	
	override function beatHit()
	{
		super.beatHit();

		switch (SONG.song.toLowerCase()) {
			case 'monosus':
				switch (curBeat) {
					case 28:
						FlxTween.tween(healthBar, {alpha: 0.4}, 3, {ease: FlxEase.linear});
						FlxTween.tween(healthBarBG, {alpha: 0.4}, 3, {ease: FlxEase.linear});
						FlxTween.tween(scoreTxt, {alpha: 0.4}, 3, {ease: FlxEase.linear});
						FlxTween.tween(iconP1, {alpha: 1}, 3, {ease: FlxEase.linear});
						FlxTween.tween(iconP2, {alpha: 1}, 3, {ease: FlxEase.linear});
				}
		}

		if(lastBeatHit >= curBeat) {
			//trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + lastBeatHit);
			return;
		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				//FlxG.log.add('CHANGED BPM!');
				setOnLuas('curBpm', Conductor.bpm);
				setOnLuas('crochet', Conductor.crochet);
				setOnLuas('stepCrochet', Conductor.stepCrochet);
			}
			setOnLuas('mustHitSection', SONG.notes[Math.floor(curStep / 16)].mustHitSection);
			setOnLuas('altAnim', SONG.notes[Math.floor(curStep / 16)].altAnim);
			setOnLuas('gfSection', SONG.notes[Math.floor(curStep / 16)].gfSection);
			// else
			// Conductor.changeBPM(SONG.bpm);
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null && !endingSong && !isCameraOnForcedPos)
		{
			moveCameraSection(Std.int(curStep / 16));
		}
		if (camZooming && FlxG.camera.zoom < 1.35 && ClientPrefs.camZooms && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015; 
			camHUD.zoom += 0.03;
		}

		if(ClientPrefs.camZooms) {
			if (curSong.toLowerCase() == 'reactor' && curBeat >= 128 && curBeat < 191 && camZooming && FlxG.camera.zoom < 1.35)
			{
				FlxG.camera.zoom += 0.025;
				camHUD.zoom += 0.03;
			}

			if (curSong.toLowerCase() == 'reactor' && curBeat >= 319 && curBeat < 383 && camZooming && FlxG.camera.zoom < 1.35)
			{
				FlxG.camera.zoom += 0.025;
				camHUD.zoom += 0.03;
			}
			
			if (curSong.toLowerCase() == 'reactor' && curBeat >= 480 && curBeat < 607 && camZooming && FlxG.camera.zoom < 1.35)
			{
				FlxG.camera.zoom += 0.035;
				camHUD.zoom += 0.03;
			}
		}

		iconP1.scale.set(1.2, 1.2);
		iconP2.scale.set(1.2, 1.2);

		iconP1.updateHitbox();
		iconP2.updateHitbox();
		
		if (gf != null && curBeat % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && !gf.stunned && gf.animation.curAnim.name != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
		{
			gf.dance();
		}
		if (curBeat % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
		{
			boyfriend.dance();
		}
		if (curBeat % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
		{
			dad.dance();
		}

		if (isStoryMode && curBeat == 260 && curSong == 'Rivals')
		{
			boyfriend.playAnim('shoot', true);
		}

		if (isStoryMode && curBeat == 260 && curSong == 'Rivals')
		{
			dad.playAnim('die', true);
			dad.stunned = true;
		}
		
		if (curBeat % 4 == 0 && curSong == 'Reactor')
		{
			orb.scale.set(0.75, 0.75);
			ass2.alpha = 0.9;
			orb.alpha = 1;
		}

		if (curBeat == 128 && curSong == 'Reactor')
		{
			defaultCamZoom = 0.7;
		}

		if (curBeat == 191 && curSong == 'Reactor')
		{
			defaultCamZoom = 0.5;
		}

		if (curBeat == 319 && curSong == 'Reactor')
		{
			defaultCamZoom = 0.7;
		}

		if (curBeat == 383 && curSong == 'Reactor')
		{
			defaultCamZoom = 0.5;
		}

		if (curBeat == 480 && curSong == 'Reactor')
		{
			defaultCamZoom = 0.9;
		}

		if (curBeat == 607 && curSong == 'Reactor')
		{
			defaultCamZoom = 0.7;
		}

		switch (curStage)
		{
			case 'school':
				if(!ClientPrefs.lowQuality) {
					bgGirls.dance();
				}

			case 'mall':
				if(!ClientPrefs.lowQuality) {
					upperBoppers.dance(true);
				}

				if(heyTimer <= 0) bottomBoppers.dance(true);
				santa.dance(true);

			case 'reactor':
				if (!ClientPrefs.Optimization)
				{	
					if(curBeat % 4 == 0) {
						amogus.animation.play('bop', true);
						dripster.animation.play('bop', true);
						yellow.animation.play('bop', true);
						brown.animation.play('bop', true);
					}
				}
				
			case 'polus-maroon':
				if (!ClientPrefs.Optimization)
				{	
					if(curBeat % 2 == 0) {
						sus.animation.play('sus', true);
					}
				}
				
			case 'meltdown':
				if (!ClientPrefs.Optimization)
				{	
					if(curBeat % 4 == 0) {
						crowd.animation.play('CrowdBop', true);
					}
				}

			case 'limo':
				if(!ClientPrefs.lowQuality) {
					grpLimoDancers.forEach(function(dancer:BackgroundDancer)
					{
						dancer.dance();
					});
				}

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					phillyCityLights.forEach(function(light:BGSprite)
					{
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1, [curLight]);

					phillyCityLights.members[curLight].visible = true;
					phillyCityLights.members[curLight].alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		if (curStage == 'spooky' && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
		lastBeatHit = curBeat;

		setOnLuas('curBeat', curBeat); //DAWGG?????
		callOnLuas('onBeatHit', []);
	}

	function PartialLightsOUTOn():Void 
	{
		camGame.flash(FlxColor.BLACK, 1);
		if (!ClientPrefs.Optimization)
		{	
			machineDark.alpha = 1;
			bgDark.alpha = 1;
			stageFront2Dark.alpha = 1;
			stageFront3Dark.alpha = 1;
		}
		miraGradient.alpha = 1;
	}

	function PartialLightsOUTOff():Void 
	{
		camGame.flash(FlxColor.WHITE, 0.35);
		if (!ClientPrefs.Optimization)
		{	
			machineDark.alpha = 0;
			bgDark.alpha = 0;
			stageFront2Dark.alpha = 0;
			stageFront3Dark.alpha = 0;
			}
		miraGradient.alpha = 0;
	}

	function LightsOUTOn():Void 
	{
		camGame.flash(FlxColor.WHITE, 0.35);
		lightsOutSprite.alpha = 1;
		if (!ClientPrefs.Optimization)
		{	
			stageFront2.alpha = 0;
			stageFront3.alpha = 0;
		}
		miraGradient.alpha = 0;
		if (!ClientPrefs.Optimization)
		{	
			stageFront2Dark.alpha = 0;
			stageFront3Dark.alpha = 0;
		}
	}
	
	function LightsOUTOff():Void 
	{
		camGame.flash(FlxColor.BLACK, 0.35);
		lightsOutSprite.alpha = 0;
		if (!ClientPrefs.Optimization)
		{	
			stageFront2.alpha = 1;
			stageFront3.alpha = 1;
		}
		miraGradient.alpha = 1;
		if (!ClientPrefs.Optimization)
		{	
			stageFront2Dark.alpha = 1;
			stageFront2Dark.alpha = 1;
		}
	}

	public var closeLuas:Array<FunkinLua> = [];
	public function callOnLuas(event:String, args:Array<Dynamic>):Dynamic {
		var returnVal:Dynamic = FunkinLua.Function_Continue;
		#if LUA_ALLOWED
		for (i in 0...luaArray.length) {
			var ret:Dynamic = luaArray[i].call(event, args);
			if(ret != FunkinLua.Function_Continue) {
				returnVal = ret;
			}
		}

		for (i in 0...closeLuas.length) {
			luaArray.remove(closeLuas[i]);
			closeLuas[i].stop();
		}
		#end
		return returnVal;
	}

	public function setOnLuas(variable:String, arg:Dynamic) {
		#if LUA_ALLOWED
		for (i in 0...luaArray.length) {
			luaArray[i].set(variable, arg);
		}
		#end
	}

	function StrumPlayAnim(isDad:Bool, id:Int, time:Float) {
		var spr:StrumNote = null;
		if(isDad) {
			spr = strumLineNotes.members[id];
		} else {
			spr = playerStrums.members[id];
		}

		if(spr != null) {
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	public var ratingName:String = '?';
	public var ratingPercent:Float;
	public var ratingFC:String;
	public function RecalculateRating() {
		setOnLuas('score', songScore);
		setOnLuas('misses', songMisses);
		setOnLuas('hits', songHits);

		var ret:Dynamic = callOnLuas('onRecalculateRating', []);
		if(ret != FunkinLua.Function_Stop)
		{
			if(totalPlayed < 1) //Prevent divide by 0
				ratingName = '?';
			else
			{
				// Rating Percent
				ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));
				//trace((totalNotesHit / totalPlayed) + ', Total: ' + totalPlayed + ', notes hit: ' + totalNotesHit);

				// Rating Name
				if(ratingPercent >= 1)
				{
					ratingName = ratingStuff[ratingStuff.length-1][0]; //Uses last string
				}
				else
				{
					for (i in 0...ratingStuff.length-1)
					{
						if(ratingPercent < ratingStuff[i][1])
						{
							ratingName = ratingStuff[i][0];
							break;
						}
					}
				}
			}

			// Rating FC
			ratingFC = "";
			if (sicks > 0) ratingFC = "SFC";
			if (goods > 0) ratingFC = "GFC";
			if (bads > 0 || shits > 0) ratingFC = "FC";
			if (songMisses > 0 && songMisses < 10) ratingFC = "SDCB";
			else if (songMisses >= 10) ratingFC = "Clear";
		}
		setOnLuas('rating', ratingPercent);
		setOnLuas('ratingName', ratingName);
		setOnLuas('ratingFC', ratingFC);
	}

	public static var othersCodeName:String = 'otherAchievements';
	
	#if ACHIEVEMENTS_ALLOWED
	private function checkForAchievement(achievesToCheck:Array<String> = null):String {
	
		if(chartingMode) return null;

		var achievementsToCheck:Array<String> = achievesToCheck;
		if (achievementsToCheck == null) {
			achievementsToCheck = [];
			for (i in 0...Achievements.achievementsStuff.length) {
				achievementsToCheck.push(Achievements.achievementsStuff[i][2]);
			}
			achievementsToCheck.push(othersCodeName);
		}

		for (i in 0...achievementsToCheck.length) {
			var achievementName:String = achievementsToCheck[i];
			var unlock:Bool = false;

			for (json in Achievements.loadedAchievements) { //Requires jsons for call
				var ret:Dynamic = callOnLuas('onCheckForAchievement', [json.icon]); //Set custom goals

				if (ret == FunkinLua.Function_Continue && !Achievements.isAchievementUnlocked(json.icon) && json.customGoal && !unlock) {
					unlock = true;
					achievementName = json.icon;
				}
			}

			if(!Achievements.isAchievementUnlocked(achievementName) && !cpuControlled && !unlock) {
				switch(achievementName)
				{

					case 'polus_week':
						if(ClientPrefs.SussusMoogusSongComplete && ClientPrefs.SabotageSongComplete && ClientPrefs.MeltdownSongComplete) {
							unlock = true;
						}

					case 'mira-hq_week':
						if(ClientPrefs.SussusToogusSongComplete && ClientPrefs.LightsDownSongComplete && ClientPrefs.ReactorSongComplete && ClientPrefs.EjectedSongComplete) {
							unlock = true;
						}
						
					case 'skeld_week':
						if(ClientPrefs.SussyBussySongComplete && ClientPrefs.RivalsSongComplete && ClientPrefs.ChewmateSongComplete) {
							unlock = true;
						}

					case 'defeat_week':
						if(ClientPrefs.DefeatSongComplete) {
							unlock = true;
						}

					case 'airship_week':
						if(ClientPrefs.MandoSongComplete && ClientPrefs.DLowSongComplete && ClientPrefs.OversightSongComplete && ClientPrefs.InfluenceSongComplete && ClientPrefs.DangerSongComplete && ClientPrefs.DoubleKillSongComplete && ClientPrefs.DeathBlowSongComplete) {
							unlock = true;
						}

					case 'tt-gray_week':
						if(ClientPrefs.InsaneSongComplete && ClientPrefs.BlackoutSongComplete && ClientPrefs.NyctophobiaSongComplete && ClientPrefs.MassacreSongComplete) {
							unlock = true;
						}

					case 'tt-maroon_week':
						if(ClientPrefs.BoilingPointSongComplete) {
							unlock = true;
						}

					case 'tt-pink_week':
						if(ClientPrefs.HeartbrokenSongComplete) {
							unlock = true;
						}

					case 'christmas':
						if(ClientPrefs.ChristmasSongComplete && ClientPrefs.SpookpostorSongComplete) {
							unlock = true;
						}
						
					case 'henry':
						if(ClientPrefs.TitularSongComplete && ClientPrefs.MissionSongComplete) {
							unlock = true;
						}
						
					case 'double':
						if(ClientPrefs.DoubleTroubleSongComplete && ClientPrefs.DoubleEjectionSongComplete && ClientPrefs.BoingSongComplete) {
							unlock = true;
						}
						
					case 'drip':
						if(ClientPrefs.DripSongComplete) {
							unlock = true;
						}
						
					case 'nuts':
						if(ClientPrefs.SkinnyNutsSongComplete) {
							unlock = true;
						}
						
					case 'jorsawsee':
						if(ClientPrefs.JorsawseeSongComplete) {
							unlock = true;
						}
						
					case 'tt':
						if(ClientPrefs.TripleTroubleSongComplete) {
							unlock = true;
						}
						
					case 'sus':
						if(ClientPrefs.MonosusSongComplete) {
							unlock = true;
						}
						
					case 'infi':
						if(ClientPrefs.InfinikillSongComplete) {
							unlock = true;
						}
						
					case 'cleaning':
						if(ClientPrefs.CleaningSongComplete) {
							unlock = true;
						}
						
					case 'nightmare':
						if(ClientPrefs.DevilsGambitSongComplete && ClientPrefs.BadTimeSongComplete && ClientPrefs.DespairSongComplete) {
							unlock = true;
						}
				}
			}

			if(unlock) {
				Achievements.unlockAchievement(achievementName);
				return achievementName;
			}
		}
		return null;
	}
	#end

	var curLight:Int = 0;
	var curLightEvent:Int = 0;
}
