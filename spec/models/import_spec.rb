require 'rails_helper'

RSpec.describe Import, type: :model do
  let(:import) { build(:import) }

  describe 'validations' do
    it 'validates required fields' do
      expect(import).to be_valid

      import.file_name = ''
      expect(import).not_to be_valid
    end

    it 'validates status inclusion' do
      import.status = 'invalid'
      expect(import).not_to be_valid
    end
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_one_attached(:file) }
  end

  describe 'status methods' do
    it 'checks status' do
      import.status = 'pending'
      expect(import.pending?).to be true

      import.status = 'processing'
      expect(import.processing?).to be true

      import.status = 'completed'
      expect(import.completed?).to be true

      import.status = 'failed'
      expect(import.failed?).to be true
    end
  end

  describe 'progress calculation' do
    it 'calculates progress' do
      import.total_rows = 100
      import.processed_rows = 25
      expect(import.calculate_progress).to eq(25.0)
    end

    it 'handles zero total rows' do
      import.total_rows = 0
      expect(import.calculate_progress).to eq(0)
    end
  end
end
