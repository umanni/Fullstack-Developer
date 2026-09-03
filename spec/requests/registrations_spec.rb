require "rails_helper"

RSpec.describe "Registrations" do
  let(:valid_params) do
    {
      user: {
        full_name: "Maria Silva",
        email_address: "maria@example.com",
        password: "a-sufficiently-long-password",
        password_confirmation: "a-sufficiently-long-password"
      }
    }
  end

  describe "GET /sign_up" do
    it "is reachable without being signed in" do
      get new_registration_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /registration" do
    it "creates the account and signs the visitor in" do
      expect { post registration_path, params: valid_params }.to change(User, :count).by(1)

      expect(response).to redirect_to(profile_path)
    end

    it "always creates a regular user" do
      post registration_path, params: valid_params

      expect(User.last).to be_user
    end

    it "ignores a role smuggled through the public form" do
      params = valid_params.deep_merge(user: { role: "admin" })

      post registration_path, params: params

      expect(User.last).to be_user
      expect(User.where(role: :admin)).to be_empty
    end

    it "rejects an invalid submission without creating anything" do
      params = valid_params.deep_merge(user: { email_address: "not-an-email" })

      expect { post registration_path, params: params }.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "rejects a mismatched password confirmation" do
      params = valid_params.deep_merge(user: { password_confirmation: "something else" })

      expect { post registration_path, params: params }.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
