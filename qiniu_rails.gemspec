$:.push File.expand_path('../lib', __FILE__)
require 'qiniu_rails/version'

Gem::Specification.new do |s|
  s.name = 'qiniu_rails'
  s.version = QiniuRails::VERSION
  s.authors = ['qinmingyuan']
  s.email = ['mingyuan0715@foxmail.com']
  s.homepage = 'https://github.com/qinmingyuan/qiniu_rails'
  s.summary = 'qiniu backend for activestorage'
  s.description = 'Description of ActivestorageQiniu.'
  s.license = 'LGPL-3.0'

  s.files = Dir[
    '{app,config,db,lib}/**/*',
    'LICENSE',
    'Rakefile',
    'README.md'
  ]

  s.add_dependency 'qiniu', '~> 6.9'
  s.add_dependency 'rails', '~> 5.2'
end
