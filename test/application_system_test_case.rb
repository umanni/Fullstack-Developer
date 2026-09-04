# frozen_string_literal: true

require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  def sign_in_as(user)
    visit new_session_path
    within("main") do
      fill_in "Email", with: user.email_address
      fill_in "Password", with: "password123"
      click_button "Sign in"
    end

    if user.admin?
      assert_selector "h1", text: "Admin dashboard"
    else
      assert_selector "h1", text: user.full_name
    end
  end
end
