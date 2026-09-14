require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # Escape hatch for machines where Chrome is not on PATH (WSL, slim containers).
  Selenium::WebDriver::Chrome.path = ENV["CHROME_BINARY"] if ENV["CHROME_BINARY"].present?

  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  # One browser and one server per worker, twelve of them on a developer machine: a Turbo
  # navigation regularly takes longer than Capybara's two-second default, and the
  # assertion then lands while the new body is in the DOM but not yet showing.
  Capybara.default_max_wait_time = 5

  # A blocked style fails no request, so a broken policy still passes DOM assertions.
  teardown do
    violations = page.driver.browser.logs.get(:browser)
                     .map(&:message)
                     .grep(/Content Security Policy/)

    assert_empty violations, "the page violated its own content security policy"
  end

  private
    # Shadows the generator's cookie-jar helper, which a real browser never sees.
    # `click_on` returns before the request lands, so the wait is not decoration: without
    # it the next `visit` arrives as an anonymous visitor.
    def sign_in_as(user, password: "secret-password")
      visit new_session_path
      fill_in "Email", with: user.email
      fill_in "Password", with: password
      click_on "Sign in"

      # A bare path assertion says nothing when it fails; the page usually knows why.
      return if has_no_current_path?(new_session_path)

      flunk "sign-in did not complete: #{page.text[0, 200]}"
    end
end
