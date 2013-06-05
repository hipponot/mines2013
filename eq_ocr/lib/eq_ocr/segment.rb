require 'RMagick'
require "base64"


class Segmentation

	include Magick

	def bin_to_bmp bitmap_64
		puts "you got to bin!"
		bin = Base64.decode64(bitmap_64)
		img = Image.from_blob(bin)
		return img[0]
	end
	
	#
	def crop_image min_x, max_x, min_y, max_y, img
		cropped = img.crop(min_x, min_y, max_x - min_x, max_y - min_y, true)
		return cropped
	end

	def get_bounds stroke_data
		#stroke_data = Array(stroke_data).split(/\],\[/)
		#stroke_data.each do |i|
		#	puts i
		#end
		all_bounds = Array.new
		stroke_data.each do |inner_array|
			xvals = Array.new
			yvals = Array.new
			#inner_array = Array(inner_array)#.map {|s| s.to_i}
			inner_array.each_slice(3) do |point|
				puts point[0].is_a? Integer
				xvals.push(point[0])
				yvals.push(point[1])
			end
			#Bounds format: [min_x, max_x, min_y, max_y]
			bounds = Array.new
			bounds << xvals.min << xvals.max << yvals.min << yvals.max
			all_bounds << bounds
		end
		return all_bounds
	end

	#def format stroke_data
	#	stroke_data.each do |stroke|
	#		stroke = Array(stroke)
	#	return stroke_data
	#end
	
	#Accepts a 64bit bitmap encoding and stroke data, and returns an array of bitmaps to be processed by tesseract
	def segment bitmap_64, stroke_data
		#img = Image.new()
		img = bin_to_bmp(bitmap_64)
		#split_json stroke_data
		stroke_data = eval(stroke_data)
		all_bounds = get_bounds stroke_data
		all_bounds.each_with_index do |bounds, index|
			cropped = crop_image(bounds[0], bounds[1], bounds[2], bounds[3], img)
			cropped.write("chop_after#{index}.jpg")
		end
		puts "Done!"
	end

end

