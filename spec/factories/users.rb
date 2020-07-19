FactoryBot.define do
  factory :user do
    full_name { FFaker::Name.name }
    email { FFaker::Internet.email }
    password { 'changeme' }
    password_confirmation { 'changeme' }
    avatar { Rack::Test::UploadedFile.new('spec/files/user_avatar.jpg', 'image/jpg') }
  end
end
