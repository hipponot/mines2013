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
	import flash.events.ProgressEvent;
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
			log("Loader data length is: " + _response_body.length);
			decode_data(_response_body);
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
			log("Png bytes length: " + png_bytes.length);
			var encoder:Base64Encoder = new Base64Encoder();
			encoder.encodeBytes(png_bytes);
			var encodedBytes:String = encoder.toString();
						
			// Encode strokes as JSON
			var strokes_json:String = JSON.stringify(strokes);
			
			log("Sending " + encodedBytes.length + " encoded bmp bytes...");
			log("Sending " + strokes_json.length + " strokes bytes");
			
			Main.status.text = "Send " + encodedBytes.length + ", response=???";
			
			var url_request:URLRequest = new URLRequest();
			var url_params:URLVariables = new URLVariables();
			url_params.bmp = encodedBytes;
			url_params.json = strokes_json
			url_request.url = "http://localhost:9393/ocr";
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
			
			Main.status.text = "Information sent: " + png_bytes.length + " : "+ strokes_json.length; 
		}
		
		public function load_data():void
		{
			var url_request:URLRequest = new URLRequest();
			url_request.url = "http://localhost:9393/request_bmp";
			url_request.method = URLRequestMethod.GET;
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, retrieveDataSuccessHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.load(url_request);
		}
		
		private function decode_data(response:String):void
		{
			//Base64Decoder class in mx.utils is completely broken. 
			//I found a better class here https://code.google.com/p/as3yaml/source/browse/trunk/AS3YAML/src/mx/utils/Base64Decoder.as?spec=svn30&r=30
			log("Response length " + response.length);
			var decoder:Base64DecoderNew = new Base64DecoderNew();
			decoder.decode(response);
			var _decoded_body:ByteArray = decoder.drain();
			_decoded_body.position = 0;
			log("Decoded body length: " + _decoded_body.length);
			
			
			var imgLoader:Loader = new Loader();
			imgLoader.loadBytes(_decoded_body);
			imgLoader.content is BitmapData;
			imgLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgressStatus);
			imgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderReady);

			
			
//			var vBitmapDataToRead:BitmapData = new BitmapData(Const.WIDTH, Const.HEIGHT, false, 0xffffff);
//			vBitmapDataToRead.setPixels(vBitmapDataToRead.rect, _decoded_body);
//			var bitmap:Bitmap = new Bitmap(vBitmapDataToRead);
//			super.addChild(bitmap);
		}
		
		public function onProgressStatus(e:ProgressEvent):void {   
			// this is where progress will be monitored     
			trace(e.bytesLoaded, e.bytesTotal)	; 
		}
		
		public function onLoaderReady(e:Event):void {     
			// the image is now loaded, so let's add it to the display tree!     
			super.addChild(super);
		}
		
	}
}
import flash.events.Event;
import flash.events.HTTPStatusEvent;

