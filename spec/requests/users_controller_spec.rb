require "rails_helper"

RSpec.describe UsersController, type: :request do
  let(:user)  { create(:user) }
  let(:admin) { create(:user, :admin) }

  describe "GET /profile" do
    context "when signed in as the user" do
      before { sign_in user }

      it "renders the profile page" do
        get profile_path
        expect(response).to have_http_status(:success)
      end
    end

    context "when admin" do
      before { sign_in admin }

      it "renders own profile" do
        get profile_path
        expect(response).to have_http_status(:success)
      end
    end

    context "when not authenticated" do
      it "redirects to login page" do
        get profile_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "PATCH /profile" do
    let(:valid_params) do
      {
        user: {
          full_name: "Updated Name",
          email: user.email,
          password: "",
          password_confirmation: ""
        }
      }
    end

    context "when authenticated" do
      before { sign_in user }

      it "does not overwrite password when blank" do
        user.update!(password: "initial123", password_confirmation: "initial123")

        patch profile_path, params: valid_params

        expect(user.reload.valid_password?("initial123")).to be true
      end
    end

    context "admin updating own profile" do
      before { sign_in admin }

      it "updates own data" do
        patch profile_path, params: {
          user: {
            full_name: "Admin Updated",
            email: admin.email
          }
        }

        expect(admin.reload.full_name).to eq("Admin Updated")
      end
    end

    context "not authenticated" do
      it "redirects to login" do
        patch profile_path, params: valid_params
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "DELETE /profile" do
    context "user deletes own account" do
      before { sign_in user }

      it "removes account" do
        expect {
          delete profile_path
        }.to change(User, :count).by(-1)

        expect(response).to redirect_to(root_path)
      end
    end

    context "admin deletes own account" do
      before { sign_in admin }

      it "removes own account" do
        expect {
          delete profile_path
        }.to change(User, :count).by(-1)

        expect(response).to redirect_to(root_path)
      end
    end

    context "not authenticated" do
      it "redirects to login" do
        delete profile_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
