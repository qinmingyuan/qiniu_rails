$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'qiniu_rails/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = 'qiniu_rails'
  s.version = QiniuRails::VERSION
  s.authors = ['qinmingyuan']
  s.email = ['mingyuan0715@foxmail.com']
  s.homepage = 'https://github.com/qinmingyuan/qiniu_rails'
  s.summary = 'qiniu backend for activestorage'
  s.description = 'Description of ActivestorageQiniu.'
  s.license = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  s.add_dependency 'qiniu'
  s.add_dependency 'sprockets'
  s.add_dependency 'rails', '5.2.0'
end
