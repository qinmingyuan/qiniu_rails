module QiniuRails
  class Engine < ::Rails::Engine

    initializer 'qiniu_rails.variant' do
      require 'active_storage/variant'
      ActiveStorage::Variant.prepend QiniuRails::Variant
    end

  end
end
