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
        split_json request.body.read
        upload_bitmap
        db_update
      end

      helpers do

        def split_json message
          puts message.unpack('H*')
          puts "There should be a message above"

        end

        def upload_bitmap

          # new_request = request.body.read.split("[")

          s3 = AwsInstance.new
          File.open('/tmp/file_1', 'wb') { |f| f.write(request.body.read)}
          s3.upload_file('/tmp/file_1')

          status 200
          body "1"
        end
        
        def db_update
          new_request = request.body.read

          @client = MongoClient.new('localhost', 27017)
          @db     = @client['sample-db']
          @coll   = @db['test']

          @coll.remove

          3.times do |i|
           @coll.insert({'a' => i+1})
          end

          puts "There are #{@coll.count} records. Here they are:"
          @coll.find.each { |doc| puts doc.inspect }
            
          status 200
          ocr = OcrExt.new
          body "#{ocr.recognize_char}"
        end

      end
    end
  end
end