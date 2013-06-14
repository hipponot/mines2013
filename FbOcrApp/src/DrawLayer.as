package
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.display.Bitmap;
	
	public class DrawLayer extends Sprite
	{
		private var _last_x:Number;
		private var _last_y:Number;
		private var _strokes:Array;
		private var _cur_stroke:Array;
		private var _bitmap:Bitmap;
		
		public function DrawLayer():void
		{
			_strokes = new Array();
			_bitmap = new Bitmap();
			// Setup background, etc
			clear();
			
			// Mouse and single-touch point are equivalent
			this.addEventListener(MouseEvent.MOUSE_DOWN, handle_start_stroke);
		}
	
		/*Where the stroke data begins to be gathered,
			current stroke being stored in an array
			before moving on to handling in handle_move().
		*/
		private function handle_start_stroke(e:MouseEvent):void
		{
			_last_x = this.mouseX;
			_last_y = this.mouseY;
			_cur_stroke = new Array();
			handle_move(e);
			
			this.stage.addEventListener(MouseEvent.MOUSE_UP, handle_end_stroke);
			this.addEventListener(MouseEvent.MOUSE_MOVE, handle_move);
		}
		
		/*Where the stroke data stops being gathered,
			the listeners are feed up again, and the
			strokes are pushed to current stroke array.
		*/
		private function handle_end_stroke(e:MouseEvent):void
		{
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, handle_end_stroke);
			this.removeEventListener(MouseEvent.MOUSE_MOVE, handle_move);
			_strokes.push(_cur_stroke);
		}
		
		/*Collects all stroke data between the beginning and
			ending of the stroke, collecting position and
			time of each point within the stroke.
		*/
		private function handle_move(e:MouseEvent):void
		{
			// Store point x, y, t
			_cur_stroke.push(this.mouseX);
			_cur_stroke.push(this.mouseY);
			_cur_stroke.push((new Date()).getTime());
			
			// Draw simple linear path (could be improved)
			this.graphics.moveTo(_last_x, _last_y);
			this.graphics.lineStyle(20);
			this.graphics.lineTo(this.mouseX, this.mouseY);
			
			_last_x = this.mouseX;
			_last_y = this.mouseY;
		}
		
		//Clears any strokes from the canvas
		public function clear():void
		{
			_strokes = [];
			this.graphics.clear();
			
			// Draw solid background (for mouse events)
			this.graphics.beginFill(0xffffff);
			this.graphics.drawRect(0,0,Const.WIDTH,Const.HEIGHT);
			this.graphics.endFill();
			
			// Setup stroke style (const width, color)
			this.graphics.lineStyle(3, 0x222222);
			if (this.contains(_bitmap)) 
			{
				removeChild(_bitmap);
				_bitmap = null;
			}
		}
		
		//Returns any strokes.
		public function get strokes():Array
		{
			return _strokes;
		}
		
		//Returns any bitmap data.
		public function get bitmap():BitmapData
		{
			var bd:BitmapData = new BitmapData(Const.WIDTH,Const.HEIGHT, false, 0xffffff);
			bd.draw(this);
			return bd;
		}
		
		//Sets bitmap data drawn (used for loading).
		public function set bitmap(bmp:BitmapData):void
		{
			this.graphics.beginBitmapFill(bmp);
			_bitmap = new Bitmap(bmp);
			addChild(_bitmap);
		}
		
	}
}