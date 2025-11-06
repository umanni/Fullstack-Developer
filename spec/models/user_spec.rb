require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:full_name) }
    # Test Devise validation (email presence)
    it { should validate_presence_of(:email) }
    # Test uniqueness (after creating one user)
    subject { create(:user) }
    it { should validate_uniqueness_of(:email).case_insensitive }
  end

  describe 'associations' do
    it { should have_one_attached(:avatar_image) }
  end

  describe 'enums' do
    # Test that the enum is defined correctly
    it { should define_enum_for(:role).with_values(user: 0, admin: 1) }

    it 'defaults to :user role' do
      user = User.new
      expect(user.role).to eq('user')
      expect(user.user?).to be(true)
    end

    it 'can be set to :admin role' do
      admin = build(:user, :admin)
      expect(admin.role).to eq('admin')
      expect(admin.admin?).to be(true)
    end
  end
end
