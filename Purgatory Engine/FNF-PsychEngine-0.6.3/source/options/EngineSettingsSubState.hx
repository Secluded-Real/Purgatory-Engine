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

class EngineSettingsSubState extends BaseOptionsMenu
{
    public function new()
	{
		title = 'Engine Settings';
		rpcTitle = 'Engine Settings Menu'; //for Discord Rich Presence

        var option:Option = new Option('Camera follows note',
			"If checked, the camera will move according to the note.\n(Script by stilic)",
			'follownote',
			'bool',
			true);
		addOption(option);

        var option:Option = new Option('Song Name',
			"If checked, it will show the name of the song in the bottom left corner.",
			'songinfoBar',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Judgement Counter:',
			"Shows a judgement counter at the left of the screen (Example: Sicks: 93,\nGoods:0, Bads: 1, 'Shits: 0)",
			'judgementCounter',
			'string',
			'Disabled',
			['Disabled', 'Simple', 'Advanced']);
		addOption(option);

        super();
    }
}