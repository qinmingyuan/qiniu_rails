require 'sprockets/exporters/base'

# Writes a an asset file to Qiniu
class QiniuExporter < Sprockets::Exporters::Base

  def skip?(logger)
    if Sprockets.config[:sync].to_s == 'qiniu'
      logger.info "==> To Upload to Qiniu: #{ target }"
      false
    else
      true
    end
  end

  def call
    QiniuHelper.upload target, 'assets/' + asset.digest_path.to_s
  end

end

Sprockets.register_exporter '*/*', QiniuExporter
