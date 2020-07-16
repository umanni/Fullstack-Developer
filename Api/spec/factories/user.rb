FactoryBot.define do
  factory :user do
    full_name    { FFaker::Lorem.word }
    email        { FFaker::Internet.email }
    password     { FFaker::Internet.password }
    role         ['admin','noadmin'].sample
  end
end