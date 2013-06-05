package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	import starling.display.Stage;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class DrawLayer extends starling.display.Sprite
	{
		private var _last_x:Number;
		private var _last_y:Number;
		private var _strokes:Array;
		private var _cur_stroke:Array;
		private var nBox:Sprite = new Sprite();
		private var _bitmap:Bitmap;
		public var scrollRect:Rectangle;
		
		public function DrawLayer():void
		{
			_strokes = new Array();
			_bitmap = new Bitmap();
			// Setup background, etc
			clear();
			
			// Mouse and single-touch point are equivalent
//			this.addEventListener(MouseEvent.MOUSE_DOWN, handle_start_stroke);
			this.addEventListener(TouchPhase.BEGAN, handle_start_stroke);
		}
		
//		private function handle_start_stroke(e:MouseEvent):void
		private function handle_start_stroke(touchEvent:TouchEvent):void
		{
//			_last_x = this.mouseX;
			var touch:Touch = touchEvent.getTouch(this);
			_last_x = touch.globalX;
//			_last_y = this.mouseY;
			_last_y = touch.globalY;
			_cur_stroke = new Array();
//			handle_move(e);
			handle_move(touchEvent);
			
			this.stage.addEventListener(MouseEvent.MOUSE_UP, handle_end_stroke);
			this.addEventListener(MouseEvent.MOUSE_MOVE, handle_move);
		}
		
		private function handle_end_stroke(e:MouseEvent):void
		{
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, handle_end_stroke);
			this.removeEventListener(MouseEvent.MOUSE_MOVE, handle_move);
			_strokes.push(_cur_stroke);
		}
		
//		private function handle_move(e:MouseEvent):void
		private function handle_move(touchEvent:TouchEvent):void
		{
			var curX:Number = touchEvent.getTouch(this).globalX;
			var curY:Number = touchEvent.getTouch(this).globalY;
			// Store point x, y, t
//			_cur_stroke.push(this.mouseX);
//			_cur_stroke.push(this.mouseY);
//			_cur_stroke.push((new Date()).getTime());
			_cur_stroke.push(curX);
			_cur_stroke.push(curY);
			_cur_stroke.push((new Date()).getTime());
			
			// Draw simple linear path (could be improved)
			// this.graphics.moveTo(_last_x, _last_y);
			// this.graphics.lineTo(this.mouseX, this.mouseY);
			nBox.graphics.moveTo(_last_x, _last_y);
			nBox.graphics.lineTo(curX, curY);
			
			//_last_x = this.mouseX;
			//_last_y = this.mouseY;
			_last_x = curX;
			_last_y = curY;
		}
		
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
		
		public function get strokes():Array
		{
			return _strokes;
		}
		
		public function get bitmap():BitmapData
		{
			var bd:BitmapData = new BitmapData(Const.WIDTH,Const.HEIGHT, false, 0xffffff);
			bd.draw(this);
			return bd;
		}
		
		public function set bitmap(bmp:BitmapData)
		{
			this.graphics.beginBitmapFill(bmp);
			_bitmap = new Bitmap(bmp);
			addChild(_bitmap);
		}
		
	}
}
