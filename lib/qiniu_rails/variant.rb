# frozen_string_literal: true

module QiniuRails::Variant

  def key
    "#{blob.key}"
  end

  def mode_1
    h, w = variation.transformations.fetch(:resize, '35x35').split('x')
    "imageView2/1/w/#{w}/h/#{h}"
  end

  def service_url(expires_in: ActiveStorage.service_urls_expire_in, disposition: :inline)
    service.url key, fop: mode_1, expires_in: expires_in, disposition: disposition, filename: filename, content_type: content_type
  end

end


