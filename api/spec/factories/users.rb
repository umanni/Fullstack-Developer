FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    image { Faker::LoremFlickr.image(size: "50x60") }
    email { Faker::Internet.email }
    password { "123456" }
    password_confirmation { "123456" }
    profile { :admin }
  end
end