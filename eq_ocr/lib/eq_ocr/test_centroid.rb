require './segment'


seg = Segmentation.new

# ********************************************
# segmentation.is_fraction? Testing
# ********************************************
if(seg.is_fraction? stroke1, stroke2)
	print "Testing is fraction:"
	stroke1.concat stroke2
	puts seg.is_fraction? stroke1, stroke3
else
	puts "stroke1 and stroke2 not fractions!!!!!!!!"
end

# ********************************************
# segmentation.overlap Testing
# ********************************************
base_stroke = [2,2,0,5,5,0]

tests = {"Fail" => [0,0,0,1,1,0], 
	"TLC" => [0,0,0,3,3,0], 
	"BLC" => [0,6,0,3,4,0], 
	"TRC" => [3,0,0,6,4,0], 
	"BRC" => [3,3,0,6,6,0], 
	"AROUND" => [0,0,0,6,6,0], 
	"INSIDE" => [3,3,0,4,4,0],
	"TALL" => [3,0,0,4,6,0]}

tests.keys.each do |test|
	puts "Testing" + test + ": #{seg.overlap?(base_stroke, tests[test])}"
end
