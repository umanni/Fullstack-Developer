require "rails_helper"

RSpec.describe Authorization, type: :controller do
  controller(ActionController::Base) do
    include Authorization

    def index
      policy = authorize!(User)
      render plain: policy.class.name
    end

    def show
      authorize!(User.find(params[:id]))
      head :ok
    end

    def edit
      authorize!(User.find(params[:id]), "toggle_role?")
      head :ok
    end

    def update
      permitted = permitted_params(User.find(params[:id]), :user)
      render plain: permitted.keys.sort.join(",")
    end
  end

  let(:current_user) { create(:user) }

  before do
    routes.draw do
      root to: "anonymous#index"
      get   "index"      => "anonymous#index"
      get   "show/:id"   => "anonymous#show"
      get   "edit/:id"   => "anonymous#edit"
      patch "update/:id" => "anonymous#update"
    end
    allow(Current).to receive(:user).and_return(current_user)
  end

  describe "#authorize!" do
    context "when the policy permits the action" do
      let(:current_user) { create(:user, :admin) }

      it "lets the action run" do
        get :index

        expect(response).to have_http_status(:ok)
      end

      it "returns the policy so callers can reuse it" do
        get :index

        expect(response.body).to eq("UserPolicy")
      end
    end

    context "when the policy denies the action" do
      it "does not run the action body" do
        get :index

        expect(response).not_to have_http_status(:ok)
      end

      it "redirects with an explanatory alert instead of raising" do
        get :index

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("You are not authorized to do that.")
      end

      it "returns the visitor to where they came from when there is a referer" do
        request.env["HTTP_REFERER"] = "/index"

        get :index

        expect(response).to redirect_to("/index")
      end
    end

    it "derives the predicate from the current action name" do
      # `show?` is true for the owner, whereas `index?` is not.
      get :show, params: { id: current_user.id }

      expect(response).to have_http_status(:ok)
    end

    it "denies show? for someone else's record" do
      get :show, params: { id: create(:user).id }

      expect(response).to redirect_to(root_path)
    end

    it "accepts an explicit action to check instead" do
      admin = create(:user, :admin)
      allow(Current).to receive(:user).and_return(admin)

      get :edit, params: { id: create(:user).id }

      expect(response).to have_http_status(:ok)
    end

    it "denies the explicit action when the policy says no" do
      admin = create(:user, :admin)
      allow(Current).to receive(:user).and_return(admin)

      # toggle_role? is false when an admin targets themselves.
      get :edit, params: { id: admin.id }

      expect(response).to redirect_to(root_path)
    end
  end

  describe "#policy_for" do
    it "builds the policy named after the record's class" do
      policy = controller.send(:policy_for, current_user)

      expect(policy).to be_a(UserPolicy)
      expect(policy.record).to eq(current_user)
      expect(policy.user).to eq(current_user)
    end

    it "accepts a class and keeps it as the record" do
      policy = controller.send(:policy_for, User)

      expect(policy).to be_a(UserPolicy)
      expect(policy.record).to eq(User)
    end

    it "raises when no policy is defined for the record's class" do
      expect { controller.send(:policy_for, Session.new) }
        .to raise_error(NameError, /SessionPolicy/)
    end
  end

  describe "#permitted_params" do
    it "filters to the attributes the policy allows" do
      patch :update, params: {
        id: current_user.id,
        user: { full_name: "Ada", avatar_url: "https://x.test/a.png" }
      }

      expect(response.body).to eq("avatar_url,full_name")
    end

    it "drops attributes the policy withholds from a member" do
      patch :update, params: {
        id: current_user.id,
        user: { full_name: "Ada", role: "admin" }
      }

      expect(response.body).to eq("full_name")
    end

    it "keeps role for an admin acting on someone else" do
      admin = create(:user, :admin)
      allow(Current).to receive(:user).and_return(admin)

      patch :update, params: { id: current_user.id, user: { full_name: "Ada", role: "admin" } }

      expect(response.body).to eq("full_name,role")
    end

    it "drops role for an admin acting on themselves, so they cannot self-demote" do
      admin = create(:user, :admin)
      allow(Current).to receive(:user).and_return(admin)

      patch :update, params: { id: admin.id, user: { full_name: "Ada", role: "member" } }

      expect(response.body).to eq("full_name")
    end

    it "raises when the expected key is missing entirely" do
      expect {
        patch :update, params: { id: current_user.id }
      }.to raise_error(ActionController::ParameterMissing)
    end
  end

  # UserPolicy calls `user.admin?` without a nil guard, so an unauthenticated
  # visitor reaching `authorize!` raises NoMethodError rather than being denied.
  # `rescue_from NotAuthorizedError` does not catch it, so this surfaces as a 500
  # instead of the "not authorized" redirect. Pinned here so the behaviour is
  # visible; adding a nil guard to the policy will flip this example.
  describe "with no authenticated user" do
    let(:current_user) { nil }

    it "raises NoMethodError instead of denying access" do
      expect { get :index }.to raise_error(NoMethodError, /admin\?/)
    end
  end

  describe "NotAuthorizedError" do
    it "is a StandardError so it can be rescued normally" do
      expect(described_class::NotAuthorizedError.new).to be_a(StandardError)
    end

    it "is registered as a rescuable on the including controller" do
      handlers = self.class.controller_class.rescue_handlers.map(&:first)

      expect(handlers).to include("Authorization::NotAuthorizedError")
    end
  end
end
