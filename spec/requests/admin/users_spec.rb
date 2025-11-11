require 'rails_helper'

RSpec.describe "Admin::Users", type: :request do
  let!(:admin) { create(:user, :admin) }
  let!(:users) { create_list(:user, 3) }

  describe "GET /admin/users" do
    context "when admin is signed in" do
      before do
        sign_in admin
        get admin_users_path
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "renders list of users" do
        users.each do |user|
          expect(response.body).to include(user.full_name)
        end
      end
    end

    context "when regular user is signed in" do
      let(:user) { create(:user) }

      before do
        sign_in user
        get admin_users_path
      end

      it "redirects to root with alert" do
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include('Acesso restrito a administradores')
      end
    end
  end

  describe "GET /admin/users with search query" do
    let!(:admin) { create(:user, :admin) }
    let!(:user_john) { create(:user, full_name: 'John Doe', email: 'john@example.com') }
    let!(:user_jane) { create(:user, full_name: 'Jane Smith', email: 'jane@example.com') }

    before do
      sign_in admin
    end

    it "returns only matching users by name" do
      get admin_users_path, params: { query: 'John' }
      expect(response.body).to include('John Doe')
      expect(response.body).not_to include('Jane Smith')
    end

    it "returns only matching users by email" do
      get admin_users_path, params: { query: 'jane@example.com' }
      expect(response.body).to include('Jane Smith')
      expect(response.body).not_to include('John Doe')
    end
  end

  describe "POST /admin/users" do
    let(:admin) { create(:user, :admin) }

    before { sign_in admin }

    it "creates a new user with valid attributes" do
      expect {
        post admin_users_path, params: {
          user: {
            full_name: 'New User',
            email: 'newuser@example.com',
            password: '123456',
            role: 'user'
          }
        }
      }.to change(User, :count).by(1)

      follow_redirect!
      expect(response.body).to include('Usuário criado com sucesso')
      expect(User.last.full_name).to eq('New User')
    end

    it "does not create user with invalid data" do
      expect {
        post admin_users_path, params: {
          user: {
            full_name: '',
            email: 'invalid',
            password: '',
            role: 'user'
          }
        }
      }.not_to change(User, :count)

      expect(response.body).to include('não pôde ser criado')
    end
  end

  describe "PATCH /admin/users/:id" do
    let(:admin) { create(:user, :admin) }
    let!(:user) { create(:user, full_name: 'Old Name', email: 'old@example.com', role: :user) }

    before { sign_in admin }

    it "updates user attributes successfully" do
      patch admin_user_path(user), params: {
        user: {
          full_name: 'Updated Name',
          email: 'updated@example.com',
          role: 'admin'
        }
      }

      expect(response).to redirect_to(admin_users_path)
      follow_redirect!
      expect(response.body).to include('Usuário atualizado com sucesso')
      user.reload
      expect(user.full_name).to eq('Updated Name')
      expect(user.role).to eq('admin')
    end

    it "renders errors when update fails" do
      patch admin_user_path(user), params: {
        user: {
          email: '' # inválido
        }
      }

      expect(response.body).to include('Usuário não pôde ser atualizado')
      user.reload
      expect(user.email).to eq('old@example.com')
    end
  end

  describe "DELETE /admin/users/:id" do
    let(:admin) { create(:user, :admin) }
    let!(:user) { create(:user, full_name: 'User To Delete', email: 'delete@example.com') }

    before { sign_in admin }

    it "deletes the user successfully" do
      expect {
        delete admin_user_path(user)
      }.to change(User, :count).by(-1)

      follow_redirect!
      expect(response.body).to include('Usuário excluído com sucesso')
    end
  end

  describe "PATCH /admin/users/:id/toggle_role" do
    let(:admin) { create(:user, :admin) }
    let!(:user) { create(:user, role: :user) }

    before { sign_in admin }

    it "toggles the user role from user to admin" do
      patch toggle_role_admin_user_path(user)
      expect(response).to redirect_to(admin_users_path)
      follow_redirect!
      expect(response.body).to include('Função do usuário atualizada com sucesso')
      user.reload
      expect(user.role).to eq('admin')
    end

    it "toggles the user role from admin to user" do
      user.update(role: :admin)
      patch toggle_role_admin_user_path(user)
      user.reload
      expect(user.role).to eq('user')
    end
  end
end
