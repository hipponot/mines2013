package
{
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;
	import flash.utils.setTimeout;
	
	import feathers.controls.Button;
	import feathers.controls.Callout;
	import feathers.controls.Label;
	import feathers.controls.text.TextFieldTextRenderer;
	import feathers.themes.MetalWorksMobileTheme;
	
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.utils.Color;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	public class MainDisplay extends Sprite
	{
		private var mStarling:Starling;
		public static var draw_layer:DrawLayer;
		private var _server_comm:ServerComm;
		public static var status:TextField;
		private var theme:MetalWorksMobileTheme;
		private static const buttonWidth:Number = 75;
		private static const buttonHeight:Number = 50;
		
		private var clearButton:Button;
		private var loadButton:Button;
		private var sendButton:Button;
		
		
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
			draw_layer.x = draw_layer.y = 20;

//			var sendButton:Button = new (Assets.getTexture("Button1"), "Send");
			sendButton = new Button();
//			sendButton.label = "Send";
			sendButton.width = buttonWidth;
			sendButton.height = buttonHeight;
			sendButton.x = draw_layer.x + Const.WIDTH - buttonWidth;
			sendButton.y = draw_layer.y + Const.HEIGHT + 2;
			sendButton.addEventListener(Event.TRIGGERED, handle_send);
			addChild(sendButton);

			var sendButtonLabel:TextField = new TextField(buttonWidth, buttonHeight, "Send", "Arial", 16, Color.BLACK);
			sendButtonLabel.text = "Send";
			sendButtonLabel.touchable = false;
			sendButtonLabel.border = true;
			sendButtonLabel.x = draw_layer.x + Const.WIDTH - buttonWidth;
			sendButtonLabel.y = draw_layer.y + Const.HEIGHT + 2;
			addChild(sendButtonLabel);
			
			clearButton = new Button();
//			clearButton.label = "Clear";
			clearButton.width = buttonWidth;
			clearButton.height = buttonHeight;
			clearButton.x = draw_layer.x;
			clearButton.y = draw_layer.y + Const.HEIGHT + 2;
			clearButton.addEventListener(Event.TRIGGERED, handle_clear);
			addChild(clearButton);

			var clearButtonLabel:TextField = new TextField(buttonWidth, buttonHeight, "Clear", "Arial", 16, Color.BLACK);
			clearButtonLabel.text = "Clear";
			clearButtonLabel.touchable = false;
			clearButtonLabel.border = true;
			clearButtonLabel.x = draw_layer.x;
			clearButtonLabel.y = draw_layer.y + Const.HEIGHT + 2;
			addChild(clearButtonLabel);
			
			loadButton = new Button();
			// loadButton.label = "";
			// loadButton.scaleX = loadButton.scaleY = 1.5;
			loadButton.width = buttonWidth;
			loadButton.height = buttonHeight;
			loadButton.x = draw_layer.x + Const.WIDTH/2 - buttonWidth/2;
			loadButton.y = draw_layer.y + Const.HEIGHT + 2;
			loadButton.addEventListener(Event.TRIGGERED, handle_load);
			loadButton.addEventListener(Event.TRIGGERED, button_test);
			addChild(loadButton);

			var loadButtonLabel:TextField = new TextField(buttonWidth, buttonHeight, "Load", "Arial", 16, Color.BLACK);
			loadButtonLabel.text = "Load";
			loadButtonLabel.touchable = false;
			loadButtonLabel.border = true;
			loadButtonLabel.x = draw_layer.x + Const.WIDTH/2 - buttonWidth/2;
			loadButtonLabel.y = draw_layer.y + Const.HEIGHT + 2;
			addChild(loadButtonLabel);
			
			status = new TextField(400, 100, "blargh", "Arial", 20, Color.WHITE);
			status.y = draw_layer.x + draw_layer.height + clearButton.height + 2;
			status.x = clearButton.x;
			status.hAlign = HAlign.LEFT;
			status.vAlign = VAlign.TOP;
			addChild(status);
			
			log("here");
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
		
		private function handle_load(e:Event):void
		{
			log("load");
			_server_comm.load_data();
		}


	}
}