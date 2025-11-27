require 'rails_helper'

RSpec.describe AdminDashboardChannel, type: :channel do
  let(:admin) { create(:user, :admin) }
  let(:regular_user) { create(:user) }

  describe '#subscribed' do
    context 'when user is admin' do
      it 'allows subscription for admin' do
        stub_connection(current_user: admin)
        subscribe
        expect(subscription).to be_confirmed
      end
    end

    context 'when user is not admin' do
      it 'rejects subscription for regular user' do
        stub_connection(current_user: regular_user)
        subscribe
        expect(subscription).to be_rejected
      end
    end

    context 'when user is not authenticated' do
      it 'rejects subscription' do
        stub_connection(current_user: nil)
        subscribe
        expect(subscription).to be_rejected
      end
    end
  end
end

