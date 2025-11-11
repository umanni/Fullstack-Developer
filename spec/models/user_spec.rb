require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { build(:user) }
  let(:admin) { build(:user, :admin) }

  describe 'validations' do
    it 'validates presence of required fields' do
      expect(user).to be_valid

      user.full_name = ''
      expect(user).not_to be_valid

      user.email = ''
      expect(user).not_to be_valid
    end

    it 'validates role inclusion' do
      expect { user.role = 'invalid' }.to raise_error(ArgumentError)
    end
  end

  describe 'associations' do
    it { should have_one_attached(:avatar_image) }
    it { should have_many(:imports) }
  end

  describe 'methods' do
    it 'checks admin role' do
      expect(user.admin?).to be false
      expect(admin.admin?).to be true
    end

    it 'returns display name' do
      expect(user.display_name).to eq(user.full_name)
    end

    it 'returns initials' do
      user.full_name = 'John Doe'
      expect(user.initials).to eq('JD')
    end
  end

  describe 'scopes' do
    it 'filters by role' do
      create(:user)
      create(:user, :admin)

      expect(User.admins.count).to eq(1)
      expect(User.users.count).to eq(1)
    end
  end
end
