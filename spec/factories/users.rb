FactoryBot.define do
  factory :user do
    full_name { Faker::Name.name }
    email     { Faker::Internet.email }
    password  { "password123" }
    # Creates an admin user: create(:user, :admin)
    trait :admin do
      role { :admin }
    end
  end
end
