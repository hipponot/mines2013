require "sinatra/base"
require "json"
require "test_foo/version"
require "test_foo/aws_instance"

module Test
  module Foo 
    class Service < Sinatra::Base

      get '/' do
        "<form action=\"/upload_bitmap\" method=\"post\"><input type=\"text\" name=\"something\"><input type=\"submit\" value=\"submit\"></form>"
        # File.read("../lib/index.html")
      end
      
      get '/hello' do
        cache_control :max_age => 0
        puts "#{Time.now} Kudu: Hello!"
        status 200
        body JSON.pretty_generate({
          "status" => "success",
          "service" => "Foo"
          })
      end

      post '/upload_bitmap' do

        #Putting mongo things here
        mongo_client = MongoClient.new("localhost", 27017)
        db = mongo_client.db("mydb")
        coll = db["testCollection"]
        doc = {"name" => "MongoDB","type" => "database", "count" => 1}
        id = coll.insert(doc)
        #end mongo things

        puts "I got the message"
        puts "It was: #{params[:data]}"
        # request.body.read

        File.open('/tmp/file_1', 'wb') { |f| f.write(request.body.read)}
        status 200
      end
      get '/loadprompt' do
        erb :loader
      end

      get '/saveprompt' do
        erb :saver
      end
      
      post '/savefile' do
        # verify appropriate bucket
        # save file
        # return save status
        name = params[:upfile][:filename]
        upfile = params[:upfile][:tempfile]
        File.open('/tmp/'+name, "wb") { |f| f.write(upfile.read) }
        "SUCCESS"
      end
      
      get '/loadfile' do
        file_name = params['filename']
        ## aws api to server
        # check for file existance
        # load file
        # return file object
        if !File.exists?('/tmp/'+file_name)
          "Error Loading File"
        else
          file = File.open('/tmp/'+file_name, "r")
        end
      end
    end
  end
end