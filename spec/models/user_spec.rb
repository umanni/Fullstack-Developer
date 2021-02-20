require 'rails_helper'

RSpec.describe User, type: :model do
    it 'is valid with full_name, email, avatar_image, admin, password and password confirmation' do
        user = FactoryBot.create(:user)
        expect(user).to be_valid
    end

    it 'is invalid without full_name' do
        user = FactoryBot.build(:user, full_name: nil)
        user.valid?
        expect(user.errors[:full_name]).to include("can't be blank")
    end

    it 'is invalid without email' do
        user = FactoryBot.build(:user, email: nil)
        user.valid?
        expect(user.errors[:email]).to include("can't be blank")
    end

    it 'is invalid without avatar_image' do
        user = FactoryBot.build(:user, avatar_image: nil)
        user.valid?
        expect(user.errors[:avatar_image]).to include("can't be blank")
    end

    it 'is invalid without password' do
        user = FactoryBot.build(:user, password: nil)
        user.valid?
        expect(user.errors[:password]).to include("can't be blank")
    end

    it 'is invalid without password_confirmation' do
        user = FactoryBot.build(:user, password_confirmation: nil)
        user.valid?
        expect(user.errors[:password_confirmation]).to include("can't be blank")
    end

    it 'is valid if the user is not admin' do
        user = FactoryBot.create(:user)
        expect(user.admin).to eq(false)
    end
end
