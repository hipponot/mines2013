require 'rubygems'
# require "aws-sdk"
#require "fakes3"
require "aws-sdk"

class AwsInstance
  attr_accessor :bucket_name, :s3

  def initialize 
    @s3 = AWS::S3.new(
      :access_key_id => 'secrets',
      :secret_access_key => 'secret_key',
      :s3_endpoint => 'localhost',
      :s3_port => 10001,
      :use_ssl => false)
    puts "created the s3 instance"
    @bucket_name = 'handwriting'

    if not bucket = @s3.buckets[bucket_name]
      bucket = @s3.buckets.create(bucket_name)
    end
    puts "created the bucket"
  end

  def upload_file file_name
    puts "Creating the key for file: #{file_name}"
    key = File.basename(file_name)
    puts "key name is #{key}"
    
    buk = @s3.buckets[@bucket_name]
    obj = buk.objects[key]
    obj.write('Pathname.new(file_name)')
    "Uploading file #{file_name} to bucket #{bucket_name}"
  end

end