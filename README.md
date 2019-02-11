# Qiniu Rails
qiniu backend for activestorage and more

## Features
* Qiniu backend for activestorage;
* QiniuHelper for simple independent use;
* Qiniu extends for sprockets

## Config

```yaml
# config/storage.yml
qiniu:
  service: Qiniu
  host: xxxx.com1.z0.glb.clouddn.com  
  access_key: iX6NuM1xN04Wdh-DogI0F3jLVpc-A4CsTHETssss
  secret_key: aN44R3yzJFaeswbyM4Y8YaJvnkmsssssssss
  bucket: xxxx 
  notify_url: xxx 
  private: true
  protocol: https
  keep: false # 是否真正删除
  block: false # 是否启用分片上传
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

## Direct Upload
* dependent on JS http client sdk `axios`, please add it to your rails project first;
* then `require qiniu_direct_upload` in js file where you used qiniu direct upload;

## Assets Sync(Sprockets) support
* add `Sprockets.sync = 'qiniu'` to your initializers file

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
