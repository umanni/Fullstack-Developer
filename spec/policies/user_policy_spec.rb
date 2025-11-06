require 'rails_helper'

RSpec.describe UserPolicy, type: :policy do
  # Use `subject` to define the policy being tested
  subject { described_class.new(user, record) }

  let(:base_user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:admin) { create(:user, :admin) }

  # --- Test a Regular User ---
  context 'as a regular user' do
    let(:user) { base_user }

    describe 'permissions for their own profile' do
      let(:record) { base_user } # The record is themselves

      it { is_expected.to permit_action(:show) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
    end

    describe 'permissions for another user' do
      let(:record) { other_user } # The record is someone else

      it { is_expected.not_to permit_action(:show) }
      it { is_expected.not_to permit_action(:index) }
      it { is_expected.not_to permit_action(:create) }
      it { is_expected.not_to permit_action(:update) }
      it { is_expected.not_to permit_action(:destroy) }
      it { is_expected.not_to permit_action(:toggle_role) }
    end
  end

  # --- Test an Admin ---
  context 'as an admin' do
    let(:user) { admin } # The user is the admin
    let(:record) { other_user } # The record is someone else

    it 'permits all actions' do
      is_expected.to permit_all_actions
    end
  end

  # --- Test the Scope ---
  describe "Scope" do
    # Note: `user` and `admin` are created here by the `let!`
    let!(:user) { create(:user) }
    let!(:admin) { create(:user, :admin) }

    before do
      # Create 3 more users
      create_list(:user, 3)
    end

    it "as a user, only returns self" do
      user_scope = Pundit.policy_scope!(user, User)
      expect(user_scope.count).to eq(1)
      expect(user_scope.first).to eq(user)
    end

    it "as an admin, returns all users" do
      admin_scope = Pundit.policy_scope!(admin, User)
      # 1 user + 1 admin + 3 created = 5 total
      expect(admin_scope.count).to eq(5)
    end
  end
end
