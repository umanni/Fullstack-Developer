require "capybara/playwright"

Capybara.register_driver(:playwright) do |app|
  Capybara::Playwright::Driver.new(app, browser_type: :chromium, headless: true)
end

# config/routes.rb redirects any GET on host 127.0.0.1 to localhost. Capybara
# serves on 127.0.0.1 by default, so a browser test would follow that redirect
# to a different host and drop the session cookie set on the first one.
Capybara.server_host = "localhost"

Capybara.default_driver = :rack_test
Capybara.javascript_driver = :playwright
Capybara.server = :puma, { Silent: true }

RSpec.configure do |config|
  config.before(:each, type: :system) { driven_by :rack_test }
  config.before(:each, :js, type: :system) { driven_by :playwright }
end
