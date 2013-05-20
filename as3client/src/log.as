package
{
  import flash.system.Capabilities;
  import flash.external.ExternalInterface;

  public function log(msg:String):void
  {
    // Trace to Flash log
    trace(msg);

    // In browser, output to javascript console
    if (Capabilities.playerType=="PlugIn") {
      try {
        if (!statix.init) {
          statix.init = true;
          ExternalInterface.call("eval", "window.trace = function(msg) { console.log(msg) }");
        }
        ExternalInterface.call("trace", msg);
      } catch (e:Error) {
        trace("JS Caught: "+e);
      }
    }
  }
}

class statix
{
  public static var init:Boolean = false;
}
