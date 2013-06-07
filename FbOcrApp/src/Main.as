package
{
	
	import flash.display.Sprite;
	
	import starling.core.Starling;
	import starling.text.TextField;
//	-source-path="C:/Program Files (x86)/FlashDevelop/Tools/flexsdk/frameworks/locale/{locale}" -keep-all-type-selectors=true
	[SWF(width="1000", height="1000", frameRate="60", backgroundColor="#002143")]
	public class Main extends Sprite
	{
		private var mStarling:Starling;
		public static var draw_layer:DrawLayer;
		private var _server_comm:ServerComm;
		public static var status:TextField;
		
		public function Main():void
		{
			this.stage.color = 0xf2f2f2;
			var star:Starling = new Starling(MainDisplay, stage);
			star.start();
		}
	}
}
