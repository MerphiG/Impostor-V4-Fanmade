import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import flixel.text.FlxText;
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end
import haxe.Json;
import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

typedef AchievementFile =
{
	var unlocksAfter:String;
	var icon:String;
	var name:String;
	var description:String;
	var hidden:Bool;
	var customGoal:Bool;
}

class Achievements {
	public static var achievementShits:Array<Dynamic> = [//Name, Description, Achievement save tag, Unlocks after, Hidden achievement
		//Set unlock after to "null" if it doesnt unlock after a week!!
		["Polus",				"Beat Polus Week in Story Mode",					'polus_week',			'null', 		false],
		["Mira HQ",				"Beat Mira HQ Week in Story Mode",					'mira-hq_week',			'null', 		false],
		["Skeld",				"Beat Skeld Week in Story Mode",					'skeld_week',			'null', 		false],
		["Defeat",				"Beat Defeat Week in Story Mode",					'defeat_week',			'null', 		false],
		["Airship",				"Beat Airship Week in Story Mode",					'airship_week',			'null', 		false],
		["Gray",				"Beat Triple Trouble Gray Week in Story Mode",		'tt-gray_week',			'null', 		false],
		["Maroon",				"Beat Triple Trouble Maroon Week in Story Mode",	'tt-maroon_week',		'null', 		false],
		["Pink",				"Beat Triple Trouble Pink Week in Story Mode",		'tt-pink_week',			'null', 		false],
		["Merry Christmas",		"Beat Christmas Songs",								'christmas',			'null', 		false],
		["Henry",				"Beat Henry Songs",									'henry',				'null', 		false],
		["Double Problem",		"Beat Red & Green Double Songs",					'double',				'null', 		false],
		["Drippy",				"Beat Drip Song",									'drip',					'null', 		false],
		["Nuts",				"Beat Skinny Nuts Song",							'nuts',					'null', 		false],
		["Jorsawsee",			"Beat Jorsawsee Song",								'jorsawsee',			'null', 		false],
		["Triple Trouble",		"Beat Triple Trouble Song",							'tt',					'null', 		false],
		["Dead Amogus",			"Beat Monosus Song",								'sus',					'null', 		false],
		["Infinikill",			"Beat Infinikill Song",								'infi',					'null', 		false],
		["Cleaning",			"Beat Cleaning Song",								'cleaning',				'null', 		false],
		["Triple Nightmare",	"Beat Nightmare Songs",								'nightmare',			'null', 		false]
		
	];

	public static var achievementsStuff:Array<Dynamic> = [ 
		//Gets filled when loading achievements
	];

	public static var achievementsMap:Map<String, Bool> = new Map<String, Bool>();
	public static var loadedAchievements:Map<String, AchievementFile> = new Map<String, AchievementFile>();

	public static var henchmenDeath:Int = 0;
	public static function unlockAchievement(name:String):Void {
		FlxG.log.add('Completed achievement "' + name +'"');
		achievementsMap.set(name, true);
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
	}

	public static function isAchievementUnlocked(name:String) {
		if(achievementsMap.exists(name)) {
			return achievementsMap.get(name);
		}
		return false;
	}

	public static function getAchievementIndex(name:String) {
		for (i in 0...achievementsStuff.length) {
			if(achievementsStuff[i][2] == name) {
				return i;
			}
		}
		return -1;
	}

	public static function loadAchievements():Void {
		achievementsStuff = [];
		achievementsStuff = achievementShits;

		#if MODS_ALLOWED
		//reloadAchievements(); //custom achievements do not work. will add once it doesn't do the duplication bug -bb
		#end

		if(FlxG.save.data != null) {
			if(FlxG.save.data.achievementsMap != null) {
				achievementsMap = FlxG.save.data.achievementsMap;
			}
			if(FlxG.save.data.achievementsUnlocked != null) {
				FlxG.log.add("Trying to load stuff");
				var savedStuff:Array<String> = FlxG.save.data.achievementsUnlocked;
				for (i in 0...savedStuff.length) {
					achievementsMap.set(savedStuff[i], true);
				}
			}
			if(henchmenDeath == 0 && FlxG.save.data.henchmenDeath != null) {
				henchmenDeath = FlxG.save.data.henchmenDeath;
			}
		}
	}

