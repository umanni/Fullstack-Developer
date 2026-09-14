require "rails_helper"

RSpec.describe "Profiles", type: :request do
  def props = inertia.props.deep_symbolize_keys

  let!(:user) do
    create(:user, full_name: "Ada Lovelace", email_address: "ada@example.com", password: "password")
  end

  describe "GET /profile" do
    it "requires authentication" do
      get profile_path

      expect(response).to redirect_to(new_session_url)
    end

    it "shows the signed-in user their own details" do
      sign_in_as(user)

      get profile_path

      expect(response).to have_http_status(:ok)
      expect(inertia).to render_component("Profile/Show")
      expect(props[:user]).to include(
        id: user.id, full_name: "Ada Lovelace", email_address: "ada@example.com",
        role: "member", admin: false
      )
    end

    it "shows the viewer's own record rather than anyone else's" do
      create(:user, full_name: "Someone Else")
      sign_in_as(user)

      get profile_path

      expect(props[:user][:id]).to eq(user.id)
      expect(response.body).not_to include("Someone Else")
    end

    it "is where a member lands straight after signing in" do
      sign_in_as(user)

      expect(response).to redirect_to(profile_path)
    end

    it "serves an admin their own profile, flagged as such" do
      admin = create(:user, :admin, email_address: "boss@example.com", password: "password")
      sign_in_as(admin)

      get profile_path

      expect(props[:user]).to include(id: admin.id, role: "admin", admin: true)
    end

    it "never leaks the password digest" do
      sign_in_as(user)

      get profile_path

      expect(response.body).not_to include(user.password_digest)
    end
  end

  describe "GET /profile/edit" do
    it "requires authentication" do
      get edit_profile_path

      expect(response).to redirect_to(new_session_url)
    end

    it "renders the edit form for the signed-in user" do
      sign_in_as(user)

      get edit_profile_path

      expect(response).to have_http_status(:ok)
      expect(inertia).to render_component("Profile/Edit")
      expect(props[:user]).to include(id: user.id, full_name: "Ada Lovelace")
    end
  end

  describe "PATCH /profile" do
    it "requires authentication" do
      patch profile_path, params: { user: { full_name: "Changed" } }

      expect(response).to redirect_to(new_session_url)
      expect(user.reload.full_name).to eq("Ada Lovelace")
    end

    it "updates the profile and announces it" do
      sign_in_as(user)

      patch profile_path, params: { user: { full_name: "Ada King" } }

      expect(response).to redirect_to(profile_path)
      expect(flash[:notice]).to eq("Profile updated.")
      expect(user.reload.full_name).to eq("Ada King")
    end

    it "changes the password so the new one signs in" do
      sign_in_as(user)

      patch profile_path, params: {
        user: { password: "new-password", password_confirmation: "new-password" }
      }

      expect(response).to redirect_to(profile_path)
      expect(User.authenticate_by(email_address: "ada@example.com", password: "new-password"))
        .to eq(user)
    end

    it "sends validation errors back to the edit form" do
      sign_in_as(user)

      patch profile_path, params: { user: { full_name: "" } }

      expect(response).to redirect_to(edit_profile_path)
      expect(session[:inertia_errors][:full_name]).to include("can't be blank")
      expect(user.reload.full_name).to eq("Ada Lovelace")
    end

    it "rejects an email address already taken by someone else" do
      create(:user, email_address: "taken@example.com")
      sign_in_as(user)

      patch profile_path, params: { user: { email_address: "taken@example.com" } }

      expect(session[:inertia_errors][:email_address]).to eq([ "has already been taken" ])
      expect(user.reload.email_address).to eq("ada@example.com")
    end

    it "edits the viewer, never anyone else, since there is no id to target" do
      other = create(:user, full_name: "Someone Else")
      sign_in_as(user)

      patch profile_path, params: { id: other.id, user: { full_name: "Hijacked" } }

      expect(other.reload.full_name).to eq("Someone Else")
      expect(user.reload.full_name).to eq("Hijacked")
    end

    it "ignores a role a member tries to give themselves" do
      sign_in_as(user)

      patch profile_path, params: { user: { full_name: "Ada King", role: "admin" } }

      expect(user.reload).to be_member
    end

    # The actor here is always the record's owner, so `toggle_role?` is false and
    # `permitted_attributes` withholds `:role`. An admin cannot demote themselves
    # through the member-facing profile route either, even with a second admin
    # present to satisfy the model's headcount validation.
    it "ignores a role an admin tries to give themselves" do
      admin = create(:user, :admin, email_address: "boss@example.com", password: "password")
      create(:user, :admin, email_address: "second@example.com")
      sign_in_as(admin)

      patch profile_path, params: { user: { full_name: "Ada King", role: "member" } }

      expect(admin.reload).to be_admin
      expect(admin.full_name).to eq("Ada King")
    end

    it "rejects a request whose only field is one the policy withholds" do
      admin = create(:user, :admin, email_address: "boss@example.com", password: "password")
      sign_in_as(admin)

      patch profile_path, params: { user: { role: "member" } }

      expect(response).to have_http_status(:bad_request)
      expect(admin.reload).to be_admin
    end
  end

  describe "DELETE /profile" do
    it "requires authentication" do
      expect { delete profile_path }.not_to change(User, :count)

      expect(response).to redirect_to(new_session_url)
    end

    it "deletes the account" do
      sign_in_as(user)

      expect { delete profile_path }.to change(User, :count).by(-1)

      expect(User.find_by(id: user.id)).to be_nil
    end

    it "takes the sessions with it and signs the visitor out" do
      sign_in_as(user)

      delete profile_path

      expect(Session.count).to eq(0)

      get profile_path

      expect(response).to redirect_to(new_session_url)
    end

    it "carries the confirmation through to the landing page" do
      sign_in_as(user)

      delete profile_path
      follow_redirect! # root, which shows the now signed-out visitor the landing page

      expect(response).to have_http_status(:ok)
      expect(inertia).to render_component("home/index")
      expect(inertia.props.deep_symbolize_keys[:flash]).to include(notice: "Your account has been deleted.")
    end

    it "refuses to delete the last admin and reports why" do
      admin = create(:user, :admin, email_address: "boss@example.com", password: "password")
      sign_in_as(admin)

      expect { delete profile_path }.not_to change(User, :count)

      expect(response).to redirect_to(profile_path)
      expect(flash[:alert]).to eq("Cannot remove the last administrator")
    end

    it "leaves a refused deletion signed in" do
      admin = create(:user, :admin, email_address: "boss@example.com", password: "password")
      sign_in_as(admin)

      delete profile_path
      get profile_path

      expect(response).to have_http_status(:ok)
      expect(props[:user]).to include(id: admin.id)
    end

    it "lets an admin delete themselves when another admin remains" do
      admin = create(:user, :admin, email_address: "boss@example.com", password: "password")
      create(:user, :admin, email_address: "second@example.com")
      sign_in_as(admin)

      expect { delete profile_path }.to change(User, :count).by(-1)

      expect(flash[:notice]).to eq("Your account has been deleted.")
    end
  end
end
