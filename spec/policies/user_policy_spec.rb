require "rails_helper"

RSpec.describe UserPolicy do
  let(:admin) { build_stubbed(:user, :admin) }
  let(:no_admin) { build_stubbed(:user) }
  let(:other_no_admin) { build_stubbed(:user) }

  context "when the user is an admin" do
    subject { described_class.new(admin, other_no_admin) }

    it { is_expected.to permit_all_actions }
  end

  context "when the user manages their own record" do
    subject { described_class.new(no_admin, no_admin) }

    it { is_expected.to permit_actions(:show, :update, :edit, :destroy) }
    it { is_expected.to forbid_actions(:index, :create, :new, :toggle_role) }
  end

  context "when the user tries to manage another user's record" do
    subject { described_class.new(no_admin, other_no_admin) }

    it { is_expected.to forbid_all_actions }
  end

  describe "Scope" do
    let!(:admin_record) { create(:user, :admin) }
    let!(:no_admin_record) { create(:user) }

    it "resolves every user for an admin" do
      resolved = UserPolicy::Scope.new(admin, User.all).resolve

      expect(resolved).to contain_exactly(admin_record, no_admin_record)
    end

    it "resolves only the user's own record for a no_admin user" do
      resolved = UserPolicy::Scope.new(no_admin_record, User.all).resolve

      expect(resolved).to contain_exactly(no_admin_record)
    end
  end
end
