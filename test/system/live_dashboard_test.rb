require "application_system_test_case"

class LiveDashboardTest < ApplicationSystemTestCase
  setup do
    sign_in_as users(:admin)
    visit admin_dashboard_path
  end

  test "updates the counters without the admin doing anything" do
    assert_selector "#metric-total", text: User.count
    before = User.count

    perform_enqueued_jobs do
      User.create!(
        full_name: "Katherine Johnson", email: "katherine@umanni.test", role: :admin,
        password: "secret-password", password_confirmation: "secret-password"
      )
    end

    assert_selector "#metric-total", text: before + 1
  end

  test "reflects a role change broadcast from elsewhere" do
    admins = User.admin.count

    perform_enqueued_jobs { users(:member).update!(role: :admin) }

    assert_selector "#metric-admin", text: admins + 1
  end

  test "reflects a deletion broadcast from elsewhere" do
    before = User.count

    perform_enqueued_jobs { users(:member).destroy! }

    assert_selector "#metric-total", text: before - 1
  end
end
