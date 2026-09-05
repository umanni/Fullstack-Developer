require "rails_helper"

RSpec.describe "Registrations", type: :request do
  describe "GET /registration/new" do
    it "is accessible to a visitor" do
      get new_registration_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /registration" do
    it "creates a no_admin user, signs them in, and redirects to the profile" do
      expect {
        post registration_path, params: {
          user: {
            full_name: "Ada Lovelace",
            email: "ada@example.com",
            password: "password123",
            password_confirmation: "password123"
          }
        }
      }.to change(User, :count).by(1)

      user = User.find_by(email: "ada@example.com")
      expect(user).to be_no_admin
      expect(response).to redirect_to(profile_url)

      get profile_path
      expect(response).to have_http_status(:ok)
    end

    it "ignores a role param and always forces no_admin" do
      post registration_path, params: {
        user: {
          full_name: "Eve Attacker",
          email: "eve@example.com",
          password: "password123",
          password_confirmation: "password123",
          role: "admin"
        }
      }

      user = User.find_by(email: "eve@example.com")
      expect(user).to be_no_admin
    end

    it "re-renders the form with errors when the password confirmation does not match" do
      expect {
        post registration_path, params: {
          user: {
            full_name: "Ada Lovelace",
            email: "ada@example.com",
            password: "password123",
            password_confirmation: "mismatch"
          }
        }
      }.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
