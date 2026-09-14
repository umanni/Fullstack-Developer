require "rails_helper"

RSpec.describe "Admin::Users", type: :request do
  def props = inertia.props.deep_symbolize_keys

  let(:admin)  { create(:user, :admin, full_name: "Ada Lovelace", email_address: "ada@example.com") }
  let(:member) { create(:user, full_name: "Grace Hopper", email_address: "grace@example.com") }

  describe "GET /admin/users" do
    it "turns away a visitor who is not signed in" do
      get admin_users_path

      expect(response).to redirect_to(new_session_url)
    end

    it "turns away a member with the authorization alert" do
      sign_in_as(member)

      get admin_users_path

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("You are not authorized to do that.")
    end

    it "renders the index component for an admin" do
      sign_in_as(admin)

      get admin_users_path

      expect(response).to have_http_status(:ok)
      expect(inertia).to render_component("Admin/Users/Index")
    end

    it "serializes every user" do
      member
      sign_in_as(admin)

      get admin_users_path

      expect(props[:users].pluck(:full_name)).to contain_exactly("Ada Lovelace", "Grace Hopper")
    end

    it "exposes the search state as filters" do
      sign_in_as(admin)

      get admin_users_path

      expect(props[:filters]).to include(
        query: "", sort: "created_at", direction: "desc", role: nil, page: 1, total_pages: 1
      )
    end

    it "narrows the list by the name query" do
      member
      sign_in_as(admin)

      get admin_users_path, params: { query: "Hopper" }

      expect(props[:users].pluck(:full_name)).to eq([ "Grace Hopper" ])
      expect(props[:filters]).to include(query: "Hopper", total: 1)
    end

    it "narrows the list by role" do
      member
      sign_in_as(admin)

      get admin_users_path, params: { role: "admin" }

      expect(props[:users].pluck(:full_name)).to eq([ "Ada Lovelace" ])
    end

    it "sorts by an allowlisted column" do
      member
      sign_in_as(admin)

      get admin_users_path, params: { sort: "full_name", direction: "asc" }

      expect(props[:users].pluck(:full_name)).to eq([ "Ada Lovelace", "Grace Hopper" ])
    end

    it "paginates, reporting the page count alongside the page" do
      stub_const("UserSearch::PER_PAGE", 1)
      member
      sign_in_as(admin)

      get admin_users_path, params: { sort: "full_name", direction: "asc", page: 2 }

      expect(props[:users].pluck(:full_name)).to eq([ "Grace Hopper" ])
      expect(props[:filters]).to include(page: 2, total_pages: 2, total: 2)
    end

    it "never leaks a password digest into the page payload" do
      sign_in_as(admin)

      get admin_users_path

      expect(response.body).not_to include(admin.password_digest)
    end
  end

  describe "GET /admin/users/:id" do
    it "shows any user to an admin" do
      sign_in_as(admin)

      get admin_user_path(member)

      expect(inertia).to render_component("Admin/Users/Show")
      expect(props[:user]).to include(id: member.id, full_name: "Grace Hopper")
    end

    it "hides other users from a member behind a 404, not a 403" do
      other = create(:user)
      sign_in_as(member)

      get admin_user_path(other)

      expect(response).to have_http_status(:not_found)
    end

    # The policy grants `show?` to the record's owner, and the scope narrows to
    # the member themselves, so a member reaches their own row through the admin
    # namespace. See the note in the summary: index? is admin-only, but the
    # member-facing actions are not.
    it "lets a member reach their own row" do
      sign_in_as(member)

      get admin_user_path(member)

      expect(response).to have_http_status(:ok)
      expect(props[:user]).to include(id: member.id)
    end
  end

  describe "GET /admin/users/new" do
    it "renders the form with the assignable roles" do
      sign_in_as(admin)

      get new_admin_user_path

      expect(response).to have_http_status(:ok)
      expect(inertia).to render_component("Admin/Users/New")
      expect(props[:roles]).to eq(%w[member admin])
    end

    it "is closed to members, since only an admin may create" do
      sign_in_as(member)

      get new_admin_user_path

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("You are not authorized to do that.")
    end
  end

  describe "POST /admin/users" do
    let(:valid_params) do
      { user: { full_name: "Margaret Hamilton", email_address: "margaret@example.com",
                password: "password", password_confirmation: "password" } }
    end

    it "creates the user and announces it" do
      sign_in_as(admin)

      expect { post admin_users_path, params: valid_params }.to change(User, :count).by(1)

      expect(response).to redirect_to(admin_users_path)
      expect(flash[:notice]).to eq("Margaret Hamilton was created.")
    end

    it "lets an admin set the role on creation" do
      sign_in_as(admin)

      post admin_users_path, params: valid_params.deep_merge(user: { role: "admin" })

      expect(User.find_by(email_address: "margaret@example.com")).to be_admin
    end

    it "sends validation errors back to the form" do
      sign_in_as(admin)

      expect { post admin_users_path, params: { user: valid_params[:user].merge(full_name: "") } }
        .not_to change(User, :count)

      expect(response).to redirect_to(new_admin_user_path)
      expect(session[:inertia_errors][:full_name]).to include("can't be blank")
    end

    it "rejects a duplicate email address" do
      create(:user, email_address: "margaret@example.com")
      sign_in_as(admin)

      expect { post admin_users_path, params: valid_params }.not_to change(User, :count)

      expect(session[:inertia_errors][:email_address]).to eq([ "has already been taken" ])
    end

    it "is closed to members" do
      sign_in_as(member)

      expect { post admin_users_path, params: valid_params }.not_to change(User, :count)

      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET /admin/users/:id/edit" do
    it "renders the form with the user and the roles" do
      sign_in_as(admin)

      get edit_admin_user_path(member)

      expect(inertia).to render_component("Admin/Users/Edit")
      expect(props[:user]).to include(id: member.id)
      expect(props[:roles]).to eq(%w[member admin])
    end

    it "404s for a member editing someone else" do
      other = create(:user)
      sign_in_as(member)

      get edit_admin_user_path(other)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH /admin/users/:id" do
    it "updates the user and announces it" do
      sign_in_as(admin)

      patch admin_user_path(member), params: { user: { full_name: "Grace M. Hopper" } }

      expect(response).to redirect_to(admin_users_path)
      expect(flash[:notice]).to eq("Grace M. Hopper was updated.")
      expect(member.reload.full_name).to eq("Grace M. Hopper")
    end

    it "sends validation errors back to the edit form" do
      sign_in_as(admin)

      patch admin_user_path(member), params: { user: { full_name: "" } }

      expect(response).to redirect_to(edit_admin_user_path(member))
      expect(session[:inertia_errors][:full_name]).to include("can't be blank")
      expect(member.reload.full_name).to eq("Grace Hopper")
    end

    it "lets an admin promote a member" do
      sign_in_as(admin)

      patch admin_user_path(member), params: { user: { role: "admin" } }

      expect(member.reload).to be_admin
    end

    it "rejects a request whose only field is one the policy withholds" do
      sign_in_as(admin)

      patch admin_user_path(admin), params: { user: { role: "member" } }

      expect(response).to have_http_status(:bad_request)
      expect(admin.reload).to be_admin
    end

    # `permitted_attributes` is keyed to `toggle_role?`, so an admin editing
    # their own row never gets `:role` -- the self-demotion guard holds here as
    # well as on the dedicated toggle route, even with a second admin present to
    # satisfy the model's headcount validation.
    it "ignores a role an admin tries to give themselves" do
      create(:user, :admin, email_address: "second-admin@example.com")
      sign_in_as(admin)

      expect(UserPolicy.new(admin, admin).toggle_role?).to be(false)

      patch admin_user_path(admin), params: { user: { full_name: "Ada L.", role: "member" } }

      expect(admin.reload).to be_admin
      expect(admin.full_name).to eq("Ada L.")
    end

    it "ignores a role a member tries to give themselves" do
      sign_in_as(member)

      patch admin_user_path(member), params: { user: { full_name: "Grace", role: "admin" } }

      expect(member.reload).to be_member
    end
  end

  describe "DELETE /admin/users/:id" do
    it "deletes the user" do
      member
      sign_in_as(admin)

      expect { delete admin_user_path(member) }.to change(User, :count).by(-1)

      expect(response).to redirect_to(admin_users_path)
      expect(flash[:notice]).to eq("User deleted.")
    end

    it "refuses to delete the last admin and reports why" do
      sign_in_as(admin)

      expect { delete admin_user_path(admin) }.not_to change(User, :count)

      expect(response).to redirect_to(admin_users_path)
      expect(flash[:alert]).to eq("Cannot remove the last administrator")
    end

    it "404s for a member deleting someone else" do
      other = create(:user)
      sign_in_as(member)

      expect { delete admin_user_path(other) }.not_to change(User, :count)

      expect(response).to have_http_status(:not_found)
    end
  end
end
