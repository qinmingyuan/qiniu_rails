require 'qiniu_rails/sprockets/qiniu_exporter'
require 'qiniu_rails/sprockets/qiniu_non_digest_assets'

module Sprockets

  def self.sync
    config[:sync]
  end

  def self.sync=(sync)
    self.config = hash_reassoc(config, :sync) { sync.dup }
  end

end
