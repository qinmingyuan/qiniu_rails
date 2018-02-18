# frozen_string_literal: true
require 'qiniu'
module QiniuCommon
  attr_reader :host, :bucket

  private
  def upload_verbose(local_file, key = nil, **options)
    code, result, response_headers = Qiniu::Storage.upload_with_token_2(
      generate_uptoken(key, options),
      local_file,
      key,
      nil,
      bucket: bucket
    )
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