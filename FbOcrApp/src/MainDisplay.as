package
{
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;
	
	import feathers.controls.Button;
	import feathers.controls.Callout;
	import feathers.controls.Label;
	import feathers.controls.ScreenNavigator;
	import feathers.controls.ScreenNavigatorItem;
	import feathers.themes.MetalWorksMobileTheme;
	
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.utils.Color;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	public class MainDisplay extends Sprite
	{
		public static var draw_layer:DrawLayer;
		private var _server_comm:ServerComm;
		public static var status:TextField;
		private var theme:MetalWorksMobileTheme;
		
		private static const buttonWidth:Number = 75;
		private static const buttonHeight:Number = 50;
		private static const SPLASH_SCREEN:String = "splashScreen";
		private static const CANVAS:String = "canvas";
		
		private var clearButton:Button;
		private var loadButton:Button;
		private var sendButton:Button;
		public var navigator:ScreenNavigator;
		
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
			_server_comm = new ServerComm("localhost", this);
			draw_layer = new DrawLayer();
			draw_layer.scrollRect = new Rectangle(0,0,Const.WIDTH,Const.HEIGHT);
			Starling.current.nativeStage.addChild(draw_layer);
			draw_layer.x = draw_layer.y = 20;

			add_buttons();
			add_labels();
			
			status = new TextField(Const.WIDTH, 400, "Canvas not sent: ", "Verdana", 25, Color.WHITE);
			status.y = draw_layer.x + draw_layer.height + buttonHeight + 2;
			status.x = draw_layer.x;
			status.hAlign = HAlign.LEFT;
			status.vAlign = VAlign.TOP;
			addChild(status);
		}
		
		private function add_buttons():void 
		{
			sendButton = new Button();
			sendButton.width = buttonWidth;
			sendButton.height = buttonHeight;
			sendButton.x = draw_layer.x + Const.WIDTH - buttonWidth;
			sendButton.y = draw_layer.y + Const.HEIGHT + 2;
			sendButton.addEventListener(Event.TRIGGERED, handle_send);
			addChild(sendButton);

			clearButton = new Button();
			clearButton.width = buttonWidth;
			clearButton.height = buttonHeight;
			clearButton.x = draw_layer.x;
			clearButton.y = draw_layer.y + Const.HEIGHT + 2;
			clearButton.addEventListener(Event.TRIGGERED, handle_clear);
			addChild(clearButton);
//			
//			loadButton = new Button();
//			loadButton.width = buttonWidth;
//			loadButton.height = buttonHeight;
//			loadButton.x = draw_layer.x + Const.WIDTH/2 - buttonWidth/2;
//			loadButton.y = draw_layer.y + Const.HEIGHT + 2;
//			loadButton.addEventListener(Event.TRIGGERED, handle_load);
//			addChild(loadButton);
		}
		
		private function add_labels():void
		{
			var sendButtonLabel:TextField = new TextField(buttonWidth, buttonHeight, "Send", "Verdana", 16, Color.BLACK);
			sendButtonLabel.text = "Send";
			sendButtonLabel.touchable = false;
			sendButtonLabel.border = true;
			sendButtonLabel.x = draw_layer.x + Const.WIDTH - buttonWidth;
			sendButtonLabel.y = draw_layer.y + Const.HEIGHT + 2;
			addChild(sendButtonLabel);
			

			var clearButtonLabel:TextField = new TextField(buttonWidth, buttonHeight, "Clear", "Verdana", 16, Color.BLACK);
			clearButtonLabel.text = "Clear";
			clearButtonLabel.touchable = false;
			clearButtonLabel.border = true;
			clearButtonLabel.x = draw_layer.x;
			clearButtonLabel.y = draw_layer.y + Const.HEIGHT + 2;
			addChild(clearButtonLabel);
			

//			var loadButtonLabel:TextField = new TextField(buttonWidth, buttonHeight, "Load", "Verdana", 16, Color.BLACK);
//			loadButtonLabel.text = "Load";
//			loadButtonLabel.touchable = false;
//			loadButtonLabel.border = true;
//			loadButtonLabel.x = draw_layer.x + Const.WIDTH/2 - buttonWidth/2;
//			loadButtonLabel.y = draw_layer.y + Const.HEIGHT + 2;
//			addChild(loadButtonLabel);
		}
		
		private function button_test(e:Event):void
		{
			const label:Label = new Label();
			label.text = "Hi it's a test";
			log("Popout!");
			Callout.show(label, loadButton);
		}
		
		private function handle_send(e:Event):void
		{
			log("send");
			_server_comm.send_data(draw_layer.bitmap,
				draw_layer.strokes);
		}
		
		private function handle_clear(e:Event):void
		{
			log("clear");
			draw_layer.clear();
		}
		
//		private function handle_load(e:Event):void
//		{
//			log("load");
//			_server_comm.load_data();
//		}


	}
}