require "sinatra/base"
require "json"
require "eq_ocr/version"
require 'eq_ocr/aws_instance'
require 'mongo'
require "eq_ocr/eq_ocr"

module Eq
  module Ocr 
    class Service < Sinatra::Base
      include Mongo
      get '/' do
        "<form action=\"/upload_bitmap\" method=\"post\"><input type=\"text\" name=\"something\"><input type=\"submit\" value=\"submit\"></form>"
      end

      post '/ocr' do
        # split_json request.body.read
        upload_bitmap params
        db_update
        status 200
        body "file written to S3 storage and json written to database"
      end

      get '/request_bmp' do
        puts "hello"
        s3 = AwsInstance.new
        s3.get_file 
      end

      helpers do
        def upload_bitmap params

          puts "BMP encoded data: #{params[:bmp]}"
          puts "JSON data: #{params[:json]}"

          s3 = AwsInstance.new
          File.open('/tmp/file_1', 'wb') { |f| f.write(params[:bmp])}
          s3.upload_file('/tmp/file_1')
        end
        
        def db_update
          @client = MongoClient.new('localhost', 27017)
          @db     = @client['json-db']
          @coll   = @db['test']

          @coll.remove

          # 3.times do |i|
          #  @coll.insert({'a' => i+1})
          # end

          @coll.insert({'json' => params[:json]})

          puts "There are #{@coll.count} records. Here they are:"
          @coll.find.each { |doc| puts doc.inspect }
            
          # ocr = OcrExt.new
          # puts eval("2+2")
        end
      end
    end
  end
end