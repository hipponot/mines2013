package
{
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;
	
	import feathers.controls.Button;
	import feathers.controls.Label;
	import feathers.themes.MetalWorksMobileTheme;
	import feathers.controls.Callout;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.events.TouchEvent;
	
	public class MainDisplay extends Sprite
	{
		private var mStarling:Starling;
		public static var draw_layer:DrawLayer;
		private var _server_comm:ServerComm;
		public static var status:TextField;
		private var theme:MetalWorksMobileTheme;
	
		
		private var clearButton:Button;
		
		public function MainDisplay()
		{
			this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			setTimeout(init, 500);
		}
		
		protected function addedToStageHandler(event:Event):void
		{
			this.theme = new MetalWorksMobileTheme(this.stage);
		}
		
		private function init():void
		{
			_server_comm = new ServerComm("localhost");
			draw_layer = new DrawLayer();
			draw_layer.scrollRect = new Rectangle(0,0,Const.WIDTH,Const.HEIGHT);
			Starling.current.nativeStage.addChild(draw_layer);
//			addChild(draw_layer);
			draw_layer.x = draw_layer.y = 20;

			var sendButton:Button = new Button();
			sendButton.label = "Send";
			sendButton.x = draw_layer.x + 20;
			sendButton.width = 75;
			sendButton.height = 75;
			sendButton.y = 150;
			sendButton.addEventListener(TouchPhase.BEGAN, handle_send);
			addChild(sendButton);
//						var btn:Sprite = new Sprite();
//						var t:TextField = new TextField();
//						t.text = "Send";
//						t.width = 40;
//						t.height = 19;
//						t.scaleX = t.scaleY = 2.5;
//						t.selectable = false;
//						btn.addChild(t);
//						addChild(btn);
//						btn.graphics.beginFill(0xaab2ff);
//						btn.graphics.drawRoundRect(0,0,t.width,t.height,5);
//						btn.x = draw_layer.x + Const.WIDTH - t.width;
//						btn.y = draw_layer.y + Const.HEIGHT + 2;
//						btn.mouseEnabled = true;
//						btn.mouseChildren = false;
//						btn.addEventListener(MouseEvent.MOUSE_DOWN, handle_send);
//			var clearButton:Button = new Button();
			clearButton = new Button();
			clearButton.label = "Clear";
			clearButton.x = 300;
			clearButton.y = 150;
			clearButton.width = 75;
			clearButton.height = 75;
//			clearButton.addEventListener(TouchPhase.BEGAN, handle_clear);
			clearButton.addEventListener(TouchPhase.BEGAN , button_test);
			addChild(clearButton);
//						btn = new Sprite();
//						t = new TextField();
//						t.text = "Clear";
//						t.width = 40;
//						t.height = 19;
//						t.scaleX = t.scaleY = 2.5;
//						t.selectable = false;
//						btn.addChild(t);
//						addChild(btn);
//						btn.graphics.beginFill(0xffb2aa);
//						btn.graphics.drawRoundRect(0,0,t.width,t.height,5);
//						btn.x = draw_layer.x;
//						btn.y = draw_layer.y + Const.HEIGHT + 2;
//						btn.mouseEnabled = true;
//						btn.mouseChildren = false;
//						btn.addEventListener(MouseEvent.MOUSE_DOWN, handle_clear);
			var loadButton:Button = new Button();
			loadButton.label = "Load";
			loadButton.x = 400;
			loadButton.y = 150;
			loadButton.width = 75;
			loadButton.height = 75;
			loadButton.addEventListener(TouchPhase.BEGAN, handle_load);
			loadButton.addEventListener(TouchPhase.BEGAN, button_test);
			addChild(loadButton);
//						btn = new Sprite();
//						t = new TextField();
//						t.text = "Load";
//						t.width = 40;
//						t.height = 19;
//						t.scaleX = t.scaleY = 2.5;
//						t.selectable = false;
//						btn.addChild(t);
//						addChild(btn);
//						btn.graphics.beginFill(0xaab2ff);
//						btn.graphics.drawRoundRect(0,0,t.width,t.height,5);
//						btn.x = draw_layer.x + Const.WIDTH/2 - t.width/2;
//						btn.y = draw_layer.y + Const.HEIGHT + 2;
//						btn.mouseEnabled = true;
//						btn.mouseChildren = false;
//						btn.addEventListener(MouseEvent.MOUSE_DOWN, handle_load);
			
			
			status = new TextField(Const.WIDTH,Const.HEIGHT,"...");
			status.width = Const.WIDTH;
			//			status.y = btn.y + btn.height;
			addChild(status);
			log("here");
		}
		
		private function button_test(e:TouchEvent):void
		{
			const label:Label = new Label();
			label.text = "Hi it's a test";
			log("Popout!");
			Callout.show(label, clearButton );
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