require "rails_helper"

RSpec.describe "Admin users" do
  let(:administrator) { create(:user, :admin, full_name: "Ada Admin") }

  before { sign_in administrator }

  describe "GET /admin/users" do
    it "lists the people in the system" do
      create(:user, full_name: "Maria Silva")

      get admin_users_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Maria Silva")
    end

    it "finds people by name" do
      create(:user, full_name: "Maria Silva")
      create(:user, full_name: "Joao Souza")

      get admin_users_path, params: { query: "maria" }

      expect(response.body).to include("Maria Silva")
      expect(response.body).not_to include("Joao Souza")
    end

    it "finds people by email address" do
      create(:user, full_name: "Maria Silva", email_address: "maria@example.com")
      create(:user, full_name: "Joao Souza", email_address: "joao@example.com")

      get admin_users_path, params: { query: "joao@" }

      expect(response.body).to include("Joao Souza")
      expect(response.body).not_to include("Maria Silva")
    end

    it "treats a search term as data, not as SQL" do
      create(:user, full_name: "Maria Silva")

      get admin_users_path, params: { query: "'; DROP TABLE users; --" }

      expect(response).to have_http_status(:ok)
      expect(User.count).to be_positive
    end

    it "filters by role" do
      create(:user, full_name: "Maria Silva")

      get admin_users_path, params: { role: "admin" }

      expect(response.body).to include("Ada Admin")
      expect(response.body).not_to include("Maria Silva")
    end

    it "ignores a role filter it does not recognise" do
      create(:user, full_name: "Maria Silva")

      get admin_users_path, params: { role: "wizard" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Maria Silva")
    end

    it "paginates" do
      create_list(:user, 3)

      get admin_users_path, params: { per_page: 2 }

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /admin/users" do
    let(:params) do
      {
        user: {
          full_name: "Nova Pessoa",
          email_address: "nova@example.com",
          password: "a-sufficiently-long-password",
          role: "admin"
        }
      }
    end

    it "creates a user" do
      expect { post admin_users_path, params: params }.to change(User, :count).by(1)

      expect(response).to redirect_to(admin_users_path)
    end

    it "may assign the administrator role, unlike the public form" do
      post admin_users_path, params: params

      expect(User.find_by(email_address: "nova@example.com")).to be_admin
    end

    it "rejects an invalid submission" do
      invalid = params.deep_merge(user: { email_address: "" })

      expect { post admin_users_path, params: invalid }.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "PATCH /admin/users/:id" do
    it "updates another user" do
      user = create(:user)

      patch admin_user_path(user), params: { user: { full_name: "Nome Novo" } }

      expect(user.reload.full_name).to eq("Nome Novo")
    end

    it "promotes a regular user" do
      user = create(:user)

      patch admin_user_path(user), params: { user: { role: "admin" } }

      expect(user.reload).to be_admin
    end
  end

  describe "DELETE /admin/users/:id" do
    it "deletes another user" do
      user = create(:user)

      expect { delete admin_user_path(user) }.to change(User, :count).by(-1)

      expect(response).to redirect_to(admin_users_path)
    end
  end

  describe "protecting the last administrator" do
    it "refuses to delete the only administrator" do
      create(:user)

      expect { delete admin_user_path(administrator) }.not_to change(User, :count)

      expect(flash[:alert]).to be_present
    end

    it "refuses to demote the only administrator" do
      patch admin_user_path(administrator), params: { user: { role: "user" } }

      expect(administrator.reload).to be_admin
    end

    it "allows deleting an administrator while another one remains" do
      other = create(:user, :admin)

      expect { delete admin_user_path(other) }.to change(User, :count).by(-1)
    end

    it "allows demoting an administrator while another one remains" do
      other = create(:user, :admin)

      patch admin_user_path(other), params: { user: { role: "user" } }

      expect(other.reload).to be_user
    end
  end

  describe "authorization" do
    it "refuses every action to a regular user" do
      sign_in create(:user)
      target = create(:user)

      get admin_users_path
      expect(response).to redirect_to(profile_path)

      patch admin_user_path(target), params: { user: { role: "admin" } }
      expect(target.reload).to be_user

      expect { delete admin_user_path(target) }.not_to change(User, :count)
    end
  end
end
