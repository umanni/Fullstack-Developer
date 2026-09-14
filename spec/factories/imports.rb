FactoryBot.define do
  factory :import do
    user { association :user, :admin }

    transient { rows { [ [ "Ada Lovelace", "ada@example.test", "admin" ] ] } }

    after(:build) do |import, evaluator|
      csv = CSV.generate do |out|
        out << %w[full_name email role]
        evaluator.rows.each { out << _1 }
      end

      import.file.attach(
        io: StringIO.new(csv), filename: "users.csv", content_type: "text/csv"
      )
    end
  end
end
