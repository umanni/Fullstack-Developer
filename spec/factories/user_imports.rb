FactoryBot.define do
  factory :user_import do
    administrator factory: %i[user admin]

    trait :with_csv do
      after(:build) do |import|
        import.file.attach(
          io: Rails.root.join("spec/fixtures/files/users.csv").open,
          filename: "users.csv",
          content_type: "text/csv"
        )
      end
    end
  end
end
