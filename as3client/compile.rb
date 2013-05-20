#!/usr/bin/ruby

#require "json"

def get_arg(name)
  return nil if (ARGV.index(name)==nil)
  val = ARGV[ARGV.index(name)+1]
  raise "Argument #{name} expects a value" if (val==nil || val.start_with?("-"))
  return val
end

def has_switch?(name)
  return false if (ARGV.index(name)==nil)
  return true
end

app_xml = Dir.glob("**/src/**/Main-*.xml").first
raise "Error: app.xml not found!" if (app_xml==nil)
app_main = "#{File.dirname(app_xml)}/Main.as"
swf = "Main.swf"
dir = Dir.getwd+"/bin-debug"
app = "#{app_main} -output #{dir}/#{swf}"

os = `uname -s`
os.chomp!

source_paths = ["-source-path+=src",
               ].join(" ")

flex_opts = [
             "+configname=air",
             "-swf-version=17"
            ].join(" ")

source_paths += " -library-path+=lib" if (File.directory?("lib"))

use_asc2 = true; #!has_switch?('-fast') || os=="Darwin" || has_switch?('-scout')

# asc2 compiler requires different delimiter for defines
define_delimiter = use_asc2 ? '"' : '';

# autoreload
if (has_switch?("-fast")) then
  flex_opts += " -define+=AUTORELOAD::ENABLED,true"
  ip_addr = `ifconfig`.match(/10\.0\.1\.\d+/).to_s
  if (ip_addr.length>0) then
    loader_url = "http://" + ip_addr + "/#{swf}";
    flex_opts += " -define+=AUTORELOAD::URL,'#{define_delimiter + loader_url + define_delimiter}'"
    puts " - AUTORELOAD::URL=#{loader_url}"
  end
else
  flex_opts += " -define+=AUTORELOAD::ENABLED,false -define+=AUTORELOAD::URL,false"
end

# Load config xml file(s) (comma-separatedlist is ok)
config_file = get_arg('-config')

if (config_file==nil) then
  config_file = (has_switch?("-debug")) ? 'config.debug.xml' : 'config.rc.xml';
  puts " - NO config files specified, using #{ config_file }"
end

if (config_file!=nil) then
  config_file.split(',').each { |file|
    flex_opts += " -load-config+=#{file}"
  }
end

# This is mostly for FCSH to get a different commandline for different proejcts
#flex_opts += " -define+=CONFIG::CWD,#{Dir.getwd}"

defines = ARGV.clone
while (defines.length>0) do
  arg = defines.shift
  if (arg=='-define') then
    define = defines.shift
    raise "\nInvalid define syntax: #{define}\nRequired syntax: NAMESPACE::KEY,VALUE" if define.match(/^\w+::\w+,.*/)==nil
    key, value = define.split(",")
    flex_opts += " -define+=#{key},'#{define_delimiter + value + define_delimiter}'"
  end
end

# debug mode
if (has_switch?("-debug")) then
  # debug param (stores stack traces, etc)
  flex_opts += " -debug -optimize=false"
  puts " - DEBUG MODE!"
else
  puts " - NOT debug mode (use -debug to compile with debug enabled)"
  flex_opts += " -optimize"
end

flex_opts += " -static-link-runtime-shared-libraries" unless use_asc2
flex_opts += " -compress=false" if use_asc2
flex_opts += " -omit-trace-statements=false" if has_switch?("-trace")
flex_opts += " -advanced-telemetry" if has_switch?("-scout")

# Flex font transcoder needs help sometimes (error transcoding roboto)
flex_opts += " -managers=flash.fonts.AFEFontManager" unless use_asc2

puts "mxmlc #{source_paths} #{flex_opts} #{app}"

if (os!="Darwin") then
  #fcshd uses $FLEX_HOME
  if (use_asc2) then
    output = `$AIR_HOME/bin/mxmlc #{source_paths} #{flex_opts} #{app}`;
  else
    output = `fcshd.py "mxmlc #{source_paths} #{flex_opts} #{app}"`;
  end
else
  puts "Using MXMLC"
  output = `$AIR_HOME/bin/mxmlc #{source_paths} #{flex_opts} #{app}`;
end
result = $?

(puts "compile failed\n#{output}"; exit) unless (result.success? && output.match(/error/i)==nil && File.exists?(dir+'/'+swf))

`cp #{app_xml} #{dir}/Main-app.xml`

puts "compile succeeded"

if (os=="Darwin") then
  `cp #{dir}/#{swf} ~/Sites/`
else
  `cp #{dir}/#{swf} /var/www`
end
