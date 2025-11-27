FactoryBot.define do
  factory :user do
    full_name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    password { 'password123' }
    password_confirmation { 'password123' }
    role { :user }

    trait :admin do
      role { :admin }
    end

    trait :with_avatar_url do
      avatar_url { Faker::Internet.url }
    end
  end
end

