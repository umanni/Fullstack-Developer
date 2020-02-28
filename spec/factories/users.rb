# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    full_name { Faker::Name.unique.name }
    email { Faker::Internet.safe_email(full_name) }
    photo { Helpers::ImageUpload.fixture_image }
    password { 'password' }
    password_confirmation { 'password' }
    created_at { Time.zone.local(2019, 1, 18, 6, 28, 0) }

    trait :non_admin do
      role { "non_admin" }
    end

    trait :admin do
      role { "admin" }
    end
  end
end
