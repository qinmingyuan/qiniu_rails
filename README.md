# Qiniu Rails
qiniu backend for activestorage and more

## Features
* Qiniu backend for activestorage;
* QiniuHelper for simple independent use;
* Qiniu extends for sprockets

## Config

```yaml
# config/qiniu.yml
default: &default
  host: http://examples.com/
  bucket: 
  access_key: 
  secret_key: 

development:
  <<: *default

staging:
  <<: *default

test:
  <<: *default

production:
  <<: *default
  host: http://assets.yigexiangfa.com/
  bucket: example
  
# config/storage.yml
qiniu:
  service: Qiniu
  host: xxxx.com1.z0.glb.clouddn.com  
  access_key: iX6NuM1xN04Wdh-DogI0F3jLVpc-A4CsTHETssss
  secret_key: aN44R3yzJFaeswbyM4Y8YaJvnkmsssssssss
  bucket: xxxx  
```

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'qiniu_rails'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install qiniu_rails
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
