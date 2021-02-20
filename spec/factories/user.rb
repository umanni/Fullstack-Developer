FactoryBot.define do
    factory :user do
        full_name {Faker::Name.name}
        email {Faker::Internet.email}
        avatar_image {'not-avaliable'}
        admin {false}
        password {'123456'}
        password_confirmation {'123456'}
    end
end
