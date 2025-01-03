package substates.pages;

class MainPage extends BaseSettingsSubstate
{
	var bg:FlxSprite;

	override function setupMenu():Void
	{
		bg = new FlxSprite().makeGraphic(Std.int(FlxG.width * 1.5), Std.int(FlxG.height * 1.5), 0xFFFF8800);
		add(bg);
		super.setupMenu();
	}

	override function createOptions():Void
	{
		super.createOptions();
		bg.alpha = 0.5;

		createCheckBox('Mute Sound', 'Whether to keep the sound muted regardless of volume (Acts like pressing 0)', Prefs.muteSound, function(value:Bool):Bool
		{
			return Prefs.muteSound = value;
		});
	}
}