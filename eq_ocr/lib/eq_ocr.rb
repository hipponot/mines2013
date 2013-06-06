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
        # upload_bitmap
        # db_update
        # process_data
        status 200
        body "file written to S3 storage and json written to database"
      end

      get '/request_bmp' do
        s3 = AwsInstance.new
        s3.get_file 
      end

      helpers do
        def upload_bitmap
          time = Time.now.strftime "%Y-%m-%d_%H:%M:%S"
          s3 = AwsInstance.new
          File.open("/tmp/#{time}", 'wb') { |f| f.write(params[:bmp])}
          s3.upload_file "/tmp/#{time}", time
          
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
          @coll.find.each { |doc| puts doc.inspect }
            
          # ocr = OcrExt.new
          # puts eval("2+2")
        end
        
        def process_data
          seg = Segmentation.new
          seg.segment(params[:bmp], params[:json])
        end
      end
    end
  end
end