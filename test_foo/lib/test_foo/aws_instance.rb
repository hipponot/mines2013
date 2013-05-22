require 'rubygems'
require "aws-sdk"
require "fakes3"
require "aws/s3"

class AwsInstance
  # include AWS::S3

  def initialize
    AWS::S3::Base.establish_connection!(:access_key_id => "123",
      :secret_access_key => "abc",
      :server => "localhost",
      :port => "10001")

    Bucket.create('mystuff')

    ('a'..'z').each do |filename|
      S3Object.store(filename, 'Hello World', 'mystuff')
    end

    bucket = Bucket.find('mystuff')
    bucket.objects.each do |s3_obj|
      puts "#{s3_obj.key}:#{s3_obj.value}"
    end

    Bucket.delete("mystuff",:force => true) # Delete your bucket and all its keys
  end
end