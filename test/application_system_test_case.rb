require "test_helper"

Capybara.register_driver :selenium_chromium_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.binary = ENV["CHROME_BIN"] if ENV["CHROME_BIN"].present?
  options.add_argument("--headless=new")
  options.add_argument("--no-sandbox")
  options.add_argument("--disable-dev-shm-usage")
  options.add_argument("--window-size=1400,1000")

  Capybara::Selenium::Driver.new(app, browser: :chrome, options:)
end

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium_chromium_headless
end
