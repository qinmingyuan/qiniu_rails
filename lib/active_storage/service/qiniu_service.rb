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

    def delete_prefixed(prefix)
      instrument :delete_prefixed, prefix: prefix do
        file_for(prefix).each { |item| delete item['key'] }
      end
    end

    def exist?(key)
      instrument :exist, key: key do |payload|
        answer = file_for(key)
        payload[:exist] = answer
      end
    end

    def download(key, &block)
      if block_given?
        instrument :streaming_download, key: key do
          open(url(key, attname: key)) do |file|
            while data = file.read(64.kilobytes)
              yield data
            end
          end
        end
      else
        instrument :download, key: key do
          open(url(key, attname: key)).read
        end
      end
    end

    def download_chunk(key, range)
      instrument :download_chunk, key: key, range: range do
        uri = URI(url(key, expires_in: 30.seconds, attname: key))
        Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |client|
          client.get(uri, 'Range' => "bytes=#{range.begin}-#{range.exclude_end? ? range.end - 1 : range.end}").body
        end
      end
    end

    def url(key, **options)
      instrument :url, key: key do |payload|
        if options[:attname].present?
          options[:fop] = options[:fop].to_s + '&'
          options[:fop] << "attname=#{URI.escape(options[:attname])}"
        end
        url = Qiniu::Auth.authorize_download_url_2(host, key, fop: options[:fop], expires_in: options[:expires_in], schema: protocol)
        payload[:url] = url
        url
      end
    end

    def url_for_direct_upload(key, expires_in:, content_type:, content_length:, checksum:)
      instrument :url, key: key do |payload|
        url = Qiniu::Config.up_host(bucket) + "/mkblk/#{content_length}"
        payload[:url] = url
        url
      end
    end

    def headers_for_direct_upload(key, filename:, content_type:, content_length:, checksum:)
      {
        'Content-Type' => 'application/octet-stream',
        'Content-MD5' => checksum,
        'Authorization' => "UpToken #{generate_uptoken(key)}"
      }
    end

    private
    # Reads the object for the given key in chunks, yielding each to the block.
    def stream(key)
      object = object_for(key)

      chunk_size = 5.megabytes
      offset = 0

      while offset < object.content_length
        yield object.get(range: "bytes=#{offset}-#{offset + chunk_size - 1}").body.read.force_encoding(Encoding::BINARY)
        offset += chunk_size
      end
    end

  end
end
