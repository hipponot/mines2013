require "sinatra/base"
require "json"
require "eq_ocr/version"
require 'eq_ocr/aws_instance'
require 'mongo'
require "eq_ocr/eq_ocr"
require "eq_ocr/segment"

module Eq
  module Ocr 
    class Service < Sinatra::Base
      include Mongo

      ## Website for showing all of the currently OCR'ed segmented images
      get '/' do
        Dir.chdir "../lib/public"
        erb :images
      end

      ## Completes all of the OCR steps
      post '/ocr' do
        # set a global Time variable for using in storage of segmented bitmaps, data retrieval, and more
        @time = Time.now.strftime "%Y-%m-%d_%H_%M_%S"
        @ocr_values = []

        ## call the steps
        db_update
        process_data
        upload_bitmap

        ## return to the app
        content_type :json
        status 200
        body @ocr_values.to_s
      end

      ## used for returning the last image sent
      ## I'm not sure if this even works any more 
      ## because we segment before sending to the S3 now
      get '/request_bmp' do
        s3 = AwsInstance.new
        s3.get_file params[:filename]
      end

      ## all of the helper methods
      helpers do

        ## send the JSON to the database
        ## the JSON is not used for anything yet
        def db_update
          @client = MongoClient.new('localhost', 27017)
          @db     = @client['handwriting-data']
          @coll   = @db['json-bmp']
          @coll.insert({'json' => params[:json]})
        end
        
        ## the actual segmentation begins here
        ## after segmentation each of the names 
        ## is returned and then the ocr is run
        def process_data
          seg = Segmentation.new
          @values = seg.segment(params[:bmp], params[:json], @time)
          run_ocr 
        end
        
        ## this runs the actual tesseract code on each part of the segmented image
        def run_ocr 
          @values.each_with_index do |symbol, index|
            if !symbol.is_a? String
              file = "/tmp/crop#{@time}_#{index}.png"
              t = %x[tesseract #{file} out -l eng+equ -psm 10 digits]
              sym_val = `cat out.txt`.strip

              @ocr_values << (sym_val.empty? ? "?" : sym_val) ## ? if empty, the value if it isn't!
            else
              @ocr_values << symbol
            end
          end

          ## create a temporary string so that we can add Float() around the parts that are doing integer division
          ## we do not do this in the segment because it would then display it on the app screen
          tmpstr = ""
          @ocr_values.each { |value| tmpstr << value }
          tmpstr.gsub!( "(", "Float(" )
          tmpstr.gsub!( "=", "==" )
          tmpstr.gsub!( "x", "*" )
          tmpstr.gsub!( "X", "*" )

          ## rescue if eval fails
          begin
            eval_value = eval(tmpstr)
          rescue SyntaxError, NameError => invalid
            eval_value = "Equation can't be evaluated"
          rescue StandardError => err
            eval_value = "Equation can't be evaluated"
          end

          @ocr_values << "= #{sprintf("%g", eval_value)}" ## pretty up the text. This removes the .0 at the end of a whole number

          ## debugging
          puts "ocr values to string:" + @ocr_values.join("")
          puts tmpstr
          puts "the eval value: #{eval_value}"
        end

        ## this uploads the bitmaps to the S3 server
        ## it looks in the tmp folder and then for each 
        ## crop{DATE}_{TIME}_{INDEX} file it will upload 
        ## it to the server and then delete it from /tmp/
        def upload_bitmap
          s3 = AwsInstance.new
          Dir.glob("/tmp/crop*").each_with_index do |filename, i|
            s3.upload_file "#{filename}", "crop#{@time}_#{i}"
            File.delete filename
          end
        end
      end
    end
  end
end