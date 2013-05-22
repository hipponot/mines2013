require "sinatra/base"
require "json"
require "test_foo/version"
module Test
  module Foo 
    class Service < Sinatra::Base
      get '/' do
        "Hello World World"
      end
      get '/hello' do
        cache_control :max_age => 0
        puts "#{Time.now} Kudu: Hello!"
        status 200
        body JSON.pretty_generate({
          "status" => "success",
          "service" => "FooBar"
        })
      end
    end
  end
end