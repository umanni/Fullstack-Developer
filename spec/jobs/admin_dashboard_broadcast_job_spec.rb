require 'rails_helper'

RSpec.describe AdminDashboardBroadcastJob, type: :job do
  describe '#perform' do
    let!(:admin) { create(:user, :admin) }
    let!(:regular_user) { create(:user) }

    it 'broadcasts dashboard statistics' do
      expect(ActionCable.server).to receive(:broadcast).with(
        'admin_dashboard',
        hash_including(
          total_users: 2,
          total_admins: 1,
          total_regular_users: 1,
          total_guests: 0
        )
      )

      described_class.new.perform
    end

    it 'calculates correct user counts' do
      create_list(:user, 3, :admin)
      create_list(:user, 5)

      expect(ActionCable.server).to receive(:broadcast).with(
        'admin_dashboard',
        hash_including(
          total_users: 10, # 1 initial admin + 3 new admins + 1 initial user + 5 new users
          total_admins: 4,
          total_regular_users: 6,
          total_guests: 0
        )
      )

      described_class.new.perform
    end
  end
end

