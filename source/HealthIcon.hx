package;

import flixel.FlxSprite;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	private var isOldIcon:Bool = false;
	private var isPlayer:Bool = false;
	private var char:String = '';

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		isOldIcon = (char == 'bf-old');
		this.isPlayer = isPlayer;
		changeIcon(char);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 12, sprTracker.y - 30);
	}

	public function swapOldIcon() {
		if(isOldIcon = !isOldIcon) changeIcon('bf-old');
		else changeIcon('bf');
	}

	private var iconOffsets:Array<Float> = [0, 0];
	public function changeIcon(char:String) {
		if(this.char != char) {
			var name:String = 'icons/' + char;
			var xmlPath:String = 'icons/' + char; //shitty.
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-' + char; //Older versions of psych engine's support
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-face'; //Prevents crash from missing icon
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/face'; //Prevents crash from missing icon

			//Prevents crashes on Animated icons (i think???).
			if(!Paths.fileExists('images/' + xmlPath + '.xml', IMAGE)) xmlPath = 'icons/icon-' + char; //Older versions of psych engine's support
			if(!Paths.fileExists('images/' + xmlPath + '.xml', IMAGE)) xmlPath = 'icons/icon-face'; //Prevents crash from missing icon
			if(!Paths.fileExists('images/' + xmlPath + '.xml', IMAGE)) xmlPath = 'icons/face'; //Prevents crash from missing icon

			if (Paths.fileExists(xmlPath, xmlContent)){
            	trace("XML file exists: " + xmlPath);
				var xmlContent = sys.io.File.getContent(xmlPath);
				var xml = Xml.parse(xmlContent);
				animation.addByPrefix('neutral', 'Neutral', 12, true, isPlayer);
				animation.addByPrefix('defeat', 'Defeat', 12, true, isPlayer);
				animation.addByPrefix('winning', 'Winning', 12, true, isPlayer);
				animation.play('neutral');
			}
					
			var graphic = Paths.image(name);
			var iSize:Float = Math.round(graphic.width / graphic.height);
			loadGraphic(graphic, true, Math.floor(graphic.width / iSize), Math.floor(graphic.height));
			iconOffsets[0] = (width - 150) / iSize;
			iconOffsets[1] = (height - 150) / iSize;
			updateHitbox();
		
			animation.add(char, [for(i in 0...frames.frames.length) i], 0, false, isPlayer);
			animation.play(char);
			this.char = char;
		}
	}

	override function updateHitbox()
	{
		super.updateHitbox();
		offset.x = iconOffsets[0];
		offset.y = iconOffsets[1];
	}

	public function getCharacter():String {
		return char;
	}
}
