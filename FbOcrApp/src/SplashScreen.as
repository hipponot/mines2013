package
{
	import flash.utils.setTimeout;
	
	import feathers.controls.Screen;
	import feathers.controls.ScreenNavigator;
	import feathers.controls.ScreenNavigatorItem;
	
	public class SplashScreen extends Screen
	{
		private static const CANVAS:String = "canvas";
		private var navigator:ScreenNavigator;
		
		public function SplashScreen()
		{
			super();
//			navigator = nav;
//			setTimeout(addCanvasScreen, 2000, 1);
		}
		
		private function addCanvasScreen():void 
		{
			navigator.addScreen(CANVAS, new ScreenNavigatorItem(MainDisplay));
		}
	}
}