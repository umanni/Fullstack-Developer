FactoryBot.define do
  factory :spreadsheet_import do
    association :user, factory: [ :user, :admin ]
    status { :pending }

    after(:build) do |spreadsheet_import|
      spreadsheet_import.file.attach(
        io: StringIO.new("nome,email\nFixture User,fixture@example.com\n"),
        filename: "import.csv",
        content_type: "text/csv"
      )
    end
  end

  factory :spreadsheet_import_row_error do
    association :spreadsheet_import
    sequence(:row_number) { |n| n + 1 }
    message { "E-mail não pode ficar em branco" }
    raw_data { { "nome" => "Missing E-mail", "email" => "" }.to_json }
  end
end
