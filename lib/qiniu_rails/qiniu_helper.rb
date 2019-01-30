# frozen_string_literal: true
require 'qiniu'
require 'qiniu_rails/qiniu_common'

module QiniuHelper
  extend QiniuCommon
  extend self
  @config ||= Rails.configuration.active_storage['service_configurations'][Rails.configuration.active_storage['service'].to_s]
  @protocol ||= @config['protocol'] || 'https'
  @host ||= @config['host']
  @bucket ||= @config['bucket']
  @pipeline ||= @config['pipeline']
  @bucket_private ||= @config['private']

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

  def av_concat(key, format: 'mp3', index: 2, keys: [], prefix: '00')
    urls = keys.map { |k| Qiniu::Utils.urlsafe_base64_encode download_url(k) }
    saveas_key = Qiniu::Utils.urlsafe_base64_encode("#{bucket}:#{prefix}_#{key}")
    api = "avconcat/2/format/#{format}/index/#{index}/" + urls.join('/')
    fops = api + '|saveas/' + saveas_key

    pfops(key, fops)
  end

  def av_watermark(key, wm_url, format: 'mp4', gravity: 'NorthWest', prefix: '01')
    url = Qiniu::Utils.urlsafe_base64_encode(wm_url)
    saveas_key = Qiniu::Utils.urlsafe_base64_encode("#{bucket}:#{prefix}_#{key}")
    api = "avthumb/#{format}/wmImage/#{url}/wmGravity/#{gravity}"
    fops = api + '|saveas/' + saveas_key

    pfops(key, fops)
  end

  def prefop(persistent_id)
    code, result, response_headers = Qiniu::Fop::Persistance.prefop(persistent_id)
    puts result
    result
  end

  def avinfo(key)
    code, result, res = Qiniu::HTTP.api_get(download_url(key, fop: 'avinfo'))
    result['streams']
  end

  def pfops(key, fops)
    pfops = Qiniu::Fop::Persistance::PfopPolicy.new(
      bucket,
      key,
      fops,
      @config['notify_url']
    )
    pfops.pipeline = @pipeline

    code, result, response_headers = Qiniu::Fop::Persistance.pfop(pfops)
    puts result
    result
  end

end
