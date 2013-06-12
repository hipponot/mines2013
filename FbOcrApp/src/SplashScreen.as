package
{
	import feathers.controls.Screen;
	import starling.text.TextField;
	import starling.utils.Color;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	public class SplashScreen extends Screen
	{
		private var status:TextField;
		
		public function SplashScreen()
		{
			super();
			
			status = new TextField(Const.WIDTH+200, 400, "A Better Calculator", "Helvetica", 50, Color.WHITE);
			status.y = 50;
			status.x = 50;
			status.hAlign = HAlign.LEFT;
			status.vAlign = VAlign.TOP;
			addChild(status);
		}
	}
}