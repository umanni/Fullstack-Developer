require "rails_helper"

RSpec.describe "Admin::UserRoles", type: :request do
  let(:admin)  { create(:user, :admin, full_name: "Ada Lovelace", email_address: "ada@example.com") }
  let(:member) { create(:user, full_name: "Grace Hopper", email_address: "grace@example.com") }

  describe "PATCH /admin/users/:user_id/role" do
    it "turns away a visitor who is not signed in" do
      patch admin_user_role_path(member)

      expect(response).to redirect_to(new_session_url)
      expect(member.reload).to be_member
    end

    it "promotes a member" do
      sign_in_as(admin)

      patch admin_user_role_path(member)

      expect(member.reload).to be_admin
      expect(flash[:notice]).to eq("Grace Hopper is now admin.")
    end

    it "demotes another admin" do
      second = create(:user, :admin, full_name: "Grace Hopper", email_address: "grace@example.com")
      sign_in_as(admin)

      patch admin_user_role_path(second)

      expect(second.reload).to be_member
      expect(flash[:notice]).to eq("Grace Hopper is now member.")
    end

    it "reads the role before the write, so the toggle never reports the old value" do
      sign_in_as(admin)

      patch admin_user_role_path(member)

      expect(flash[:notice]).to include("now admin")
      expect(member.reload.role).to eq("admin")
    end
  end

  describe "the self-demotion guard" do
    it "stops an admin from toggling their own role" do
      sign_in_as(admin)

      patch admin_user_role_path(admin)

      expect(admin.reload).to be_admin
      expect(flash[:alert]).to eq("You are not authorized to do that.")
    end

    it "stops the last admin even when they are the only user" do
      sign_in_as(admin)
      expect(User.admin.count).to eq(1)

      patch admin_user_role_path(admin)

      expect(admin.reload).to be_admin
      expect(User.admin.count).to eq(1)
    end

    it "stops a member from promoting themselves" do
      sign_in_as(member)

      patch admin_user_role_path(member)

      expect(member.reload).to be_member
      expect(flash[:alert]).to eq("You are not authorized to do that.")
    end

    it "hides other users from a member behind a 404, not a 403" do
      other = create(:user)
      sign_in_as(member)

      patch admin_user_role_path(other)

      expect(response).to have_http_status(:not_found)
      expect(other.reload).to be_member
    end
  end

  describe "where it redirects" do
    it "goes back where the toggle was clicked from" do
      sign_in_as(admin)

      patch admin_user_role_path(member), headers: { "HTTP_REFERER" => admin_user_path(member) }

      expect(response).to redirect_to(admin_user_path(member))
    end

    it "falls back to the index when there is no referer" do
      sign_in_as(admin)

      patch admin_user_role_path(member)

      expect(response).to redirect_to(admin_users_path)
    end

    it "falls back to the index when a denied toggle has no referer" do
      sign_in_as(admin)

      patch admin_user_role_path(admin)

      expect(response).to redirect_to(root_path) # Authorization#deny_access owns this fallback
    end
  end

  describe "when the write fails" do
    # The model's last-admin validation cannot fire here: `toggle_role?` already
    # requires the actor to be a *different* admin, so that actor is always the
    # second admin the validation looks for. The reachable failure is a record
    # that is already invalid on another attribute -- data predating a
    # validation, say -- which the toggle then has to save.
    it "reports the errors instead of announcing a change" do
      member.update_column(:full_name, "")
      sign_in_as(admin)

      patch admin_user_role_path(member)

      expect(member.reload).to be_member
      expect(response).to redirect_to(admin_users_path)
      expect(flash[:notice]).to be_nil
      expect(flash[:alert]).to include("Full name can't be blank")
    end
  end
end
