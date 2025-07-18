$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "yuba/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "yuba"
  s.version     = Yuba::VERSION
  s.authors     = ["willnet"]
  s.email       = ["netwillnet@gmail.com"]
  s.homepage    = "https://github.com/willnet/yuba"
  s.summary     = "Add New Layers to Rails"
  s.description = "Add New Layers to Rails. Form, Service, ViewModel."
  s.license     = "MIT"
  s.required_ruby_version = ">= 3.2.0"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", ">= 7.1.0"
  s.add_dependency "reform-rails"
  s.add_dependency "dry-types", ">= 1.0"
end
