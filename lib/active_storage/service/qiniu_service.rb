# frozen_string_literal: true
require 'qiniu_rails/qiniu_common'

module ActiveStorage
  # Wraps the Qiniu Cloud Storage as an Active Storage service. See ActiveStorage::Service for the generic API
  # documentation that applies to all services.
  class Service::QiniuService < Service
    include QiniuCommon
    attr_reader :client, :bucket_private

    def initialize(host:, secret_key:, access_key:, bucket:, **options)
      @host = host
      @bucket = bucket
      @bucket_private = options.delete(:private) || false
      @keep = options.delete(:keep) || false
      @protocol = (options.delete(:protocol) || 'https').to_s
      @client = Qiniu.establish_connection!(
        access_key: access_key,
        secret_key: secret_key,
        protocol: @protocol,
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
          Qiniu::Storage.delete(bucket, key) unless @keep
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
        uri = URI(url(key, attname: key))
        Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |client|
          client.get(uri, 'Range' => "bytes=#{range.begin}-#{range.exclude_end? ? range.end - 1 : range.end}").body
        end
      end
    end

    def url(key, **options)
      if options[:size]
        key += "-#{options.delete(:size)}"
      end
      instrument :url, key: key do |payload|
        if options[:filename].present? && options[:disposition].to_s == 'attachment'
          options[:fop] ||= ''
          options[:fop] = options[:fop] + '&' unless options[:fop].blank? || options[:fop].end_with?('&')
          options[:fop] = options[:fop] + "attname=#{URI.escape(options[:filename].to_s)}"
        end
        url = download_url(key, fop: options[:fop], expires_in: options[:expires_in], schema: protocol)
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

    def headers_for_direct_upload(key, filename:, content_type:, content_length:, checksum:)
      uptoken = generate_uptoken(key)
      _url = url(key, filename: filename)
      {
        'Content-Type' => 'application/octet-stream',
        'Content-MD5' => checksum,
        'Authorization' => "UpToken #{uptoken}",
        'Up-Token' => uptoken,
        'Content-Url' => _url
      }
    end

    def method_for_direct_upload
      'POST'
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
