require "sinatra/base"
require "json"
require "eq_ocr/version"
require "eq_ocr/eq_ocr"
module Eq
  module Ocr 
    class Service < Sinatra::Base
      get '/' do
        "Hello World"
      end
      get '/hello' do
        cache_control :max_age => 0
        puts "#{Time.now} Kudu: Hello!"
        status 200
        body JSON.pretty_generate({
          "status" => "success",
          "service" => "Ocr"
        })
      end
    end
  end
end