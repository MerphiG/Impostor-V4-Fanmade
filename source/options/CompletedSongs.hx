package options;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

using StringTools;

class CompletedSongs extends BaseOptionsMenu //Why you are here?
{
	public function new()
	{
		title = 'Completed Songs';
		rpcTitle = 'Completed Songs Menu'; //for Discord Rich Presence

		var option:Option = new Option('Christmas Song',
			"Christmas",
			'ChristmasSongComplete',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Spookpostor Song',
			"Spookpostor",
			'SpookpostorSongComplete',
			'bool',
			false);
		addOption(option);
		
		var option:Option = new Option('Titular Song',
			"Titular",
			'TitularSongComplete',
			'bool',
			false);
		addOption(option);
		
		var option:Option = new Option('Mission Song',
			"Mission",
			'MissionSongComplete',
			'bool',
			false);
		addOption(option);
		
		var option:Option = new Option('DoubleTrouble Song',
			"DoubleTrouble",
			'DoubleTroubleSongComplete',
			'bool',
			false);
		addOption(option);
		
		var option:Option = new Option('DoubleEjection Song',
			"DoubleEjection",
			'DoubleEjectionSongComplete',
			'bool',
			false);
		addOption(option);
		
		var option:Option = new Option('Boing Song',
			"Boing",
			'BoingSongComplete',
			'bool',
			false);
		addOption(option);
		
		var option:Option = new Option('DevilsGambit Song',
			"DevilsGambit",
			'DevilsGambitSongComplete',
			'bool',
			false);
		addOption(option);
		
		var option:Option = new Option('BadTime Song',
			"BadTime",
			'BadTimeSongComplete',
			'bool',
			false);
		addOption(option);
		
		var option:Option = new Option('Despair Song',
			"Despair",
			'DespairSongComplete',
			'bool',
			false);
		addOption(option);
		super();
	}
}