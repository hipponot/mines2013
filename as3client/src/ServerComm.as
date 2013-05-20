package
{
  import flash.display.BitmapData;
  import flash.display.PNGEncoderOptions;
  import flash.geom.Rectangle;
  import flash.utils.ByteArray;
  import mx.graphics.codec.PNGEncoder;

  public class ServerComm
  {
    private var _host:String;

    public function ServerComm(host:String):void
    {
      _host = host;      
    }

    /**
     * - bmp is a BitmapData object of the rasterized strokes
     * - strokes is an array of arrays.  The outer array is an array
     *   of stroke data.  The stroke data is an array of Numbers
     *   with length divisible by 3:
     *     [ x, y, t, x, y, t, x, y, t ... ]
     */
    public function send_data(bmp:BitmapData,
                              strokes:Array):void
    {
      // Encode bitmapdata as PNG file (requires Flash 11.3+)
      //var png_bytes:ByteArray = new ByteArray();
      //bmp.encode(new Rectangle(0,0,bmp.width,bmp.height), new PNGEncoderOptions(true), png_bytes);

      var p:PNGEncoder = new PNGEncoder();
      var png_bytes:ByteArray = p.encode(bmp);
      log("PNG is "+png_bytes.length+" bytes...");

      // Encode strokes as JSON
      var strokes_json:String = JSON.stringify(strokes);

      log("strokes JSON:");
      log(strokes_json);

      // Send binary bytes: png_length + png_bytes + json string
      // See: http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/utils/ByteArray.html
      var bytes:ByteArray = new ByteArray();
      bytes.endian = "bigEndian";
      bytes.writeInt(png_bytes.length);
      bytes.writeBytes(png_bytes, 0, png_bytes.length);
      bytes.writeMultiByte(strokes_json, "utf-8");

      log("Sending "+bytes.length+" bytes...");

      // TODO: send bytes to _host here, ala:
      // http://stackoverflow.com/questions/8854952/how-to-upload-bitmapdata-to-a-server-actionscript-3/8856655#8856655

      Main.status.text = "Send "+bytes.length+", response=???";
    }
  }
}
