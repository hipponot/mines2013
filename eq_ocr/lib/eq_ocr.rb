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
        @ocr_text = {}
        db_update
        process_data
        run_ocr
        upload_bitmap
        content_type :json
        status 200
        body @ocr_text.sort.to_json
      end

      get '/request_bmp' do
        s3 = AwsInstance.new
        s3.get_file params[:filename]
      end

      helpers do

        def run_ocr
          Dir.chdir "/tmp"
          Dir.glob("crop*").each do |file|
            puts "Running tesseract on #{file}"
            %x[tesseract -psm 10 #{file} out nobatch digits]
            @ocr_text[file] = `cat out.txt`.strip
          end  
          puts @ocr_text.sort
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

          # @coll.remove
          # 3.times do |i|
          #  @coll.insert({'a' => i+1})
          # end

          @coll.insert({'json' => params[:json]})

          puts "There are #{@coll.count} records. Here they are:"
          #@coll.find.each { |doc| puts doc.inspect }
            
          # ocr = OcrExt.new
          # puts eval("2+2")
        end
        
        def process_data
          seg = Segmentation.new
          seg.segment(params[:bmp], params[:json], @time)
        end
      end
    end
  end
end