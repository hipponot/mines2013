# set path to app that will be used to configure unicorn, 
# note the trailing slash in this example
dir = File.join(File.expand_path(File.dirname(__FILE__ )), File::SEPARATOR)
#worker_processes 2
working_directory dir
timeout 30
# Application directories
FileUtils.mkdir_p "/tmp/unicorn/sockets/test_blah"
FileUtils.mkdir_p "/tmp/unicorn/pids/test_blah"
FileUtils.mkdir_p "/var/log/unicorn/test_blah"
# Specify path to socket unicorn listens to, 
# we will use this in our nginx.conf later
listen "/tmp/unicorn/sockets/test_blah/unicorn.sock", :backlog => 64
# Set process id path
pid "/tmp/unicorn/pids/test_blah/unicorn.pid"
# Set log file paths
stderr_path "/var/log/unicorn/test_blah/stderr.log"
stdout_path "/var/log/unicorn/test_blah/stdout.log"