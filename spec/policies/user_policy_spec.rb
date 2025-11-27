require 'rails_helper'

RSpec.describe UserPolicy, type: :policy do
  let(:admin) { create(:user, :admin) }
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  subject { described_class }

  describe '#index?' do
    it 'grants access to admin' do
      expect(subject.new(admin, User).index?).to be true
    end

    it 'denies access to regular user' do
      expect(subject.new(user, User).index?).to be false
    end
  end

  describe '#show?' do
    it 'grants access to admin' do
      expect(subject.new(admin, user).show?).to be true
    end

    it 'grants access to own profile' do
      expect(subject.new(user, user).show?).to be true
    end

    it 'denies access to other users profile' do
      expect(subject.new(user, other_user).show?).to be false
    end
  end

  describe '#update?' do
    it 'grants access to admin' do
      expect(subject.new(admin, user).update?).to be true
    end

    it 'grants access to own profile' do
      expect(subject.new(user, user).update?).to be true
    end

    it 'denies access to other users profile' do
      expect(subject.new(user, other_user).update?).to be false
    end
  end

  describe '#destroy?' do
    it 'grants access to admin' do
      expect(subject.new(admin, user).destroy?).to be true
    end

    it 'grants access to own profile' do
      expect(subject.new(user, user).destroy?).to be true
    end

    it 'denies access to other users profile' do
      expect(subject.new(user, other_user).destroy?).to be false
    end
  end

  describe '#create?' do
    it 'grants access to admin' do
      expect(subject.new(admin, User).create?).to be true
    end

    it 'denies access to regular user' do
      expect(subject.new(user, User).create?).to be false
    end

    it 'denies access to nil user' do
      expect(subject.new(nil, User).create?).to be_falsy
    end
  end

  describe '#new?' do
    it 'delegates to create?' do
      policy = subject.new(admin, User)
      expect(policy.new?).to eq(policy.create?)
    end
  end

  describe '#edit?' do
    it 'delegates to update?' do
      policy = subject.new(user, user)
      expect(policy.edit?).to eq(policy.update?)
    end
  end

  describe '#toggle_role?' do
    it 'grants access to admin for other users' do
      expect(subject.new(admin, user).toggle_role?).to be true
    end

    it 'denies access when admin tries to change own role' do
      expect(subject.new(admin, admin).toggle_role?).to be false
    end

    it 'denies access to regular user' do
      expect(subject.new(user, user).toggle_role?).to be false
    end

    it 'denies access to nil user' do
      expect(subject.new(nil, user).toggle_role?).to be_falsy
    end
  end

  describe 'Scope' do
    let!(:user1) { create(:user) }
    let!(:user2) { create(:user) }

    context 'when user is admin' do
      it 'returns all users' do
        scope = Pundit.policy_scope(admin, User)
        expect(scope.to_a).to include(admin, user1, user2)
      end
    end

    context 'when user is regular user' do
      it 'returns only own user' do
        scope = Pundit.policy_scope(user1, User)
        expect(scope.to_a).to eq([user1])
        expect(scope.to_a).not_to include(user2)
      end
    end

    context 'when user is nil' do
      it 'returns no users' do
        scope = Pundit.policy_scope(nil, User)
        expect(scope.to_a).to be_empty
      end
    end
  end
end

