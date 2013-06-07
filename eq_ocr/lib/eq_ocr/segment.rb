require 'RMagick'
require "base64"


class Segmentation

	include Magick

	# Accepts a 64bit bitmap encoding and associated stroke data, and returns an array of bitmaps to be processed by tesseract
	def segment bitmap_64, stroke_data, t
		img = bin_to_bmp(bitmap_64)

		#Convert json from string into 2d array
		stroke_data = eval(stroke_data)

		stroke_data = compress stroke_data

		all_bounds = get_bounds stroke_data

		# Create the array of bitmaps to be returned

		all_bounds.each_with_index do |bounds, index|
			cropped = crop_image(bounds[0], bounds[1], bounds[2], bounds[3], img)
			cropped.write("/tmp/crop#{t}_#{index}.png")
			cropped.write("crop#{t}_#{index}.png")
		end
		puts "Done!"
	end

	# Decodes 64bit encoding of a bitmap and returns an image generated by the binary data
	def bin_to_bmp bitmap_64
		bin = Base64.decode64(bitmap_64)
		img = Image.from_blob(bin)
		return img[0]
	end

	# Determines if two strokes are close enough together (in time) to be considered part of the same char. If they are, they are compressed into one stroke.
	def compress stroke_data, i=0
		eps = 500

		if i >= (stroke_data.length-1)
			return stroke_data
		end

		line1 = stroke_data[i]
		line2 = stroke_data[i+1]

		if (line2[2] - line1[-1]) < eps
			if i>0
				new_stroke_data = stroke_data[0..i-1]
			else
				new_stroke_data = Array.new
			end
			stroke = line1.concat(line2)
			new_stroke_data << stroke
			if (i+2) < stroke_data.length
				new_stroke_data.concat(stroke_data[i+2..-1])
			end
			return compress new_stroke_data, i
		else
			return compress stroke_data, i+1
		end
	end
	
	# Accepts 4 coordinates defining a rectange, and an image (img)
	# Returns the image defined within img by the rectangle parameter
	def crop_image min_x, max_x, min_y, max_y, img
		cropped = img.crop(min_x, min_y, max_x - min_x, max_y - min_y, true)
		bg = Image.new(max_x - min_x + 100, max_y - min_y + 100)
		cropped = bg.composite(cropped, CenterGravity, OverCompositeOp)
		return cropped
	end

	# Accepts a 2d array of stroke data, where each inner array is a single stroke [x,y,t,x,y,t...]
	# Returns a 2d array, where each innner array is the of minima/maxima of x and y coordinates for that stroke [[min_x, max_x, min_y, max_y],[min_x, max_x, min_y, max_y]...]
	def get_bounds stroke_data
		# 2d array to be returned
		all_bounds = Array.new

		stroke_data.each do |inner_array|

			# Arrays for storing x and y values for the stroke currently being inspected
			xvals = Array.new
			yvals = Array.new

			inner_array.each_slice(3) do |point|
				xvals.push(point[0])
				yvals.push(point[1])
			end

			# A temporary array that stores the min/max x/y for the stroke being inspected
			bounds = Array.new
			bounds << xvals.min << xvals.max << yvals.min << yvals.max

			# Add the bounds for the current stroke to the array of all bounds
			all_bounds << bounds
		end

		return all_bounds
	end
end

