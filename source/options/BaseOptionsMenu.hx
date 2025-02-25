package options;

import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxUIInputText;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;

using StringTools;
// search bars

class BaseOptionsMenu extends FlxSubState
{
	private var curOption:Option = null;
	private var curSelected:Int = 0;
	private var optionsArray:Array<Option>;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var checkboxGroup:FlxTypedGroup<CheckboxThingie>;
	private var grpTexts:FlxTypedGroup<AttachedText>;

	private var descBox:FlxSprite;
	private var descText:FlxText;

	var optionSearchText:FlxUIInputText;
	var searchText:FlxText;

	public var title:String;
	public var rpcTitle:String;

	public function new()
	{
		super();

		if (title == null)
			title = 'Options';
		if (rpcTitle == null)
			rpcTitle = 'Options Menu';
			var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
			bg.color = 0xFFea71fd;
			bg.screenCenter();
			bg.updateHitbox();
			add(bg);

			var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
			grid.velocity.set(20, 20);
			grid.alpha = 0;
			FlxTween.tween(grid, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
			add(grid);

		// avoids lagspikes while scrolling through menus!
		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		grpTexts = new FlxTypedGroup<AttachedText>();
		add(grpTexts);

		checkboxGroup = new FlxTypedGroup<CheckboxThingie>();
		add(checkboxGroup);

		descBox = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		descBox.alpha = 0.6;
		add(descBox);

		var titleText:Alphabet = new Alphabet(75, 40, title, true);
		titleText.scaleX = 0.6;
		titleText.scaleY = 0.6;
		titleText.alpha = 0.4;
		add(titleText);

		descText = new FlxText(50, 600, 1180, "", 32);
		descText.setFormat(Paths.font("funkin.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);

		for (i in 0...optionsArray.length)
		{
			var optionText:Alphabet = new Alphabet(290, 260, optionsArray[i].name, false);
			optionText.isMenuItem = true;
			/*optionText.forceX = 300;
				optionText.yMult = 90; */
			optionText.targetY = i;
			optionText.color = 0xFFFFFFFF;
			grpOptions.add(optionText);

			if (optionsArray[i].type == 'bool')
			{
				var checkbox:CheckboxThingie = new CheckboxThingie(optionText.x - 105, optionText.y, optionsArray[i].getValue() == true);
				checkbox.sprTracker = optionText;
				checkbox.ID = i;
				checkboxGroup.add(checkbox);
			}
			else
			{
				optionText.x -= 80;
				optionText.startPosition.x -= 80;
				// optionText.xAdd -= 80;
				var valueText:AttachedText = new AttachedText('' + optionsArray[i].getValue(), optionText.width + 80);
				valueText.sprTracker = optionText;
				valueText.copyAlpha = true;
				valueText.ID = i;
				grpTexts.add(valueText);
				optionsArray[i].setChild(valueText);
			}
			// optionText.snapToPosition(); //Don't ignore me when i ask for not making a fucking pull request to uncomment this line ok
			updateTextFrom(optionsArray[i]);
		}

		changeSelection();
		reloadCheckboxes();

		originalOptionsArray = optionsArray.copy();

		optionSearchText = new FlxUIInputText(0, 0, 500, '', 16);
		optionSearchText.x = FlxG.width - optionSearchText.width;
		add(optionSearchText);

		optionSearchText = new FlxUIInputText(0, 0, 500, '', 16);
		optionSearchText.x = FlxG.width - optionSearchText.width;
		add(optionSearchText);

		var buttonTop:FlxButton = new FlxButton(0, optionSearchText.y + optionSearchText.height + 5, "", function()
		{
			optionsSearch(optionSearchText.text);
		});
		buttonTop.setGraphicSize(Std.int(optionSearchText.width), 50);
		buttonTop.updateHitbox();
		buttonTop.label.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.BLACK, RIGHT);
		buttonTop.x = FlxG.width - buttonTop.width;
		add(buttonTop);

		searchText = new FlxText(975, buttonTop.y + 20, 100, "Search", 24);
		searchText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.BLACK);
		add(searchText);
		FlxG.mouse.visible = true;
	}

	public function addOption(option:Option)
	{
		if (optionsArray == null || optionsArray.length < 1)
			optionsArray = [];
		optionsArray.push(option);
	}

	var originalOptionsArray:Array<Option> = [];
	var optionsFound:Array<Option> = [];

	function optionsSearch(?query:String = '')
	{
		optionsFound = [];
		var foundOptions:Int = 0;
		final txt:FlxText = new FlxText(0, 0, 0, 'No options found matching your query', 16);
		txt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		txt.scrollFactor.set();
		txt.screenCenter(XY);
		for (i in 0...originalOptionsArray.length)
		{
			if (query != null && query.length > 0)
			{
				var optionName = originalOptionsArray[i].name.toLowerCase();
				var q = query.toLowerCase();
				if (optionName.indexOf(q) != -1)
				{
					optionsFound.push(originalOptionsArray[i]);
					foundOptions++;
				}
			}
		}
		if (foundOptions > 0 || query.length <= 0)
		{
			if (txt != null)
				remove(txt); // don't do destroy/kill on this btw
			regenerateOptions(query);
		}
		else if (foundOptions <= 0)
		{
			add(txt);
			new FlxTimer().start(3, function(timer)
			{
				if (txt != null)
					remove(txt);
			});
			return;
		}
	}

	function regenerateOptions(?query:String = '')
	{
		if (query.length > 0)
			optionsArray = optionsFound;
		else if (optionsArray != originalOptionsArray)
			optionsArray = originalOptionsArray.copy();
		regenList();
	}

	function regenList()
	{
		grpOptions.forEach(option ->
		{
			grpOptions.remove(option, true);
			option.destroy();
		});
		grpTexts.forEach(text ->
		{
			grpTexts.remove(text, true);
			text.destroy();
		});
		checkboxGroup.forEach(check ->
		{
			checkboxGroup.remove(check, true);
			check.destroy();
		});

		// we clear the remaining ones
		grpOptions.clear();
		grpTexts.clear();
		checkboxGroup.clear();

		for (i in 0...optionsArray.length)
		{
			var optionText:Alphabet = new Alphabet(290, 260, optionsArray[i].name, false);
			optionText.isMenuItem = true;
			/*optionText.forceX = 300;
				optionText.yMult = 90; */
			optionText.targetY = i;
			grpOptions.add(optionText);

			if (optionsArray[i].type == 'bool')
			{
				var checkbox:CheckboxThingie = new CheckboxThingie(optionText.x - 105, optionText.y, optionsArray[i].getValue() == true);
				checkbox.sprTracker = optionText;
				checkbox.ID = i;
				checkboxGroup.add(checkbox);
			}
			else if (optionsArray[i].type != 'link')
			{
				optionText.x -= 80;
				optionText.startPosition.x -= 80;
				// optionText.xAdd -= 80;
				var valueText:AttachedText = new AttachedText('' + optionsArray[i].getValue(), optionText.width + 80);
				valueText.sprTracker = optionText;
				valueText.copyAlpha = true;
				valueText.ID = i;
				grpTexts.add(valueText);
				optionsArray[i].setChild(valueText);
			}
			// optionText.snapToPosition(); //Don't ignore me when i ask for not making a fucking pull request to uncomment this line ok
			updateTextFrom(optionsArray[i]);
		}

		changeSelection();
		reloadCheckboxes();
	}

	var nextAccept:Int = 5;
	var holdTime:Float = 0;
	var holdValue:Float = 0;

	override function update(elapsed:Float)
	{
		var shiftMult:Int = 1;
		if (!optionSearchText.hasFocus)
		{
			if (FlxG.keys.justPressed.UP)
			{
				changeSelection(-1);
			}
			if (FlxG.keys.justPressed.DOWN)
			{
				changeSelection(1);
			}

			if (FlxG.keys.justPressed.ESCAPE)
			{
				close();
				FlxG.sound.play(Paths.sound('confirm'));
			}

			if (nextAccept <= 0)
			{
				var usesCheckbox = true;
				if (curOption.type != 'bool')
				{
					usesCheckbox = false;
				}

				if (usesCheckbox)
				{
					if (FlxG.keys.justPressed.ENTER)
					{
						FlxG.sound.play(Paths.sound('scroll'));
						curOption.setValue((curOption.getValue() == true) ? false : true);
						curOption.change();
						reloadCheckboxes();
					}
				}
				else
				{
					if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.RIGHT)
					{
						if (FlxG.keys.pressed.SHIFT)
							shiftMult = 10;

						var pressed = (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.RIGHT);
						if (holdTime > 0.5 || pressed)
						{
							if (pressed)
							{
								var add:Dynamic = null;
								if (curOption.type != 'string')
								{
									add = FlxG.keys.justPressed.LEFT ? shiftMult * -curOption.changeValue : shiftMult * curOption.changeValue;
								}

								switch (curOption.type)
								{
									case 'int' | 'float' | 'percent':
										holdValue = curOption.getValue() + add;
										if (holdValue < curOption.minValue)
											holdValue = curOption.minValue;
										else if (holdValue > curOption.maxValue)
											holdValue = curOption.maxValue;

										switch (curOption.type)
										{
											case 'int':
												holdValue = Math.round(holdValue);
												curOption.setValue(holdValue);

											case 'float' | 'percent':
												holdValue = FlxMath.roundDecimal(holdValue, curOption.decimals);
												curOption.setValue(holdValue);
										}

									case 'string':
										var num:Int = curOption.curOption; // lol
										if (FlxG.keys.justPressed.LEFT)
											--num;
										else
											num++;

										if (num < 0)
										{
											num = curOption.options.length - 1;
										}
										else if (num >= curOption.options.length)
										{
											num = 0;
										}

										curOption.curOption = num;
										curOption.setValue(curOption.options[num]); // lol
										// trace(curOption.options[num]);
								}
								updateTextFrom(curOption);
								curOption.change();
								FlxG.sound.play(Paths.sound('scroll'));
							}
							else if (curOption.type != 'string')
							{
								holdValue += curOption.scrollSpeed * elapsed * (FlxG.keys.justPressed.LEFT ? -1 : 1);
								if (holdValue < curOption.minValue)
									holdValue = curOption.minValue;
								else if (holdValue > curOption.maxValue)
									holdValue = curOption.maxValue;

								switch (curOption.type)
								{
									case 'int':
										curOption.setValue(Math.round(holdValue));

									case 'float' | 'percent':
										curOption.setValue(FlxMath.roundDecimal(holdValue, curOption.decimals));
								}
								updateTextFrom(curOption);
								curOption.change();
							}
						}

						if (curOption.type != 'string')
						{
							holdTime += elapsed;
						}
					}
					else if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.RIGHT)
					{
						clearHold();
					}
				}

				if (FlxG.keys.justPressed.R)
				{
					for (i in 0...optionsArray.length)
					{
						var leOption:Option = optionsArray[i];
						leOption.setValue(leOption.defaultValue);
						if (leOption.type != 'bool')
						{
							if (leOption.type == 'string')
							{
								leOption.curOption = leOption.options.indexOf(leOption.getValue());
							}
							updateTextFrom(leOption);
						}
						leOption.change();
					}
					FlxG.sound.play(Paths.sound('confirm'));
					reloadCheckboxes();
				}
			}
		}

