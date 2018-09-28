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

  def av_concat(key, format: 'mp3')
    saveas_key = Qiniu::Utils.urlsafe_base64_encode("#{bucket}:#{key}")
    api = "avconcat/2/format/#{format}/index"
    fops = api + '|saveas/' + saveas_key


    pfops = Qiniu::Fop::Persistance::PfopPolicy.new(
      bucket,
      key,
      fops,
      @config['notify_url']
    )
    pfops.pipeline = pipeline
    code, result, response_headers = Qiniu::Fop::Persistance.pfop(pfops)
    result
  end

end
