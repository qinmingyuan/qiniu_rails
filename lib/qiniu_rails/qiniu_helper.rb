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

  def av_concat(key, format: 'mp3', index: 2, keys: [])
    urls = keys.map { |k| Qiniu::Utils.urlsafe_base64_encode download_url(k) }
    saveas_key = Qiniu::Utils.urlsafe_base64_encode("#{bucket}:#{key}")
    api = "avconcat/2/format/#{format}/index/#{index}/" + urls.join('/')
    fops = api + '|saveas/' + saveas_key

    pfops = Qiniu::Fop::Persistance::PfopPolicy.new(
      bucket,
      key,
      fops,
      @config['notify_url']
    )
    code, result, response_headers = Qiniu::Fop::Persistance.pfop(pfops)
    result
    binding.pry
  end

  def prefop(persistent_id)
    code, result, response_headers = Qiniu::Fop::Persistance.pfop(persistent_id)
  end

end
