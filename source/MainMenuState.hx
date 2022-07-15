package;

import flixel.addons.display.FlxBackdrop;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxTimer;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.5.2'; //This is also used for Discord RPC
	public var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = [
		'story',
		'freeplay',
		'options',
		'awards',
		'discord'
	];

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;

	var starFG:FlxBackdrop;
	var starBG:FlxBackdrop;
	var redImpostor:FlxSprite;
	var greenImpostor:FlxSprite;
	var vignette:FlxSprite;

	override function create()
	{
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		var bg:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.scrollFactor.set();
		add(bg);

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

		redImpostor = new FlxSprite(704.55, 106.65);
		redImpostor.frames = Paths.getSparrowAtlas('menu/impostorMenu');
		redImpostor.animation.addByPrefix('idle', 'red smile', 24, true);
		redImpostor.animation.play('idle');
		redImpostor.antialiasing = true;
		redImpostor.updateHitbox();
		redImpostor.active = true;
		redImpostor.scrollFactor.set();
		add(redImpostor);

		greenImpostor = new FlxSprite(-159.35, 102.35);
		greenImpostor.frames = Paths.getSparrowAtlas('menu/impostorMenu');
		greenImpostor.animation.addByPrefix('idle', 'green smile', 24, true);
		greenImpostor.animation.play('idle');
		greenImpostor.antialiasing = true;
		greenImpostor.updateHitbox();
		greenImpostor.active = true;
		greenImpostor.scrollFactor.set();
		add(greenImpostor);

		vignette = new FlxSprite(0, 0).loadGraphic(Paths.image('menu/vignette'));
		vignette.antialiasing = true;
		vignette.updateHitbox();
		vignette.active = false;
		vignette.scrollFactor.set();
		add(vignette);	

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for(i in 0...optionShit.length) {
			var testButton:FlxSprite = new FlxSprite(0, 130);
			testButton.ID = i;
			testButton.frames = Paths.getSparrowAtlas('menu/ButtonSheet');
			testButton.animation.addByPrefix('idle', optionShit[i] + 'Idle', 24, true);
			testButton.animation.addByPrefix('hover', optionShit[i] + 'Hover', 24, true);
			testButton.animation.play('idle');
			testButton.antialiasing = true;
			testButton.updateHitbox();
			testButton.screenCenter(X);
			testButton.scrollFactor.set();
			switch(i) {
				case 0:
					testButton.setPosition(357.5, 379.9);
				case 1:
					testButton.setPosition(655.5, 379.9);
				case 2:
					testButton.setPosition(357.5, 513.3);
				case 3:
					testButton.setPosition(551.5, 513.3);
				case 4:
					testButton.setPosition(745.5, 513.3);
			}
			menuItems.add(testButton);
		}		

		var logo:FlxSprite = new FlxSprite(0, 100);
		logo.frames = Paths.getSparrowAtlas('logoBumpin2');
		logo.animation.addByPrefix('bump', 'logo bumpin', 24, true);
		logo.animation.play('bump');
		logo.screenCenter();
		logo.updateHitbox();
		logo.antialiasing = true;
		logo.scale.set(0.50, 0.50);
		logo.y -= 160;
		add(logo);

		var versionShit:FlxText = new FlxText(5, FlxG.height - 80, 900, "Psych Engine 0.5.2 - V.S. Impostor by Team Funktastic");
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionShit.screenCenter(X);
		add(versionShit);
		
		var versionShit:FlxText = new FlxText(5, FlxG.height - 65, 900, "If you wan't use my fanmade for your mod, just add my nickname in credits.");
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionShit.screenCenter(X);
		add(versionShit);
		
		var versionShit:FlxText = new FlxText(5, FlxG.height - 50, 1300, "Big thanks to Betrayal developers, Hershey, Uhard, HopKa, Lenya The Cat, Sirox,
		LEOAQUIBOT, murkedGuyyr, Sotopia, VanDaniel, Flopster, Nes, FNF Fan, Fran, GrishaAsd, 
		Bravu, AlexZockt, Jigsaw, Agente TV, Adam_02M5, ConcreteDayShow, Arievix, DeepFriedBolonese and TerraRune.");
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionShit.screenCenter(X);
		add(versionShit);
		
		var versionShit:FlxText = new FlxText(5, FlxG.height - 95, 900, "V.S. Impostor v4 - Fanmade (1.2) by: Merphi");
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionShit.screenCenter(X);
		add(versionShit);
		
		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		menuItems.forEach(function(spr:FlxSprite)
		{
			starFG.x -= 0.03;
			starBG.x -= 0.01;
		});
		if (!selectedSomethin)
		{
			if (curSelected == 0) {
				if (controls.UI_RIGHT_P)
				{
					new FlxTimer().start(0.05, function(tmr:FlxTimer)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						changeItem(1);
					});
				}

				if (controls.UI_DOWN_P)
				{
					new FlxTimer().start(0.05, function(tmr:FlxTimer)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						changeItem(2);
					});
				}
			}

			if (curSelected == 1) {
				if (controls.UI_LEFT_P)
				{
					new FlxTimer().start(0.05, function(tmr:FlxTimer)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						changeItem(-1);
					});
				}

				if (controls.UI_DOWN_P)
				{
					new FlxTimer().start(0.05, function(tmr:FlxTimer)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						changeItem(3);
					});
				}
			}

			if (curSelected == 2) {
				if (controls.UI_RIGHT_P)
				{
					new FlxTimer().start(0.05, function(tmr:FlxTimer)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						changeItem(1);
					});
				}
				
				if (controls.UI_UP_P)
				{
					new FlxTimer().start(0.05, function(tmr:FlxTimer)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						changeItem(-2);
					});
				}
			}
			
			if (curSelected == 3) {
				if (controls.UI_LEFT_P)
				{
					new FlxTimer().start(0.05, function(tmr:FlxTimer)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						changeItem(-1);
					});
				}

				if (controls.UI_RIGHT_P)
				{
					new FlxTimer().start(0.05, function(tmr:FlxTimer)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						changeItem(1);
					});
				}
			}

			if (curSelected == 4) {
				if (controls.UI_LEFT_P)
				{
					new FlxTimer().start(0.05, function(tmr:FlxTimer)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						changeItem(-1);
					});
				}

				if (controls.UI_UP_P)
				{
					new FlxTimer().start(0.05, function(tmr:FlxTimer)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						changeItem(-3);
					});
				}
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
					if (optionShit[curSelected] == 'discord')
					{
						CoolUtil.browserLoad('https://discord.gg/pY54h9wq7q');
					}
					else
					{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
						FlxTween.tween(starFG, {y: 500}, 0.7, {
							ease: FlxEase.quadInOut
						});
						FlxTween.tween(starBG, {y: 500}, 0.7, {
							ease: FlxEase.quadInOut,
							startDelay: 0.2
						});
						FlxTween.tween(greenImpostor, {y: 902.35}, 0.7, {
							ease: FlxEase.quadInOut,
							startDelay: 0.24
						});
						FlxTween.tween(redImpostor, {y: 906.65}, 0.7, {
							ease: FlxEase.quadInOut,
							startDelay: 0.3
						});
						FlxG.camera.fade(FlxColor.BLACK, 0.7, false);
						FlxTween.tween(spr, {alpha: 0}, 1.3, {
							ease: FlxEase.quadOut,
							onComplete: function(twn:FlxTween)
							{
								spr.kill();
							}
						});
						};
						{
							var daChoice:String = optionShit[curSelected];
							switch (daChoice)
							{
								case 'story':
									MusicBeatState.switchState(new StoryMenuState());
								case 'freeplay':
									MusicBeatState.switchState(new FreeplayState());
								case 'options':
									LoadingState.loadAndSwitchState(new options.OptionsState());
								case 'awards':
									LoadingState.loadAndSwitchState(new AchievementsMenuState());
							}
						}
					});
				}
			}
			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('hover');
			}
		});
	}
}
