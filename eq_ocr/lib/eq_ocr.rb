require "sinatra/base"
require "json"
require "eq_ocr/version"
require 'eq_ocr/aws_instance'
require 'mongo'
require "eq_ocr/eq_ocr"
include Mongo

module Eq
  module Ocr 
    class Service < Sinatra::Base
      get '/' do
        "<form action=\"/upload_bitmap\" method=\"post\"><input type=\"text\" name=\"something\"><input type=\"submit\" value=\"submit\"></form>"
      end

      post '/upload_bitmap' do

        # new_request = request.body.read.split("[")

        s3 = AwsInstance.new
        File.open('/tmp/file_1', 'wb') { |f| f.write(request.body.read)}
        s3.upload_file('/tmp/file_1')

        status 200
        body "1"
      end

      post '/db_update' do
        new_request = request.body.read

        @client = MongoClient.new('127.0.0.1', 27017)
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