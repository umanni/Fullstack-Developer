require "rails_helper"

RSpec.describe "Admin::Dashboards", type: :request do
  def props = inertia.props.deep_symbolize_keys

  let!(:admin)  { create(:user, :admin, email_address: "boss@example.com", password: "password") }
  let!(:member) do
    create(:user, full_name: "Regular Member", email_address: "member@example.com", password: "password")
  end

  it "requires authentication" do
    get admin_dashboard_path

    expect(response).to redirect_to(new_session_url)
  end

  it "lets an admin in" do
    sign_in_as(admin)

    get admin_dashboard_path

    expect(response).to have_http_status(:ok)
  end

  it "renders the dashboard component for an admin" do
    sign_in_as(admin)

    get admin_dashboard_path

    expect(inertia).to render_component("Admin/Dashboard")
  end

  it "hands the component the current stats" do
    sign_in_as(admin)

    get admin_dashboard_path

    expect(props[:stats]).to include(total: 2, by_role: { member: 1, admin: 1 })
  end

  it "turns a member away with the authorization alert" do
    sign_in_as(member)

    get admin_dashboard_path

    expect(response).to redirect_to(root_path)
    expect(flash[:alert]).to eq("You are not authorized to do that.")
  end

  it "sends a member back where they came from" do
    sign_in_as(member)

    get admin_dashboard_path, headers: { "HTTP_REFERER" => profile_path }

    expect(response).to redirect_to(profile_path)
  end

  it "is where an admin lands straight after signing in" do
    sign_in_as(admin)

    expect(response).to redirect_to(admin_dashboard_path)
  end
end
