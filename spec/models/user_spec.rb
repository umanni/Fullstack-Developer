require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    # Ensure presence of full_name, email and role attributes
    it { is_expected.to validate_presence_of(:full_name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:role) }
  end

  describe 'associations' do
    # Ensure User model has one attached avatar_image
    it { is_expected.to have_one_attached(:avatar_image) }
  end

  describe 'roles' do
    # Ensure the User model defines admin and user roles
    it 'defines the admin role' do
      expect(User.roles[:admin]).to eq(1)
    end

    it 'defines the user role' do
      expect(User.roles[:user]).to eq(2)
    end
  end

  describe 'devise modules' do
    # Ensure the User model has devise modules enabled
    it { is_expected.to be_database_authenticatable }
    it { is_expected.to be_registerable }
    it { is_expected.to be_recoverable }
    it { is_expected.to be_rememberable }
    it { is_expected.to be_validatable }
  end

  describe 'when creating a new user' do
    let(:user) { FactoryBot.build(:user) }

    context 'with all required attributes' do
      # Ensure a new user with all required attributes is valid
      it 'is valid' do
        expect(user).to be_valid
      end
    end

    context 'without a full name' do
      # Ensure a new user without full_name attribute is invalid
      it 'is invalid' do
        user.full_name = nil
        expect(user).to be_invalid
      end
    end

    context 'without an email' do
      # Ensure a new user without email attribute is invalid
      it 'is invalid' do
        user.email = nil
        expect(user).to be_invalid
      end
    end

    context 'without a role' do
      # Ensure a new user without role attribute is invalid
      it 'is invalid' do
        user.role = nil
        expect(user).to be_invalid
      end
    end
  end
end
