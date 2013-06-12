package
{
	
	import flash.display.Sprite;
	import flash.utils.setTimeout;
	
	import feathers.controls.ScreenNavigator;
	import feathers.controls.ScreenNavigatorItem;
	
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
		public var navigator:ScreenNavigator;
		private static const SPLASH_SCREEN:String = "splashScreen";
		private static const CANVAS:String = "canvas";
		
		public function Main():void
		{

			this.stage.color = 0xf2f2f2;
			var star:Starling = new Starling(SplashScreen, stage);
			
			star.start();
			
			this.navigator = new ScreenNavigator();
//			star.addChild(this.navigator);
			star.stage.addChild(this.navigator);
			this.navigator.addScreen(SPLASH_SCREEN, new ScreenNavigatorItem(SplashScreen));
			this.navigator.showScreen(SPLASH_SCREEN);
			var splashScreen:SplashScreen = SplashScreen(navigator.activeScreen);
			navigator.addScreen(CANVAS, new ScreenNavigatorItem(MainDisplay));
			
			setTimeout(function addCanvasScreen():void {navigator.showScreen(CANVAS)}, 5000, 1);
			
		}
	}
}
