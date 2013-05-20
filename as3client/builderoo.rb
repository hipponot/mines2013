#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

$os = (`uname -s`).chomp! rescue 'Windows'
tools_dir = File.dirname(__FILE__)
case $os
when 'Windows'
  $adl_cmd = '%AIR_HOME%\bin\adl.exe'
  $adt_cmd = '%AIR_HOME%\bin\adt.bat'
  $adb_cmd = '%ANDROID_SDK%\platform-tools\adb.exe'
when 'Linux'
  # silence the fixme output
  $adl_cmd = 'WINEDEBUG=fixme-all wine $AIR_HOME/bin/adl.exe'
  $adt_cmd = 'wine $AIR_HOME/bin/adt.bat'
  $adb_cmd = '$ANDROID_SDK/platform-tools/adb'
when 'Darwin'
  $adl_cmd = '$AIR_HOME/bin/adl'
  $adt_cmd = '$AIR_HOME/bin/adt'
  $adb_cmd = '$ANDROID_SDK/platform-tools/adb'
else
  $adl_cmd = 'adl'
  $adt_cmd = 'adt'
  $adb_cmd = 'adb'
end

def get_arg(name, default=nil, as_array=false)
  return default if (ARGV.index(name)==nil)
  val = ARGV[ARGV.index(name)+1]
  raise "Argument #{name} expects a value" if (val==nil || val.start_with?("-"))

  if (as_array) then
    rtn = []
    ARGV.each_index { |idx|
      rtn.push(ARGV[idx+1]) if (ARGV[idx]==name)
    }
    return rtn;
  else
    return val
  end
end

def has_switch?(name)
  return false if (ARGV.index(name)==nil)
  return true
end

def validate_args
  valid_multiple = ['-define']
  valid_args = ['-config', '-define', '-screensize', '-platform', '-recycle-fcshd']
  valid_switches = ['-scout', '-compile', '-package', '-cache', '-install', '-testflight', '-simulate', '-wine2', '-trace'] # TODO: allow multiple -define's
  validate = ARGV.clone
  while (validate.length>0) do
    arg = validate.shift
    mult = false
    raise "Argument #{arg} must start with a -" unless arg.start_with?("-")
    raise "Multiply defined argument #{arg}" if (valid_multiple.index(arg)==nil && validate.index(arg)!=nil)
    if (valid_switches.index(arg)!=nil) then
      next
    elsif (valid_args.index(arg)!=nil) then
      validate.shift
      next
    else
      raise "Unknown argument #{arg}"
    end
  end
end

def run(cmd)
  show = cmd.clone
  show.gsub!(/token=.*?\s/, 'token=***') # hide Testflight tokens from output
  show.gsub!(/storepass\s.*?\s/, 'storepass *** ') # hide packaging store passwords from output
  puts show

  output = `#{cmd} 2>&1`
  result = $?
  puts "#{output}\n"
  exit unless result.success?

  return output
end

validate_args()

platform = get_arg("-platform") || "android"

`mkdir bin-debug` if (!File.directory?("bin-debug"))
`ln -s ../src/assets bin-debug/assets` if (!File.exists?("bin-debug/assets") && File.exists?("src/assets"))
`ln -s ../src/cache bin-debug/cache` if (!File.exists?("bin-debug/cache") && File.exists?("src/cache"))

if ($os=='Linux' && has_switch?("-wine2")) then
  $adl_cmd = 'WINEPREFIX="/home/admin/.wine2 "'+$adl_cmd
end

# Platform TODO: android
raise "Uknown platform target: #{platform}" unless (platform=="ios" || platform=="android")

# Configs TODO: app-store
CONFIG_FAST = 'fast'
CONFIG_DEBUG = 'debug'
CONFIG_TEST = 'test'
CONFIG_RC = 'rc'
valid_configs = [CONFIG_FAST, CONFIG_DEBUG, CONFIG_TEST, CONFIG_RC, nil]
config = get_arg("-config", nil)
raise "Unknown config: #{config}" unless valid_configs.include?(config)
#raise "Specifying -config requires at least -compile (and optionally -package)" if (config!=nil && !has_switch?("-compile"))
#raise "Specifying -config and -package requires -compile" if (config!=nil && has_switch?("-package") && !has_switch?("-compile"))
raise "Specifying -compile or -package requires -config" if (config==nil && (has_switch?("-compile") || has_switch?("-package")))
raise "Specifying -define requires -compile" if (has_switch?("-define") && !has_switch?("-compile"))

raise "Specifying -compile and -install requires -package" if (has_switch?("-compile") && has_switch?("-install") && !has_switch?("-package"))

puts "Warning:  Specified -config with -package but not -compile (I hope the last compilation was using the same config)" if (config!=nil && has_switch?("-package") && !has_switch?("-compile"))

puts "=========="
puts "Builderoo!"
puts "=========="
puts " - platform: "+platform
puts " - config: "+config.to_s if (config)

if (has_switch?('-recycle-fcshd')) then
  procs = `ps -aef | grep -i fcsh | grep -v grep | grep -v builderoo.rb`.split("\n");
  procs.each { |line|
    pid = line.match(/.*?\s+(\d+)/)[1]
    puts "Killing:  #{pid}"
    `kill -9 #{pid}`
  }
end


# Interpreter config provides the fastest builds, but slower on-device performance
if (platform=='ios') then
  package = "ipa-debug-interpreter" if config==CONFIG_FAST
  package = "ipa-debug-interpreter" if config==CONFIG_DEBUG
  package = "ipa-test" if config==CONFIG_TEST
  package = "ipa-test" if config==CONFIG_RC # ad-hoc?
