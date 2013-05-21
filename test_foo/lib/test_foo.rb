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
        puts "I got the message"
        puts "It was: #{params[:data]}"
        puts "Or maybe it was #{request.body.read}"
      end

    end
  end
end