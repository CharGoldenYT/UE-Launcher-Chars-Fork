package substates;

import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.FlxSubState;
import substates.options.*;
import substates.options.OptionGroup.MenuSetting;

using StringTools;

/**
 * Base class used to setup all Option substates, with shortcuts to Save.data.<settingName> to save time.
 */
class BaseSettingsSubstate extends FlxSubState
{
	/**
	 * Handles options
	 */
	public var grpOptions:OptionGroup;

	/**
	 * The box that goes behind the description text
	 */
	public var descBox:FlxSprite;

	/**
	 * A seperate camera to keep the description box in view and at a consistent zoom.
	 */
	public var camDesc:FlxCamera;

	/**
	 * A seperate camera to keep the BG in view and at a consistent zoom.
	 */
	public var camBG:FlxCamera;

	/**
	 * A camera that tracks with the options group to keep the current option in view.
	 */
	public var camMenu:FlxCamera;

	/**
	 * Text that displays a description for the current option.
	 */
	public var descText:FlxText;

	/**
	 * A variable to keep track of the currently selected option.
	 */
	public var curSelected:Int = 0;

	var camFollow:FlxObject;

	public function new()
	{
		super();
		setupCams();
		setupMenu();
		createOptions();
		setupDescText();
	}

	function setupCams():Void
	{
		camDesc = new FlxCamera();
		camBG = new FlxCamera();
		camMenu = new FlxCamera();

		camBG.bgColor.alpha = 0;
		camMenu.bgColor.alpha = 0;
		camDesc.bgColor.alpha = 0;

		FlxG.cameras.add(camBG, false);
		FlxG.cameras.add(camMenu, false);
		FlxG.cameras.add(camDesc, false);
	}

	function setupMenu():Void
	{
		grpOptions = new OptionGroup();
		add(grpOptions);
		grpOptions.cameras = [camMenu];

		descBox = new FlxSprite().makeGraphic(10, 10, 0xC2000000);
		add(descBox);
		descBox.cameras = [camDesc];

		descText = new FlxText(0, 0, FlxG.width, 'DEFAULT DESCRIPTION', 20);
		descText.setFormat(Paths.font('naname_goma.ttf'), 20, 0xFFFFFFFF, CENTER, OUTLINE, 0xFF000000);
		descText.borderSize = 3;
		add(descText);
		descText.cameras = [camDesc];

		camFollow = new FlxObject(FlxG.width * 0.5, 0, 10, 10);
		add(camFollow);
	}

	function createOptions():Void
	{
		// Code for creating options here.
	}

	function setupDescText():Void
	{
		if (grpOptions.members.length == 0)
		{
			createBackupOption(); // To prevent crashes!
		}
		if (grpOptions.members.length > 6)
		{
			camMenu.follow(camFollow, LOCKON, 0.06);
		}

		descText.text = grpOptions.members[curSelected].desc;
		descText.y = FlxG.height - (descText.height + 5);
		descBox.setGraphicSize(FlxG.width, descText.height + 10);
		descBox.updateHitbox();
		descBox.y = FlxG.height - descBox.height;
	}

	function createBackupOption():Void
	{
		createCheckBox('NULL', 'NULL', false, null);
	}

	var up:Bool = false;
	var down:Bool = false;
	var left:Bool = false;
	var right:Bool = false;
	var leftPress:Bool = false;
	var rightPress:Bool = false;
	var accept:Bool = false;
	var exit:Bool = false;
	var blockBackspace:Bool = false;

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		up = (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.W);
		down = (FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.S);

		left = (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.A);
		right = (FlxG.keys.pressed.RIGHT || FlxG.keys.pressed.D);
		leftPress = (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A);
		rightPress = (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D);

		accept = (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE);
		exit = (FlxG.keys.justPressed.ESCAPE || (!blockBackspace && FlxG.keys.justPressed.BACKSPACE));

		handleInputs();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected = grpOptions.change_index(change, camFollow);

		descText.text = grpOptions.members[curSelected].desc;
		descText.y = FlxG.height - (descText.height + 5);
		descBox.setGraphicSize(FlxG.width, descText.height + 10);
		descBox.updateHitbox();
		descBox.y = FlxG.height - descBox.height;

		if (grpOptions.members[curSelected].desc.trim() == '')
		{
			descBox.visible = false;
			descText.visible = false;
		}

		//FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	/**
	 * Creates a new checkbox and adds it to the options group.
	 */
	function createCheckBox(name:String, desc:String, defaultValue:Bool, onChange:Null<Bool->Bool>):Void
	{
		/* Old Code \/
			var checkbox:Checkbox = new Checkbox(20, 150 * grpOptions.length, defaultValue, setting);

			var text:FlxText = new FlxText(150, 150 * grpTexts.length, 0, name, 60);
			grpOptions.add(checkbox);
			grpTexts.add(text);
		 */

		grpOptions.add_checkbox(20, 150 * grpOptions.length, defaultValue, onChange, name, desc);
	}

	/**
	 * Creates a number option and adds it to the options group
	 */
	function createNumOption(name:String, desc:String, defaultValue:Float, min:Float, max:Float, step:Float, precision:Int, onChange:Null<Float->Float>,
			valueFormatter:Null<Float->String> = null, slow:Bool = false):Void
	{
		grpOptions.add_numOption(20, 150 * grpOptions.length, defaultValue, min, max, step, precision, onChange, valueFormatter, name, desc, slow);
	}

	function handleInputs():Void
	{
		if (up)
		{
			changeSelection(-1);
		}
		if (down)
		{
			changeSelection(1);
		}

		var curMember:MenuSetting = grpOptions.members[curSelected];
		var checkbox:Null<Checkbox> = curMember.checkbox;
		var num:Null<NumOption> = curMember.numOption;

		if (accept)
		{
			if (grpOptions.members[curSelected].type == 'checkbox')
			{
				//FlxG.sound.play(Paths.sound('accept'));
				checkbox.set_currentValue(!checkbox.currentValue);
			}
		}

		if (left)
		{
			if (grpOptions.members[curSelected].type != 'checkbox')
			{
				if (curMember.type == 'number')
				{
					if (!num.slow)
					{
						//FlxG.sound.play(Paths.sound('scrollMenu'));
						num.do_step(-1);
					}
				}
			}
		}
		if (right)
		{
			if (grpOptions.members[curSelected].type != 'checkbox')
			{
				if (curMember.type == 'number')
				{
					if (!num.slow)
					{
						//FlxG.sound.play(Paths.sound('scrollMenu'));
						num.do_step(1);
					}
				}
			}
		}

		if (leftPress)
		{
			if (curMember.type == 'number')
			{
				if (num.slow)
				{
					//FlxG.sound.play(Paths.sound('scrollMenu'));
					num.do_step(-1);
				}
			}
		}
		if (rightPress)
		{
			if (curMember.type == 'number')
			{
				if (num.slow)
				{
					//FlxG.sound.play(Paths.sound('scrollMenu'));
					num.do_step(1);
				}
			}
		}

		if (exit)
		{
			camFollow.x = FlxG.width * 0.5;
			camFollow.y = FlxG.height * 0.5;
			close();
		}
	}

	override function close():Void
	{
		super.close();

		FlxG.cameras.remove(camBG);
		FlxG.cameras.remove(camMenu);
		FlxG.cameras.remove(camDesc);
	}
}
