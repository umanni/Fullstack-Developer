FactoryBot.define do
  factory :import do
    association :user
    file_name { "users.csv" }
    status { "pending" }
    progress { 0.0 }
    total_rows { 0 }
    processed_rows { 0 }
    successful_rows { 0 }
    failed_rows { 0 }
    error_details { "" }

    trait :processing do
      status { "processing" }
      progress { 25.0 }
      total_rows { 100 }
      processed_rows { 25 }
      successful_rows { 20 }
      failed_rows { 5 }
    end

    trait :completed do
      status { "completed" }
      progress { 100.0 }
      total_rows { 100 }
      processed_rows { 100 }
      successful_rows { 95 }
      failed_rows { 5 }
    end

    trait :failed do
      status { "failed" }
      error_details { "Import failed: Invalid file format" }
    end

    trait :with_file do
      after(:build) do |import|
        import.file.attach(
          io: StringIO.new("full_name,email\nJohn Doe,john@example.com"),
          filename: import.file_name,
          content_type: 'text/csv'
        )
      end
    end
  end
end
