FactoryBot.define do
  factory :active_storage_blob, class: 'ActiveStorage::Blob' do
    id { 1 }
    key { "MyString" }
    filename { "MyString" }
    content_type { 'image/jpeg' }
    metadata { "MyText" }
    byte_size { 1 }
    checksum { "MyString" }
    created_at { "2018-09-16 18:14:13" }
  end
end
