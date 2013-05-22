# set path to app that will be used to configure unicorn, 
# note the trailing slash in this example
dir = File.join(File.expand_path(File.dirname(__FILE__ )), File::SEPARATOR)
#worker_processes 2
working_directory dir
timeout 30
# Application directories
FileUtils.mkdir_p "/tmp/unicorn/sockets/eq_ocr"
FileUtils.mkdir_p "/tmp/unicorn/pids/eq_ocr"
FileUtils.mkdir_p "/var/log/unicorn/eq_ocr"
# Specify path to socket unicorn listens to, 
# we will use this in our nginx.conf later
listen "/tmp/unicorn/sockets/eq_ocr/unicorn.sock", :backlog => 64
# Set process id path
pid "/tmp/unicorn/pids/eq_ocr/unicorn.pid"
# Set log file paths
stderr_path "/var/log/unicorn/eq_ocr/stderr.log"
stdout_path "/var/log/unicorn/eq_ocr/stdout.log"