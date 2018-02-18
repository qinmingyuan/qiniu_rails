# frozen_string_literal: true
require 'activestorage_qiniu/qiniu_helper'

module ActiveStorage
  # Wraps the Qiniu Cloud Storage as an Active Storage service. See ActiveStorage::Service for the generic API
  # documentation that applies to all services.
  class Service::QiniuService < Service
    attr_reader :client

    def initialize(host:, secret_key:, access_key:, bucket:, **options)
      @client = Qiniu.establish_connection!(access_key: access_key, secret_key: secret_key)
      @host = host
      @bucket = bucket
    end

    def upload(key, io, checksum: nil, **options)
      instrument :upload, key: key, checksum: checksum do
        begin
          code, result, response_headers = upload_verbose(io, key, options)
          result['key']
        rescue
          raise ActiveStorage::IntegrityError
        end
      end
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

    def url(key, **options)
      instrument :url, key: key do |payload|
        Qiniu::Auth.authorize_download_url_2(host, key)
      end
    end

    def headers_for_direct_upload(key, content_type:, checksum:, **)
      { 'Content-Type' => content_type, 'Content-MD5' => checksum, 'x-token' => generate_uptoken(key) }
    end

  end
end
