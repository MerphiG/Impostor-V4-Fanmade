package;

import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

class ClientPrefs {
	public static var downScroll:Bool = false;
	public static var middleScroll:Bool = false;
	public static var showFPS:Bool = true;
	public static var flashing:Bool = true;
	public static var ShowScreenAfterTitleState:Bool = true;
	public static var globalAntialiasing:Bool = true;
	public static var noteSplashes:Bool = true;
	public static var lowQuality:Bool = false;
	public static var framerate:Int = 60;
	public static var cursing:Bool = true;
	public static var violence:Bool = true;
	public static var camZooms:Bool = true;
	public static var Optimization:Bool = false;
	public static var hideHud:Bool = false;
	public static var noteOffset:Int = 0;
	public static var arrowHSV:Array<Array<Int>> = [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]];
	public static var imagesPersist:Bool = false;
	public static var ghostTapping:Bool = true;
	public static var timeBarType:String = 'Time Left';
	public static var scoreZoom:Bool = true;
	public static var noReset:Bool = false;
	public static var healthBarAlpha:Float = 1;
	public static var controllerMode:Bool = false;
	public static var hitsoundVolume:Float = 0;
	public static var gameplaySettings:Map<String, Dynamic> = [
		'scrollspeed' => 1.0,
		'scrolltype' => 'multiplicative', 
		// anyone reading this, amod is multiplicative speed mod, cmod is constant speed mod, and xmod is bpm based speed mod.
		// an amod example would be chartSpeed * multiplier
		// cmod would just be constantSpeed = chartSpeed
		// and xmod basically works by basing the speed on the bpm.
		// iirc (beatsPerSecond * (conductorToNoteDifference / 1000)) * noteSize (110 or something like that depending on it, prolly just use note.height)
		// bps is calculated by bpm / 60
		// oh yeah and you'd have to actually convert the difference to seconds which I already do, because this is based on beats and stuff. but it should work
		// just fine. but I wont implement it because I don't know how you handle sustains and other stuff like that.
		// oh yeah when you calculate the bps divide it by the songSpeed or rate because it wont scroll correctly when speeds exist.
		'songspeed' => 1.0,
		'healthgain' => 1.0,
		'healthloss' => 1.0,
		'instakill' => false,
		'practice' => false,
		'botplay' => false,
		'opponentplay' => false
	];

	public static var comboOffset:Array<Int> = [0, 0, 0, 0];
	public static var ratingOffset:Int = 0;
	public static var sickWindow:Int = 45;
	public static var goodWindow:Int = 90;
	public static var badWindow:Int = 135;
	public static var safeFrames:Float = 10;
	
	
	
	public static var SussusMoogusSongComplete:Bool = false;
	public static var SabotageSongComplete:Bool = false;
	public static var MeltdownSongComplete:Bool = false;
	
	public static var SussusToogusSongComplete:Bool = false;
	public static var LightsDownSongComplete:Bool = false;
	public static var ReactorSongComplete:Bool = false;
	public static var EjectedSongComplete:Bool = false;
	
	public static var SussyBussySongComplete:Bool = false;
	public static var RivalsSongComplete:Bool = false;
	public static var ChewmateSongComplete:Bool = false;
	
	public static var DefeatSongComplete:Bool = false;
	
	public static var MandoSongComplete:Bool = false;
	public static var DLowSongComplete:Bool = false;
	public static var OversightSongComplete:Bool = false;
	public static var InfluenceSongComplete:Bool = false;
	public static var DangerSongComplete:Bool = false;
	public static var DoubleKillSongComplete:Bool = false;
	public static var DeathBlowSongComplete:Bool = false;
	
	public static var InsaneSongComplete:Bool = false;
	public static var BlackoutSongComplete:Bool = false;
	public static var NyctophobiaSongComplete:Bool = false;
	public static var MassacreSongComplete:Bool = false;
	
	public static var BoilingPointSongComplete:Bool = false;
	
	public static var HeartbrokenSongComplete:Bool = false;

	public static var ChristmasSongComplete:Bool = false;
	public static var SpookpostorSongComplete:Bool = false;
	
	public static var TitularSongComplete:Bool = false;
	public static var MissionSongComplete:Bool = false;
	
	public static var DoubleTroubleSongComplete:Bool = false;
	public static var DoubleEjectionSongComplete:Bool = false;
	public static var BoingSongComplete:Bool = false;
	
	public static var DripSongComplete:Bool = false;
	
	public static var SkinnyNutsSongComplete:Bool = false;
	
	public static var JorsawseeSongComplete:Bool = false;
	
	public static var TripleTroubleSongComplete:Bool = false;
	
	public static var MonosusSongComplete:Bool = false;
	
	public static var InfinikillSongComplete:Bool = false;
	
	public static var CleaningSongComplete:Bool = false;
	
	public static var DevilsGambitSongComplete:Bool = false;
	public static var BadTimeSongComplete:Bool = false;
	public static var DespairSongComplete:Bool = false;



	//Every key has two binds, add your key bind down here and then add your control on options/ControlsSubState.hx and Controls.hx
	public static var keyBinds:Map<String, Array<FlxKey>> = [
		//Key Bind, Name for ControlsSubState
		'note_left'		=> [A, LEFT],
		'note_down'		=> [S, DOWN],
		'note_up'		=> [W, UP],
		'note_right'	=> [D, RIGHT],
		
		'ui_left'		=> [A, LEFT],
		'ui_down'		=> [S, DOWN],
		'ui_up'			=> [W, UP],
		'ui_right'		=> [D, RIGHT],
		
		'accept'		=> [SPACE, ENTER],
		'back'			=> [BACKSPACE, ESCAPE],
		'pause'			=> [ENTER, ESCAPE],
		'reset'			=> [R, NONE],
		
		'volume_mute'	=> [ZERO, NONE],
		'volume_up'		=> [NUMPADPLUS, PLUS],
		'volume_down'	=> [NUMPADMINUS, MINUS],
		
		'debug_1'		=> [SEVEN, NONE],
		'debug_2'		=> [EIGHT, NONE]
	];
	public static var defaultKeys:Map<String, Array<FlxKey>> = null;

	public static function loadDefaultKeys() {
		defaultKeys = keyBinds.copy();
		//trace(defaultKeys);
	}

	public static function saveSettings() {
		FlxG.save.data.downScroll = downScroll;
		FlxG.save.data.middleScroll = middleScroll;
		FlxG.save.data.showFPS = showFPS;
		FlxG.save.data.flashing = flashing;
		FlxG.save.data.ShowScreenAfterTitleState = ShowScreenAfterTitleState;
		FlxG.save.data.globalAntialiasing = globalAntialiasing;
		FlxG.save.data.noteSplashes = noteSplashes;
		FlxG.save.data.lowQuality = lowQuality;
		FlxG.save.data.framerate = framerate;
		//FlxG.save.data.cursing = cursing;
		//FlxG.save.data.violence = violence;
		FlxG.save.data.camZooms = camZooms;
		FlxG.save.data.noteOffset = noteOffset;
		FlxG.save.data.hideHud = hideHud;
		FlxG.save.data.arrowHSV = arrowHSV;
		FlxG.save.data.imagesPersist = imagesPersist;
		FlxG.save.data.ghostTapping = ghostTapping;
		FlxG.save.data.timeBarType = timeBarType;
		FlxG.save.data.scoreZoom = scoreZoom;
		FlxG.save.data.noReset = noReset;
		FlxG.save.data.healthBarAlpha = healthBarAlpha;
		FlxG.save.data.comboOffset = comboOffset;
		FlxG.save.data.achievementsMap = Achievements.achievementsMap;
		FlxG.save.data.henchmenDeath = Achievements.henchmenDeath;
		FlxG.save.data.Optimization = Optimization;

		FlxG.save.data.ratingOffset = ratingOffset;
		FlxG.save.data.sickWindow = sickWindow;
		FlxG.save.data.goodWindow = goodWindow;
		FlxG.save.data.badWindow = badWindow;
		FlxG.save.data.safeFrames = safeFrames;
		FlxG.save.data.gameplaySettings = gameplaySettings;
		FlxG.save.data.controllerMode = controllerMode;
		
		
		
		FlxG.save.data.SussusMoogusSongComplete = SussusMoogusSongComplete; //Polus
		FlxG.save.data.SabotageSongComplete = SabotageSongComplete; //Polus
		FlxG.save.data.MeltdownSongComplete = MeltdownSongComplete; //Polus
		
		FlxG.save.data.SussusToogusSongComplete = SussusToogusSongComplete; //Mira HQ
		FlxG.save.data.LightsDownSongComplete = LightsDownSongComplete; //Mira HQ
		FlxG.save.data.ReactorSongComplete = ReactorSongComplete; //Mira HQ
		FlxG.save.data.EjectedSongComplete = EjectedSongComplete; //Mira HQ
		
		FlxG.save.data.SussyBussySongComplete = SussyBussySongComplete; //Skeld
		FlxG.save.data.RivalsSongComplete = RivalsSongComplete; //Skeld
		FlxG.save.data.ChewmateSongComplete = ChewmateSongComplete; //Skeld
		
		FlxG.save.data.DefeatSongComplete = DefeatSongComplete; //Defeat
		
		FlxG.save.data.MandoSongComplete = MandoSongComplete; //Airship
		FlxG.save.data.DLowSongComplete = DLowSongComplete; //Airship
		FlxG.save.data.OversightSongComplete = OversightSongComplete; //Airship
		FlxG.save.data.InfluenceSongComplete = InfluenceSongComplete; //Airship
		FlxG.save.data.DangerSongComplete = DangerSongComplete; //Airship
		FlxG.save.data.DoubleKillSongComplete = DoubleKillSongComplete; //Airship
		FlxG.save.data.DeathBlowSongComplete = DeathBlowSongComplete; //Airship
		
		FlxG.save.data.InsaneSongComplete = InsaneSongComplete; //Gray
		FlxG.save.data.BlackoutSongComplete = BlackoutSongComplete; //Gray
		FlxG.save.data.NyctophobiaSongComplete = NyctophobiaSongComplete; //Gray
		FlxG.save.data.MassacreSongComplete = MassacreSongComplete; //Gray
		
		FlxG.save.data.BoilingPointSongComplete = BoilingPointSongComplete; //Maroon
		
		FlxG.save.data.HeartbrokenSongComplete = HeartbrokenSongComplete; //Pink

		FlxG.save.data.ChristmasSongComplete = ChristmasSongComplete; //Merry Christmas
		FlxG.save.data.SpookpostorSongComplete = SpookpostorSongComplete; //Merry Christmas
		
		FlxG.save.data.TitularSongComplete = TitularSongComplete; //Henry
		FlxG.save.data.MissionSongComplete = MissionSongComplete; //Henry
		
		FlxG.save.data.DoubleTroubleSongComplete = DoubleTroubleSongComplete; //Double Problem
		FlxG.save.data.DoubleEjectionSongComplete = DoubleEjectionSongComplete; //Double Problem
		FlxG.save.data.BoingSongComplete = BoingSongComplete; //Double Problem
		
		FlxG.save.data.DripSongComplete = DripSongComplete; //Drippy
		
		FlxG.save.data.SkinnyNutsSongComplete = SkinnyNutsSongComplete; //Nuts
		
		FlxG.save.data.JorsawseeSongComplete = JorsawseeSongComplete; //Jorsawsee
		
		FlxG.save.data.TripleTroubleSongComplete = TripleTroubleSongComplete; //Triple Trouble
		
		FlxG.save.data.MonosusSongComplete = MonosusSongComplete; //Dead Amogus
		
		FlxG.save.data.InfinikillSongComplete = InfinikillSongComplete; //Infinikill
		
		FlxG.save.data.CleaningSongComplete = CleaningSongComplete; //Cleaning
		
		FlxG.save.data.DevilsGambitSongComplete = DevilsGambitSongComplete; //Triple Nightmare
		FlxG.save.data.BadTimeSongComplete = BadTimeSongComplete; //Triple Nightmare
		FlxG.save.data.DespairSongComplete = DespairSongComplete; //Triple Nightmare
		
		
		
		FlxG.save.flush();

		var save:FlxSave = new FlxSave();
		save.bind('controls_v2', 'ninjamuffin99'); //Placing this in a separate save so that it can be manually deleted without removing your Score and stuff
		save.data.customControls = keyBinds;
		save.flush();
		FlxG.log.add("Settings saved!");
	}

	public static function loadPrefs() {
		if(FlxG.save.data.downScroll != null) {
			downScroll = FlxG.save.data.downScroll;
		}
		if(FlxG.save.data.middleScroll != null) {
			middleScroll = FlxG.save.data.middleScroll;
		}
		if(FlxG.save.data.showFPS != null) {
			showFPS = FlxG.save.data.showFPS;
			if(Main.fpsVar != null) {
				Main.fpsVar.visible = showFPS;
			}
		}
		if(FlxG.save.data.flashing != null) {
			flashing = FlxG.save.data.flashing;
		}
		if(FlxG.save.data.ShowScreenAfterTitleState != null) {
			ShowScreenAfterTitleState = FlxG.save.data.ShowScreenAfterTitleState;
		}
		if(FlxG.save.data.globalAntialiasing != null) {
			globalAntialiasing = FlxG.save.data.globalAntialiasing;
		}
		if(FlxG.save.data.noteSplashes != null) {
			noteSplashes = FlxG.save.data.noteSplashes;
		}
		if(FlxG.save.data.lowQuality != null) {
			lowQuality = FlxG.save.data.lowQuality;
		}
		if(FlxG.save.data.framerate != null) {
			framerate = FlxG.save.data.framerate;
			if(framerate > FlxG.drawFramerate) {
				FlxG.updateFramerate = framerate;
				FlxG.drawFramerate = framerate;
			} else {
				FlxG.drawFramerate = framerate;
				FlxG.updateFramerate = framerate;
			}
		}
		/*if(FlxG.save.data.cursing != null) {
			cursing = FlxG.save.data.cursing;
		}
		if(FlxG.save.data.violence != null) {
			violence = FlxG.save.data.violence;
		}*/
		if(FlxG.save.data.camZooms != null) {
			camZooms = FlxG.save.data.camZooms;
		}
		if(FlxG.save.data.Optimization != null) {
			Optimization = FlxG.save.data.Optimization;
		}
		
		if(FlxG.save.data.SussusMoogusSongComplete != null) {
			SussusMoogusSongComplete = FlxG.save.data.SussusMoogusSongComplete;
		}
		if(FlxG.save.data.SabotageSongComplete != null) {
			SabotageSongComplete = FlxG.save.data.SabotageSongComplete;
		}
		if(FlxG.save.data.MeltdownSongComplete != null) {
			MeltdownSongComplete = FlxG.save.data.MeltdownSongComplete;
		}

		if(FlxG.save.data.SussusToogusSongComplete != null) {
			SussusToogusSongComplete = FlxG.save.data.SussusToogusSongComplete;
		}
		if(FlxG.save.data.LightsDownSongComplete != null) {
			LightsDownSongComplete = FlxG.save.data.LightsDownSongComplete;
		}
		if(FlxG.save.data.ReactorSongComplete != null) {
			ReactorSongComplete = FlxG.save.data.ReactorSongComplete;
		}
		if(FlxG.save.data.EjectedSongComplete != null) {
			EjectedSongComplete = FlxG.save.data.EjectedSongComplete;
		}

		if(FlxG.save.data.SussyBussySongComplete != null) {
			SussyBussySongComplete = FlxG.save.data.SussyBussySongComplete;
		}
		if(FlxG.save.data.RivalsSongComplete != null) {
			RivalsSongComplete = FlxG.save.data.RivalsSongComplete;
		}
		if(FlxG.save.data.ChewmateSongComplete != null) {
			ChewmateSongComplete = FlxG.save.data.ChewmateSongComplete;
		}

		if(FlxG.save.data.DefeatSongComplete != null) {
			DefeatSongComplete = FlxG.save.data.DefeatSongComplete;
		}

		if(FlxG.save.data.MandoSongComplete != null) {
			MandoSongComplete = FlxG.save.data.MandoSongComplete;
		}
		if(FlxG.save.data.DLowSongComplete != null) {
			DLowSongComplete = FlxG.save.data.DLowSongComplete;
		}
		if(FlxG.save.data.OversightSongComplete != null) {
			OversightSongComplete = FlxG.save.data.OversightSongComplete;
		}
		if(FlxG.save.data.InfluenceSongComplete != null) {
			InfluenceSongComplete = FlxG.save.data.InfluenceSongComplete;
		}
		if(FlxG.save.data.DangerSongComplete != null) {
			DangerSongComplete = FlxG.save.data.DangerSongComplete;
		}
		if(FlxG.save.data.DoubleKillSongComplete != null) {
			DoubleKillSongComplete = FlxG.save.data.DoubleKillSongComplete;
		}
		if(FlxG.save.data.DeathBlowSongComplete != null) {
			DeathBlowSongComplete = FlxG.save.data.DeathBlowSongComplete;
		}

		if(FlxG.save.data.InsaneSongComplete != null) {
			InsaneSongComplete = FlxG.save.data.InsaneSongComplete;
		}
		if(FlxG.save.data.BlackoutSongComplete != null) {
			BlackoutSongComplete = FlxG.save.data.BlackoutSongComplete;
		}
		if(FlxG.save.data.NyctophobiaSongComplete != null) {
			NyctophobiaSongComplete = FlxG.save.data.NyctophobiaSongComplete;
		}
		if(FlxG.save.data.MassacreSongComplete != null) {
			MassacreSongComplete = FlxG.save.data.MassacreSongComplete;
		}

		if(FlxG.save.data.BoilingPointSongComplete != null) {
			BoilingPointSongComplete = FlxG.save.data.BoilingPointSongComplete;
		}

		if(FlxG.save.data.HeartbrokenSongComplete != null) {
			HeartbrokenSongComplete = FlxG.save.data.HeartbrokenSongComplete;
		}

		if(FlxG.save.data.ChristmasSongComplete != null) {
			ChristmasSongComplete = FlxG.save.data.ChristmasSongComplete;
		}
		if(FlxG.save.data.SpookpostorSongComplete != null) {
			SpookpostorSongComplete = FlxG.save.data.SpookpostorSongComplete;
		}
		
		if(FlxG.save.data.TitularSongComplete != null) {
			TitularSongComplete = FlxG.save.data.TitularSongComplete;
		}
		if(FlxG.save.data.MissionSongComplete != null) {
			MissionSongComplete = FlxG.save.data.MissionSongComplete;
		}
		
		if(FlxG.save.data.DoubleTroubleSongComplete != null) {
			DoubleTroubleSongComplete = FlxG.save.data.DoubleTroubleSongComplete;
		}
		if(FlxG.save.data.DoubleEjectionSongComplete != null) {
			DoubleEjectionSongComplete = FlxG.save.data.DoubleEjectionSongComplete;
		}
		if(FlxG.save.data.BoingSongComplete != null) {
			BoingSongComplete = FlxG.save.data.BoingSongComplete;
		}
		
		if(FlxG.save.data.DripSongComplete != null) {
			DripSongComplete = FlxG.save.data.DripSongComplete;
		}

		if(FlxG.save.data.SkinnyNutsSongComplete != null) {
			SkinnyNutsSongComplete = FlxG.save.data.SkinnyNutsSongComplete;
		}

		if(FlxG.save.data.JorsawseeSongComplete != null) {
			JorsawseeSongComplete = FlxG.save.data.JorsawseeSongComplete;
		}

		if(FlxG.save.data.TripleTroubleSongComplete != null) {
			TripleTroubleSongComplete = FlxG.save.data.TripleTroubleSongComplete;
		}

		if(FlxG.save.data.MonosusSongComplete != null) {
			MonosusSongComplete = FlxG.save.data.MonosusSongComplete;
		}

		if(FlxG.save.data.InfinikillSongComplete != null) {
			InfinikillSongComplete = FlxG.save.data.InfinikillSongComplete;
		}

		if(FlxG.save.data.CleaningSongComplete != null) {
			CleaningSongComplete = FlxG.save.data.CleaningSongComplete;
		}
		
		if(FlxG.save.data.DevilsGambitSongComplete != null) {
			DevilsGambitSongComplete = FlxG.save.data.DevilsGambitSongComplete;
		}
		if(FlxG.save.data.BadTimeSongComplete != null) {
			BadTimeSongComplete = FlxG.save.data.BadTimeSongComplete;
		}
		if(FlxG.save.data.DespairSongComplete != null) {
			DespairSongComplete = FlxG.save.data.DespairSongComplete;
		}
		
		if(FlxG.save.data.hideHud != null) {
			hideHud = FlxG.save.data.hideHud;
		}
		if(FlxG.save.data.noteOffset != null) {
			noteOffset = FlxG.save.data.noteOffset;
		}
		if(FlxG.save.data.arrowHSV != null) {
			arrowHSV = FlxG.save.data.arrowHSV;
		}
		if(FlxG.save.data.ghostTapping != null) {
			ghostTapping = FlxG.save.data.ghostTapping;
		}
		if(FlxG.save.data.timeBarType != null) {
			timeBarType = FlxG.save.data.timeBarType;
		}
		if(FlxG.save.data.scoreZoom != null) {
			scoreZoom = FlxG.save.data.scoreZoom;
		}
		if(FlxG.save.data.noReset != null) {
			noReset = FlxG.save.data.noReset;
		}
		if(FlxG.save.data.healthBarAlpha != null) {
			healthBarAlpha = FlxG.save.data.healthBarAlpha;
		}
		if(FlxG.save.data.comboOffset != null) {
			comboOffset = FlxG.save.data.comboOffset;
		}
		
		if(FlxG.save.data.ratingOffset != null) {
			ratingOffset = FlxG.save.data.ratingOffset;
		}
		if(FlxG.save.data.sickWindow != null) {
			sickWindow = FlxG.save.data.sickWindow;
		}
		if(FlxG.save.data.goodWindow != null) {
			goodWindow = FlxG.save.data.goodWindow;
		}
		if(FlxG.save.data.badWindow != null) {
			badWindow = FlxG.save.data.badWindow;
		}
		if(FlxG.save.data.safeFrames != null) {
			safeFrames = FlxG.save.data.safeFrames;
		}
		if(FlxG.save.data.controllerMode != null) {
			controllerMode = FlxG.save.data.controllerMode;
		}
		if(FlxG.save.data.hitsoundVolume != null) {
			hitsoundVolume = FlxG.save.data.hitsoundVolume;
		}
		if(FlxG.save.data.gameplaySettings != null)
		{
			var savedMap:Map<String, Dynamic> = FlxG.save.data.gameplaySettings;
			for (name => value in savedMap)
			{
				gameplaySettings.set(name, value);
			}
		}
		
		// flixel automatically saves your volume!
		if(FlxG.save.data.volume != null)
		{
			FlxG.sound.volume = FlxG.save.data.volume;
		}
		if (FlxG.save.data.mute != null)
		{
			FlxG.sound.muted = FlxG.save.data.mute;
		}

		var save:FlxSave = new FlxSave();
		save.bind('controls_v2', 'ninjamuffin99');
		if(save != null && save.data.customControls != null) {
			var loadedControls:Map<String, Array<FlxKey>> = save.data.customControls;
			for (control => keys in loadedControls) {
				keyBinds.set(control, keys);
			}
			reloadControls();
		}
	}

	inline public static function getGameplaySetting(name:String, defaultValue:Dynamic):Dynamic {
		return /*PlayState.isStoryMode ? defaultValue : */ (gameplaySettings.exists(name) ? gameplaySettings.get(name) : defaultValue);
	}

	public static function reloadControls() {
		PlayerSettings.player1.controls.setKeyboardScheme(KeyboardScheme.Solo);

		TitleState.muteKeys = copyKey(keyBinds.get('volume_mute'));
		TitleState.volumeDownKeys = copyKey(keyBinds.get('volume_down'));
		TitleState.volumeUpKeys = copyKey(keyBinds.get('volume_up'));
		FlxG.sound.muteKeys = TitleState.muteKeys;
		FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
		FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;
	}
	public static function copyKey(arrayToCopy:Array<FlxKey>):Array<FlxKey> {
		var copiedArray:Array<FlxKey> = arrayToCopy.copy();
		var i:Int = 0;
		var len:Int = copiedArray.length;

		while (i < len) {
			if(copiedArray[i] == NONE) {
				copiedArray.remove(NONE);
				--i;
			}
			i++;
			len = copiedArray.length;
		}
		return copiedArray;
	}
}
