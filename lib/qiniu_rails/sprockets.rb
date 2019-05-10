# frozen_string_literal: true

require_relative 'sprockets/qiniu_exporter'
require_relative 'sprockets/qiniu_non_digest_assets'

module Sprockets

  def self.sync
    config[:sync]
  end

  def self.sync=(sync)
    self.config = hash_reassoc(config, :sync) { sync.dup }
  end

end
