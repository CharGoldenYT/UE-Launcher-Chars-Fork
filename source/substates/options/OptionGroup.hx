package substates.options;

import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

class OptionGroup extends FlxTypedGroup<MenuSetting>
{
	private var index:Int = 0;

	public var curSelected_Y:Float = 0;

	public function new(MaxSize:Int = 0)
	{
		super(MaxSize);
	}

	public function add_checkbox(x:Float, y:Float, defaultValue:Bool, onChange:Null<Bool->Bool>, settingName:String, settingDesc:String)
	{
		var checkbox:MenuSetting = new MenuSetting(x, y, settingName, settingDesc);
		checkbox.create_checkbox(defaultValue, onChange);
		add(checkbox);
	}

	public function add_numOption(x:Float, y:Float, defaultValue:Float, min:Float, max:Float, step:Float, precision:Int, onChange:Null<Float->Float>,
			valueFormatter:Null<Float->String>, settingName:String, settingDesc:String, slow:Bool = false)
	{
		var numoption:MenuSetting = new MenuSetting(x, y, settingName, settingDesc);
		numoption.create_numOption(defaultValue, min, max, step, precision, onChange, valueFormatter, slow);
		add(numoption);
	}

	private function set_index(value:Int):Int
	{
		index = value;
		// trace(index);
		if (index < 0)
			index = members.length - 1;
		if (index > members.length - 1)
			index = 0;

		// trace(index);
		for (i in 0...members.length)
		{
			if (i == index)
			{
				members[i].name.color = 0xFFE600;
				members[i].alpha = 1;
			}
			if (i != index)
			{
				members[i].name.color = 0xFFFFFF;
				members[i].alpha = 0.4;
			}
		}
		return index;
	}

	public function change_index(change:Int, camFollow:Null<FlxObject> = null):Int
	{
		set_index(index + change);
		if (camFollow != null)
		{
			camFollow.y = members[index].y;
		}
		return index;
	}

	public function set_currentValue(value:Bool)
	{
		return this.members[index].set_currentValue(value);
	}

	public function get_currentValue():Dynamic
	{
		return this.members[index].get_currentValue();
	}
}

class MenuSetting extends FlxTypedSpriteGroup<Dynamic>
{
	public var checkbox:Null<Checkbox>;
	public var numOption:Null<NumOption>;

	public var name:FlxText;
	public var desc:String;

	public var type:String;

	public function new(x:Float, y:Float, settingName:String, desc:String)
	{
		super(x, y, 0);

		this.desc = desc;

		name = new FlxText(120, 25, 0, settingName, 30);
		name.setFormat(Paths.font('naname_goma.ttf'), 30, 0xFFFFFFFF, LEFT, OUTLINE, 0xFF000000);
		add(name);
	}

	public function create_checkbox(defaultValue:Bool, onChange:Null<Bool->Bool>)
	{
		type = 'checkbox';
		checkbox = new Checkbox(0, 0, defaultValue, onChange);
		add(checkbox);
	}

	public function create_numOption(defaultValue:Float, min:Float, max:Float, step:Float, precision:Int, onChange:Null<Float->Float> = null,
			valueFormatter:Null<Float->String> = null, slow:Bool = false)
	{
		type = 'number';
		numOption = new NumOption(0, 25, defaultValue, min, max, step, precision, onChange, valueFormatter, slow);
		add(numOption);
	}

	public function set_currentValue(value:Bool):Bool
	{
		return checkbox.set_currentValue(value);
	}

	public function get_currentValue():Dynamic
	{
		switch (type)
		{
			default:
				return checkbox.currentValue;
			case 'number':
				return numOption.currentValue;
		}
	}
}
