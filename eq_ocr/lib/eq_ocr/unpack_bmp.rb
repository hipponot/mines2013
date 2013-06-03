require "base64"
require "RMagick"

include Magick

class UnpackBmp

	def bin_to_bmp bitmap_64
		
		bin = Base64.decode64(bitmap_64)
		img = Image.new()
    	img.import_pixels(bin)

  	end
end