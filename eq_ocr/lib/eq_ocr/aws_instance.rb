require 'rubygems'
# require "aws-sdk"
#require "fakes3"
# require "aws-sdk"
require 'aws/s3'

class AwsInstance
  include AWS::S3

  attr_accessor :bucket_name, :s3

  # def initialize 
  #   @s3 = AWS::S3.new(
  #     :access_key_id => 'secrets',
  #     :secret_access_key => 'secret_key',
  #     :s3_endpoint => 's3.amazonaws.com',
  #     :s3_port => 10001,
  #     :use_ssl => false)
  #   puts "created the s3 instance"
  #   @bucket_name = 'handwriting'

  #   if not bucket = @s3.buckets[bucket_name]
  #     bucket = @s3.buckets.create(bucket_name)
  #   end
  #   puts "created the bucket"
  # end

  # def upload_file file_name
  #   puts "Creating the key for file: #{file_name}"
  #   key = File.basename(file_name)
  #   puts "key name is #{key}"
    
  #   buk = @s3.buckets[@bucket_name]
  #   obj = buk.objects[key]
  #   obj.write('Pathname.new(file_name)')
  #   "Uploading file #{file_name} to bucket #{bucket_name}"
  # end

  def initialize
    puts "creating s3"
    @bucket_name = 'handwriting'
    s3 = AWS::S3::Base.establish_connection!(
      :access_key_id => "123",
      :secret_access_key => "abc",
      :server => "localhost",
      :port => "10001")
    
    puts "creating bucket"
    if !Bucket.create(@bucket_name)
      Bucket.find(@bucket_name)
    end
  end

  def upload_file file
    puts "uploading file"
    S3Object.store("test_file", open(file), @bucket_name)
    b = Bucket.find('handwriting')
    puts b["test_file"]
  end

  def get_file file_name="test_file"
    puts "retrieving file"
    file = S3Object.find file_name, @bucket_name
    puts "the file's value is: #{file.value}"
    file.value
  end

end