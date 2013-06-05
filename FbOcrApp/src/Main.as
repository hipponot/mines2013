package
{
	import starling.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import starling.text.TextField;
	import flash.utils.setTimeout;
	
	import mx.charts.BubbleChart;
	
	[SWF(width="1280", height="752", frameRate="60", backgroundColor="#002143")]
	public class Main extends Sprite
	{
		public static var draw_layer:DrawLayer;
		private var _server_comm:ServerComm;
		public static var status:TextField;
		
		public function Main():void
		{
//			this.stage.align = StageAlign.TOP_LEFT;
//			this.stage.scaleMode = StageScaleMode.NO_SCALE;
//			this.stage.frameRate = 30;
			this.stage.color = 0xf2f2f2;
			
			// Some devices take a little time for their stage
			// size to settle
			setTimeout(init, 500);
		}
		
		private function init():void
		{
			_server_comm = new ServerComm("localhost");
			draw_layer = new DrawLayer();
			draw_layer.scrollRect = new Rectangle(0,0,Const.WIDTH,Const.HEIGHT);
			addChild(draw_layer);
			draw_layer.x = draw_layer.y = 20;
			
			
//			var btn:Sprite = new Sprite();
//			var t:TextField = new TextField();
//			t.text = "Send";
//			t.width = 40;
//			t.height = 19;
//			t.scaleX = t.scaleY = 2.5;
//			t.selectable = false;
//			btn.addChild(t);
//			addChild(btn);
//			btn.graphics.beginFill(0xaab2ff);
//			btn.graphics.drawRoundRect(0,0,t.width,t.height,5);
//			btn.x = draw_layer.x + Const.WIDTH - t.width;
//			btn.y = draw_layer.y + Const.HEIGHT + 2;
//			btn.mouseEnabled = true;
//			btn.mouseChildren = false;
//			btn.addEventListener(MouseEvent.MOUSE_DOWN, handle_send);
//			
//			btn = new Sprite();
//			t = new TextField();
//			t.text = "Clear";
//			t.width = 40;
//			t.height = 19;
//			t.scaleX = t.scaleY = 2.5;
//			t.selectable = false;
//			btn.addChild(t);
//			addChild(btn);
//			btn.graphics.beginFill(0xffb2aa);
//			btn.graphics.drawRoundRect(0,0,t.width,t.height,5);
//			btn.x = draw_layer.x;
//			btn.y = draw_layer.y + Const.HEIGHT + 2;
//			btn.mouseEnabled = true;
//			btn.mouseChildren = false;
//			btn.addEventListener(MouseEvent.MOUSE_DOWN, handle_clear);
//			
//			btn = new Sprite();
//			t = new TextField();
//			t.text = "Load";
//			t.width = 40;
//			t.height = 19;
//			t.scaleX = t.scaleY = 2.5;
//			t.selectable = false;
//			btn.addChild(t);
//			addChild(btn);
//			btn.graphics.beginFill(0xaab2ff);
//			btn.graphics.drawRoundRect(0,0,t.width,t.height,5);
//			btn.x = draw_layer.x + Const.WIDTH/2 - t.width/2;
//			btn.y = draw_layer.y + Const.HEIGHT + 2;
//			btn.mouseEnabled = true;
//			btn.mouseChildren = false;
//			btn.addEventListener(MouseEvent.MOUSE_DOWN, handle_load);
			
			status = new TextField(45,10,"...");
			status.width = Const.WIDTH;
//			status.y = btn.y + btn.height;
			addChild(status);
		}
		
		private function handle_send(e:MouseEvent):void
		{
			log("send");
			_server_comm.send_data(draw_layer.bitmap,
				draw_layer.strokes);
		}
		
		private function handle_clear(e:MouseEvent):void
		{
			log("clear");
			draw_layer.clear();
		}
		
		private function handle_load(e:MouseEvent):void
		{
			log("load");
			_server_comm.load_data();
		}
	}
}
