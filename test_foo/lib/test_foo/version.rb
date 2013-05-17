require 'yaml'
module Test
module Foo
  kudu = YAML::load(IO.read(File.join(File.dirname(__FILE__), '../../kudu.yaml')))
  VERSION = kudu[:publications][0][:version]
  NAME = kudu[:publications][0][:name]
end
end