#Sample mongo code

require 'rubygems'
require 'mongo'

include Mongo

@client = MongoClient.new('localhost', 27017)
@db     = @client['sample-db']
@coll   = @db['test']

@coll.remove

3.times do |i|
  @coll.insert({'a' => i+1})
end

puts "There are #{@coll.count} records. Here they are:"
@coll.find.each { |doc| puts doc.inspect }