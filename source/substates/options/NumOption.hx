package substates.options;
// This is literally a direct copy from my game Char's Adventure lmao.

import flixel.math.FlxMath;

/**
 * Makes a FlxText that displays a number (Unless valueFormatter specified.)
 */
 class NumOption extends FlxText
 {
     public var currentValue:Float;
 
     var min:Float;
     var max:Float;
     var step:Float;
     var onChange:Null<Float->Float>;
     var precision:Int = 0;
     var valueFormatter:Null<Float->String>;
 
     public var slow:Bool = false;
 
     public function new(x:Float, y:Float, defaultValue:Float, min:Float, max:Float, step:Float, precision:Int, onChange:Null<Float->Float>,
             valueFormatter:Null<Float->String>, slow:Bool = false)
     {
         super(x, y, 0, Std.string(FlxMath.roundDecimal(defaultValue, precision)), 30);
 
         this.currentValue = defaultValue;
         this.min = min;
         this.max = max;
         this.step = step;
         this.precision = precision;
         this.onChange = onChange;
         this.valueFormatter = valueFormatter;
         this.slow = slow;
         setFormat(Paths.font('naname_goma.ttf'), 30, 0xFFFFFFFF, null, OUTLINE, 0xFF000000);
         update_text();
     }
 
     public function do_step(change:Int = 1):Float
     {
         if (change == 1)
         {
             if (currentValue + step > max)
             {
                 return currentValue;
             }
             else
             {
                 currentValue += step;
                 update_text();
             }
         }
         else if (change == -1)
         {
             if (currentValue - step < min)
             {
                 return currentValue;
             }
             else
             {
                 currentValue -= step;
                 update_text();
             }
         }
         onChange(currentValue);
         return currentValue;
     }
 
     public function update_text()
     {
         if (valueFormatter == null)
             text = Std.string(FlxMath.roundDecimal(currentValue, precision));
         else
             text = valueFormatter(FlxMath.roundDecimal(currentValue, precision));
     }
 }
 