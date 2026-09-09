FactoryBot.define do
  factory :user do
    full_name { Faker::Name.name }
    sequence(:email_address) { |n| "user#{n}@example.com" }
    password { "a-sufficiently-long-password" }
    role { :user }

    trait :admin do
      role { :admin }
    end
  end
end
