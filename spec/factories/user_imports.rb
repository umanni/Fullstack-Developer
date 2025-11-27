FactoryBot.define do
  factory :user_import do
    association :user, factory: :user, strategy: :create
    status { :pending }
    total_rows { 0 }
    processed_rows { 0 }
    success_count { 0 }
    error_count { 0 }
    error_messages { [] }

    after(:build) do |user_import|
      # Create a simple CSV file for testing
      csv_content = "full_name,email,role\nJohn Doe,john@example.com,user"
      file = StringIO.new(csv_content)
      user_import.spreadsheet_file.attach(
        io: file,
        filename: 'test.csv',
        content_type: 'text/csv'
      )
    end

    trait :processing do
      status { :processing }
      total_rows { 10 }
      processed_rows { 5 }
    end

    trait :completed do
      status { :completed }
      total_rows { 10 }
      processed_rows { 10 }
      success_count { 10 }
      error_count { 0 }
    end

    trait :failed do
      status { :failed }
      error_messages { ['Import failed'] }
    end
  end
end

