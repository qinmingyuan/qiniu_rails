require 'active_storage/service/qiniu_service'

require 'active_storage/analyzer/qiniu_image_analyzer'
require 'active_storage/analyzer/qiniu_video_analyzer'

require 'qiniu_rails/sprockets'
require 'qiniu_rails/engine'
require 'qiniu_rails/variant'

autoload :QiniuHelper, 'qiniu_rails/qiniu_helper'

module QiniuRails
end
