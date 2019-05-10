# frozen_string_literal: true

module QiniuRails
  class Engine < ::Rails::Engine

    initializer 'qiniu_rails.variant' do
      require 'active_storage/variant'
      if ActiveStorage::Blob.service.is_a?(ActiveStorage::Service::QiniuService)
        ActiveStorage::Variant.prepend QiniuRails::Variant
      end
    end

    initializer 'qiniu_rails.analyzers' do |app|
      if ActiveStorage::Blob.service.is_a?(ActiveStorage::Service::QiniuService)
        app.config.active_storage.analyzers = [
          ActiveStorage::Analyzer::QiniuImageAnalyzer,
          ActiveStorage::Analyzer::QiniuVideoAnalyzer
        ]
      end
    end

  end
end
