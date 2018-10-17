# frozen_string_literal: true
require 'qiniu'
module QiniuCommon
  attr_reader :config, :protocol, :host, :bucket, :bucket_private

  def upload_verbose(local_file, key = nil, **options)
    code, result, response_headers = Qiniu::Storage.upload_with_token_2(
      generate_uptoken(key, options),
      local_file,
      key,
      nil,
      bucket: bucket
    )
  end

  def download_url(key, **options)
    if bucket_private
      Qiniu::Auth.authorize_download_url_2(host, key, **options)
    else
      url_encoded_key = CGI::escape(key)
      url = URI::Generic.build(host: host, scheme: protocol, path: '/' + url_encoded_key)
      o = options.compact.slice(:fop)
      if o.key?(:fop)
        url.query = o.delete(:fop)
      end
      url.to_s
    end
  end

  def file_for(prefix = '')
    list_policy = Qiniu::Storage::ListPolicy.new(bucket, 10, prefix, '/')
    code, result, response_headers, s, d = Qiniu::Storage.list(list_policy)
    result['items']
  end

  def generate_uptoken(key = nil, expires_in: Qiniu::Auth::DEFAULT_AUTH_SECONDS, deadline: nil,  **options)
    put_policy = Qiniu::Auth::PutPolicy.new(bucket, key, expires_in, deadline)
    options.slice(*Qiniu::Auth::PutPolicy::PARAMS.keys).each do |k, v|
      put_policy.send("#{k}=", v)
    end
    Qiniu::Auth.generate_uptoken(put_policy)
  end

end
