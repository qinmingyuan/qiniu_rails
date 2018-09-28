FactoryBot.define do
  factory :active_storage_attachment, class: 'ActiveStorage::Attachment' do
    association :record, factory: :user
    association :blob, factory: :active_storage_blob
    id { 1 }
    name { "MyString" }
    created_at { "2018-09-16 17:59:35" }
  end
end
