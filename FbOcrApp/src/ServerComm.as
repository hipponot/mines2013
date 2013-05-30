package
{
	import com.sociodox.utils.Base64;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.PNGEncoderOptions;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	
	import mx.binding.utils.BindingUtils;
	import mx.utils.Base64Encoder;
	import flash.events.ProgressEvent;
	
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
			loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			loader.removeEventListener(Event.COMPLETE, successHandler);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			trace("error here: " + event.toString());
		}
		
		private function successHandler(event:Event):void {
			var loader:URLLoader = event.target as URLLoader;
			loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			loader.removeEventListener(Event.COMPLETE, successHandler);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			_response_status = "200";
			_response_body = loader.data;
			Main.status.text = " Response was: " + _response_status + " Body was: " + _response_body;
		}
		
		private function httpStatusHandler(event:HTTPStatusEvent):void {
			trace("HTTP status received: " + event.status);
		}
		
		private function retrieveDataSuccessHandler(event:Event):void {
			log("calling success on data retrieval");
			var loader:URLLoader = event.target as URLLoader;
			loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			loader.removeEventListener(Event.COMPLETE, retrieveDataSuccessHandler);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			_response_status = "200";
			_response_body = loader.data;
			decode_data(_response_body);

//			Main.status.text = " Response was: " + _response_status + " Body was: " + _response_body + " Decoded string was: " + _decoded_body;
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
			var encoder:Base64Encoder = new Base64Encoder();
			encoder.encodeBytes(png_bytes);
			var encodedBytes:String = encoder.toString();
			trace("the byte string is: " + encodedBytes);
						
			
//			var p:PNGEncoder = new PNGEncoder();
//			var png_bytes:ByteArray = p.encode(bmp);
			log("PNG is "+png_bytes.length+" bytes...");
			log("JSON is:\n " + strokes_json);
			
			// Encode strokes as JSON
			var strokes_json:String = JSON.stringify(strokes);
			
			log("Sending " + encodedBytes.length + "bmp bytes...");
			log("Sending " + strokes_json.length + " strokes bytes");
			
			Main.status.text = "Send " + encodedBytes.length + ", response=???";
			
			var url_request:URLRequest = new URLRequest();
			var url_params:URLVariables = new URLVariables();
			log("Setting url params {bmp} to: " + encodedBytes );
			url_params.bmp = encodedBytes;
			log("Setting url params {json} to: " + strokes_json);
			url_params.json = strokes_json
			url_request.url = "http://localhost:9393/ocr";
//			url_request.contentType = "application/octet-stream";
			url_request.method = URLRequestMethod.POST;
			
			url_request.data = url_params;
			url_request.requestHeaders.push(
				new URLRequestHeader('Cache-Control', 'no-cache'));
			
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			loader.addEventListener(Event.COMPLETE, successHandler);
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.load(url_request);
			
			
			Main.status.text = "Information sent: " + png_bytes.length + strokes_json.length; 
			//navigateToURL(new URLRequest("http://localhost:9393/upload_bitmap"));
		}
		
		public function load_data():void
		{
			log("here!?!?");
			trace("getting data");
			var url_request:URLRequest = new URLRequest();
			url_request.url = "http://localhost:9393/request_bmp";
			url_request.method = URLRequestMethod.GET;
			var loader:URLLoader = new URLLoader();
			log("adding event listeners and calling request");
			loader.addEventListener(Event.COMPLETE, retrieveDataSuccessHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.load(url_request);
			var imgLoader:Loader = new Loader();
			imgLoader.load(url_request);
			imgLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgressStatus);
			imgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderReady);
		}
		
		private function decode_data(response:String):void
		{
			//Base64Decoder class in mx.utils is completely broken. 
			//I'm using this class here. http://jpauclair.net/2010/01/09/base64-optimized-as3-lib/
			var _decoded_body:ByteArray = Base64.decode(response);
			_decoded_body.position = 0;
			var vBitmapDataToRead:BitmapData = new BitmapData(Const.WIDTH, Const.HEIGHT, false, 0xffffff);
			vBitmapDataToRead.setPixels(vBitmapDataToRead.rect, _decoded_body);
			var bitmap:Bitmap = new Bitmap(vBitmapDataToRead);
			super.addChild(bitmap);
		}
		
		public function onProgressStatus(e:ProgressEvent):void {   
			// this is where progress will be monitored     
			trace(e.bytesLoaded, e.bytesTotal)	; 
		}
		
		public function onLoaderReady(e:Event):void {     
			// the image is now loaded, so let's add it to the display tree!     
			super.addChild();
		}
		
	}
}
import flash.events.Event;
import flash.events.HTTPStatusEvent;

