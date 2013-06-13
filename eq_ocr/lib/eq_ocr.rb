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
      get '/' do
        "<form action=\"/upload_bitmap\" method=\"post\"><input type=\"text\" name=\"something\"><input type=\"submit\" value=\"submit\"></form>"
      end

      post '/ocr' do
        # split_json request.body.read
        @time = Time.now.strftime "%Y-%m-%d_%H:%M:%S"
        @ocr_json = {}
        @ocr_values = []
        db_update
        process_data
        run_ocr
        upload_bitmap
        content_type :json
        status 200
        # body @ocr_json.sort.to_json
        body @ocr_values.to_s
      end

      get '/request_bmp' do
        s3 = AwsInstance.new
        s3.get_file params[:filename]
      end

      helpers do

        def run_ocr
          Dir.chdir "/tmp"
          Dir.glob("crop*").sort.each do |file|
            puts "Running tesseract on #{file}"
            t = %x[tesseract -l eng+equ -psm 10 #{file} out nobatch digits]
            puts t
            @ocr_json[file] = `cat out.txt`.strip
            @ocr_values << `cat out.txt`.strip
            puts @ocr_values
          end  
          puts "ocr values to string" + @ocr_values.to_s
          tmpstr = ""
          @ocr_values.each do |value|
            tmpstr << value
          end
          eval_value = eval(tmpstr)
          puts "the eval value: #{eval_value}"
          @ocr_values << "=#{eval_value}"
          # puts @ocr_json.sort
          puts "ocr values sorted #{@ocr_values.sort}"
        end

        def upload_bitmap
          s3 = AwsInstance.new
          #File.open("/tmp/#{@time}", 'wb') { |f| f.write(params[:bmp])}
          #s3.upload_file "/tmp/#{@time}", @time
          #Dir.glob(/^(\/tmp\/crop#{@time}\_\d*)$/).each_with_index do |filename, i|
          Dir.glob("/tmp/crop*").each_with_index do |filename, i|
            s3.upload_file "#{filename}", "crop#{@time}_#{i}"
            File.delete filename
          end
        end
        
        def db_update
          @client = MongoClient.new('localhost', 27017)
          @db     = @client['handwriting-data']
          @coll   = @db['json-bmp']
          @coll.insert({'json' => params[:json]})
        end
        
        def process_data
          seg = Segmentation.new
          seg.segment(params[:bmp], params[:json], @time)
        end
      end
    end
  end
end