		if (nextAccept > 0)
		{
			nextAccept -= 1;
		}
		super.update(elapsed);
	}

	function updateTextFrom(option:Option)
	{
		var text:String = option.displayFormat;
		var val:Dynamic = option.getValue();
		if (option.type == 'percent')
			val *= 100;
		var def:Dynamic = option.defaultValue;
		option.text = text.replace('%v', val).replace('%d', def);
	}

	function clearHold()
	{
		if (holdTime > 0.5)
		{
			FlxG.sound.play(Paths.sound('scroll'));
		}
		holdTime = 0;
	}

	function changeSelection(change:Int = 0)
	{
		curSelected += change;
		if (curSelected < 0)
			curSelected = optionsArray.length - 1;
		if (curSelected >= optionsArray.length)
			curSelected = 0;

		descText.text = optionsArray[curSelected].description;
		descText.screenCenter(Y);
		descText.y += 270;

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			item.targetX = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}
		for (text in grpTexts)
		{
			text.alpha = 0.6;
			if (text.ID == curSelected)
			{
				text.alpha = 1;
			}
		}

		descBox.setPosition(descText.x - 10, descText.y - 10);
		descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
		descBox.updateHitbox();
		curOption = optionsArray[curSelected]; // shorter lol
		FlxG.sound.play(Paths.sound('scroll'));
	}

	function reloadCheckboxes()
	{
		for (checkbox in checkboxGroup)
		{
			checkbox.daValue = (optionsArray[checkbox.ID].getValue() == true);
		}
	}
}
