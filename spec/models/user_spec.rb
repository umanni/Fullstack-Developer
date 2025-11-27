require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:full_name) }
    it { is_expected.to validate_length_of(:full_name).is_at_least(2).is_at_most(100) }
    it { is_expected.to validate_presence_of(:email) }
    
    it 'validates uniqueness of email case-insensitively' do
      create(:user, email: 'test@example.com')
      user = build(:user, email: 'TEST@example.com')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('has already been taken')
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:user_imports).dependent(:destroy) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:role).with_values(user: 0, admin: 1) }
  end

  describe '#admin?' do
    context 'when user is admin' do
      let(:user) { create(:user, :admin) }

      it 'returns true' do
        expect(user.admin?).to be true
      end
    end

    context 'when user is not admin' do
      let(:user) { create(:user) }

      it 'returns false' do
        expect(user.admin?).to be false
      end
    end
  end

  describe '#display_avatar' do
    context 'when user has attached avatar' do
      let(:user) { create(:user) }

      before do
        # Create a simple test image in memory (1x1 PNG)
        png_data = "\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x06\x00\x00\x00\x1f\x15\xc4\x89\x00\x00\x00\nIDATx\x9cc\x00\x01\x00\x00\x05\x00\x01\r\n-\xdb\x00\x00\x00\x00IEND\xaeB`\x82"
        file = StringIO.new(png_data)
        
        user.avatar_image.attach(
          io: file,
          filename: 'test.png',
          content_type: 'image/png'
        )
      end

      it 'returns attached image' do
        expect(user.display_avatar).to eq(user.avatar_image)
      end
    end

    context 'when user has avatar_url' do
      let(:user) { create(:user, :with_avatar_url) }

      it 'returns avatar_url' do
        expect(user.display_avatar).to eq(user.avatar_url)
      end
    end

    context 'when user has no avatar' do
      let(:user) { create(:user) }

      it 'returns default placeholder' do
        expect(user.display_avatar).to eq('https://via.placeholder.com/150')
      end
    end
  end
end

