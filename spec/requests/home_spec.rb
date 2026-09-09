require "rails_helper"

RSpec.describe "The root path" do
  it "sends a visitor to the sign in page" do
    get root_path

    expect(response).to redirect_to(new_session_path)
  end

  it "sends a regular user to their profile" do
    sign_in create(:user)

    get root_path

    expect(response).to redirect_to(profile_path)
  end

  it "sends an administrator to the dashboard" do
    sign_in create(:user, :admin)

    get root_path

    expect(response).to redirect_to(admin_dashboard_path)
  end
end
