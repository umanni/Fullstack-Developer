require 'rails_helper'
require 'stringio'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:full_name) }
    it { should validate_presence_of(:email) }
    it { should validate_length_of(:full_name).is_at_least(2).is_at_most(100) }
    
    it 'validates email format' do
      user = build(:user, email: 'invalid_email')

      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('is invalid')
    end

    it 'validates email uniqueness' do
      create(:user, email: 'test@example.com')
      user = build(:user, email: 'test@example.com')

      expect(user).not_to be_valid
    end
  end

  describe 'enums' do
    it { should define_enum_for(:role).with_values(user: 0, admin: 1) }
  end

  describe 'default values' do
    it 'sets default role as user' do
      user = User.new(full_name: 'Test', email: 'test@example.com', password: '123456')

      expect(user.role).to eq('user')
    end
  end

  describe 'role methods' do
    let(:user) { create(:user) }
    let(:admin) { create(:user, :admin) }

    it 'checks if user is admin' do
      expect(user.admin?).to be false
      expect(admin.admin?).to be true
    end

    it 'checks if user is regular user' do
      expect(user.user?).to be true
      expect(admin.user?).to be false
    end
  end

  describe 'avatar attachment' do
    it 'has one attached avatar' do
      user = build(:user)
      expect(user).to respond_to(:avatar)
    end

    it 'validates file size' do
      user = build(:user)
      
      fake_file_io = StringIO.new('a' * 6.megabytes) 

      user.avatar.attach(
        io: fake_file_io,
        filename: 'large_file.png',
        content_type: 'image/png'
      )
      
      user.valid?
      
      expect(user.errors[:avatar]).to include('is too large (max 5MB)')
    end

    it 'validates content type' do
      user = build(:user)
      
      fake_file_io = StringIO.new('this is not an image') 
      
      user.avatar.attach(
        io: fake_file_io,
        filename: 'test.txt',
        content_type: 'text/plain'
      )
      
      user.valid?
      
      expect(user.errors[:avatar]).to include('must be a JPEG, PNG, or GIF')
    end
  end

  describe 'authorization helpers' do
    let(:user) { create(:user) }
    let(:admin) { create(:user, :admin) }

    it 'user cannot be admin' do
      expect(user.admin?).to be false
    end

    it 'admin is admin' do
      expect(admin.admin?).to be true
    end

    it 'can change user to admin' do
      user.admin!
      expect(user.admin?).to be true
    end

    it 'can change admin to user' do
      admin.user!
      expect(admin.user?).to be true
    end
  end
end