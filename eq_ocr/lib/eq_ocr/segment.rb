require 'RMagick'
require "base64"

class Segmentation
	include Math
	include Magick

	# Threshold angle for determining if the centroids of two strokes should be considered above one another.
	REGRESSION = 60 * PI / 180.0

	# Accepts a 64bit bitmap encoding and associated stroke data, and returns an array of bitmaps to be processed by tesseract
	def segment bitmap_64, stroke_data, t
		img = bin_to_bmp(bitmap_64)

		#Convert json from string into 2d array
		#stroke_data = eval(stroke_data)
		#stroke_data = compress stroke_data
		#all_bounds = get_all_bounds stroke_data
		
		values = break_down img

		values.each_with_index do |symbol, index|
			if !symbol.is_a? String
				symbol.write("/tmp/crop#{t}_#{index}.png")
				symbol.write("crop#{t}_#{index}.png")
			end
		end
		# Create the array of bitmaps to be returned
		#all_bounds.each_with_index do |bounds, index|
		#	cropped = crop_image(bounds[0], bounds[1], bounds[2], bounds[3], img)
		#	cropped.write("/tmp/crop#{t}_#{index}.png")
		#	cropped.write("crop#{t}_#{index}.png")
		#end
		return values
	end

	def break_down img, axis=true
		segments = Array.new
		sub_imgs = line_seg img, axis
		#puts sub_imgs.length

		if axis
			sub_imgs.each do |sub_img|
				segments += (break_down sub_img, !axis)
			end
		else
			if sub_imgs.length <= 1
				return [img]
			end
			segments += (break_down sub_imgs[0], !axis)
			1.step(sub_imgs.length-2,2) do |i|
				segments = ["("] + segments + [")"] + ["/"] + ["("] + (break_down sub_imgs[i+1], !axis) + [")"]
			end
		end

		return segments
	end

	## Offline segmentation using a single dimmension
	## Ex: Horz segmentation looks at each col to determine where segs start and stop
	## The sections are split and stored in an array of sub-images
	def line_seg img, axis
		sub_img = Array.new
		width = img.columns
		height = img.rows
		## dx, dy determine how far to scan the image
		## w, h, determine the size of the col/row
		if axis
			dx=width-1
			dy=0
			w=1
			h=height
		else
			dx=0
			dy=height-1
			w=width
			h=1
		end

		## space is a flag that denotes the col/row is not part of a sub-image
		## start is the staring left-most/top-most edge of the sub-image
		space = true
		empty = true
		start = 0
		(0..dx).each do |x|
			(0..dy).each do |y|
				## Creates an array of pixels that comprise a row/col
				line = img.get_pixels(x,y,w,h)
				## empty is a flag denoting a col/row with no black pixels
				## ADD: If you have a different color pen just check that at least one pixel is not white
				empty=true
				line.each do |pixel|
					## Pixel intesity is a value from 0 to 255 denoting how bright a pixel is (255=white)
					if pixel.intensity() == 0
						empty = false
						break
					end
				end
				## If a new sub-image has been hit
				if !empty && space
					space = false
					start = axis ? x : y
				## If a sub-image is complete
				elsif empty && !space
					space = true
					if axis
						sub_img << crop_image(start, x, dy, h, img)
					else
						sub_img << crop_image(dx, w, start, y, img)
					end
				end
			end
		end

		if !empty && !space
			if axis
				sub_img << crop_image(start, dx, dy, h, img)
			else
				sub_img << crop_image(dx, w, start, dy, img)
			end
		end

		return sub_img
	end

	# Accepts two strokes and determines if they are part of a fraction by performing a linear regression on their centroids.
	def is_fraction? stroke1, stroke2
		# Get centroids for both strokes
		x1, y1 = centroid(stroke1)
		x2, y2 = centroid(stroke2)
		
		# Handle case where regression is a straight vertical line (avoid division by 0)
		if x2 - x1 == 0
			return true
		end

		slope = (y2 - y1) / (x2 - x1)
		angle = atan2((y2 - y1).abs , (x2 - x1).abs)

		# Compare angle to epsilon value, if it is larger, the two strokes are "on top" of each other, and belong to a fraction
		if angle > REGRESSION
			return true
		else
			return false
		end
	end

	# Accepts two stroks and determines if they overlap with one another
	def overlap? stroke1, stroke2

		min_x = 0
		max_x = 1
		min_y = 2
		max_y = 3

		bounds1 = get_bounds stroke1
		bounds2 = get_bounds stroke2

		if (bounds1[max_x] >= bounds2[min_x]) && (bounds1[max_y] >= bounds2[min_y]) && (bounds2[max_x] >= bounds1[min_x]) && (bounds2[max_y] >= bounds1[min_y])
			return true
		end

		return false
	end

	# Decodes 64bit encoding of a bitmap and returns an image generated by the binary data
	def bin_to_bmp bitmap_64
		bin = Base64.decode64(bitmap_64)
		img = Image.from_blob(bin)
		return img[0]
	end

	# (Recursive) Determines if two strokes are close enough together (in time) to be considered part of the same char. If they are, they are compressed into one stroke.
	def compress stroke_data, i=0

		if i >= (stroke_data.length-1)
			return stroke_data
		end

		line1 = stroke_data[i]
		line2 = stroke_data[i+1]


		if line1.length <= 3
			stroke_data.delete_at i
			return compress stroke_data, i
		end

		if line2.length <= 3
			stroke_data.delete_at i+1
			return compress stroke_data, i
		end

		if (is_fraction? line1, line2) || (overlap? line1, line2)
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

	# Determines the centroid for a stroke, returns it in the form [c_x, c_y]
	def centroid stroke
		# Index is incremented by 3 to handle the stroke data format [x,y,t,x,y,t]
		i = 3
		mass = 0

		centroid = Array.new
		centroid << 0 << 0
		stroke[0..-4].each_slice(3) do |point|

			#Centroid = (x1 + x2) / 2
			c_x = (point[0] + stroke[i])/2.0
			c_y = (point[1] + stroke[i + 1])/2.0

			#Length  = sqrt((dx)^2 + (dy)^2)
			length = (((point[0] - stroke[i])**2) + ((point[1] - stroke[i+1])**2))**0.5
			mass += length

			centroid[0] += c_x * length
			centroid[1] += c_y * length 
			#Increment helper index
			i += 3
		end

		#Centroid = sum(C_i*%mass)
		centroid[0] /= mass
		centroid[1] /= mass

		return centroid
	end

	# Accepts a 2d array of stroke data, where each inner array is a single stroke [x,y,t,x,y,t...]
	# Returns a 2d array, where each innner array is the of minima/maxima of x and y coordinates for that stroke [[min_x, max_x, min_y, max_y],[min_x, max_x, min_y, max_y]...]
	def get_all_bounds stroke_data
		all_bounds = Array.new

		stroke_data.each do |inner_array|
			all_bounds << get_bounds(inner_array)
		end

		return all_bounds
	end

	# Returns an array of bounds [x_min, x_max, y_min, y_max] for the stroke
	def get_bounds stroke
		# Arrays for storing x and y values for the stroke currently being inspected
		xvals = Array.new
		yvals = Array.new

		stroke.each_slice(3) do |point|
			xvals.push(point[0])
			yvals.push(point[1])
		end

		# A temporary array that stores the min/max x/y for the stroke being inspected
		bounds = Array.new
		bounds << xvals.min << xvals.max << yvals.min << yvals.max

		return bounds
	end
end

