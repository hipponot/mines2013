require "sinatra/base"
require "json"
require "test_blah/version"
require "test_blah/test_blah"

module Test
  module Blah 
    class Service < Sinatra::Base
      get '/' do
        foo = BlahExt.new()
        body foo.hello.to_s
      end
      get '/hello' do
        cache_control :max_age => 0
        puts "#{Time.now} Kudu: Hello!"
        status 200
        body JSON.pretty_generate({
          "status" => "success",
          "service" => "Blah"
        })
      end
    end
  end
end