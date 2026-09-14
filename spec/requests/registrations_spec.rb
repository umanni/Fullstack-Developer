require "rails_helper"

RSpec.describe "Registrations", type: :request do
  let(:valid_params) do
    { user: { full_name: "Ada Lovelace", email_address: "ada@example.com",
              password: "password", password_confirmation: "password" } }
  end

  describe "GET /registration/new" do
    it "is open to a visitor who is not signed in" do
      get new_registration_path

      expect(response).to have_http_status(:ok)
      expect(inertia).to render_component("Auth/Register")
    end

    it "sends a signed-in visitor away, since they already have an account" do
      user = create(:user, email_address: "someone@example.com", password: "password")
      sign_in_as(user)

      get new_registration_path

      expect(response).to redirect_to(root_path)
    end
  end

  describe "POST /registration" do
    it "creates the account" do
      expect { post registration_path, params: valid_params }.to change(User, :count).by(1)

      expect(response).to redirect_to(profile_path)
      expect(flash[:notice]).to eq("Welcome, Ada Lovelace.")
    end

    it "signs the new user straight in" do
      post registration_path, params: valid_params

      expect(Session.count).to eq(1)

      get profile_path

      expect(response).to have_http_status(:ok)
      expect(inertia.props.deep_symbolize_keys[:user])
        .to include(email_address: "ada@example.com")
    end

    it "registers a member" do
      post registration_path, params: valid_params

      expect(User.find_by(email_address: "ada@example.com")).to be_member
    end

    it "refuses to let a registrant make themselves an admin" do
      post registration_path, params: valid_params.deep_merge(user: { role: "admin" })

      expect(User.find_by(email_address: "ada@example.com")).to be_member
      expect(User.admin.count).to eq(0)
    end

    it "normalizes the email address before storing it" do
      post registration_path, params: valid_params.deep_merge(
        user: { email_address: "  ADA@Example.COM  " }
      )

      expect(User.find_by(email_address: "ada@example.com")).to be_present
    end

    it "squishes the name before storing it" do
      post registration_path, params: valid_params.deep_merge(user: { full_name: "  Ada   Lovelace " })

      expect(User.last.full_name).to eq("Ada Lovelace")
    end

    it "sends validation errors back to the form" do
      expect { post registration_path, params: valid_params.deep_merge(user: { full_name: "" }) }
        .not_to change(User, :count)

      expect(response).to redirect_to(new_registration_path)
      expect(session[:inertia_errors][:full_name]).to include("can't be blank")
    end

    it "rejects an email address that is already registered" do
      create(:user, email_address: "ada@example.com")

      expect { post registration_path, params: valid_params }.not_to change(User, :count)

      expect(session[:inertia_errors][:email_address]).to eq([ "has already been taken" ])
    end

    it "rejects a malformed email address" do
      expect { post registration_path, params: valid_params.deep_merge(user: { email_address: "nope" }) }
        .not_to change(User, :count)

      expect(session[:inertia_errors][:email_address]).to be_present
    end

    it "rejects a password that does not match its confirmation" do
      expect {
        post registration_path, params: valid_params.deep_merge(user: { password_confirmation: "other" })
      }.not_to change(User, :count)

      expect(session[:inertia_errors][:password_confirmation]).to include("doesn't match Password")
    end

    it "rejects a blank password" do
      expect {
        post registration_path,
             params: valid_params.deep_merge(user: { password: "", password_confirmation: "" })
      }.not_to change(User, :count)

      expect(session[:inertia_errors][:password]).to include("can't be blank")
    end

    it "rejects a password below the minimum length" do
      expect {
        post registration_path, params: valid_params.deep_merge(
          user: { password: "short", password_confirmation: "short" }
        )
      }.not_to change(User, :count)

      expect(session[:inertia_errors][:password])
        .to include("is too short (minimum is 8 characters)")
    end

    it "accepts a password exactly at the minimum length" do
      post registration_path, params: valid_params.deep_merge(
        user: { password: "12345678", password_confirmation: "12345678" }
      )

      expect(User.find_by(email_address: "ada@example.com")).to be_present
    end

    # The test environment runs a :null_store, whose `increment` always returns
    # nil, so the throttle can never trip on its own here. Stubbing the count
    # exercises the wiring: the configured limit and the `with:` handler.
    it "turns away a flood of signups with the throttle message" do
      allow(ActionController::Base.cache_store).to receive(:increment).and_return(11)

      expect { post registration_path, params: valid_params }.not_to change(User, :count)

      expect(response).to redirect_to(new_registration_path)
      expect(flash[:alert]).to eq("Try again later.")
    end

    it "rejects a request with no user params at all" do
      expect { post registration_path, params: {} }.not_to change(User, :count)

      expect(response).to have_http_status(:bad_request)
    end

    it "sends a signed-in visitor away without creating a second account" do
      user = create(:user, email_address: "someone@example.com", password: "password")
      sign_in_as(user)

      expect { post registration_path, params: valid_params }.not_to change(User, :count)

      expect(response).to redirect_to(root_path)
    end
  end
end
