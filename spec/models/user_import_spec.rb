require 'rails_helper'

RSpec.describe UserImport, type: :model do
  let(:admin) { create(:user, :admin) }

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_one_attached(:spreadsheet_file) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:spreadsheet_file) }

    context 'when file type is invalid' do
      let(:invalid_file) do
        Rack::Test::UploadedFile.new(
          StringIO.new('invalid'),
          'text/plain',
          original_filename: 'test.txt'
        )
      end

      it 'adds error for invalid file type' do
        import = UserImport.new(user: admin)
        import.spreadsheet_file.attach(invalid_file)
        import.valid?
        expect(import.errors[:spreadsheet_file]).to include('must be a valid Excel or CSV file')
      end
    end

    context 'when file type is valid' do
      it 'accepts CSV files' do
        csv_content = "full_name,email\nJohn Doe,john@example.com"
        file = StringIO.new(csv_content)
        import = UserImport.new(user: admin)
        import.spreadsheet_file.attach(
          io: file,
          filename: 'test.csv',
          content_type: 'text/csv'
        )
        expect(import).to be_valid
      end

      it 'accepts XLSX files' do
        file = StringIO.new('test')
        import = UserImport.new(user: admin)
        import.spreadsheet_file.attach(
          io: file,
          filename: 'test.xlsx',
          content_type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        )
        expect(import).to be_valid
      end

      it 'accepts XLS files' do
        file = StringIO.new('test')
        import = UserImport.new(user: admin)
        import.spreadsheet_file.attach(
          io: file,
          filename: 'test.xls',
          content_type: 'application/vnd.ms-excel'
        )
        expect(import).to be_valid
      end
    end
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:status).with_values(pending: 0, processing: 1, completed: 2, failed: 3) }
  end

  describe 'scopes' do
    let!(:import1) { create(:user_import, user: admin, created_at: 2.days.ago) }
    let!(:import2) { create(:user_import, user: admin, created_at: 1.day.ago) }
    let!(:import3) { create(:user_import, user: admin, created_at: Time.current) }

    describe '.recent' do
      it 'returns imports ordered by created_at desc' do
        expect(UserImport.recent.to_a).to eq([import3, import2, import1])
      end
    end

    describe '.by_status' do
      let!(:pending_import) { create(:user_import, user: admin, status: :pending) }
      let!(:completed_import) { create(:user_import, user: admin, status: :completed) }

      it 'returns imports filtered by status' do
        expect(UserImport.by_status(:pending)).to include(pending_import)
        expect(UserImport.by_status(:pending)).not_to include(completed_import)
      end
    end
  end

  describe '#progress_percentage' do
    context 'when total_rows is zero' do
      let(:import) { create(:user_import, total_rows: 0) }

      it 'returns 0' do
        expect(import.progress_percentage).to eq(0)
      end
    end

    context 'when processed_rows is less than total_rows' do
      let(:import) { create(:user_import, total_rows: 10, processed_rows: 5) }

      it 'returns correct percentage' do
        expect(import.progress_percentage).to eq(50.0)
      end
    end

    context 'when processed_rows equals total_rows' do
      let(:import) { create(:user_import, total_rows: 10, processed_rows: 10) }

      it 'returns 100' do
        expect(import.progress_percentage).to eq(100.0)
      end
    end

    context 'when processed_rows is greater than total_rows' do
      let(:import) { create(:user_import, total_rows: 10, processed_rows: 12) }

      it 'returns percentage greater than 100' do
        expect(import.progress_percentage).to be > 100
      end
    end

    context 'when values are nil' do
      let(:import) { create(:user_import, total_rows: nil, processed_rows: nil) }

      it 'handles nil values gracefully' do
        expect(import.progress_percentage).to eq(0)
      end
    end
  end

  describe '#finished?' do
    context 'when status is completed' do
      let(:import) { create(:user_import, :completed) }

      it 'returns true' do
        expect(import.finished?).to be true
      end
    end

    context 'when status is failed' do
      let(:import) { create(:user_import, :failed) }

      it 'returns true' do
        expect(import.finished?).to be true
      end
    end

    context 'when status is processing' do
      let(:import) { create(:user_import, :processing) }

      it 'returns false' do
        expect(import.finished?).to be false
      end
    end

    context 'when status is pending' do
      let(:import) { create(:user_import, :pending) }

      it 'returns false' do
        expect(import.finished?).to be false
      end
    end
  end
end

