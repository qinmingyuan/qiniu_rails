module QiniuRails
  class Engine < ::Rails::Engine

    initializer 'qiniu_rails.variant' do
      require 'active_storage/variant'
      if ActiveStorage::Blob.service.is_a?(ActiveStorage::Service::QiniuService)
        ActiveStorage::Variant.prepend QiniuRails::Variant
      end
    end

  end
end
