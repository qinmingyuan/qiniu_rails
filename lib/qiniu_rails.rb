# frozen_string_literal: true

require_relative 'qiniu_rails/engine'
require_relative 'qiniu_rails/variant'

require_relative 'active_storage/service/qiniu_service'

require_relative 'active_storage/analyzer/qiniu_image_analyzer'
require_relative 'active_storage/analyzer/qiniu_video_analyzer'

autoload :QiniuHelper, 'qiniu_rails/qiniu_helper'
autoload :Sprockets, 'qiniu_rails/sprockets'
