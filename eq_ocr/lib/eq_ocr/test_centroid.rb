require './segment'


seg = Segmentation.new

stroke = [0,0,0,2,0,0,2,3,0,0,3,0]
stroke1 = [1,0,0,1,1,0]
stroke2 = [0,3,0,1,3,0,2,3,0]
stroke3 = [1,4,0,1,5,0]

if(seg.is_fraction? stroke1, stroke2)
	stroke1.concat stroke2
	puts seg.is_fraction? stroke1, stroke3
else
	puts "stroke1 and stroke2 not fractions!!!!!!!!"
end



print seg.centroid stroke