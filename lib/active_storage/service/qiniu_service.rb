# frozen_string_literal: true

require "google/cloud/storage"
require "active_support/core_ext/object/to_query"

module ActiveStorage
  # Wraps the Qiniu Cloud Storage as an Active Storage service. See ActiveStorage::Service for the generic API
  # documentation that applies to all services.
  class Service::QiniuService < Service
    attr_reader :client, :host, :secret_key, :access_key, :bucket


    def initialize(host:, secret_key:, access_key:, bucket:, **options)
      @client = Qiniu.establish_connection!(access_key: access_key, secret_key: secret_key)
      @host = host
      @bucket = bucket
    end

    def upload(key, io, checksum: nil, **options)
      instrument :upload, key, checksum: checksum do
        begin
          code, result, response_headers = upload_verbose(io, key, options)
          result['key']
        rescue
          raise ActiveStorage::IntegrityError
        end
      end
    end

    def upload_verbose(local_file, key = nil, **options)
      code, result, response_headers = Qiniu::Storage.upload_with_token_2(
        generate_uptoken(key, options),
        local_file,
        key,
        nil,
        bucket: bucket
      )
    end

    def delete(key)
      instrument :delete, key do
        begin
          code, result, response_headers = Qiniu::Storage.delete(
            bucket,
            key
          )
          code
        rescue
          # Ignore files already deleted
        end
      end
    end

    def exist?(key)
      instrument :exist, key do |payload|
        answer = file_for(key)
        payload[:exist] = answer
      end
    end

    def url(key)
      instrument :url, key do |payload|
        Qiniu::Auth.authorize_download_url_2(host, key)
      end
    end

    private
    def file_for(prefix = '')
      list_policy = Qiniu::Storage::ListPolicy.new(config['bucket'], 10, prefix, '/')
      code, result, response_headers, s, d = Qiniu::Storage.list(list_policy)
      result['items']
    end

    def generate_uptoken(key = nil, **options)
      put_policy = Qiniu::Auth::PutPolicy.new(bucket, key)
      options.slice(*Qiniu::Auth::PutPolicy::PARAMS.keys).each do |k, v|
        put_policy.send(k.to_s + '=', v)
      end
      Qiniu::Auth.generate_uptoken(put_policy)
    end

  end
end
