FactoryBot.define do
  factory :user_bulk do
    state { 1 }
    file { Rack::Test::UploadedFile.new('spec/files/user_bulk_file.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet') }
  end
end