	public static function reloadAchievements() {	//Achievements in game are hardcoded, no need to make a folder for them
		loadedAchievements.clear();

		#if MODS_ALLOWED //Based on WeekData.hx
		var disabledMods:Array<String> = [];
		var modsListPath:String = 'modsList.txt';
		var directories:Array<String> = [Paths.mods()];
		if(FileSystem.exists(modsListPath))
		{
			var stuff:Array<String> = CoolUtil.coolTextFile(modsListPath);
			for (i in 0...stuff.length)
			{
				var splitName:Array<String> = stuff[i].trim().split('|');
				if(splitName[1] == '0') // Disable mod
				{
					disabledMods.push(splitName[0]);
				}
				else // Sort mod loading order based on modsList.txt file
				{
					var path = haxe.io.Path.join([Paths.mods(), splitName[0]]);
					//trace('trying to push: ' + splitName[0]);
					if (sys.FileSystem.isDirectory(path) && !Paths.ignoreModFolders.contains(splitName[0]) && !disabledMods.contains(splitName[0]) && !directories.contains(path + '/'))
					{
						directories.push(path + '/');
						//trace('pushed Directory: ' + splitName[0]);
					}
				}
			}
		}

		var modsDirectories:Array<String> = Paths.getModDirectories();
		for (folder in modsDirectories)
		{
			var pathThing:String = haxe.io.Path.join([Paths.mods(), folder]) + '/';
			if (!disabledMods.contains(folder) && !directories.contains(pathThing))
			{
				directories.push(pathThing);
				//trace('pushed Directory: ' + folder);
			}
		}

		for (i in 0...directories.length) {
			var directory:String = directories[i] + 'achievements/';

			//trace(directory);
			if (FileSystem.exists(directory)) {

				var listOfAchievements:Array<String> = CoolUtil.coolTextFile(directory + 'achievementList.txt');

				for (achievement in listOfAchievements) {
					var path:String = directory + achievement + '.json';

					if (FileSystem.exists(path) && !loadedAchievements.exists(achievement) && achievement != PlayState.othersCodeName) {
						loadedAchievements.set(achievement, getAchievementInfo(path));
					}

					//trace(path);
				}

				for (file in FileSystem.readDirectory(directory)) {
					var path = haxe.io.Path.join([directory, file]);
					
					var cutName:String = file.substr(0, file.length - 5);
					if (!FileSystem.isDirectory(path) && file.endsWith('.json') && !loadedAchievements.exists(cutName) && cutName != PlayState.othersCodeName) {
						loadedAchievements.set(cutName, getAchievementInfo(path));
					}

					//trace(file);
				}
			}
		}

		for (json in loadedAchievements) {
			//trace(json);
			achievementsStuff.push([json.name, json.description, json.icon, json.unlocksAfter, json.hidden]);
		}
		#end
	}

	private static function getAchievementInfo(path:String):AchievementFile {
		var rawJson:String = null;
		#if MODS_ALLOWED
		if (FileSystem.exists(path)) {
			rawJson = File.getContent(path);
		}
		#else
		if(OpenFlAssets.exists(path)) {
			rawJson = Assets.getText(path);
		}
		#end

		if(rawJson != null && rawJson.length > 0) {
			return cast Json.parse(rawJson);
		}
		return null;
	}
}

class AttachedAchievement extends FlxSprite {
	public var sprTracker:FlxSprite;
	private var tag:String;
	public function new(x:Float = 0, y:Float = 0, name:String) {
		super(x, y);

		changeAchievement(name);
		antialiasing = ClientPrefs.globalAntialiasing;
	}

	public function changeAchievement(tag:String) {
		this.tag = tag;
		reloadAchievementImage();
	}

