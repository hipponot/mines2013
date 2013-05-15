lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'test_foo/version'
Gem::Specification.new do |gem|
  basedir = File.dirname(__FILE__)
  gem.name          = %q{test_foo}
  gem.authors       = ["Sean Kelly"]
  gem.email         = ["sean.kelly@wootlearning.com"]
  gem.description   = %q{generic kudu module description}
  gem.summary       = %q{generic kudu module summary}
  gem.homepage      = %q{http://wootlearning.com}  
  gem.files         = Dir.glob("lib/**/*").select {|f| f !=  "sha1"} +
                      Dir.glob("bin/**/*") +
                      Dir.glob("config/**/*") +
                      Dir.glob("ext/**/*.{cpp,h,rb,c}") +
                      Dir.glob("kudu.yaml")
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  begin
    text = IO.read(File.join(basedir,'kudu.yaml'))
    kudu = YAML::load(text)
    kudu[:dependencies].each do |dep|
      name = dep[:namespace].nil? ? dep[:name] : dep[:namespace] + "_" + dep[:name]
      gem.add_dependency name, dep[:version]
    end                                                   
    gem.version = kudu[:publications][0][:version]
  rescue
    abort("Error parsing kudu.yaml")
  end
end