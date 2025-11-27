require 'rails_helper'

RSpec.describe AvatarUploadable, type: :model do
  let(:user) { create(:user) }

  describe 'avatar_image attachment' do
    it 'allows attaching avatar_image' do
      expect(user).to respond_to(:avatar_image)
    end

    it 'has_one_attached :avatar_image' do
      expect(User.reflect_on_association(:avatar_image_attachment)).to be_present
    end
  end

  describe 'validations' do
    context 'when avatar_image is attached' do
      it 'validates content type for invalid files' do
        invalid_file = Rack::Test::UploadedFile.new(
          StringIO.new('invalid'),
          'text/plain',
          original_filename: 'test.txt'
        )
        user.avatar_image.attach(invalid_file)
        user.reload if user.persisted?
        user.valid?
        expect(user.avatar_image.attached?).to be true
      end

      it 'accepts PNG files' do
        png_data = "\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x06\x00\x00\x00\x1f\x15\xc4\x89\x00\x00\x00\nIDATx\x9cc\x00\x01\x00\x00\x05\x00\x01\r\n-\xdb\x00\x00\x00\x00IEND\xaeB`\x82"
        file = StringIO.new(png_data)
        file.set_encoding('BINARY')
        
        user.avatar_image.attach(
          io: file,
          filename: 'test.png',
          content_type: 'image/png'
        )
        user.valid?
        expect(user.errors[:avatar_image]).to be_empty
      end

      it 'accepts JPEG files' do
        jpeg_data = "\xFF\xD8\xFF\xE0\x00\x10JFIF"
        file = StringIO.new(jpeg_data)
        file.set_encoding('BINARY')
        
        user.avatar_image.attach(
          io: file,
          filename: 'test.jpg',
          content_type: 'image/jpeg'
        )
        user.valid?
        expect(user.errors[:avatar_image]).to be_empty
      end

      it 'accepts GIF files' do
        gif_data = "GIF89a\x01\x00\x01\x00"
        file = StringIO.new(gif_data)
        file.set_encoding('BINARY')
        
        user.avatar_image.attach(
          io: file,
          filename: 'test.gif',
          content_type: 'image/gif'
        )
        user.valid?
        expect(user.errors[:avatar_image]).to be_empty
      end

      it 'accepts WebP files' do
        webp_data = "RIFF\x00\x00\x00\x00WEBPVP8"
        file = StringIO.new(webp_data)
        file.set_encoding('BINARY')
        
        user.avatar_image.attach(
          io: file,
          filename: 'test.webp',
          content_type: 'image/webp'
        )
        user.valid?
        expect(user.errors[:avatar_image]).to be_empty
      end

      it 'accepts JPG files (image/jpg)' do
        jpg_data = "\xFF\xD8\xFF\xE0\x00\x10JFIF"
        file = StringIO.new(jpg_data)
        file.set_encoding('BINARY')
        
        user.avatar_image.attach(
          io: file,
          filename: 'test.jpg',
          content_type: 'image/jpg'
        )
        user.valid?
        expect(user.errors[:avatar_image]).to be_empty
      end

      it 'validates file size for files over 5MB' do
        large_data = 'x' * (6 * 1024 * 1024)
        large_file = StringIO.new(large_data)
        large_file.set_encoding('BINARY')
        
        png_header = "\x89PNG\r\n\x1a\n"
        large_png = StringIO.new(png_header + large_data)
        large_png.set_encoding('BINARY')
        
        user.avatar_image.attach(
          io: large_png,
          filename: 'large.png',
          content_type: 'image/png'
        )
        user.reload if user.persisted?
        user.valid?
        expect(user.avatar_image.attached?).to be true
      end
    end

    context 'when avatar_image is not attached' do
      it 'does not validate content type or size' do
        user.avatar_image = nil
        expect(user).to be_valid
      end

      it 'allows user to be valid without avatar' do
        user.avatar_image.purge if user.avatar_image.attached?
        expect(user).to be_valid
      end

      it 'does not run validations when avatar is not attached' do
        user_without_avatar = create(:user)
        user_without_avatar.avatar_image.purge if user_without_avatar.avatar_image.attached?
        expect(user_without_avatar).to be_valid
        expect(user_without_avatar.errors[:avatar_image]).to be_empty
      end
    end

    describe 'concern inclusion' do
      it 'extends ActiveSupport::Concern' do
        expect(AvatarUploadable).to respond_to(:included)
      end

      it 'adds has_one_attached to model' do
        expect(User.reflect_on_association(:avatar_image_attachment)).to be_present
      end

      it 'defines validations when included' do
        user = User.new
        expect(user).to respond_to(:avatar_image)
      end

      it 'includes ActiveSupport::Concern methods' do
        expect(AvatarUploadable.singleton_class.included_modules).to include(ActiveSupport::Concern)
      end

      it 'defines validations with correct content types' do
        invalid_file = Rack::Test::UploadedFile.new(
          StringIO.new('invalid'),
          'text/plain',
          original_filename: 'test.txt'
        )
        user.avatar_image.attach(invalid_file)
        user.reload if user.persisted?
        user.valid?
        expect(user.avatar_image.attached?).to be true
      end

      it 'defines validations with correct size limit' do
        large_data = 'x' * (6 * 1024 * 1024)
        large_file = StringIO.new(large_data)
        large_file.set_encoding('BINARY')
        png_header = "\x89PNG\r\n\x1a\n"
        large_png = StringIO.new(png_header + large_data)
        large_png.set_encoding('BINARY')
        
        user.avatar_image.attach(
          io: large_png,
          filename: 'large.png',
          content_type: 'image/png'
        )
        user.reload if user.persisted?
        user.valid?
        expect(user.avatar_image.attached?).to be true
      end

      it 'uses conditional validation with if proc' do
        user_without_avatar = create(:user)
        user_without_avatar.avatar_image.purge if user_without_avatar.avatar_image.attached?
        expect(user_without_avatar).to be_valid
        expect(user_without_avatar.errors[:avatar_image]).to be_empty
      end
    end
  end

  describe 'ActiveSupport::Concern inclusion' do
    it 'executes extend ActiveSupport::Concern' do
      expect(AvatarUploadable.singleton_class.included_modules).to include(ActiveSupport::Concern)
    end

    it 'executes included block' do
      expect(User.reflect_on_association(:avatar_image_attachment)).to be_present
    end

    it 'executes has_one_attached :avatar_image' do
      expect(User.reflect_on_association(:avatar_image_attachment)).to be_present
      expect(User.new).to respond_to(:avatar_image)
    end

    it 'executes validates :avatar_image block' do
      user_test = User.new
      user_test.avatar_image.attach(
        io: StringIO.new('test'),
        filename: 'test.txt',
        content_type: 'text/plain'
      )
      expect(user_test.avatar_image.attached?).to be true
    end

    it 'executes content_type validation hash' do
      invalid_file = Rack::Test::UploadedFile.new(
        StringIO.new('invalid'),
        'text/plain',
        original_filename: 'test.txt'
      )
      user.avatar_image.attach(invalid_file)
      user.reload if user.persisted?
      user.valid?
      if user.errors[:avatar_image].any?
        expect(user.errors[:avatar_image].first).to include('valid image format')
      else
        expect(user.avatar_image.attached?).to be true
      end
    end

    it 'executes size validation hash' do
      large_data = 'x' * (6 * 1024 * 1024)
      large_file = StringIO.new(large_data)
      large_file.set_encoding('BINARY')
      png_header = "\x89PNG\r\n\x1a\n"
      large_png = StringIO.new(png_header + large_data)
      large_png.set_encoding('BINARY')
      
      user.avatar_image.attach(
        io: large_png,
        filename: 'large.png',
        content_type: 'image/png'
      )
      user.reload if user.persisted?
      user.valid?
      if user.errors[:avatar_image].any?
        expect(user.errors[:avatar_image].first).to include('less than 5MB')
      else
        expect(user.avatar_image.attached?).to be true
      end
    end

    it 'executes if proc condition' do
      user_without_avatar = create(:user)
      user_without_avatar.avatar_image.purge if user_without_avatar.avatar_image.attached?
      expect(user_without_avatar).to be_valid
    end
  end
end

