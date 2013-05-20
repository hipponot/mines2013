require "sinatra/base"
require "json"
require "test_foo/version"
module Test
  module Foo 
    class Service < Sinatra::Base
      get '/' do
        "<form action=\"/dbupdate\" method=\"get\"><input type=\"text\" name=\"something\"><input type=\"submit\" value=\"submit\"></form>"
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
      get '/dbupdate' do
        
      end

    end
  end
end