# frozen_string_literal: true
require 'qiniu_rails/qiniu_common'

module ActiveStorage
  # Wraps the Qiniu Cloud Storage as an Active Storage service. See ActiveStorage::Service for the generic API
  # documentation that applies to all services.
  class Service::QiniuService < Service
    include QiniuCommon
    attr_reader :client, :protocol

    def initialize(host:, secret_key:, access_key:, bucket:, **options)
      @host = host
      @bucket = bucket
      @protocol = (options.delete(:protocol) || 'https').to_sym
      @client = Qiniu.establish_connection!(
        access_key: access_key,
        secret_key: secret_key,
        protocal: @protocal,
        **options
      )
    end

    def upload(key, io, checksum: nil, **options)
      instrument :upload, key: key, checksum: checksum do
        begin
          code, result, response_headers = upload_verbose(io, key, options)
          result['key']
        rescue => e
          puts e.backtrace
          raise ActiveStorage::IntegrityError
        end
      end
    end

    def delete(key)
      instrument :delete, key: key do
        begin
          Qiniu::Storage.delete(bucket, key)
        rescue => e
          puts e.backtrace
        end
      end
    end

    def exist?(key)
      instrument :exist, key: key do |payload|
        answer = file_for(key)
        payload[:exist] = answer
      end
    end

    def url(key, **options)
      instrument :url, key: key do |payload|
        url = Qiniu::Auth.authorize_download_url_2(host, key, schema: protocol)
        payload[:url] = url
        url
      end
    end

    def url_for_direct_upload(key, expires_in:, content_type:, content_length:, checksum:)
      instrument :url, key: key do |payload|
        url = Qiniu::Config.up_host(bucket)
        payload[:url] = url
        url
      end
    end

    def headers_for_direct_upload(key, content_type:, checksum:, **)
      { 'Content-Type' => content_type, 'Content-MD5' => checksum, 'x-token' => generate_uptoken(key) }
    end

  end
end
