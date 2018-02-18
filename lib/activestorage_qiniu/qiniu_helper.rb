# frozen_string_literal: true
require 'qiniu'
require 'activestorage_qiniu'

module QiniuHelper
  extend QiniuCommon
  extend self
  @config ||= Rails.application.config_for('qiniu')
  @host ||= @config['host']
  @bucket ||= @config['bucket']

  def download_url(key)
    Qiniu::Auth.authorize_download_url_2(host, key)
  end

  def qiniu_url(key)
    host << '/' unless host.end_with? '/'
    host + key.to_s
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
