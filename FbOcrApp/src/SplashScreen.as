package
{
	import feathers.controls.Screen;
//	import feathers.themes.MetalWorksMobileTheme;
	
	import starling.text.TextField;
	import starling.utils.Color;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	public class SplashScreen extends Screen
	{
		private var status:TextField;
//		private var theme:MetalWorksMobileTheme;
		
		public function SplashScreen()
		{
			super();
//			this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			status = new TextField(Const.WIDTH+200, 400, "A Better Calculator", "Helvetica", 50, Color.WHITE);
			status.y = 50;
			status.x = 50;
			status.hAlign = HAlign.LEFT;
			status.vAlign = VAlign.TOP;
			addChild(status);
		}
		
		//can't get this to work at all 
		//we tried with this.stage just like MainDisplay, but it won't work
//		protected function addedToStageHandler(event:Event):void
//		{
//			this.theme = new MetalWorksMobileTheme(Main.star.stage);
//		}
	}
}