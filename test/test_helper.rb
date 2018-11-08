ENV['RAILS_ENV'] = 'test'
require_relative '../test/dummy/config/environment'
require 'rails/test_help'
require 'minitest/mock'

ActiveRecord::Migrator.migrations_paths = [File.expand_path('../test/dummy/db/migrate', __dir__)]
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

if defined?(FactoryBot)
  FactoryBot.definition_file_paths << QiniuRails::Engine.root.join('test/factories')
  FactoryBot.find_definitions
end

class ActiveSupport::TestCase
  self.file_fixture_path = File.expand_path('fixtures/files', __dir__)
  Rails.configuration.active_storage.service = :qiniu
  ActiveStorage::Current.host = QiniuHelper.host
  Qiniu.establish_connection!(
    access_key: QiniuHelper.config['access_key'],
    secret_key: QiniuHelper.config['secret_key'],
    protocol: QiniuHelper.config['protocol']
  )

  include FactoryBot::Syntax::Methods
end
