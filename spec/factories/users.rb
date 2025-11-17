require 'faker'

FactoryBot.define do
  factory :user do
    full_name { "Regular User" }
    email { Faker::Internet.email }
    password { "password123" }
    admin { false }

    trait :admin do
      admin { true }
    end
  end
end
