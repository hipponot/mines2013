require 'mongo'

include Mongo

mongo_client = MongoClient.new("localhost", 9393)
db = mongo_client.db("mydb")
coll = db["testCollection"]
doc = {"name" => "MongoDB","type" => "database", "count" => 1}
id = coll.insert(doc)

# @client = MongoClient.new('localhost', 27017)
# @db = @client['sample-db']
# @coll = @db['test']

# @coll.remove

# 3.times do |i|
# 	@coll.insert({'a' => i+1)}
# end

# puts "There are #{@coll.count} records. Here they are: "
# @coll.find.each { |doc| puts doc.inspect }

# class Mongostuff

# 	attr_accessor :id

# 	def initialize(id)
# 		@id = id
# 	end

# end