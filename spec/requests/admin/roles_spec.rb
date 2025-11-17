require 'rails_helper'

RSpec.describe "Admin::Roles", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:user)  { create(:user) }

  describe "PATCH /admin/roles/:id/update" do
    it "toggles admin role" do
      sign_in admin

      patch admin_role_path(user)
      expect(user.reload.admin).to eq(true)
      expect(response).to redirect_to(admin_users_path)
    end
  end
end
