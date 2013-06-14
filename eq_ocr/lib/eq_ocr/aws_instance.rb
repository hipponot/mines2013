require 'rubygems'
require 'aws/s3'

class AwsInstance
  include AWS::S3

  attr_accessor :bucket_name, :s3

  ## Initialize the server and create a bucket
  ## to store the segmented images
  def initialize
    ## creating s3
    @bucket_name = 'handwriting'
    # open the port
    s3 = AWS::S3::Base.establish_connection!(
      :access_key_id => "123",
      :secret_access_key => "abc",
      :server => "localhost",
      :port => "10001")
    
    # create the bucket
    if !Bucket.create(@bucket_name)
      Bucket.find(@bucket_name)
    end
  end

  ## upload file using the filename and an identifier
  ## based on crop{DATE}_{TIME}_{INDEX} where index is
  ## one of the segmented images based off of which were
  ## segmented first
  def upload_file file, time
    S3Object.store(time, open(file), @bucket_name)
  end

  ## retrieve the file based on the name 
  ## currently I think this is wrong. We 
  ## no longer store binary data in a file,
  ## we store actual images
  def get_file file_name="test_file"
    file = S3Object.find file_name, @bucket_name
    file.value # return the binary data in the file
  end

end