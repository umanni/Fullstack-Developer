require "capybara-playwright-driver"

Capybara.register_driver(:playwright) do |app|
  Capybara::Playwright::Driver.new(app, browser_type: :chromium, headless: true)
end

Capybara.default_max_wait_time = 5
Capybara.save_path = Rails.root.join("tmp/capybara")

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :playwright
  end
end
