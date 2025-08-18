package;

#if desktop
import Discord.DiscordClient;
#end
import editors.ChartingState;
import flash.text.TextField;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.FlxObject;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
import flixel.system.FlxSound;
import openfl.utils.Assets as OpenFlAssets;
import WeekData;
#if MODS_ALLOWED
import sys.FileSystem;
#end

using StringTools;



class CategoryState extends MusicBeatState
{
	public static var categorySelected:String;

	private var InMainFreeplayState:Bool = false;

	var text:FlxText;

	private var CurrentSongIcon:FlxSprite;

	var icons:Array<FlxSprite> = [];
	var titles:Array<FlxSprite> = [];
	private var camFollow:FlxObject;
	private static var prevCamFollow:FlxObject;

	private var AllPossibleSongs:Array<String> = ["story", "remixes", "secret", "mods"];

	private var CurrentPack:Int = 0;

	var bg:FlxSprite = new FlxSprite();

	var loadingPack:Bool = false;

	public static var bgPaths:Array<String> = 
	[
		'backgrounds/darlyboxman',
		'backgrounds/isaaclul',
		'backgrounds/osp',
		'backgrounds/slushX',
		'backgrounds/voltrex'
	];

	public static var loadingCategory:Bool = false;

	override function create()
	{

		#if MODS_ALLOWED
		var disabledMods:Array<String> = [];
		var directories:Array<String> = [Paths.mods(), Paths.getPreloadPath()];
		var originalLength:Int = directories.length;
		var modsDirectories:Array<String> = Paths.getModDirectories();
		var modsListPath:String = 'modsList.txt';
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
		#else
		var directories:Array<String> = [Paths.getPreloadPath()];
		var originalLength:Int = directories.length;
		#end

		#if MODS_ALLOWED
		for (i in 0...directories.length) {
			var directory:String = directories[i] + 'categories.txt';
			if(FileSystem.exists(directory)) {
				var listOfWeeks:Array<String> = CoolUtil.coolTextFile(directory + 'weekList.txt');
				for (daWeek in listOfWeeks)
				{
					var path:String = directory + daWeek + '.txt';
					if(sys.FileSystem.exists(path))
					{
						//AllPossibleSongs += [''];
					}
				}

				for (file in FileSystem.readDirectory(directory))
				{
					var path = haxe.io.Path.join([directory, file]);
					if (!sys.FileSystem.isDirectory(path) && file.endsWith('.txt'))
					{
						
					}
				}
			}
		}
		#end

		#if desktop DiscordClient.changePresence("In the Freeplay Menus", null); #end

		// lmao
		bg.loadGraphic(Paths.image('menuBGBlue', "preload"));
		bg.color = 0xFF202020;
		bg.scrollFactor.set();
		add(bg);

		for (i in 0...AllPossibleSongs.length)
		{
			Highscore.load();
	
			var CurrentSongIcon:FlxSprite = new FlxSprite(0,0).loadGraphic(Paths.image('freeplaycategories/menu_' + (AllPossibleSongs[i].toLowerCase()), "preload"));
			CurrentSongIcon.centerOffsets(false);
			CurrentSongIcon.x = (1000 * i + 1) + (1000 - CurrentSongIcon.width);
			CurrentSongIcon.y = (FlxG.height / 2) - 256;
			CurrentSongIcon.setGraphicSize(Std.int(CurrentSongIcon.width * 0.7));
			CurrentSongIcon.antialiasing = true;
	
			var NameAlpha:Alphabet = new Alphabet(40, (FlxG.height / 2), AllPossibleSongs[i], true);
			NameAlpha.x = CurrentSongIcon.x;
	
			add(CurrentSongIcon);
			icons.push(CurrentSongIcon);
			add(NameAlpha);
			NameAlpha.alpha = 0; // nobody will know!!!
			titles.push(NameAlpha);
		}

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 46).makeGraphic(FlxG.width, 56, 0xFF000000);
		textBG.alpha = 0.6;
		textBG.scrollFactor.set();
		var leText:String = "< / > Change Category | ACCEPT to proceed | BACK to return";
		text = new FlxText(textBG.x + -10, textBG.y + 2, FlxG.width, leText, 21);
		text.setFormat(Paths.font("comic-sans.ttf"), 18, FlxColor.WHITE, CENTER);
		text.scrollFactor.set();
		add(textBG);
		add(text);

		var scale:Float = 1;
		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(icons[CurrentPack].x + 256, icons[CurrentPack].y + 450);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
	
		add(camFollow);
			
		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		FlxG.camera.focusOn(camFollow.getPosition());

		UpdatePackSelection(0);
		super.create();
	}

	public function LoadProperPack()
	{
		switch (AllPossibleSongs[CurrentPack].toLowerCase())
		{
			case 'story':
				FlxG.switchState(new FreeplayState());
				categorySelected = 'story';
			case 'mods':
				FlxG.switchState(new FreeplayState());
				categorySelected = null;
			case 'remixes':
				FlxG.switchState(new FreeplayState());
				categorySelected = 'remixes';
			case 'secret':
				FlxG.switchState(new FreeplayState());
				categorySelected = 'secret';
		}
	}

	public function UpdatePackSelection(change:Int)
	{
		CurrentPack += change;
		if (CurrentPack == -1)
			CurrentPack = AllPossibleSongs.length - 1;
		
		if (CurrentPack == AllPossibleSongs.length)
			CurrentPack = 0;
	
		camFollow.x = icons[CurrentPack].x + 450; // IM SO STUPID AF HELPPPPPPPPPPPPPPPPPPP
		// i was changing the x from the line 96 :sob:
	}
	override function update(elapsed:Float)
	{

		if (!InMainFreeplayState) 
			{
			if (!loadingCategory)
			{
				if (controls.UI_LEFT_P)
				{
					UpdatePackSelection(-1);
				}
				if (controls.UI_RIGHT_P)
				{
					UpdatePackSelection(1);
				}
				if (controls.ACCEPT && !loadingPack)
					{
						FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
						loadingCategory = true;
		
						new FlxTimer().start(0.2, function(Dumbshit:FlxTimer)
						{
							for (item in icons) { FlxTween.tween(item, {alpha: 0, y: item.y - 200}, 0.5, {ease: FlxEase.cubeInOut}); }
							for (item in titles) { FlxTween.tween(item, {alpha: 0, y: item.y - 200}, 0.5, {ease: FlxEase.cubeInOut}); }
							FlxTween.tween(camera, {'alpha': 0}, 0.4, {ease: FlxEase.cubeInOut}); // i tried to do an a lil different transition
							new FlxTimer().start(0.7, function(Dumbshit:FlxTimer)
							{
								for (item in icons) { item.visible = false; }
								for (item in titles) { item.visible = false; }
		
								LoadProperPack();
								loadingCategory = false;
							});
						});
					}
				if (controls.BACK)
					{
						FlxG.sound.play(Paths.sound('cancelMenu'));
						MusicBeatState.switchState(new MainMenuState());
					}	
				
					return;
				}					
			} else {

			}
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}
	}
	public static function randomizeBG():flixel.system.FlxAssets.FlxGraphicAsset
		{
			var chance:Int = FlxG.random.int(0, bgPaths.length - 1);
			return Paths.image(bgPaths[chance]);
		}
}


		




class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";
	public var blocked:Bool = false;

	public function new(song:String, week:Int, songCharacter:String, color:Int, blocked:Bool)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Paths.currentModDirectory;
		this.blocked = blocked;
		if(this.folder == null) this.folder = '';
	}
}