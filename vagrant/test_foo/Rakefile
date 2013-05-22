require "bundler/gem_tasks"
require 'rake/testtask'
Rake::TestTask.new do |t|
  t.pattern = 'test/unit/test*.rb'
end
desc "Run tests"
task :default => :test
task :rebuild do
  Rake::Task['install'].execute
end