$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "activestorage_qiniu/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "activestorage_qiniu"
  s.version     = ActivestorageQiniu::VERSION
  s.authors     = ["qinmingyuan"]
  s.email       = ["mingyuan0715@foxmail.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of ActivestorageQiniu."
  s.description = "TODO: Description of ActivestorageQiniu."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.1.4"

  s.add_development_dependency "sqlite3"
end
