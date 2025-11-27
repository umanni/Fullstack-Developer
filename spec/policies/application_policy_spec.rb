require 'rails_helper'

RSpec.describe ApplicationPolicy, type: :policy do
  let(:user) { create(:user) }
  let(:record) { User.new }

  subject { described_class.new(user, record) }

  describe '#index?' do
    it 'returns false by default' do
      expect(subject.index?).to be false
    end
  end

  describe '#show?' do
    it 'returns false by default' do
      expect(subject.show?).to be false
    end
  end

  describe '#create?' do
    it 'returns false by default' do
      expect(subject.create?).to be false
    end
  end

  describe '#new?' do
    it 'delegates to create?' do
      expect(subject.new?).to eq(subject.create?)
    end
  end

  describe '#update?' do
    it 'returns false by default' do
      expect(subject.update?).to be false
    end
  end

  describe '#edit?' do
    it 'delegates to update?' do
      expect(subject.edit?).to eq(subject.update?)
    end
  end

  describe '#destroy?' do
    it 'returns false by default' do
      expect(subject.destroy?).to be false
    end
  end

  describe 'Scope' do
    let(:scope_class) { ApplicationPolicy::Scope }
    let(:scope) { User.all }

    subject { scope_class.new(user, scope) }

    it 'raises NotImplementedError' do
      expect { subject.resolve }.to raise_error(NotImplementedError)
    end
  end
end

