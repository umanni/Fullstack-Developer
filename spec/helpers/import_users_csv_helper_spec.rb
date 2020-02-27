# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImportUsersCsvHelper do
  subject { described_class.import_csv(csv_file) }

  context 'with valid csv' do
    let(:csv_file) { File.new(fixture_path + '/csv/users_valid.csv') }

    it 'returns true when succeed' do
      expect(subject).to be true
    end

    it 'successfully import users to database' do
      expect{subject}.to change{User.count}.by(4)
    end
  end

  context 'with invalid csv' do
    let(:csv_file) { File.new(fixture_path + '/csv/users_invalid.csv') }

    it 'returns false when an error occurred' do
      expect(subject).to be false
    end

    it 'do not import users to database' do
      expect{subject}.to_not change{User.count}
    end
  end

  context 'without csv' do
    let(:csv_file) { nil }

    it 'returns false when csv_file is nil' do
      expect(subject).to be false
    end

    it 'do not import users to database' do
      expect{subject}.to_not change{User.count}
    end
  end
end
