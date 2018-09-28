require 'test_helper'

class QiniuHelperTest < ActiveSupport::TestCase
  setup do

  end

  test 'av_concat ok' do
    QiniuHelper.upload file_fixture('01.mp3'), '01.mp3'
    QiniuHelper.upload file_fixture('02.mp3'), '02.mp3'
    QiniuHelper.upload file_fixture('03.mp3'), '03.mp3'

    QiniuHelper.av_concat('01.mp3', keys: ['02.mp3', '03.mp3'])
  end


end
