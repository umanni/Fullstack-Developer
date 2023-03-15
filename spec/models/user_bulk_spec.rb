require 'rails_helper'

RSpec.describe UserBulk, type: :model do
  describe 'validations' do
    # Ensure presence of csv_file attribute
    it { is_expected.to validate_presence_of(:csv_file) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      # Create a user_bulk instance with the FactoryBot gem
      user_bulk = FactoryBot.build(:user_bulk)
      # Expect the user_bulk instance to be valid
      expect(user_bulk).to be_valid
    end
  end

  describe '#process_csv_file!' do
    # Set up shared variables for the tests
    let(:csv_file) { Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/user_bulk_sample.csv")) }
    let(:user_bulk) { FactoryBot.create(:user_bulk, csv_file: csv_file) }

    # Test the success cases when the CSV file is valid
    context 'when CSV file is valid' do
      it 'creates new users based on the CSV file' do
        # Expect the User.count to increase by 3 after the CSV file is processed
        expect {
          user_bulk.process_csv_file!
        }.to change { User.count }.by(3)
      end

      it 'sets a default password for each user' do
        # Process the CSV file with the user_bulk instance
        user_bulk.process_csv_file!
        # Expect the last user created to have the default password '123mudar'
        expect(User.last.valid_password?('123mudar')).to be true
      end
    end

    # Test the case when the CSV file is invalid
    context 'when CSV file is invalid' do
      it 'returns false' do
        # Create an invalid user_bulk instance
        invalid_user_bulk = FactoryBot.build(:user_bulk)
        # Expect the process_csv_file! method to return false
        expect(invalid_user_bulk.process_csv_file!).to be false
      end
    end

    # Test the case when an error occurs while processing the CSV file
    context 'when an error occurs while processing the CSV file' do
      it 'returns false' do
        # Mock the Roo::CSV.new method to raise a StandardError
        allow(Roo::CSV).to receive(:new).and_raise(StandardError)
        # Expect the process_csv_file! method to return false
        expect(user_bulk.process_csv_file!).to be false
      end
    end
  end
end
