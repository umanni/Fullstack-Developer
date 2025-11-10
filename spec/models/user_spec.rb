require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject { build(:user) }

    it { should validate_presence_of(:full_name) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:role) }

    it {
      should define_enum_for(:role).with_values({
        admin: "admin", no_admin: "no_admin"
      }).backed_by_column_of_type(:enum)
    }

    context 'email' do
      it 'is unique' do
        user1 = create(:user)
        user2 = build(:user, email: user1.email)

        user2.valid?

        expect(user2.errors[:email]).to eq([ "has already been taken" ])
      end

      it 'has a valid format' do
        user1 = build(:user, email: 'usernamedomain.com')
        user2 = build(:user, email: 'username@@domain.com')
        user3 = build(:user, email: 'user name@domain.com')
        user4 = build(:user, email: 'user@domain..com')
        user5 = build(:user, email: '.user@domain.com')

        user1.valid?
        user2.valid?
        user3.valid?
        user4.valid?
        user5.valid?

        expect(user1.errors[:email]).to include("is invalid")
        expect(user2.errors[:email]).to include("is invalid")
        expect(user3.errors[:email]).to include("is invalid")
        expect(user4.errors[:email]).to include("is invalid")
        expect(user5.errors[:email]).to include("is invalid")
      end
    end


    context '#avatar_image_content_type' do
      it 'is valid if avatar_image is png' do
        subject.avatar_image.content_type = 'image/png'

        expect(subject).to be_valid
      end

      it 'is valid if avatar_image is jpeg' do
        subject.avatar_image.content_type = 'image/jpeg'
        expect(subject).to be_valid
      end

      it 'is valid if avatar_image is jpg' do
        subject.avatar_image.content_type = 'image/jpg'
        expect(subject).to be_valid
      end

      it 'is invalid if avatar_image is gif' do
        subject.avatar_image.content_type = 'image/gif'

        expect(subject).not_to be_valid
        expect(subject.errors[:avatar_image]).to include('must be a JPG, JPEG or PNG')
      end
    end
  end

  describe 'default role' do
    it 'is no_admin by default' do
      user = User.new(full_name: 'João Silva', email: 'jsilva@email.com', password: '123456')
      user.avatar_image.attach(
        io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'avatar_image.jpg')),
        filename: 'avatar_image.jpg',
        content_type: 'image/jpg'
      )

      user.save!

      expect(user.role).to eq('no_admin')
    end
  end

  describe '#generate_password' do
    it 'generates a password for basic users' do
      expect(User.count).to eq 0

      user = User.new(full_name: 'Abel A', email: 'a@email.com')
      user.avatar_image.attach(
        io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'avatar_image.jpg')),
        filename: 'avatar_image.jpg',
        content_type: 'image/jpg'
      )
      user.save!

      expect(User.count).to eq 1
      expect(User.last.full_name).to eq('Abel A')
    end
  end
end
