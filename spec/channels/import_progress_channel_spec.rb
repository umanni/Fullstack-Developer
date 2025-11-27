require 'rails_helper'

RSpec.describe ImportProgressChannel, type: :channel do
  let(:admin) { create(:user, :admin) }
  let(:regular_user) { create(:user) }
  let(:user_import) { create(:user_import, user: admin) }

  describe '#subscribed' do
    context 'when user is admin with import_id' do
      it 'allows subscription' do
        stub_connection(current_user: admin)
        subscribe(import_id: user_import.id)
        expect(subscription).to be_confirmed
      end
    end

    context 'when user is admin without import_id' do
      it 'allows subscription but may not stream' do
        stub_connection(current_user: admin)
        subscribe
        expect(subscription).to be_confirmed
      end
    end

    context 'when user is not admin' do
      it 'rejects subscription' do
        stub_connection(current_user: regular_user)
        subscribe(import_id: user_import.id)
        expect(subscription).to be_rejected
      end
    end

    context 'when user is not authenticated' do
      it 'rejects subscription' do
        stub_connection(current_user: nil)
        subscribe(import_id: user_import.id)
        expect(subscription).to be_rejected
      end
    end
  end
end