else
  package = "apk-debug" if config==CONFIG_FAST
  package = "apk-debug" if config==CONFIG_DEBUG
  package = "apk-captive-runtime" if config==CONFIG_TEST
  package = "apk-captive-runtime" if config==CONFIG_RC # ad-hoc?
end

raise "-cache requires -package" if (!has_switch?("-package") && has_switch?("-cache"))
puts "WARNING: -scout may not work without -compile" if (has_switch?("-scout") && !has_switch?("-compile"))
puts "WARNING: -scout may not work without -package" if (has_switch?("-scout") && !has_switch?("-package"))

defines = !has_switch?('-define') ? '' : (' '+get_arg('-define', nil, true).map { |itm| "-define "+itm }.join(" "))

#-------------------------------------
# compile step
#-------------------------------------
if (has_switch?("-compile")) then
  # Default compile args for deployment, TODO, take compile args
  compile_args = ""
  compile_args += " -trace -scout" if (has_switch?("-scout"))
  compile_args += " -trace" if (has_switch?("-trace") && !has_switch?("-scout"))
  compile_args += " -debug -fast" if (config==CONFIG_FAST)
  compile_args += " -debug" if (config==CONFIG_DEBUG)
  compile_args += defines

  case config
  when CONFIG_FAST
    compile_args += " -config config.fast.xml"
  when CONFIG_DEBUG
    compile_args += " -config config.debug.xml"
  when CONFIG_TEST
    compile_args += " -config config.test.xml"
  when CONFIG_RC
    compile_args += " -config config.rc.xml"
  end

  run "rm -f bin-debug/Main.swf"

  puts "============"
  puts "Compiling..."
  puts "============"
  output = run "#{tools_dir}/compile.rb#{compile_args}"
  raise "Compiler error!\n#{output}" if (output.match(/error/i)!=nil)
  output.split("\n").each { |i| puts i if (i.index('mxmlc')!=nil) }
end

#-------------------------------------
# package step
#-------------------------------------
if (has_switch?("-package")) then

  #-------------------------------------
  # content bundling
  #-------------------------------------
  if (has_switch?("-cache")) then
    puts "==================================="
    puts "Running content bundling script..."
    puts "==================================="
    run "rm -f src/cache/*"
    run "cd ../../../ruby/app/woot_content_bundle/; ./woot_content_bundle.rb; cd -";
  else
    puts "======================================="
    puts "Wiping bundle cache, rm src/cache/* !!!"
    puts "======================================="
    run "rm -f src/cache/*"
  end

  puts "==========================="
  puts "Packaging..."
  puts " - package "+package.to_s
  puts " - platform "+platform.to_s
  puts " - scout "+has_switch?("-scout").to_s
  puts "==========================="

  package_file = "bin-debug/Main.#{ (platform=='ios' ? 'ipa' : 'apk') }"

  run "rm -rf bin-debug/AOT* bin-debug/air* #{package_file}"

  # TODO: release mode will need to use different certs
  cert_options = ''
  if (platform=='ios') then
    cert_options = "-storetype pkcs12 -storepass *** -keystore #{tools_dir}/certs/Certificates.p12 -provisioning-profile #{tools_dir}/profiles/NimbeeDevGeneric.mobileprovision"
  else
    cert_options = "-storetype pkcs12 -keystore androidCert.p12 -storepass samplePassword"
  end

  package_args = ["-package -target #{package}",
                  (has_switch?("-scout") ? "-sampler" : ""),
                  cert_options,
                  "#{package_file} bin-debug/Main-app.xml -e bin-debug/Main.swf Main.swf"
                 ].join(" ")
   
  package_args += " -C src assets" if (File.directory?("src/assets"))
  package_args += " -C src cache" if (File.directory?("src/cache"))

  if ($os=="Darwin") then
    run "java -jar \"\$AIR_HOME/lib/adt.jar\" #{package_args}"
  elsif ($os=="Linux") then
    if (platform=='ios') then
      # Oddly, wine needs this file touched...
      `cat bin-debug/Main-app.xml; sleep 2; cat bin-debug/Main-app.xml`
      run "wine java -jar 'Z:\\opt\\air_sdk_3.6\\lib\\adt.jar' #{package_args}"
    else
      run "java -jar \"\$AIR_HOME/lib/adt.jar\" #{package_args}"
    end
  else
    raise "Unknown os: #{$os}"
  end
end

#-------------------------------------
# install step
#-------------------------------------
if (has_switch?("-install")) then
  if (platform=='ios') then
    run "#{$adt_cmd} -installApp -platform ios -package bin-debug/Main.ipa"
  else
    run "#{$adb_cmd} install -r bin-debug/Main.apk"
  end
end

if (has_switch?("-trace") && platform=='android') then
  app_id = `cat bin-debug/Main-app.xml`.match(/<id>(.*?)<\/id>/)[1]
  # use exec so we see output in realtime
  exec "#{$adb_cmd} logcat air.#{app_id}:V *:S"
end

screensize = ''
if (platform=='ios') then
  # default to iPad
  screensize = get_arg("-screensize", "iPad")
else
  # default to 1280x736 (soft menu is 64-px tall on Nexus 7)
  screensize = get_arg("-screensize", "736x1280:736x1280")
end


#-------------------------------------
# simulate step
#-------------------------------------
if (has_switch?("-simulate")) then
  puts "> #{$adl_cmd} -screensize #{screensize} -profile extendedMobileDevice bin-debug/Main-app.xml"
  `#{$adl_cmd} -screensize #{screensize} -profile extendedMobileDevice bin-debug/Main-app.xml`
end

puts "Builderoo has left the building!"
