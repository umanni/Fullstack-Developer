require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1440, 1000 ]

  def sign_in_through_ui(user, password: "StrongPassword!123")
    visit new_session_path
    fill_in "Email address", with: user.email
    fill_in "Password", with: password
    click_button "Sign in"
  end
end