	public function reloadAchievementImage() {
		if(Achievements.isAchievementUnlocked(tag)) {
			var imagePath:FlxGraphic = Paths.image('achievementgrid');
			var isModIcon:Bool = false;

			if (Achievements.loadedAchievements.exists(tag)) {
				isModIcon = true;
				imagePath = Paths.image(Achievements.loadedAchievements.get(tag).icon);
			}

			var index:Int = Achievements.getAchievementIndex(tag);
			if (isModIcon) index = 0;

			trace(imagePath);

			loadGraphic(imagePath, true, 150, 150);
			animation.add('icon', [index], 0, false, false);
			animation.play('icon');
		} else {
			loadGraphic(Paths.image('lockedachievement'));
		}
		scale.set(0.7, 0.7);
		updateHitbox();
	}

	override function update(elapsed:Float) {
		if (sprTracker != null)
			setPosition(sprTracker.x - 130, sprTracker.y + 25);

		super.update(elapsed);
	}
}

class AchievementObject extends FlxSpriteGroup {
	public var onFinish:Void->Void = null;
	var alphaTween:FlxTween;
	public function new(name:String, ?camera:FlxCamera = null)
	{
		super(x, y);
		ClientPrefs.saveSettings();

		var id:Int = Achievements.getAchievementIndex(name);
		var achieveName:String = Achievements.achievementsStuff[id][0];
		var text:String = Achievements.achievementsStuff[id][1];

		if(Achievements.loadedAchievements.exists(name)) {
			id = 0;
			achieveName = Achievements.loadedAchievements.get(name).name;
			text = Achievements.loadedAchievements.get(name).description;
		}

		var achievementBG:FlxSprite = new FlxSprite(60, 50).makeGraphic(420, 120, FlxColor.BLACK);
		achievementBG.scrollFactor.set();

		var imagePath = Paths.image('achievementgrid');
		var modsImage = null;
		var isModIcon:Bool = false;

		//fucking hell bro
		/*if (Achievements.loadedAchievements.exists(name)) {
			isModIcon = true;
			modsImage = Paths.image(Achievements.loadedAchievements.get(name).icon);
		}*/

		var index:Int = Achievements.getAchievementIndex(name);
		if (isModIcon) index = 0;

		//trace(imagePath);
		//trace(modsImage);

		var achievementIcon:FlxSprite = new FlxSprite(achievementBG.x + 10, achievementBG.y + 10).loadGraphic((isModIcon ? modsImage : imagePath), true, 150, 150);
		achievementIcon.animation.add('icon', [index], 0, false, false);
		achievementIcon.animation.play('icon');
		achievementIcon.scrollFactor.set();
		achievementIcon.setGraphicSize(Std.int(achievementIcon.width * (2 / 3)));
		achievementIcon.updateHitbox();
		achievementIcon.antialiasing = ClientPrefs.globalAntialiasing;

		var achievementName:FlxText = new FlxText(achievementIcon.x + achievementIcon.width + 20, achievementIcon.y + 16, 280, achieveName, 16);
		achievementName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT);
		achievementName.scrollFactor.set();

		var achievementText:FlxText = new FlxText(achievementName.x, achievementName.y + 32, 280, text, 16);
		achievementText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT);
		achievementText.scrollFactor.set();

		add(achievementBG);
		add(achievementName);
		add(achievementText);
		add(achievementIcon);

		var cam:Array<FlxCamera> = FlxCamera.defaultCameras;
		if(camera != null) {
			cam = [camera];
		}
		alpha = 0;
		achievementBG.cameras = cam;
		achievementName.cameras = cam;
		achievementText.cameras = cam;
		achievementIcon.cameras = cam;
		alphaTween = FlxTween.tween(this, {alpha: 1}, 0.5, {onComplete: function (twn:FlxTween) {
			alphaTween = FlxTween.tween(this, {alpha: 0}, 0.5, {
				startDelay: 2.5,
				onComplete: function(twn:FlxTween) {
					alphaTween = null;
					remove(this);
					if(onFinish != null) onFinish();
				}
			});
		}});
	}

	override function destroy() {
		if(alphaTween != null) {
			alphaTween.cancel();
		}
		super.destroy();
	}
}