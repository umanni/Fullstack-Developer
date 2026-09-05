FactoryBot.define do
  factory :user do
    sequence(:full_name) { |n| "#{Faker::Name.name} #{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    role { :no_admin }

    trait :admin do
      role { :admin }
    end

    trait :with_avatar do
      after(:build) do |user|
        user.avatar.attach(
          io: StringIO.new("fake-image-bytes"),
          filename: "avatar.png",
          content_type: "image/png"
        )
      end
    end
  end
end
