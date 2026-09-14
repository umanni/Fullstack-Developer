FactoryBot.define do
  factory :user do
    full_name { "Ada Lovelace" }
    sequence(:email_address) { |n| "user#{n}@example.com" }
    password { "password" }

    trait :admin do
      role { :admin }
    end

    trait :with_avatar_image do
      after(:build) do |user|
        user.avatar_image.attach(
          io: Rails.root.join("spec/fixtures/files/avatar.png").open,
          filename: "avatar.png",
          content_type: "image/png"
        )
      end
    end

    trait :with_avatar_url do
      avatar_url { "https://cdn.example.com/avatars/ada.png" }
    end
  end
end
