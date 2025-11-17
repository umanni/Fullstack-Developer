require "rails_helper"

RSpec.describe CsvImportUsersService do
  let(:service) { described_class.new }
  let(:file_path) { Rails.root.join("spec/fixtures/files/users.csv") }
  let(:file) { Rack::Test::UploadedFile.new(file_path, "text/csv") }

  describe "#call" do
    it "creates users from a valid CSV file" do
      expect { service.call(file) }
        .to change(User, :count).by(2)
    end

    it "creates users with correct attributes" do
      service.call(file)
      user = User.find_by(email: "john@example.com")

      expect(user.full_name).to eq("John Doe")
      expect(user.valid_password?("password123")).to be true
    end

    it "skips rows where the email already exists" do
      create(:user, email: "john@example.com")

      expect { service.call(file) }
        .to change(User, :count).by(1)
    end

    it "handles extra spaces in first and last name via squish" do
      csv_with_spaces = <<~CSV
        First Name,Surname,Email Address,Password
          John   ,   Doe   ,spaces@example.com,password123
      CSV

      temp = Tempfile.new
      temp.write(csv_with_spaces)
      temp.rewind

      uploaded = Rack::Test::UploadedFile.new(temp.path, "text/csv")

      service.call(uploaded)
      user = User.find_by(email: "spaces@example.com")

      expect(user.full_name).to eq("John Doe")

      temp.close
      temp.unlink
    end

    it "does not raise errors if a row is malformed" do
      bad_csv = <<~CSV
        First Name,Surname,Email Address,Password
        John,Doe,,password123
      CSV

      temp = Tempfile.new
      temp.write(bad_csv)
      temp.rewind

      uploaded = Rack::Test::UploadedFile.new(temp.path, "text/csv")

      expect { service.call(uploaded) }.not_to raise_error
      expect(User.count).to eq(0)

      temp.close
      temp.unlink
    end
  end
end
