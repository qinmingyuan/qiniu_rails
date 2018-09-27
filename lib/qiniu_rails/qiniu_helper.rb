# frozen_string_literal: true
require 'qiniu'
require 'qiniu_rails/qiniu_common'

module QiniuHelper
  extend QiniuCommon
  extend self
  @config ||= Rails.configuration.active_storage['service_configurations'][Rails.configuration.active_storage['service'].to_s]
  @host ||= @config['host']
  @bucket ||= @config['bucket']

  def download_url(key)
    Qiniu::Auth.authorize_download_url_2(host, key)
  end

  def qiniu_url(key)
    _host = host
    _host = host + '/' unless _host.end_with? '/'
    _host = 'http://' + _host unless _host.start_with? 'http://'
    _host + key.to_s
  end

  def upload(local_file, key = nil, **options)
    code, result, response_headers = upload_verbose(local_file, key, options)
    result['key']
  end

  def delete(key)
    code, result, response_headers = Qiniu::Storage.delete(
      bucket,
      key
    )
    code
  end

end
