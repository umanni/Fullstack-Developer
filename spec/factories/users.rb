FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "testuser#{n}" }
    password { "senha123" }
    role { "user" }

    trait :admin do
      role { "admin" }
    end
  end
end
