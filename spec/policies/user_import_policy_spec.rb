require 'rails_helper'

RSpec.describe UserImportPolicy, type: :policy do
  subject { described_class }

  let(:admin) { create(:user, :admin) }
  let(:user) { create(:user) }
  let(:user_import) { create(:user_import) }

  describe '#index?' do
    it 'grants access to admin' do
      expect(subject.new(admin, UserImport).index?).to be true
    end

    it 'denies access to regular user' do
      expect(subject.new(user, UserImport).index?).to be false
    end

    it 'denies access to nil user' do
      policy = subject.new(nil, UserImport)
      expect(policy.index?).to be_falsy
    end
  end

  describe '#show?' do
    it 'grants access to admin' do
      expect(subject.new(admin, user_import).show?).to be true
    end

    it 'denies access to regular user' do
      expect(subject.new(user, user_import).show?).to be false
    end

    it 'denies access to nil user' do
      policy = subject.new(nil, user_import)
      expect(policy.show?).to be_falsy
    end
  end

  describe '#create?' do
    it 'grants access to admin' do
      expect(subject.new(admin, UserImport).create?).to be true
    end

    it 'denies access to regular user' do
      expect(subject.new(user, UserImport).create?).to be false
    end

    it 'denies access to nil user' do
      policy = subject.new(nil, UserImport)
      expect(policy.create?).to be_falsy
    end
  end

  describe '#new?' do
    it 'delegates to create?' do
      policy = subject.new(admin, UserImport)
      expect(policy.new?).to eq(policy.create?)
    end
  end

  describe '#status?' do
    it 'grants access to admin' do
      expect(subject.new(admin, user_import).status?).to be true
    end

    it 'denies access to regular user' do
      expect(subject.new(user, user_import).status?).to be false
    end

    it 'denies access to nil user' do
      policy = subject.new(nil, user_import)
      expect(policy.status?).to be_falsy
    end
  end

  describe 'Scope' do
    let!(:import1) { create(:user_import, user: admin) }
    let!(:import2) { create(:user_import, user: admin) }

    context 'when user is admin' do
      it 'returns all imports' do
        expect(Pundit.policy_scope(admin, UserImport).to_a).to include(import1, import2)
      end
    end

    context 'when user is regular user' do
      it 'returns no imports' do
        expect(Pundit.policy_scope(user, UserImport).to_a).to be_empty
      end
    end

    context 'when user is nil' do
      it 'returns no imports' do
        expect(Pundit.policy_scope(nil, UserImport).to_a).to be_empty
      end
    end
  end
end

