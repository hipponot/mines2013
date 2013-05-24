package
{
	import flash.display.BitmapData;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.navigateToURL;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.events.*;
	import mx.graphics.codec.PNGEncoder;
	import flash.display.PNGEncoderOptions;
	
	public class ServerComm
	{
		private var _host:String;
		private var _response_status:String;
		private var _response_body:String;
		public function ServerComm(host:String):void
		{
			_host = host;      
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void {
			var loader:URLLoader = event.target as URLLoader;
			loader.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, successHandler);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			trace("error here");
		}
		
		private function successHandler(event:Event):void {
			log("this was a success!");
			//trace("Responded ");
			var loader:URLLoader = event.target as URLLoader;
			loader.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, successHandler);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			_response_status = "200";
			_response_body = loader.data;
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
			var png_bytes:ByteArray = new ByteArray();
			bmp.encode(new Rectangle(0,0,bmp.width,bmp.height), new PNGEncoderOptions(true), png_bytes);
			
			//var p:PNGEncoder = new PNGEncoder();
			//var png_bytes:ByteArray = p.encode(bmp);
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
			
			log("Sending " + bytes.length + " bytes...");
			
			Main.status.text = "Send " + bytes.length + ", response=???";
			
			var url_request:URLRequest = new URLRequest();
			url_request.url = "http://localhost:9393/db_update";
			url_request.contentType = "binary/octet-stream";
			url_request.method = URLRequestMethod.POST;
			url_request.data = bytes;
			url_request.requestHeaders.push(
				new URLRequestHeader('Cache-Control', 'no-cache'));
			
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			loader.addEventListener(Event.COMPLETE, successHandler);
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.load(url_request);
			
			Main.status.text = "Information sent: " + bytes.length + " Response was: " + _response_status + " Body was: " + _response_body;
			//navigateToURL(new URLRequest("http://localhost:9393/upload_bitmap"));
		}
		
	}
}
