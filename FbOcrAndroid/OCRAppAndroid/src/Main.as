package
{
	
	import flash.display.Sprite;
	import flash.utils.setTimeout;
	
	import feathers.controls.ScreenNavigator;
	import feathers.controls.ScreenNavigatorItem;
	
	import starling.core.Starling;

//	-source-path="C:/Program Files (x86)/FlashDevelop/Tools/flexsdk/frameworks/locale/{locale}" -keep-all-type-selectors=true
	[SWF(width="920", height="1000", frameRate="60", backgroundColor="#002143")]
	public class Main extends Sprite
	{
		public var navigator:ScreenNavigator;

		private static const SPLASH_SCREEN:String = "splashScreen";
		private static const CANVAS:String = "canvas";
		public static var star:Starling;
		
		/*
			Starts up the application with a splash screen
			which shows a simple title and background
			for a few seconds before moving onto the drawing
			canvas.
		*/ 
		public function Main():void
		{
			this.stage.color = 0x2f2f2f;
			star = new Starling(SplashScreen, stage);
			star.start();
			
			this.navigator = new ScreenNavigator();
			star.stage.addChild(this.navigator);
			this.navigator.addScreen(SPLASH_SCREEN, new ScreenNavigatorItem(SplashScreen));
			navigator.addScreen(CANVAS, new ScreenNavigatorItem(MainDisplay));

			this.navigator.showScreen(SPLASH_SCREEN);
						
			setTimeout(function addCanvasScreen():void {navigator.showScreen(CANVAS)}, 1000, 1);
		}
	}
}
